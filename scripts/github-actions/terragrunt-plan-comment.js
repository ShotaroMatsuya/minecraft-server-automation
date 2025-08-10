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
 * @returns {string} Formatted comment body
 */
function createTerragruntPlanComment(inputs) {
  const { environment, status, planFilePath } = inputs;
  
  // Environment-specific titles
  const titles = {
    keeping: '## 📋 Plan Result (keeping/security-test)',
    scheduling: '## 📋 Plan Result (scheduling/infrastructure)'
  };
  
  let commentBody = `${titles[environment] || `## 📋 Plan Result (${environment})`}\n\n`;
  
  try {
    // Try to read the actual plan output
    const planOutput = fs.readFileSync(planFilePath, 'utf8');
    
    // Parse plan summary
    const addMatches = planOutput.match(/(\d+)\s+to\s+add/);
    const changeMatches = planOutput.match(/(\d+)\s+to\s+change/);
    const destroyMatches = planOutput.match(/(\d+)\s+to\s+destroy/);
    
    const toAdd = addMatches ? parseInt(addMatches[1]) : 0;
    const toChange = changeMatches ? parseInt(changeMatches[1]) : 0;
    const toDestroy = destroyMatches ? parseInt(destroyMatches[1]) : 0;
    
    if (toDestroy > 0) {
      commentBody += `⚠️ **Resource Deletion will happen**\n\n`;
      commentBody += `This plan contains resource delete operation. Please check the plan result very carefully!\n\n`;
    } else if (toAdd > 0 || toChange > 0) {
      commentBody += `🔄 **Infrastructure changes detected**\n\n`;
    } else {
      commentBody += `✅ **No changes detected**\n\n`;
      commentBody += `Infrastructure is up to date with the configuration.\n\n`;
    }
    
    commentBody += `\`\`\`\n`;
    commentBody += `Plan: ${toAdd} to add, ${toChange} to change, ${toDestroy} to destroy.\n`;
    commentBody += `\`\`\`\n\n`;
    
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
    commentBody += planOutput.slice(0, 5000);
    if (planOutput.length > 5000) {
      commentBody += `\n... (content truncated)\n`;
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
      commentBody += `Unable to retrieve detailed plan output.\n\n`;
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

  // Environment-specific identifiers
  const identifiers = {
    keeping: '## 📋 Plan Result (keeping/security-test)',
    scheduling: '## 📋 Plan Result (scheduling/infrastructure)'
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
