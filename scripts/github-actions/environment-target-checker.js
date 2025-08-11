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
  
  const hasKeepingLabel = labels.includes('target:keeping');
  const hasSchedulingLabel = labels.includes('target:scheduling');
  const hasAnyTargetLabel = hasKeepingLabel || hasSchedulingLabel;
  
  
  return {
    should_run_keeping: hasKeepingLabel.toString(),
    should_run_scheduling: hasSchedulingLabel.toString(),
    should_run_checks: hasAnyTargetLabel.toString()
  };
};
