/**
 * Environment Target Checker
 * 
 * Checks PR labels to determine which environments should be targeted
 * for CI/CD operations.
 */

module.exports = async (github, context) => {
  const { data: pullRequest } = await github.rest.pulls.get({
    owner: context.repo.owner,
    repo: context.repo.repo,
    pull_number: context.issue.number,
  });
  
  const labels = pullRequest.labels.map(label => label.name);
  console.log('PR Labels:', labels);
  
  const hasKeepingLabel = labels.includes('target:keeping');
  const hasSchedulingLabel = labels.includes('target:scheduling');
  const hasAnyTargetLabel = hasKeepingLabel || hasSchedulingLabel;
  
  console.log('Has keeping label:', hasKeepingLabel);
  console.log('Has scheduling label:', hasSchedulingLabel);
  console.log('Should run checks:', hasAnyTargetLabel);
  
  return {
    should_run_keeping: hasKeepingLabel,
    should_run_scheduling: hasSchedulingLabel,
    should_run_checks: hasAnyTargetLabel
  };
};
