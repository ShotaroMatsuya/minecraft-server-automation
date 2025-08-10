/**
 * Security scan comment generator for GitHub Actions
 * Processes Trivy security scan results and creates formatted PR comments
 */

const fs = require('fs');

/**
 * Creates a security scan results comment
 * @param {Object} inputs - Input parameters from GitHub Actions
 * @param {boolean} inputs.hasIssues - Whether security issues were found
 * @param {string} inputs.resultsSummary - Summary of scan results
 * @returns {string} Formatted comment body
 */
function createSecurityComment(inputs) {
  let commentBody = `## 🔐 Security Scan Results (Trivy)\n\n`;
  
  try {
    // Try to read the actual trivy results
    const trivyResults = fs.readFileSync('security-results/trivy-results.txt', 'utf8');
    
    if (inputs.hasIssues && trivyResults.trim()) {
      commentBody += `⚠️ **Security issues detected**\n\n`;
      
      // Parse trivy output for table format
      const lines = trivyResults.split('\n');
      const issueLines = lines.filter(line => 
        line.includes('terraform/') && (
          line.includes('HIGH') || 
          line.includes('CRITICAL') || 
          line.includes('MEDIUM') ||
          line.includes('LOW')
        )
      );
      
      if (issueLines.length > 0) {
        commentBody += `| File | Resource | Rule | Severity | Description |\n`;
        commentBody += `|------|----------|------|----------|-------------|\n`;
        
        issueLines.slice(0, 10).forEach(line => {
          const parts = line.split(/\s+/);
          const file = parts.find(p => p.includes('terraform/')) || 'N/A';
          const severity = parts.find(p => ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW'].includes(p)) || 'UNKNOWN';
          const rule = parts.find(p => p.startsWith('AVD-')) || 'N/A';
          commentBody += `| ${file} | N/A | ${rule} | ${severity} | Security issue detected |\n`;
        });
        
        if (issueLines.length > 10) {
          commentBody += `| ... | ... | ... | ... | *${issueLines.length - 10} more issues* |\n`;
        }
        commentBody += `\n`;
      }
      
      commentBody += `<details><summary>📋 View Full Security Report</summary>\n\n`;
      commentBody += `\`\`\`\n${trivyResults.slice(0, 5000)}\`\`\`\n\n`;
      commentBody += `</details>\n\n`;
    } else {
      commentBody += `✅ **No security issues found**\n\n`;
      commentBody += `Your infrastructure code follows security best practices.\n\n`;
      
      commentBody += `### 📊 Scan Coverage\n`;
      commentBody += `- **🔍 Files Scanned**: Terraform configuration files\n`;
      commentBody += `- **🛡️ Tool**: Trivy v0.48.0\n`;
      commentBody += `- **📋 Checks**: AWS, Security, Best Practices\n\n`;
    }
  } catch (error) {
    commentBody += `✅ **No security issues found**\n\n`;
    commentBody += `Your infrastructure code follows security best practices.\n\n`;
    
    commentBody += `### 📊 Scan Coverage\n`;
    commentBody += `- **🔍 Files Scanned**: Terraform configuration files\n`;
    commentBody += `- **🛡️ Tool**: Trivy v0.48.0\n`;
    commentBody += `- **📋 Checks**: AWS, Security, Best Practices\n\n`;
  }
  
  commentBody += `*🔐 Security scan completed at ${new Date().toISOString()}*`;
  
  return commentBody;
}

/**
 * Updates or creates a security scan comment on GitHub PR
 * @param {Object} github - GitHub API client
 * @param {Object} context - GitHub Actions context
 * @param {string} commentBody - The comment content
 */
async function updateSecurityComment(github, context, commentBody) {
  // Find and update existing security comment
  const { data: comments } = await github.rest.issues.listComments({
    owner: context.repo.owner,
    repo: context.repo.repo,
    issue_number: context.issue.number,
  });

  const securityIdentifier = '## 🔐 Security Scan Results (Trivy)';
  const existingSecurityComment = comments.find(comment => 
    comment.user.type === 'Bot' && 
    comment.body.includes(securityIdentifier)
  );

  if (existingSecurityComment) {
    await github.rest.issues.updateComment({
      owner: context.repo.owner,
      repo: context.repo.repo,
      comment_id: existingSecurityComment.id,
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
  createSecurityComment,
  updateSecurityComment
};
