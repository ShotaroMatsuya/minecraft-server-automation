#!/bin/bash
set -e
ENV_DIR="$1"
MAX_RETRIES=3
RETRY_COUNT=0
while [ "$RETRY_COUNT" -lt "$MAX_RETRIES" ]; do
  echo "=== Terragrunt Apply - Attempt $((RETRY_COUNT + 1))/$MAX_RETRIES ==="
  terragrunt init --terragrunt-non-interactive || INIT_EXIT=$?
  if [ "$INIT_EXIT" != "" ] && [ "$INIT_EXIT" -ne 0 ]; then
    if [ "$RETRY_COUNT" -eq $((MAX_RETRIES - 1)) ]; then
      exit 1
    fi
    RETRY_COUNT=$((RETRY_COUNT + 1))
    sleep 30
    continue
  fi
  terragrunt plan --terragrunt-non-interactive -out=tfplan || PLAN_EXIT=$?
  if [ "$PLAN_EXIT" != "" ] && [ "$PLAN_EXIT" -ne 0 ]; then
    if [ "$RETRY_COUNT" -eq $((MAX_RETRIES - 1)) ]; then
      exit 2
    fi
    RETRY_COUNT=$((RETRY_COUNT + 1))
    sleep 30
    continue
  fi
  terragrunt apply --terragrunt-non-interactive -auto-approve tfplan && exit 0 || APPLY_EXIT=$?
  if grep -q "Error acquiring the state lock" apply_output.txt; then
    if [ "$RETRY_COUNT" -eq $((MAX_RETRIES - 1)) ]; then
      exit 3
    fi
    RETRY_COUNT=$((RETRY_COUNT + 1))
    sleep 60
    continue
  else
    exit "$APPLY_EXIT"
  fi
done
