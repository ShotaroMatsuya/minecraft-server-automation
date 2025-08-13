/**
 * Auto Label PR by Environment
 * 
 * Automatically detects infrastructure changes and applies appropriate labels
 * for environment-specific CI/CD operations.
 */

module.exports = async (github, context, changedFiles) => {
  
  // Analyze which environments are affected
  const keepingFiles = changedFiles.filter(file => 
    file.includes('terragrunt/environments/keeping/') || 
    file.includes('terraform/keeping/')
  );
  
  const schedulingFiles = changedFiles.filter(file => 
    file.includes('terragrunt/environments/scheduling/') || 
    file.includes('terraform/scheduling/')
  );
  
  const moduleFiles = changedFiles.filter(file => 
    file.includes('terraform/modules/')
  );
  
  // Determine which environments should be labeled
  const shouldLabelKeeping = keepingFiles.length > 0 || moduleFiles.length > 0;
  const shouldLabelScheduling = schedulingFiles.length > 0 || moduleFiles.length > 0;
  
  
  // Get current labels
  const { data: currentLabels } = await github.rest.issues.listLabelsOnIssue({
    owner: context.repo.owner,
    repo: context.repo.repo,
    issue_number: context.issue.number,
  });
  
  const currentLabelNames = currentLabels.map(label => label.name);
  
  // Determine required labels
  const requiredLabels = [];
  if (shouldLabelKeeping) {
    requiredLabels.push('target:keeping');
  }
  if (shouldLabelScheduling) {
    requiredLabels.push('target:scheduling');
  }
  
  
  // Remove old target labels that are no longer needed
  const targetLabelsToRemove = currentLabelNames.filter(label => 
    label.startsWith('target:') && !requiredLabels.includes(label)
  );
  
  for (const labelToRemove of targetLabelsToRemove) {
    try {
      await github.rest.issues.removeLabel({
        owner: context.repo.owner,
        repo: context.repo.repo,
        issue_number: context.issue.number,
        name: labelToRemove
      });
    } catch (error) {
    }
  }
  
  // Add new required labels
  const labelsToAdd = requiredLabels.filter(label => !currentLabelNames.includes(label));
  
  if (labelsToAdd.length > 0) {
    try {
      await github.rest.issues.addLabels({
        owner: context.repo.owner,
        repo: context.repo.repo,
        issue_number: context.issue.number,
        labels: labelsToAdd
      });
    } catch (error) {
    }
  }
  
  // Create summary comment if labels were applied
  if (requiredLabels.length > 0) {
    await createSummaryComment(github, context, {
      keepingFiles,
      schedulingFiles,
      moduleFiles,
      labelsToAdd
    });
  }
};

/**
 * Creates or updates the environment detection summary comment
 */
async function createSummaryComment(github, context, { keepingFiles, schedulingFiles, moduleFiles, labelsToAdd }) {
  const summary = `## 🏷️ Environment Detection Results

**Detected Infrastructure Changes:**
${keepingFiles.length > 0 ? `
### 🏠 Keeping Environment
- **Files changed:** ${keepingFiles.length}
- **Label:** \`target:keeping\` ${labelsToAdd.includes('target:keeping') ? '(added)' : '(existing)'}

<details>
<summary>Changed files</summary>

${keepingFiles.map(f => `- \`${f}\``).join('\n')}
</details>` : ''}
${schedulingFiles.length > 0 ? `
### ⏰ Scheduling Environment  
- **Files changed:** ${schedulingFiles.length}
- **Label:** \`target:scheduling\` ${labelsToAdd.includes('target:scheduling') ? '(added)' : '(existing)'}

<details>
<summary>Changed files</summary>

${schedulingFiles.map(f => `- \`${f}\``).join('\n')}
</details>` : ''}
${moduleFiles.length > 0 ? `
### 🧩 Shared Modules (Affects Both Environments)
- **Files changed:** ${moduleFiles.length}
- **Impact:** Both \`keeping\` and \`scheduling\` environments
- **Labels:** \`target:keeping\` + \`target:scheduling\` ${(labelsToAdd.includes('target:keeping') || labelsToAdd.includes('target:scheduling')) ? '(added)' : '(existing)'}

<details>
<summary>Changed module files</summary>

${moduleFiles.map(f => `- \`${f}\``).join('\n')}
</details>` : ''}

**Next Steps:**
- 🔍 PR checks will run for detected environments
- 🚀 Apply will execute for labeled environments after merge
- 📝 You can manually add/remove \`target:\` labels if needed

*🤖 Labels updated automatically based on infrastructure changes*`;
  
  // Find existing auto-label comment
  const { data: comments } = await github.rest.issues.listComments({
    owner: context.repo.owner,
    repo: context.repo.repo,
    issue_number: context.issue.number,
  });
  
  const autoLabelIdentifier = '## 🏷️ Environment Detection Results';
  const existingComment = comments.find(comment => 
    comment.user.type === 'Bot' && 
    comment.body.includes(autoLabelIdentifier)
  );
  
  if (existingComment) {
    await github.rest.issues.updateComment({
      owner: context.repo.owner,
      repo: context.repo.repo,
      comment_id: existingComment.id,
      body: summary
    });
  } else {
    await github.rest.issues.createComment({
      owner: context.repo.owner,
      repo: context.repo.repo,
      issue_number: context.issue.number,
      body: summary
    });
  }
}
