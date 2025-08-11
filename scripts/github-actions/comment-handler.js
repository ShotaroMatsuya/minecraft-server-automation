/**
 * Main script runner for GitHub Actions comments
 * Routes comment generation based on comment type
 */

const { createSecurityComment, updateSecurityComment } = require('./security-comment.js');
const { createCodeQualityComment, updateCodeQualityComment } = require('./code-quality-comment.js');
const { createTerragruntPlanComment, updateTerragruntPlanComment } = require('./terragrunt-plan-comment.js');
const { createTerragruntApplyComment, updateTerragruntApplyComment } = require('./terragrunt-apply-comment.js');

/**
 * Main function to handle comment generation and posting
 * @param {Object} github - GitHub API client
 * @param {Object} context - GitHub Actions context
 * @param {Object} inputs - Input parameters from GitHub Actions
 */
async function main(github, context, inputs) {
  const { commentType } = inputs;
  
  try {
    let commentBody;
    
    switch (commentType) {
      case 'security':
        commentBody = createSecurityComment(inputs);
        await updateSecurityComment(github, context, commentBody);
        break;
        
      case 'code-quality':
        commentBody = createCodeQualityComment(inputs);
        await updateCodeQualityComment(github, context, commentBody);
        break;
        
      case 'terragrunt-plan':
        const terragruntInputs = {
          environment: inputs.environment,
          status: inputs.status,
          planFilePath: inputs.planFilePath,
          initErrorLog: inputs.initErrorLog || '',
          planErrorLog: inputs.planErrorLog || '',
          formatErrorLog: inputs.formatErrorLog || '',
          validateErrorLog: inputs.validateErrorLog || '',
          initErrorLogPath: inputs.initErrorLogPath,
          planErrorLogPath: inputs.planErrorLogPath,
          formatErrorLogPath: inputs.formatErrorLogPath,
          validateErrorLogPath: inputs.validateErrorLogPath,
          artifactBasePath: inputs.artifactBasePath
        };
        commentBody = createTerragruntPlanComment(terragruntInputs);
        await updateTerragruntPlanComment(github, context, commentBody, inputs.environment);
        break;
        
      case 'terragrunt-plan-summary':
        // Create a simple summary comment for when all environments are skipped
        commentBody = `## 📋 Terragrunt Plan Summary\n\n${inputs.message}\n\n---\n*Updated: ${new Date().toISOString()}*`;
        
        // Find existing plan comments and update them or create a new one
        const { data: comments } = await github.rest.issues.listComments({
          owner: context.repo.owner,
          repo: context.repo.repo,
          issue_number: context.issue.number,
        });
        
        const existingComment = comments.find(comment => 
          comment.body.includes('📋 Terragrunt Plan Summary')
        );
        
        if (existingComment) {
          await github.rest.issues.updateComment({
            owner: context.repo.owner,
            repo: context.repo.repo,
            comment_id: existingComment.id,
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
        break;
        
      case 'terragrunt-apply':
        const applyInputs = {
          environment: inputs.environment,
          status: inputs.status,
          applyFilePath: inputs.applyFilePath,
          initErrorLogPath: inputs.initErrorLogPath,
          applyErrorLogPath: inputs.applyErrorLogPath,
          artifactBasePath: inputs.artifactBasePath,
          resourcesApplied: inputs.resourcesApplied,
          resourcesChanged: inputs.resourcesChanged,
          resourcesDestroyed: inputs.resourcesDestroyed
        };
        commentBody = createTerragruntApplyComment(applyInputs);
        
        // Use prNumber from inputs if provided (from apply workflow)
        const issueNumber = inputs.prNumber || context.issue.number;
        
        await updateTerragruntApplyComment(github, context, commentBody, inputs.environment, issueNumber);
        break;
        
      default:
        throw new Error(`Unknown comment type: ${commentType}`);
    }
    
    
  } catch (error) {
    console.error(`Error posting ${commentType} comment:`, error);
    throw error;
  }
}

// Export for GitHub Actions usage
module.exports = main;

// Execute if called directly
if (require.main === module) {
}
