#!/bin/bash
set -e

TEST_USER="lab-test-user-$(date +%s)"
POLICY_NAME="lab-escalation-policy-$(date +%s)"

aws iam create-user --user-name "$TEST_USER"
aws iam create-access-key --user-name "$TEST_USER" > "./output-${TEST_USER}-accesskey.json"

aws iam attach-user-policy \
  --user-name "$TEST_USER" \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

cat > /tmp/inline-policy.json << 'JSON'
{
  "Version": "2012-10-17",
  "Statement": [
    { "Effect": "Allow", "Action": "iam:*", "Resource": "*" }
  ]
}
JSON

aws iam put-user-policy \
  --user-name "$TEST_USER" \
  --policy-name "$POLICY_NAME" \
  --policy-document file:///tmp/inline-policy.json

echo "Done. User: $TEST_USER | Policy: $POLICY_NAME"

# Cleanup
# aws iam detach-user-policy --user-name "$TEST_USER" --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
# aws iam delete-user-policy --user-name "$TEST_USER" --policy-name "$POLICY_NAME"
# ACCESS_KEY_ID=$(grep AccessKeyId "./output-${TEST_USER}-accesskey.json" | head -1 | cut -d '"' -f4)
# aws iam delete-access-key --user-name "$TEST_USER" --access-key-id "$ACCESS_KEY_ID"
# aws iam delete-user --user-name "$TEST_USER"
