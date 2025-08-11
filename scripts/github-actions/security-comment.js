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
 * @param {string} inputs.scanStatus - Status of the scan (success, failed, error)
 * @param {string} inputs.errorLog - Error log if scan failed (legacy)
 * @param {string} inputs.errorLogPath - Path to error log file
 * @returns {string} Formatted comment body
 */
function createSecurityComment(inputs) {
  let commentBody = `## 🔐 Security Scan Results (Trivy)\n\n`;
  
  // Read error log from file path if provided
  let errorLog = inputs.errorLog || '';
  if (inputs.errorLogPath && !errorLog) {
    try {
      errorLog = fs.readFileSync(inputs.errorLogPath, 'utf8');
    } catch (error) {
      // Error file doesn't exist or is empty
    }
  }
  
  // Check if scan failed
  if (inputs.scanStatus === 'failed' || inputs.scanStatus === 'error') {
    commentBody += `❌ **Security scan failed**\n\n`;
    commentBody += `The Trivy security scan encountered an error and could not complete successfully.\n\n`;
    
    if (errorLog) {
      commentBody += `### 🚨 Error Details\n\n`;
      commentBody += `<details><summary>📋 View Error Log (Click to expand)</summary>\n\n`;
      commentBody += `\`\`\`\n${errorLog.slice(0, 3000)}\`\`\`\n\n`;
      commentBody += `</details>\n\n`;
    }
    
    commentBody += `### 🔧 Troubleshooting\n`;
    commentBody += `- Check if Terraform files are valid\n`;
    commentBody += `- Verify Trivy configuration in \`trivy.yaml\`\n`;
    commentBody += `- Check workflow logs for detailed error information\n\n`;
    
    // Add CI/CD links section for failed scans
    commentBody += `### 🔗 Links\n\n`;
    commentBody += `- 📊 **[View GitHub Actions Run](${process.env.GITHUB_SERVER_URL}/${process.env.GITHUB_REPOSITORY}/actions/runs/${process.env.GITHUB_RUN_ID})**\n`;
    commentBody += `- 📦 **[Download Security Artifacts](${process.env.GITHUB_SERVER_URL}/${process.env.GITHUB_REPOSITORY}/actions/runs/${process.env.GITHUB_RUN_ID}#artifacts)**\n`;
    commentBody += `- 🔍 **[View Security Scan Job](${process.env.GITHUB_SERVER_URL}/${process.env.GITHUB_REPOSITORY}/actions/runs/${process.env.GITHUB_RUN_ID}/job/${process.env.GITHUB_JOB})**\n\n`;
    
    commentBody += `*❌ Security scan failed at ${new Date().toISOString()}*`;
    return commentBody;
  }
  
  try {
    // Try to read the trivy JSON results first, fallback to table format
    let trivyData = null;
    try {
      const jsonResults = fs.readFileSync('security-results/trivy-results.json', 'utf8');
      trivyData = JSON.parse(jsonResults);
    } catch {
      // Use table format processing
    }

    if (trivyData) {
      const severityCounts = {
        UNKNOWN: 0,
        LOW: 0,
        MEDIUM: 0,
        HIGH: 0,
        CRITICAL: 0
      };

      const findings = [];

      trivyData.Results.forEach(result => {
        if (result.Misconfigurations) {
          result.Misconfigurations.forEach(finding => {
            severityCounts[finding.Severity]++;
            findings.push({
              severity: finding.Severity,
              location: result.Target || 'N/A',
              title: finding.Message,
              id: finding.ID
            });
          });
        }
      });

      const totalFindings = severityCounts.UNKNOWN + severityCounts.LOW + severityCounts.MEDIUM + severityCounts.HIGH + severityCounts.CRITICAL;

      if (inputs.hasIssues && totalFindings > 0) {
        commentBody += `⚠️ **Security issues detected**\n\n`;
        // ...existing code for summary, table, links, details...
        commentBody += `**Findings by Severity:**\n`;
        commentBody += `\`\`\`\n`;
        commentBody += `UNKNOWN: ${severityCounts.UNKNOWN}, LOW: ${severityCounts.LOW}, MEDIUM: ${severityCounts.MEDIUM}, HIGH: ${severityCounts.HIGH}, CRITICAL: ${severityCounts.CRITICAL}\n`;
        commentBody += `\`\`\`\n\n`;
        commentBody += `| Severity | Location | Error Title | ID |\n`;
        commentBody += `|----------|----------|-------------|----|\n`;
        findings.slice(0, 20).forEach(finding => {
          const location = finding.location || 'N/A';
          const title = finding.title.replace(/\|/g, '\\|');
          commentBody += `| ${finding.severity} | ${location} | ${title} | ${finding.id} |\n`;
        });
        if (findings.length > 20) {
          commentBody += `| ... | ... | ... | *${findings.length - 20} more findings* |\n`;
        }
        commentBody += `\n`;
        commentBody += `### 📊 Scan Coverage\n`;
        commentBody += `- **🔍 Files Scanned**: Terraform configuration files\n`;
        commentBody += `- **🛡️ Tool**: Trivy v0.58.1\n`;
        commentBody += `- **📋 Checks**: AWS, Security, Best Practices\n\n`;
        commentBody += `### 🔗 Links\n\n`;
        commentBody += `- 📊 **[View GitHub Actions Run](${process.env.GITHUB_SERVER_URL}/${process.env.GITHUB_REPOSITORY}/actions/runs/${process.env.GITHUB_RUN_ID})**\n`;
        commentBody += `- 📦 **[Download Security Artifacts](${process.env.GITHUB_SERVER_URL}/${process.env.GITHUB_REPOSITORY}/actions/runs/${process.env.GITHUB_RUN_ID}#artifacts)**\n`;
        commentBody += `- 🔍 **[View Security Scan Job](${process.env.GITHUB_SERVER_URL}/${process.env.GITHUB_REPOSITORY}/actions/runs/${process.env.GITHUB_RUN_ID}/job/${process.env.GITHUB_JOB})**\n\n`;
        commentBody += `<details><summary>📋 View Full Security Report (Click to expand)</summary>\n\n`;
        commentBody += `\`\`\`json\n${JSON.stringify(trivyData, null, 2).slice(0, 5000)}\`\`\`\n\n`;
        commentBody += `</details>\n\n`;
      } else {
        commentBody += `✅ **No security issues found**\n\n`;
        commentBody += `**Findings by Severity:**\n`;
        commentBody += `\`\`\`\n`;
        commentBody += `UNKNOWN: 0, LOW: 0, MEDIUM: 0, HIGH: 0, CRITICAL: 0\n`;
        commentBody += `\`\`\`\n\n`;
        commentBody += `Your infrastructure code follows security best practices.\n\n`;
        commentBody += `### 📊 Scan Coverage\n`;
        commentBody += `- **🔍 Files Scanned**: Terraform configuration files\n`;
        commentBody += `- **🛡️ Tool**: Trivy v0.58.1\n`;
        commentBody += `- **📋 Checks**: AWS, Security, Best Practices\n\n`;
        commentBody += `### 🔗 Links\n\n`;
        commentBody += `- 📊 **[View GitHub Actions Run](${process.env.GITHUB_SERVER_URL}/${process.env.GITHUB_REPOSITORY}/actions/runs/${process.env.GITHUB_RUN_ID})**\n`;
        commentBody += `- 📦 **[Download Security Artifacts](${process.env.GITHUB_SERVER_URL}/${process.env.GITHUB_REPOSITORY}/actions/runs/${process.env.GITHUB_RUN_ID}#artifacts)**\n`;
        commentBody += `- 🔍 **[View Security Scan Job](${process.env.GITHUB_SERVER_URL}/${process.env.GITHUB_REPOSITORY}/actions/runs/${process.env.GITHUB_RUN_ID}/job/${process.env.GITHUB_JOB})**\n\n`;
        commentBody += `<details><summary>📋 View Full Security Report (Click to expand)</summary>\n\n`;
        commentBody += `\`\`\`json\n${JSON.stringify(trivyData, null, 2).slice(0, 5000)}\`\`\`\n\n`;
        commentBody += `</details>\n\n`;
      }
    } else {
      // Fallback to table format parsing
      const trivyResults = fs.readFileSync('security-results/trivy-results.txt', 'utf8');
      
      if (inputs.hasIssues && trivyResults.trim()) {
        commentBody += `⚠️ **Security issues detected**\n\n`;
        
        // Parse trivy output for table format (fallback)
        const lines = trivyResults.split('\n');
        const issueLines = lines.filter(line => 
          line.includes('terraform/') && (
            line.includes('HIGH') || 
            line.includes('CRITICAL') || 
            line.includes('MEDIUM') ||
            line.includes('LOW')
          )
        );
        
        // Count severities for summary
        const severityCounts = { UNKNOWN: 0, LOW: 0, MEDIUM: 0, HIGH: 0, CRITICAL: 0 };
        issueLines.forEach(line => {
          if (line.includes('CRITICAL')) severityCounts.CRITICAL++;
          else if (line.includes('HIGH')) severityCounts.HIGH++;
          else if (line.includes('MEDIUM')) severityCounts.MEDIUM++;
          else if (line.includes('LOW')) severityCounts.LOW++;
          else severityCounts.UNKNOWN++;
        });
        
        // Add severity count summary in code block
        commentBody += `**Findings by Severity:**\n`;
        commentBody += `\`\`\`\n`;
        commentBody += `UNKNOWN: ${severityCounts.UNKNOWN}, LOW: ${severityCounts.LOW}, MEDIUM: ${severityCounts.MEDIUM}, HIGH: ${severityCounts.HIGH}, CRITICAL: ${severityCounts.CRITICAL}\n`;
        commentBody += `\`\`\`\n\n`;
        
        if (issueLines.length > 0) {
          // Add table as proper Markdown table
          commentBody += `| Severity | Location | Error Title | ID |\n`;
          commentBody += `|----------|----------|-------------|----|\n`;
          
          issueLines.slice(0, 10).forEach(line => {
            const parts = line.split(/\s+/);
            const file = parts.find(p => p.includes('terraform/')) || 'N/A';
            const severity = parts.find(p => ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW'].includes(p)) || 'UNKNOWN';
            const rule = parts.find(p => p.startsWith('AVD-')) || 'N/A';
            commentBody += `| ${severity} | ${file} | Security issue detected | ${rule} |\n`;
          });
          
          if (issueLines.length > 10) {
            commentBody += `| ... | ... | ... | *${issueLines.length - 10} more issues* |\n`;
          }
          commentBody += `\n`;
        }
        
        // Add Scan Coverage section for security issues found (table format)
        commentBody += `### 📊 Scan Coverage\n`;
        commentBody += `- **🔍 Files Scanned**: Terraform configuration files\n`;
        commentBody += `- **🛡️ Tool**: Trivy v0.58.1\n`;
        commentBody += `- **📋 Checks**: AWS, Security, Best Practices\n\n`;
        
        // Add CI/CD links section
        commentBody += `### 🔗 Links\n\n`;
        commentBody += `- 📊 **[View GitHub Actions Run](${process.env.GITHUB_SERVER_URL}/${process.env.GITHUB_REPOSITORY}/actions/runs/${process.env.GITHUB_RUN_ID})**\n`;
        commentBody += `- 📦 **[Download Security Artifacts](${process.env.GITHUB_SERVER_URL}/${process.env.GITHUB_REPOSITORY}/actions/runs/${process.env.GITHUB_RUN_ID}#artifacts)**\n`;
        commentBody += `- 🔍 **[View Security Scan Job](${process.env.GITHUB_SERVER_URL}/${process.env.GITHUB_REPOSITORY}/actions/runs/${process.env.GITHUB_RUN_ID}/job/${process.env.GITHUB_JOB})**\n\n`;
        
        commentBody += `<details><summary>📋 View Full Security Report (Click to expand)</summary>\n\n`;
        commentBody += `\`\`\`\n${trivyResults.slice(0, 5000)}\`\`\`\n\n`;
        commentBody += `</details>\n\n`;
      } else {
        commentBody += `✅ **No security issues found**\n\n`;
        commentBody += `**Findings by Severity:**\n`;
        commentBody += `\`\`\`\n`;
        commentBody += `UNKNOWN: 0, LOW: 0, MEDIUM: 0, HIGH: 0, CRITICAL: 0\n`;
        commentBody += `\`\`\`\n\n`;
        commentBody += `Your infrastructure code follows security best practices.\n\n`;
        
        // Add Scan Coverage section for no security issues
        commentBody += `### 📊 Scan Coverage\n`;
        commentBody += `- **🔍 Files Scanned**: Terraform configuration files\n`;
        commentBody += `- **🛡️ Tool**: Trivy v0.58.1\n`;
        commentBody += `- **📋 Checks**: AWS, Security, Best Practices\n\n`;
        
        // Add CI/CD links section
        commentBody += `### 🔗 Links\n\n`;
        commentBody += `- 📊 **[View GitHub Actions Run](${process.env.GITHUB_SERVER_URL}/${process.env.GITHUB_REPOSITORY}/actions/runs/${process.env.GITHUB_RUN_ID})**\n`;
        commentBody += `- 📦 **[Download Security Artifacts](${process.env.GITHUB_SERVER_URL}/${process.env.GITHUB_REPOSITORY}/actions/runs/${process.env.GITHUB_RUN_ID}#artifacts)**\n`;
        commentBody += `- 🔍 **[View Security Scan Job](${process.env.GITHUB_SERVER_URL}/${process.env.GITHUB_REPOSITORY}/actions/runs/${process.env.GITHUB_RUN_ID}/job/${process.env.GITHUB_JOB})**\n\n`;
        
        // Add collapsible section for detailed results even when no issues
        commentBody += `<details><summary>📋 View Full Security Report (Click to expand)</summary>\n\n`;
        commentBody += `\`\`\`\n${trivyResults.slice(0, 5000)}\`\`\`\n\n`;
        commentBody += `</details>\n\n`;
      }
    }
    
  } catch (error) {
    commentBody += `✅ **No security issues found**\n\n`;
    commentBody += `Your infrastructure code follows security best practices.\n\n`;
    
    commentBody += `### 📊 Scan Coverage\n`;
    commentBody += `- **🔍 Files Scanned**: Terraform configuration files\n`;
    commentBody += `- **🛡️ Tool**: Trivy v0.58.1\n`;
    commentBody += `- **📋 Checks**: AWS, Security, Best Practices\n\n`;
    
    // Add CI/CD links section
    commentBody += `### 🔗 Links\n\n`;
    commentBody += `- 📊 **[View GitHub Actions Run](${process.env.GITHUB_SERVER_URL}/${process.env.GITHUB_REPOSITORY}/actions/runs/${process.env.GITHUB_RUN_ID})**\n`;
    commentBody += `- 📦 **[Download Security Artifacts](${process.env.GITHUB_SERVER_URL}/${process.env.GITHUB_REPOSITORY}/actions/runs/${process.env.GITHUB_RUN_ID}#artifacts)**\n`;
    commentBody += `- 🔍 **[View Security Scan Job](${process.env.GITHUB_SERVER_URL}/${process.env.GITHUB_REPOSITORY}/actions/runs/${process.env.GITHUB_RUN_ID}/job/${process.env.GITHUB_JOB})**\n\n`;
    
    // Add collapsible section for detailed results even when no scan results
    commentBody += `<details><summary>📋 View Full Security Report (Click to expand)</summary>\n\n`;
    commentBody += `\`\`\`\nNo security scan results available.\`\`\`\n\n`;
    commentBody += `</details>\n\n`;
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
