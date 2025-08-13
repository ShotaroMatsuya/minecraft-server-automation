const { execSync } = require('child_process');
function getPrInfo() {
  try {
    const commitMsg = execSync('git log -1 --pretty=format:%B').toString();
    const prNumberMatch = commitMsg.match(/Merge pull request #(\d+)/);
    if (prNumberMatch) {
      return { pr_number: prNumberMatch[1] };
    }
    // fallback: use GitHub CLI
    const sha = execSync('git rev-parse HEAD').toString().trim();
    const apiResult = execSync(`gh api repos/${process.env.GITHUB_REPOSITORY}/commits/${sha}/pulls --jq '.[0].number'`).toString().trim();
    return { pr_number: apiResult };
  } catch (e) {
    return { pr_number: '' };
  }
}
if (require.main === module) {
  const info = getPrInfo();
  console.log(`pr_number=${info.pr_number}`);
}
module.exports = getPrInfo;
