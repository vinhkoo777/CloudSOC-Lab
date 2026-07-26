# 02 - Simulation

## Mục đích

Mô phỏng các sự kiện bảo mật trên AWS (IAM privilege escalation, unauthorized S3 access) để sinh log/event thật trên CloudTrail. Log này sẽ được dùng làm input để viết và test detection rule ở bước [03-detection-analysis.md](03-detection-analysis.md).

> Ở đây tôi sẽ sử dụng một máy ảo riêng (đóng vai "attacker machine") để chạy các script mô phỏng, tách biệt với máy Wazuh nhằm mô phỏng đúng luồng thực tế: attacker hành động trên AWS -> CloudTrail ghi log -> S3 -> Wazuh phát hiện.

## Kịch bản 1: IAM Privilege Escalation

**Case:** Giả định admin bị **phishing**, lộ access key. Attacker dùng key đó tạo user mới, gắn `AdministratorAccess` và policy `iam:*` để duy trì persistence. MITRE T1078 - Valid Accounts.

**Script:** [`simulate/iam-privilege-escalation.sh`](../simulate/iam-privilege-escalation.sh)

- Chạy script:
```
./simulate/iam-privilege-escalation.sh
```

- Sau khi chạy xong sẽ có kết quả giống ở dưới 

<img width="652" height="52" alt="Screenshot 2026-07-20 184736" src="https://github.com/user-attachments/assets/5c2b2ff9-0155-4351-9516-18e3b6f54bab" />


## Kịch bản 2: S3 Bucket Policy Tampering
 
**Mô tả:** Mô phỏng hành vi tạo bucket, gắn policy Deny, sau đó thử truy cập object bị từ chối tương ứng kỹ thuật thay đổi bucket policy gây gián đoạn truy cập.
 
**Script:** [`simulate/s3-bucket-policy-tampering.sh`](../simulate/s3-bucket-policy-tampering.sh)
 
- Chạy script:
```
./simulate/s3-bucket-policy-tampering.sh
```

<img width="1053" height="45" alt="Screenshot 2026-07-21 102306" src="https://github.com/user-attachments/assets/95748bec-abe3-4c81-a6e7-195f7ff2db32" />

## Xác nhận log đã ghi nhận trên Wazuh
 
- Các sự kiện AWS đã được thu thập và hiển thị trong **Cloud Security -> Amazon Web Services**.
 
<img width="1882" height="876" alt="Screenshot 2026-07-20 190320" src="https://github.com/user-attachments/assets/ac539be0-782b-49ff-93e4-270a6e4bfbd8" />

| Event | Mô tả |
| --- | --- |
| CreateUser | Tạo mới một IAM User. |
| AttachUserPolicy | Gán IAM Policy cho User. |
| PutUserPolicy | Thêm Inline Policy cho User. |
| ListUsers | Liệt kê danh sách IAM Users. |
| CreateBucket | Tạo mới S3 Bucket. |
| PutBucketPolicy | Cập nhật Bucket Policy trên S3 Bucket. |


