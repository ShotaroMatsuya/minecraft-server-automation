/**
 * Terragrunt plan comment generator for GitHub Actions
 * Processes Terragrunt plan results and creates formatted PR comments
 */

const fs = require('fs');

/**
 * Creates a Terragrunt plan results comment
 * @param {Object} inputs - Input parameters from GitHub Actions
 * @param {string} inputs.environment - Environment name (keeping/scheduling)
 * @param {string} inputs.status - Plan execution status
 * @param {string} inputs.planFilePath - Path to plan output file
 * @param {string} inputs.initErrorLog - Error log from init step
 * @param {string} inputs.planErrorLog - Error log from plan step
 * @param {string} inputs.formatErrorLog - Error log from format check
 * @param {string} inputs.validateErrorLog - Error log from validate step
 * @returns {string} Formatted comment body
 */
function createTerragruntPlanComment(inputs) {
  const { environment, status, planFilePath, initErrorLog, planErrorLog, formatErrorLog, validateErrorLog } = inputs;
  
  // Environment-specific titles
  const titles = {
    keeping: '## 📋 Plan Result (keeping)',
    scheduling: '## 📋 Plan Result (scheduling)'
  };
  
  let commentBody = `${titles[environment] || `## 📋 Plan Result (${environment})`}\n\n`;
  
  // Helper function to check if log contains actual errors (not just info/success messages)
  function hasActualErrors(logContent) {
    if (!logContent || logContent.trim() === '') return false;
    
    // Common success patterns that should not be treated as errors
    const successPatterns = [
      /Success! The configuration is valid/,
      /Terraform has been successfully initialized/,
      /You may now begin working with Terraform/,
      /Initializing the backend/,
      /Initializing modules/,
      /Initializing provider plugins/,
      /Using previously-installed/,
      /Downloading/,
      /Installed/
    ];
    
    // Check if content is mainly success/info messages
    const lines = logContent.split('\n').filter(line => line.trim());
    const errorLines = lines.filter(line => {
      return !successPatterns.some(pattern => pattern.test(line));
    });
    
    // If most lines are success/info, and content is short, likely not an error
    if (errorLines.length < lines.length * 0.3 && logContent.length < 1000) {
      return false;
    }
    
    // Look for actual error indicators
    const errorIndicators = [
      /error/i,
      /failed/i,
      /cannot/i,
      /unable to/i,
      /invalid/i,
      /not found/i,
      /denied/i,
      /timeout/i,
      /exception/i,
      /runtime error/i
    ];
    
    return errorIndicators.some(pattern => pattern.test(logContent));
  }

  // Check if any step failed and show detailed error information
  const hasFormatError = hasActualErrors(formatErrorLog);
  const hasValidateError = hasActualErrors(validateErrorLog);
  const hasInitError = status === 'init_failed' || hasActualErrors(initErrorLog);
  
  // Enhanced plan analysis - prioritize valid plan results over status codes
  // Based on terraform plan -detailed-exitcode: 0=no changes, 1=error, 2=changes
  let planContentForCheck = '';
  try {
    planContentForCheck = fs.readFileSync(planFilePath, 'utf8');
    console.log(`DEBUG: Successfully read planFilePath: ${planFilePath}, size: ${planContentForCheck.length} bytes`);
  } catch (error) {
    console.log(`DEBUG: Failed to read planFilePath: ${planFilePath}, error: ${error.message}`);
    planContentForCheck = planErrorLog || '';
    console.log(`DEBUG: Using planErrorLog fallback, size: ${planContentForCheck.length} bytes`);
  }
  
  // Check if we have a valid plan result (most important indicator)
  const hasValidPlan = planContentForCheck && (
    planContentForCheck.includes('Plan:') ||
    (planContentForCheck.includes('to add') && planContentForCheck.includes('to change') && planContentForCheck.includes('to destroy'))
  );
  
  // Extract plan summary if available
  const addMatches = planContentForCheck.match(/(\d+)\s+to\s+add/);
  const changeMatches = planContentForCheck.match(/(\d+)\s+to\s+change/);
  const destroyMatches = planContentForCheck.match(/(\d+)\s+to\s+destroy/);
  
  const planToAdd = addMatches ? parseInt(addMatches[1]) : 0;
  const planToChange = changeMatches ? parseInt(changeMatches[1]) : 0;
  const planToDestroy = destroyMatches ? parseInt(destroyMatches[1]) : 0;
  
  const hasChanges = planToAdd > 0 || planToChange > 0 || planToDestroy > 0;
  
  // Check for definitive blocking errors (only if no valid plan exists)
  const hasDefinitivePlanErrors = !hasValidPlan && planContentForCheck && (
    planContentForCheck.includes('Error: External Program Execution Failed') ||
    planContentForCheck.includes('terraform invocation failed') ||
    /╷[\s\S]*Error:[\s\S]*╵/.test(planContentForCheck)
  );
  
  // Check for warnings (non-blocking issues shown with successful plans)
  const hasWarnings = planContentForCheck && (
    planContentForCheck.includes('RuntimeError: Python interpreter') ||
    planContentForCheck.includes('Warning:')
  );
  
  // Only treat as plan error if we have definitive errors AND no valid plan
  const hasPlanError = (status === 'failed' && !hasValidPlan) || hasDefinitivePlanErrors || (hasActualErrors(planErrorLog) && !hasValidPlan);
  
  // Determine plan status for display
  let planStatusDisplay = '⚠️ Unknown';
  if (hasPlanError) {
    planStatusDisplay = '❌ Failed';
  } else if (status === 'has_changes' || hasChanges) {
    planStatusDisplay = '🔄 Changes Detected';
  } else if (hasValidPlan || status === 'no_changes') {
    planStatusDisplay = '✅ No Changes';
  }
  
  // Show step-by-step status
  commentBody += `### 🔄 Execution Steps\n\n`;
  commentBody += `| Step | Status |\n`;
  commentBody += `|------|--------|\n`;
  commentBody += `| 🎨 **Format Check** | ${hasFormatError ? '❌ Failed' : '✅ Passed'} |\n`;
  commentBody += `| ✅ **Validation** | ${hasValidateError ? '❌ Failed' : '✅ Passed'} |\n`;
  commentBody += `| 🚀 **Init** | ${hasInitError ? '❌ Failed' : '✅ Passed'} |\n`;
  commentBody += `| 📋 **Plan** | ${planStatusDisplay} |\n\n`;
  
  // If any errors occurred, show them first
  if (hasFormatError || hasValidateError || hasInitError || hasPlanError) {
    commentBody += `### 🚨 Error Details\n\n`;
    
    if (hasFormatError) {
      commentBody += `#### 🎨 Format Check Errors\n`;
      commentBody += `Code formatting issues were detected.\n\n`;
      commentBody += `<details><summary>📋 View Format Error Log (Click to expand)</summary>\n\n`;
      commentBody += `\`\`\`\n${formatErrorLog.slice(0, 2000)}\`\`\`\n\n`;
      commentBody += `</details>\n\n`;
    }
    
    if (hasValidateError) {
      commentBody += `#### ✅ Validation Errors\n`;
      commentBody += `Configuration validation failed.\n\n`;
      commentBody += `<details><summary>📋 View Validation Error Log (Click to expand)</summary>\n\n`;
      commentBody += `\`\`\`\n${validateErrorLog.slice(0, 2000)}\`\`\`\n\n`;
      commentBody += `</details>\n\n`;
    }
    
    if (hasInitError) {
      commentBody += `#### 🚀 Initialization Errors\n`;
      commentBody += `Terragrunt initialization failed. Unable to initialize the working directory.\n\n`;
      commentBody += `<details><summary>📋 View Init Error Log (Click to expand)</summary>\n\n`;
      commentBody += `\`\`\`\n${initErrorLog.slice(0, 3000)}\`\`\`\n\n`;
      commentBody += `</details>\n\n`;
    }
    
    if (hasPlanError) {
      commentBody += `#### 📋 Plan Execution Errors\n`;
      commentBody += `Terragrunt plan execution encountered errors during infrastructure planning.\n\n`;
      
      // Check if plan content has both plan results and errors
      if (planContentForCheck && (planContentForCheck.includes('Plan:') || planContentForCheck.includes('will be created'))) {
        // Extract plan summary even when there are errors
        const addMatches = planContentForCheck.match(/(\d+)\s+to\s+add/);
        const changeMatches = planContentForCheck.match(/(\d+)\s+to\s+change/);
        const destroyMatches = planContentForCheck.match(/(\d+)\s+to\s+destroy/);
        
        const toAdd = addMatches ? parseInt(addMatches[1]) : 0;
        const toChange = changeMatches ? parseInt(changeMatches[1]) : 0;
        const toDestroy = destroyMatches ? parseInt(destroyMatches[1]) : 0;
        
        if (toAdd > 0 || toChange > 0 || toDestroy > 0) {
          commentBody += `**Planned Changes (before error occurred):**\n`;
          commentBody += `\`\`\`\n`;
          commentBody += `Plan: ${toAdd} to add, ${toChange} to change, ${toDestroy} to destroy.\n`;
          commentBody += `\`\`\`\n\n`;
        }
      }
      
      commentBody += `<details><summary>📋 View Plan Error Log (Click to expand)</summary>\n\n`;
      commentBody += `\`\`\`\n${(planContentForCheck || planErrorLog).slice(0, 5000)}${(planContentForCheck || planErrorLog).length > 5000 ? '\n... (truncated)' : ''}\`\`\`\n\n`;
      commentBody += `</details>\n\n`;
    }
    
    // Add comprehensive troubleshooting information
    commentBody += `### 🔧 Troubleshooting\n`;
    
    if (hasFormatError) {
      commentBody += `**Format Check Issues:**\n`;
      commentBody += `- Run \`terragrunt fmt\` to automatically fix formatting\n`;
      commentBody += `- Check indentation and syntax consistency\n`;
      commentBody += `- Ensure proper HCL formatting\n\n`;
    }
    
    if (hasValidateError) {
      commentBody += `**Validation Issues:**\n`;
      commentBody += `- Check Terraform configuration syntax\n`;
      commentBody += `- Verify variable declarations and references\n`;
      commentBody += `- Ensure required providers are properly configured\n`;
      commentBody += `- Validate \`terragrunt.hcl\` configuration\n\n`;
    }
    
    if (hasInitError) {
      commentBody += `**Initialization Issues:**\n`;
      commentBody += `- Check AWS credentials and permissions\n`;
      commentBody += `- Verify S3 bucket and DynamoDB table for Terraform state\n`;
      commentBody += `- Ensure required providers are accessible\n`;
      commentBody += `- Check network connectivity to provider APIs\n\n`;
    }
    
    if (hasPlanError) {
      commentBody += `**Plan Execution Issues:**\n`;
      commentBody += `- Check Terraform configuration syntax\n`;
      commentBody += `- Verify resource dependencies and references\n`;
      commentBody += `- Check AWS provider credentials and permissions\n`;
      commentBody += `- Ensure all required variables are defined\n`;
      commentBody += `- **Python 3.9 Runtime Issue**: Install Python 3.9 if Lambda packaging fails\n`;
      commentBody += `- Check external data source dependencies\n\n`;
    }
    
    commentBody += `**General Troubleshooting:**\n`;
    commentBody += `- Review workflow logs for detailed error information\n`;
    commentBody += `- Check if resources already exist with different configurations\n`;
    commentBody += `- Verify AWS service limits and quotas\n`;
    commentBody += `- Ensure proper IAM permissions for all required actions\n\n`;
    
    const failureTime = new Date().toISOString();
    if (hasInitError) {
      commentBody += `*❌ Init failed at ${failureTime} | Environment: ${environment}*`;
    } else if (hasValidateError) {
      commentBody += `*❌ Validation failed at ${failureTime} | Environment: ${environment}*`;
    } else if (hasFormatError) {
      commentBody += `*❌ Format check failed at ${failureTime} | Environment: ${environment}*`;
    } else if (hasPlanError) {
      commentBody += `*❌ Plan failed at ${failureTime} | Environment: ${environment}*`;
    }
    
    return commentBody;
  }
  
  // If no errors, proceed with normal plan output (warnings are shown as part of plan)
  try {
    // Try to read the actual plan output
    let planOutput = '';
    try {
      planOutput = fs.readFileSync(planFilePath, 'utf8');
      console.log(`DEBUG: Successfully read planOutput from ${planFilePath}, size: ${planOutput.length} bytes`);
      if (planOutput.length > 0) {
        console.log(`DEBUG: Plan output preview: ${planOutput.substring(0, 200)}...`);
      }
    } catch (planReadError) {
      console.log(`DEBUG: Failed to read planOutput from ${planFilePath}, error: ${planReadError.message}`);
      // If plan_output.txt doesn't exist or is empty, try plan_errors.txt
      // Sometimes Terragrunt outputs plan to stderr
      if (planErrorLog && planErrorLog.trim() !== '') {
        planOutput = planErrorLog;
        console.log(`DEBUG: Using planErrorLog fallback, size: ${planOutput.length} bytes`);
      }
    }
    
    // If plan_output.txt is empty but plan_errors.txt has content that looks like a plan
    if (planOutput.trim() === '' && planErrorLog && planErrorLog.trim() !== '') {
      // Check if planErrorLog contains plan output (not actual errors)
      if (planErrorLog.includes('Plan:') || planErrorLog.includes('will be created') || 
          planErrorLog.includes('will be updated') || planErrorLog.includes('will be destroyed') ||
          planErrorLog.includes('No changes') || planErrorLog.includes('Terraform used the selected providers')) {
        planOutput = planErrorLog;
      }
    }
    
    // If plan output is empty but we have actual error logs, treat as error
    if (planOutput.trim() === '' && hasActualErrors(planErrorLog)) {
      commentBody += `### 🚨 Plan Execution Error\n\n`;
      commentBody += `Plan execution failed with no output generated.\n\n`;
      commentBody += `<details><summary>📋 View Plan Error Log (Click to expand)</summary>\n\n`;
      commentBody += `\`\`\`\n${planErrorLog.slice(0, 5000)}${planErrorLog.length > 5000 ? '\n... (truncated)' : ''}\`\`\`\n\n`;
      commentBody += `</details>\n\n`;
      
      commentBody += `### 🔧 Troubleshooting\n`;
      commentBody += `- Check AWS credentials and permissions\n`;
      commentBody += `- Verify Terraform configuration syntax\n`;
      commentBody += `- Check for resource conflicts or dependencies\n`;
      commentBody += `- Review the error log above for specific issues\n\n`;
      
      commentBody += `*❌ Plan failed at ${new Date().toISOString()} | Environment: ${environment}*`;
      return commentBody;
    }
    
    // Parse plan summary
    const addMatches = planOutput.match(/(\d+)\s+to\s+add/);
    const changeMatches = planOutput.match(/(\d+)\s+to\s+change/);
    const destroyMatches = planOutput.match(/(\d+)\s+to\s+destroy/);
    
    const toAdd = addMatches ? parseInt(addMatches[1]) : 0;
    const toChange = changeMatches ? parseInt(changeMatches[1]) : 0;
    const toDestroy = destroyMatches ? parseInt(destroyMatches[1]) : 0;
    
    console.log(`DEBUG: Plan parsing results - toAdd: ${toAdd}, toChange: ${toChange}, toDestroy: ${toDestroy}`);
    console.log(`DEBUG: addMatches:`, addMatches);
    console.log(`DEBUG: changeMatches:`, changeMatches);
    console.log(`DEBUG: destroyMatches:`, destroyMatches);
    
    // Show summary message based on status and plan content
    if (status === 'has_changes' || toAdd > 0 || toChange > 0) {
      if (hasWarnings && (toAdd > 0 || toChange > 0 || toDestroy > 0)) {
        commentBody += `⚠️ **Infrastructure changes with warnings**\n\n`;
        commentBody += `The plan was generated successfully but contains warnings that should be reviewed.\n\n`;
      } else if (toDestroy > 0) {
        commentBody += `⚠️ **Resource Deletion will happen**\n\n`;
        commentBody += `This plan contains resource delete operation. Please check the plan result very carefully!\n\n`;
      } else {
        commentBody += `🔄 **Infrastructure changes detected**\n\n`;
      }
    } else {
      commentBody += `✅ **No changes detected**\n\n`;
      commentBody += `Infrastructure is up to date with the configuration.\n\n`;
    }
    
    commentBody += `\`\`\`\n`;
    commentBody += `Plan: ${toAdd} to add, ${toChange} to change, ${toDestroy} to destroy.\n`;
    commentBody += `\`\`\`\n\n`;
    
    // Show warnings if present
    if (hasWarnings) {
      commentBody += `### ⚠️ Warnings\n\n`;
      if (planOutput.includes('RuntimeError: Python interpreter')) {
        commentBody += `- **Python 3.9 Runtime**: Lambda packaging encountered Python version issues\n`;
        commentBody += `- This warning does not prevent infrastructure deployment\n`;
        commentBody += `- Consider ensuring Python 3.9 is available for optimal Lambda packaging\n\n`;
      }
    }
    
    // Only show resource summary if there are changes or for scheduling environment
    if (toDestroy > 0 || toAdd > 0 || toChange > 0 || environment === 'scheduling') {
      commentBody += `### 📊 Resource Summary\n\n`;
      commentBody += `| Type | Count |\n`;
      commentBody += `|------|-------|\n`;
      commentBody += `| ➕ **To Add** | ${toAdd} |\n`;
      commentBody += `| 🔄 **To Change** | ${toChange} |\n`;
      commentBody += `| ❌ **To Destroy** | ${toDestroy} |\n\n`;
    }
    
    // Determine summary title based on environment and changes
    const summaryTitle = environment === 'keeping' ? '🔄 Change Result (Click me)' : '📋 Show Full Plan Output';
    
    commentBody += `<details><summary>${summaryTitle}</summary>\n\n`;
    commentBody += `\`\`\`terraform\n`;
    // Truncate very long outputs
    if (planOutput.length > 8000) {
      commentBody += planOutput.slice(0, 4000);
      commentBody += `\n\n... (content truncated due to length) ...\n\n`;
      commentBody += planOutput.slice(-3000);
    } else {
      commentBody += planOutput;
    }
    commentBody += `\`\`\`\n\n`;
    commentBody += `</details>\n\n`;
    
  } catch (error) {
    // Fallback to static content if file not found
    if (status === 'no_changes') {
      commentBody += `✅ **No changes detected**\n\n`;
      commentBody += `Infrastructure is up to date with the configuration.\n\n`;
      commentBody += `\`\`\`\n`;
      commentBody += `Plan: 0 to add, 0 to change, 0 to destroy.\n`;
      commentBody += `\`\`\`\n\n`;
      
      if (environment === 'scheduling') {
        commentBody += `### 📊 Resource Summary\n\n`;
        commentBody += `| Type | Count |\n`;
        commentBody += `|------|-------|\n`;
        commentBody += `| ➕ **To Add** | 0 |\n`;
        commentBody += `| 🔄 **To Change** | 0 |\n`;
        commentBody += `| ❌ **To Destroy** | 0 |\n\n`;
        
        commentBody += `<details><summary>📋 Show Full Plan Output</summary>\n\n`;
        commentBody += `\`\`\`terraform\n`;
        commentBody += `No changes. Your infrastructure matches the configuration.\n\n`;
        commentBody += `Terraform has compared your real infrastructure against your configuration\n`;
        commentBody += `and found no differences, so no changes are needed.\n`;
        commentBody += `\`\`\`\n\n`;
        commentBody += `</details>\n\n`;
      }
    } else {
      commentBody += `⚠️ **Plan execution status**: ${status}\n\n`;
      commentBody += `Unable to retrieve detailed plan output. File may not exist or be accessible.\n\n`;
      
      // If plan failed but we have error logs, this should have been caught above
      if (planErrorLog && planErrorLog.trim() !== '') {
        commentBody += `### 🚨 Plan Error Details\n\n`;
        commentBody += `<details><summary>📋 View Plan Error Log (Click to expand)</summary>\n\n`;
        commentBody += `\`\`\`\n${planErrorLog.slice(0, 3000)}\`\`\`\n\n`;
        commentBody += `</details>\n\n`;
      }
    }
  }
  
  commentBody += `*📋 Plan executed at ${new Date().toISOString()} | Environment: ${environment}*`;
  
  return commentBody;
}

/**
 * Updates or creates a Terragrunt plan comment on GitHub PR
 * @param {Object} github - GitHub API client
 * @param {Object} context - GitHub Actions context
 * @param {string} commentBody - The comment content
 * @param {string} environment - Environment name for identifier
 */
async function updateTerragruntPlanComment(github, context, commentBody, environment) {
  // Find and update existing plan comment
  const { data: comments } = await github.rest.issues.listComments({
    owner: context.repo.owner,
    repo: context.repo.repo,
    issue_number: context.issue.number,
  });

  // Environment-specific identifiers - must match the actual titles used in createTerragruntPlanComment
  const identifiers = {
    keeping: '## 📋 Plan Result (keeping)',
    scheduling: '## 📋 Plan Result (scheduling)'
  };
  
  const planIdentifier = identifiers[environment] || `## 📋 Plan Result (${environment})`;
  const existingPlanComment = comments.find(comment => 
    comment.user.type === 'Bot' && 
    comment.body.includes(planIdentifier)
  );

  if (existingPlanComment) {
    await github.rest.issues.updateComment({
      owner: context.repo.owner,
      repo: context.repo.repo,
      comment_id: existingPlanComment.id,
      body: commentBody
    });
  } else {
    await github.rest.issues.createComment({
      owner: context.repo.owner,
      repo: context.repo.repo,
      issue_number: context.issue.number,
      body: commentBody
    });
  }
}

module.exports = {
  createTerragruntPlanComment,
  updateTerragruntPlanComment
};
