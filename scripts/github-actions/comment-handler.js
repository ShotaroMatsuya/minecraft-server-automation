/**
 * Main script runner for GitHub Actions comments
 * Routes comment generation based on comment type
 */

const { createSecurityComment, updateSecurityComment } = require('./security-comment.js');
const { createCodeQualityComment, updateCodeQualityComment } = require('./code-quality-comment.js');
const { createTerragruntPlanComment, updateTerragruntPlanComment } = require('./terragrunt-plan-comment.js');

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
      const { createTerragruntPlanComment, updateTerragruntPlanComment } = require('./terragrunt-plan-comment.js');
      const terragruntInputs = {
        environment: inputs.environment,
        status: inputs.status,
        planFilePath: inputs.planFilePath,
        initErrorLog: inputs.initErrorLog || '',
        planErrorLog: inputs.planErrorLog || '',
        formatErrorLog: inputs.formatErrorLog || '',
        validateErrorLog: inputs.validateErrorLog || ''
      };
      commentBody = createTerragruntPlanComment(terragruntInputs);
      await updateTerragruntPlanComment(github, context, commentBody, inputs.environment);
      break;
        
      default:
        throw new Error(`Unknown comment type: ${commentType}`);
    }
    
    console.log(`Successfully posted ${commentType} comment`);
    
  } catch (error) {
    console.error(`Error posting ${commentType} comment:`, error);
    throw error;
  }
}

// Export for GitHub Actions usage
module.exports = main;

// Execute if called directly
if (require.main === module) {
  // For testing purposes - get inputs from environment variables
  const inputs = {
    commentType: process.env.COMMENT_TYPE,
    hasIssues: process.env.HAS_ISSUES === 'true',
    resultsSummary: process.env.RESULTS_SUMMARY,
    environment: process.env.ENVIRONMENT,
    status: process.env.STATUS,
    planFilePath: process.env.PLAN_FILE_PATH
  };
  
  // Mock github and context for testing
  const github = {
    rest: {
      issues: {
        listComments: async () => ({ data: [] }),
        createComment: async (params) => console.log('Create comment:', params),
        updateComment: async (params) => console.log('Update comment:', params)
      }
    }
  };
  
  const context = {
    repo: { owner: 'test-owner', repo: 'test-repo' },
    issue: { number: 1 }
  };
  
  main(github, context, inputs).catch(console.error);
}
