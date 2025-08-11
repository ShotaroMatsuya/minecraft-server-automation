/**
 * Terragrunt Apply Comment Generator
 * Generates and manages GitHub PR comments for Terragrunt apply results
 */

const fs = require('fs');
const path = require('path');

/**
 * Strip ANSI escape sequences from text
 * @param {string} text - Text containing ANSI codes
 * @returns {string} Clean text without ANSI codes
 */
function stripAnsiCodes(text) {
  if (!text) return '';
  // Remove ANSI escape sequences
  return text.replace(/\x1b\[[0-9;]*m/g, '');
}

/**
 * Format Terragrunt output for better readability
 * @param {string} output - Raw Terragrunt output
 * @returns {string} Formatted output
 */
function formatTerragruntOutput(output) {
  if (!output) return '';
  
  // Strip ANSI codes first
  let cleaned = stripAnsiCodes(output);
  
  // Remove timestamp patterns like [terragrunt] 2024/01/01 12:00:00
  cleaned = cleaned.replace(/\[terragrunt\] \d{4}\/\d{2}\/\d{2} \d{2}:\d{2}:\d{2}/g, '[terragrunt]');
  
  // Clean up excessive newlines
  cleaned = cleaned.replace(/\n{3,}/g, '\n\n');
  
  // Remove leading/trailing whitespace
  cleaned = cleaned.trim();
  
  return cleaned;
}

/**
 * Read file content with multiple path attempts for apply results
 * @param {string} primaryPath - Primary file path to try
 * @param {string} environment - Environment name (keeping/scheduling)
 * @param {string} fileName - Base filename to search for
 * @param {string} artifactBasePath - Base path for artifacts
 * @returns {string} File content or empty string if not found
 */
function readApplyFileWithFallback(primaryPath, environment, fileName, artifactBasePath) {
  const pathsToTry = [
    primaryPath,
    `${artifactBasePath}/terragrunt-apply-${environment}/${fileName}`,
    `apply-results/terragrunt-apply-${environment}/${fileName}`,
    `terragrunt-apply-${environment}/${fileName}`,
    `${fileName}`
  ];
  
  for (const filePath of pathsToTry) {
    try {
      if (fs.existsSync(filePath)) {
        const content = fs.readFileSync(filePath, 'utf8');
        return content;
      }
    } catch (error) {
    }
  }
  
  return '';
}

/**
 * Parse apply results to extract resource counts
 * @param {string} applyOutput - Apply output content
 * @returns {Object} Resource counts and summary
 */
function parseApplyResults(applyOutput) {
  if (!applyOutput) {
    return {
      resourcesApplied: 0,
      resourcesChanged: 0,
      resourcesDestroyed: 0,
      summary: 'No apply output available'
    };
  }
  
  const content = stripAnsiCodes(applyOutput);
  
  // Parse apply summary from output
  let resourcesApplied = 0;
  let resourcesChanged = 0;
  let resourcesDestroyed = 0;
  
  // Look for "Apply complete!" summary line
  const applyCompleteMatch = content.match(/Apply complete! Resources: (\d+) added, (\d+) changed, (\d+) destroyed/);
  if (applyCompleteMatch) {
    resourcesApplied = parseInt(applyCompleteMatch[1]) || 0;
    resourcesChanged = parseInt(applyCompleteMatch[2]) || 0;
    resourcesDestroyed = parseInt(applyCompleteMatch[3]) || 0;
  } else {
    // Fallback: count individual operation messages
    resourcesApplied = (content.match(/Creation complete after/g) || []).length;
    resourcesChanged = (content.match(/Modifications complete after/g) || []).length;
    resourcesDestroyed = (content.match(/Destruction complete after/g) || []).length;
  }
  
  const totalChanges = resourcesApplied + resourcesChanged + resourcesDestroyed;
  
  let summary;
  if (totalChanges === 0) {
    if (content.includes('No changes') || content.includes('infrastructure is up-to-date')) {
      summary = 'No changes needed - infrastructure is up-to-date';
    } else {
      summary = 'Apply completed with no resource changes';
    }
  } else {
    const parts = [];
    if (resourcesApplied > 0) parts.push(`${resourcesApplied} added`);
    if (resourcesChanged > 0) parts.push(`${resourcesChanged} changed`);
    if (resourcesDestroyed > 0) parts.push(`${resourcesDestroyed} destroyed`);
    summary = `Apply completed: ${parts.join(', ')}`;
  }
  
  return {
    resourcesApplied,
    resourcesChanged,
    resourcesDestroyed,
    summary
  };
}

/**
 * Generate status emoji and text based on apply status
 * @param {string} status - Apply status
 * @returns {Object} Status emoji and text
 */
function getApplyStatusInfo(status) {
  switch (status) {
    case 'success':
      return { emoji: '✅', text: 'Success' };
    case 'failed':
      return { emoji: '❌', text: 'Failed' };
    case 'init_failed':
      return { emoji: '🔧', text: 'Init Failed' };
    case 'completed_with_warnings':
      return { emoji: '⚠️', text: 'Completed with Warnings' };
    default:
      return { emoji: '❓', text: 'Unknown' };
  }
}

/**
 * Create Terragrunt apply comment body
 * @param {Object} inputs - Apply inputs
 * @returns {string} Comment body markdown
 */
function createTerragruntApplyComment(inputs) {
  const { 
    environment, 
    status, 
    applyFilePath, 
    initErrorLogPath, 
    applyErrorLogPath, 
    artifactBasePath,
    resourcesApplied,
    resourcesChanged, 
    resourcesDestroyed
  } = inputs;
  
  
  // Use provided resource counts if available (from apply workflow), otherwise parse from output
  let applyResults;
  if (resourcesApplied !== undefined || resourcesChanged !== undefined || resourcesDestroyed !== undefined) {
    
    const totalChanges = (parseInt(resourcesApplied) || 0) + (parseInt(resourcesChanged) || 0) + (parseInt(resourcesDestroyed) || 0);
    let summary;
    if (totalChanges === 0) {
      summary = 'No changes needed - infrastructure is up-to-date';
    } else {
      const parts = [];
      if (resourcesApplied > 0) parts.push(`${resourcesApplied} added`);
      if (resourcesChanged > 0) parts.push(`${resourcesChanged} changed`);
      if (resourcesDestroyed > 0) parts.push(`${resourcesDestroyed} destroyed`);
      summary = `Apply completed: ${parts.join(', ')}`;
    }
    
    applyResults = {
      resourcesApplied: parseInt(resourcesApplied) || 0,
      resourcesChanged: parseInt(resourcesChanged) || 0,
      resourcesDestroyed: parseInt(resourcesDestroyed) || 0,
      summary
    };
  } else {
    // Read apply output to parse results
    const applyOutput = readApplyFileWithFallback(
      applyFilePath,
      environment,
      'apply_output.txt',
      artifactBasePath || 'apply-results'
    );
    
    applyResults = parseApplyResults(applyOutput);
  }
  
  // Read error logs if available (still needed for error display)
  const initErrors = readApplyFileWithFallback(
    initErrorLogPath,
    environment,
    'init_output.txt',
    artifactBasePath || 'apply-results'
  );
  
  const applyErrors = readApplyFileWithFallback(
    applyErrorLogPath,
    environment,
    'apply_errors.txt',
    artifactBasePath || 'apply-results'
  );
  
  const statusInfo = getApplyStatusInfo(status);
  
  // Build comment body
  let commentBody = `## ${statusInfo.emoji} Terragrunt Apply Results - ${environment.charAt(0).toUpperCase() + environment.slice(1)}\n\n`;
  
  commentBody += `**Status:** ${statusInfo.text}\n`;
  commentBody += `**Summary:** ${applyResults.summary}\n\n`;
  
  // Add resource changes summary if there were changes
  if (applyResults.resourcesApplied > 0 || applyResults.resourcesChanged > 0 || applyResults.resourcesDestroyed > 0) {
    commentBody += `### 📊 Resource Changes\n\n`;
    commentBody += `| Action | Count |\n`;
    commentBody += `|--------|-------|\n`;
    if (applyResults.resourcesApplied > 0) {
      commentBody += `| ➕ Added | ${applyResults.resourcesApplied} |\n`;
    }
    if (applyResults.resourcesChanged > 0) {
      commentBody += `| 🔄 Changed | ${applyResults.resourcesChanged} |\n`;
    }
    if (applyResults.resourcesDestroyed > 0) {
      commentBody += `| ➖ Destroyed | ${applyResults.resourcesDestroyed} |\n`;
    }
    commentBody += `\n`;
  }
  
  // Try to read apply output for display (optional if we have resource counts)
  const applyOutput = readApplyFileWithFallback(
    applyFilePath,
    environment,
    'apply_output.txt',
    artifactBasePath || 'apply-results'
  );
  
  // Add apply output if available
  if (applyOutput) {
    const formattedOutput = formatTerragruntOutput(applyOutput);
    const truncatedOutput = formattedOutput.length > 4000 
      ? formattedOutput.substring(0, 4000) + '\n\n... (output truncated)'
      : formattedOutput;
    
    commentBody += `### 📋 Apply Output\n\n`;
    commentBody += `<details>\n<summary>Click to view apply output</summary>\n\n`;
    commentBody += `\`\`\`\n${truncatedOutput}\n\`\`\`\n\n`;
    commentBody += `</details>\n\n`;
  }
  
  // Add error logs if there were failures
  if (status === 'failed' || status === 'init_failed') {
    if (status === 'init_failed' && initErrors) {
      const formattedErrors = formatTerragruntOutput(initErrors);
      commentBody += `### 🔧 Initialization Errors\n\n`;
      commentBody += `<details>\n<summary>Click to view init errors</summary>\n\n`;
      commentBody += `\`\`\`\n${formattedErrors}\n\`\`\`\n\n`;
      commentBody += `</details>\n\n`;
    }
    
    if (applyErrors) {
      const formattedErrors = formatTerragruntOutput(applyErrors);
      commentBody += `### ❌ Apply Errors\n\n`;
      commentBody += `<details>\n<summary>Click to view apply errors</summary>\n\n`;
      commentBody += `\`\`\`\n${formattedErrors}\n\`\`\`\n\n`;
      commentBody += `</details>\n\n`;
    }
  }
  
  // Add footer with timestamp
  const timestamp = new Date().toISOString();
  commentBody += `---\n*Apply completed at ${timestamp}*\n`;
  
  return commentBody;
}

/**
 * Update or create Terragrunt apply comment
 * @param {Object} github - GitHub API client
 * @param {Object} context - GitHub Actions context
 * @param {string} commentBody - Comment body content
 * @param {string} environment - Environment name
 * @param {number} issueNumber - Issue/PR number (optional, defaults to context.issue.number)
 */
async function updateTerragruntApplyComment(github, context, commentBody, environment, issueNumber = null) {
  const commentIdentifier = `<!-- terragrunt-apply-${environment} -->`;
  const fullCommentBody = `${commentIdentifier}\n${commentBody}`;
  
  // Use provided issueNumber or fall back to context.issue.number
  const targetIssueNumber = issueNumber || context.issue.number;
  
  
  try {
    // Validate required context properties
    if (!context.repo || !context.repo.owner || !context.repo.repo) {
      throw new Error('Invalid context: missing repo information');
    }
    
    if (!targetIssueNumber) {
      throw new Error('No issue number provided');
    }
    
    // Get existing comments
    const { data: comments } = await github.rest.issues.listComments({
      owner: context.repo.owner,
      repo: context.repo.repo,
      issue_number: targetIssueNumber,
    });
    
    // Find existing apply comment for this environment
    const existingComment = comments.find(comment => 
      comment.body && comment.body.includes(commentIdentifier)
    );
    
    if (existingComment) {
      // Update existing comment
      await github.rest.issues.updateComment({
        owner: context.repo.owner,
        repo: context.repo.repo,
        comment_id: existingComment.id,
        body: fullCommentBody,
      });
    } else {
      // Create new comment
      await github.rest.issues.createComment({
        owner: context.repo.owner,
        repo: context.repo.repo,
        issue_number: targetIssueNumber,
        body: fullCommentBody,
      });
    }
  } catch (error) {
    console.error(`Error updating apply comment for ${environment}:`, error);
    throw error;
  }
}

module.exports = {
  createTerragruntApplyComment,
  updateTerragruntApplyComment,
  parseApplyResults,
  formatTerragruntOutput,
  stripAnsiCodes
};
