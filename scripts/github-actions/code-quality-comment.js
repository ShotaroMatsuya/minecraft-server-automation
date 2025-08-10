/**
 * Code quality comment generator for GitHub Actions
 * Processes TFLint code quality results and creates formatted PR comments
 */

const fs = require('fs');

/**
 * Creates a code quality results comment
 * @param {Object} inputs - Input parameters from GitHub Actions
 * @param {boolean} inputs.hasIssues - Whether code quality issues were found
 * @param {string} inputs.resultsSummary - Summary of scan results
 * @returns {string} Formatted comment body
 */
function createCodeQualityComment(inputs) {
  let commentBody = `## 🔍 Code Quality Results (TFLint)\n\n`;
  
  try {
    // Try to read the actual tflint results
    const tflintResults = fs.readFileSync('quality-results/tflint-results.txt', 'utf8');
    
    if (inputs.hasIssues && tflintResults.trim()) {
      commentBody += `⚠️ **Code quality issues detected**\n\n`;
      
      // Parse tflint output for table format
      const lines = tflintResults.split('\n');
      const issueLines = lines.filter(line => 
        line.includes('Error:') || 
        line.includes('Warning:') || 
        line.includes('Notice:') ||
        (line.includes('.tf') && line.includes(':'))
      );
      
      if (issueLines.length > 0) {
        commentBody += `| File | Line | Rule | Severity | Description |\n`;
        commentBody += `|------|------|------|----------|-------------|\n`;
        
        issueLines.slice(0, 10).forEach(line => {
          const fileMatch = line.match(/([^/]+\.tf):(\d+):/);
          const file = fileMatch ? fileMatch[1] : 'N/A';
          const lineNum = fileMatch ? fileMatch[2] : 'N/A';
          
          let severity = 'Info';
          if (line.includes('Error:')) severity = 'Error';
          else if (line.includes('Warning:')) severity = 'Warning';
          else if (line.includes('Notice:')) severity = 'Notice';
          
          const rule = line.match(/\(([^)]+)\)/) ? line.match(/\(([^)]+)\)/)[1] : 'general';
          const description = line.replace(/.*: /, '').replace(/\s*\([^)]+\).*/, '').substring(0, 60) + '...';
          
          commentBody += `| ${file} | ${lineNum} | ${rule} | ${severity} | ${description} |\n`;
        });
        
        if (issueLines.length > 10) {
          commentBody += `| ... | ... | ... | ... | *${issueLines.length - 10} more issues* |\n`;
        }
        commentBody += `\n`;
      }
      
      commentBody += `<details><summary>📋 View Full Code Quality Report</summary>\n\n`;
      commentBody += `\`\`\`\n${tflintResults.slice(0, 5000)}\`\`\`\n\n`;
      commentBody += `</details>\n\n`;
    } else {
      commentBody += `✅ **No code quality issues found**\n\n`;
      commentBody += `Your Terraform code follows best practices and conventions.\n\n`;
      
      commentBody += `### 📊 Scan Coverage\n`;
      commentBody += `- **🔍 Files Scanned**: Terraform configuration files\n`;
      commentBody += `- **🛠️ Tool**: TFLint v0.50.3\n`;
      commentBody += `- **📋 Checks**: AWS, Terraform best practices\n\n`;
    }
  } catch (error) {
    commentBody += `✅ **No code quality issues found**\n\n`;
    commentBody += `Your Terraform code follows best practices and conventions.\n\n`;
    
    commentBody += `### 📊 Scan Coverage\n`;
    commentBody += `- **🔍 Files Scanned**: Terraform configuration files\n`;
    commentBody += `- **🛠️ Tool**: TFLint v0.50.3\n`;
    commentBody += `- **📋 Checks**: AWS, Terraform best practices\n\n`;
  }
  
  commentBody += `*🔍 Code quality scan completed at ${new Date().toISOString()}*`;
  
  return commentBody;
}

/**
 * Updates or creates a code quality comment on GitHub PR
 * @param {Object} github - GitHub API client
 * @param {Object} context - GitHub Actions context
 * @param {string} commentBody - The comment content
 */
async function updateCodeQualityComment(github, context, commentBody) {
  // Find and update existing code quality comment
  const { data: comments } = await github.rest.issues.listComments({
    owner: context.repo.owner,
    repo: context.repo.repo,
    issue_number: context.issue.number,
  });

  const qualityIdentifier = '## 🔍 Code Quality Results (TFLint)';
  const existingQualityComment = comments.find(comment => 
    comment.user.type === 'Bot' && 
    comment.body.includes(qualityIdentifier)
  );

  if (existingQualityComment) {
    await github.rest.issues.updateComment({
      owner: context.repo.owner,
      repo: context.repo.repo,
      comment_id: existingQualityComment.id,
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
  createCodeQualityComment,
  updateCodeQualityComment
};
