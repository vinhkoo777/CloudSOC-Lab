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

<img width="647" height="28" alt="image" src="https://github.com/user-attachments/assets/a92642a3-fa62-4935-9e97-7306d1b52497" />

## Kịch bản 2: S3 Bucket Policy Tampering
 
**Mô tả:** Mô phỏng hành vi tạo bucket, gắn policy Deny, sau đó thử truy cập object bị từ chối tương ứng kỹ thuật thay đổi bucket policy gây gián đoạn truy cập (MITRE T1562).
 
**Script:** [`simulate/s3-bucket-policy-tampering.sh`](../simulate/s3-bucket-policy-tampering.sh)
 
- Chạy script:
```
./simulate/s3-bucket-policy-tampering.sh
```
 
<img width="1053" height="45" alt="image" src="https://github.com/user-attachments/assets/d063b2b4-cbed-4894-a244-5b03ab4691ee" />

## Xác nhận log đã ghi nhận trên Wazuh
 
- Các sự kiện AWS đã được thu thập và hiển thị trong **Cloud Security -> Amazon Web Services**.
 
<img width="1905" height="308" alt="Wazuh AWS log verification" src="https://github.com/user-attachments/assets/53631b61-bac8-43c7-a84a-17a59086ea98" />

| Event | Mô tả |
| --- | --- |
| CreateUser | Tạo mới một IAM User. |
| AttachUserPolicy | Gán IAM Policy cho User. |
| PutUserPolicy | Thêm Inline Policy cho User. |
| ListUsers | Liệt kê danh sách IAM Users. |
| CreateBucket | Tạo mới S3 Bucket. |
| PutBucketPolicy | Cập nhật Bucket Policy trên S3 Bucket. |


