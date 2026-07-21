#!/bin/bash
set -e
 
BUCKET_NAME="lab-test-bucket-$(date +%s)"
REGION="ap-southeast-1"
 
echo "[+] Create Bucket"
aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION"
 
echo "lab test object" > /tmp/test-object.txt
echo "[+] PutObject"
aws s3 cp /tmp/test-object.txt "s3://$BUCKET_NAME/test-object.txt"
 
echo "[+] Download Object (Success)"
aws s3 cp "s3://$BUCKET_NAME/test-object.txt" /tmp/downloaded.txt
 
echo "[+] HeadObject"
aws s3api head-object \
    --bucket "$BUCKET_NAME" \
    --key test-object.txt
 
cat >/tmp/deny-policy.json <<JSONEOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Effect":"Deny",
      "Principal":"*",
      "Action":"s3:GetObject",
      "Resource":"arn:aws:s3:::$BUCKET_NAME/*"
    }
  ]
}
JSONEOF
 
echo "[+] PutBucketPolicy"
aws s3api put-bucket-policy \
    --bucket "$BUCKET_NAME" \
    --policy file:///tmp/deny-policy.json
 
echo "[+] Download Object (Expected AccessDenied)"
aws s3 cp "s3://$BUCKET_NAME/test-object.txt" /tmp/test2.txt || true
 
echo "[+] HeadObject (Expected AccessDenied)"
aws s3api head-object \
    --bucket "$BUCKET_NAME" \
    --key test-object.txt || true
 
echo "Done. Bucket: $BUCKET_NAME"
 
# Cleanup (run manually after analysis)
# aws s3api delete-bucket-policy --bucket "$BUCKET_NAME"
# aws s3 rm "s3://$BUCKET_NAME" --recursive
# aws s3api delete-bucket --bucket "$BUCKET_NAME" --region "$REGION"
