#!/bin/bash
# terragrunt-error-helper.sh
# Usage: terragrunt-error-helper.sh <output_file> <error_file>

OUTPUT_FILE="$1"
ERROR_FILE="$2"

# エラー詳細の抽出
if [ -f "$OUTPUT_FILE" ] && [ -s "$OUTPUT_FILE" ]; then
  tail -50 "$OUTPUT_FILE" > "$ERROR_FILE"
elif [ -f "plan_errors.txt" ] && [ -s "plan_errors.txt" ]; then
  cp plan_errors.txt "$ERROR_FILE"
elif [ -f "plan_output.txt" ] && [ -s "plan_output.txt" ]; then
  tail -50 plan_output.txt > "$ERROR_FILE"
elif [ -f "init_output.txt" ] && [ -s "init_output.txt" ]; then
  tail -50 init_output.txt > "$ERROR_FILE"
else
  echo "No detailed error logs available" > "$ERROR_FILE"
fi

# 依存リソースエラーの補足
if [ -f "$ERROR_FILE" ]; then
  if grep -q "no matching EC2 Security Group found" "$ERROR_FILE"; then
    echo "Dependency Issue: Security Group not found" >> "$ERROR_FILE"
    echo "Possible cause: apply-keeping job may not have completed successfully" >> "$ERROR_FILE"
  fi
  if grep -q "couldn't find resource.*IAM Role" "$ERROR_FILE"; then
    echo "Dependency Issue: IAM Role not found" >> "$ERROR_FILE"
    echo "Possible cause: apply-keeping job may not have created required IAM resources" >> "$ERROR_FILE"
  fi
  if grep -q "empty result.*SNS Topic" "$ERROR_FILE"; then
    echo "Dependency Issue: SNS Topic not found" >> "$ERROR_FILE"
    echo "Possible cause: apply-keeping job may not have created SNS resources" >> "$ERROR_FILE"
  fi
fi
