#!/bin/bash
# terragrunt-apply.sh
# Usage: terragrunt-apply.sh <working_dir>
set -euo pipefail

WORKING_DIR="$1"
cd "$WORKING_DIR"

handle_state_lock() {
  local max_retries=3
  local retry_count=0

  while [ "$retry_count" -lt "$max_retries" ]; do
    echo "=== Terragrunt Apply - Attempt $((retry_count + 1))/$max_retries ==="

    # Initialize
    init_exit_code=0
    terragrunt init --terragrunt-non-interactive 2>&1 | tee init_output.txt || init_exit_code=$?
    if [ "$init_exit_code" -ne 0 ]; then
      if [ "$retry_count" -eq $((max_retries - 1)) ]; then
        echo "status=init_failed"
        return 1
      fi
      retry_count=$((retry_count + 1))
      echo "⏳ Waiting 30 seconds before retry..."
      sleep 30
      continue
    fi

    # Plan
    plan_exit_code=0
    terragrunt plan --terragrunt-non-interactive -out=tfplan > plan_output.txt 2>&1 || plan_exit_code=$?
    if [ "$plan_exit_code" -ne 0 ]; then
      if [ "$retry_count" -eq $((max_retries - 1)) ]; then
        echo "status=plan_failed"
        return 1
      fi
      retry_count=$((retry_count + 1))
      echo "⏳ Waiting 30 seconds before retry..."
      sleep 30
      continue
    fi

    # Apply
    apply_exit_code=0
    terragrunt apply --terragrunt-non-interactive -auto-approve tfplan > apply_output.txt 2>&1 || apply_exit_code=$?
    if [ "$apply_exit_code" -ne 0 ] && grep -q "Error acquiring the state lock" apply_output.txt; then
      echo "⚠️ State lock error detected on attempt $((retry_count + 1))"
      if [ "$retry_count" -eq $((max_retries - 1)) ]; then
        echo "❌ Max retries reached, failing..."
        break
      fi
      retry_count=$((retry_count + 1))
      echo "⏳ Waiting 60 seconds for lock to be released..."
      sleep 60
      continue
    else
      break
    fi
  done
  return "$apply_exit_code"
}

handle_state_lock
final_exit_code=$?


# エラー詳細抽出・依存エラー補足
bash ../scripts/github-actions/terragrunt-error-helper.sh apply_output.txt apply_errors.txt

# Output status for workflow
if [ "$final_exit_code" -eq 0 ]; then
  if grep -q "Apply complete!" apply_output.txt || grep -q "No changes" apply_output.txt; then
    echo "status=success"
  else
    echo "status=completed_with_warnings"
  fi
else
  echo "status=failed"
fi
