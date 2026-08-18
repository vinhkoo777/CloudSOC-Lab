#!/bin/bash
set -euo pipefail

TEST_USER="lab-test-user-$(date +%s)"

echo "[+] Creating IAM user: $TEST_USER"
aws iam create-user --user-name "$TEST_USER"

echo "[+] Creating access key"
ACCESS_KEY_ID=$(aws iam create-access-key \
  --user-name "$TEST_USER" \
  --query 'AccessKey.AccessKeyId' \
  --output text)

echo "[+] Access key created: $ACCESS_KEY_ID"
echo "[+] Secret access key is not written to a local file"

echo "[+] Attaching AdministratorAccess"
aws iam attach-user-policy \
  --user-name "$TEST_USER" \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

echo
echo "Done. User: $TEST_USER"
echo "Expected CloudTrail events:"
echo "  CreateUser"
echo "  CreateAccessKey"
echo "  AttachUserPolicy"

# Cleanup (run manually after analysis)
# aws iam detach-user-policy \
#   --user-name "$TEST_USER" \
#   --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
#
# ACCESS_KEY_ID=$(aws iam list-access-keys \
#   --user-name "$TEST_USER" \
#   --query 'AccessKeyMetadata[0].AccessKeyId' \
#   --output text)
#
# aws iam delete-access-key \
#   --user-name "$TEST_USER" \
#   --access-key-id "$ACCESS_KEY_ID"
#
# aws iam delete-user --user-name "$TEST_USER"
