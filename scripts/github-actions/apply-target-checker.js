/**
 * Apply Target Checker
 * 
 * Determines which environments should run apply operations based on
 * both file changes and PR labels.
 */

module.exports = (labels, keepingChanges, schedulingChanges) => {
  // Check for target labels
  const keepingLabel = labels.includes('target:keeping');
  const schedulingLabel = labels.includes('target:scheduling');
  const noApplyLabel = labels.includes('no-apply');
  
  
  // Determine if we should run each environment
  // Run if: (file changes OR target label) AND NOT no-apply label
  let shouldRunKeeping = false;
  let shouldRunScheduling = false;
  
  if (!noApplyLabel) {
    if (keepingChanges || keepingLabel) {
      shouldRunKeeping = true;
    }
    
    if (schedulingChanges || schedulingLabel) {
      shouldRunScheduling = true;
    }
  }
  
  
  return {
    should_run_keeping: shouldRunKeeping.toString(),
    should_run_scheduling: shouldRunScheduling.toString()
  };
};
