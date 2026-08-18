# 02 - Simulation

## Mục đích

Mô phỏng các sự kiện bảo mật trên AWS để sinh CloudTrail event thật. Các event này sẽ được dùng để viết, test và phân tích detection rule ở bước [03-detection-analysis.md](03-detection-analysis.md).

> Ở đây ta sử dụng một máy ảo riêng đóng vai trò "attacker machine" để chạy script mô phỏng, tách biệt với máy Wazuh. Máy attacker chỉ tạo AWS activity, còn CloudTrail và Wazuh đảm nhiệm phần logging và monitoring.

## Kịch bản 1: IAM Persistence via Privileged Backdoor Account

**Case:** Giả định attacker đã có được access key của một privileged AWS identity. Attacker sử dụng quyền hiện có để tạo một IAM user mới, tạo access key cho user đó và gắn `AdministratorAccess`. Mục tiêu của scenario là mô phỏng hành vi tạo một privileged identity thứ hai để duy trì access.

**MITRE ATT&CK:**

- `T1078.004 - Valid Accounts: Cloud Accounts`: mô tả việc attacker sử dụng compromised cloud credential.
- `T1136.003 - Create Account: Cloud Account`: tương ứng với `CreateUser`.
- `T1098.001 - Additional Cloud Credentials`: tương ứng với `CreateAccessKey`.
- `T1098.003 - Additional Cloud Roles`: tương ứng với việc thêm permissions bằng `AttachUserPolicy`.

> **Lưu ý:** Scenario này được xem chủ yếu là persistence. Attacker đã có privileged access ngay từ đầu nên tôi không gọi chuỗi này là privilege escalation.

**Script:** [`simulate/iam-persistence.sh`](../simulate/iam-persistence.sh)

- Chạy script:

```bash
./simulate/iam-persistence.sh
```

## Kịch bản 2: S3 Bucket Policy Tampering

**Mô tả:** Mô phỏng hành vi tạo bucket và object, kiểm tra object đang truy cập được, sau đó áp dụng bucket policy có explicit `Deny` đối với `s3:GetObject` và kiểm tra kết quả truy cập sau khi policy có hiệu lực.

**Script:** [`simulate/s3-bucket-policy-tampering.sh`](../simulate/s3-bucket-policy-tampering.sh)

- Chạy script:

```bash
./simulate/s3-bucket-policy-tampering.sh
```

<img width="969" height="466" alt="image" src="https://github.com/user-attachments/assets/9484e0d5-45bb-4670-bac3-2a203c6f91dd" />

- Trong controlled simulation, script thực hiện các bước sau:

1. Tạo S3 bucket.
2. Upload `test-object.txt`.
3. Kiểm tra object trước khi thay đổi policy.
4. Gắn bucket policy có `Effect: Deny` cho action `s3:GetObject`.
5. Thực hiện lại `HeadObject` và ghi nhận `AccessDenied`.

> Ta không gắn MITRE ATT&CK technique cho `PutBucketPolicy` chỉ vì đây là một configuration change. MITRE mapping chỉ được sử dụng khi behavior trong lab khớp đủ rõ với technique.

## Xác nhận log đã ghi nhận trên Wazuh

- Các sự kiện AWS được thu thập và hiển thị trong **Cloud Security > Amazon Web Services**.

<img width="1882" height="876" alt="Screenshot 2026-07-20 190320" src="https://github.com/user-attachments/assets/ac539be0-782b-49ff-93e4-270a6e4bfbd8" />

| Event | Mô tả |
| --- | --- |
| CreateUser | Tạo mới một IAM User. |
| CreateAccessKey | Tạo access key cho IAM User. |
| AttachUserPolicy | Gán managed policy cho IAM User. |
| CreateBucket | Tạo mới S3 Bucket. |
| PutObject | Upload object lên S3 Bucket. |
| PutBucketPolicy | Cập nhật Bucket Policy. |
| HeadObject | Đọc metadata của object. |
| HeadObject + AccessDenied | Request đọc metadata bị từ chối. |

> Một API event xuất hiện trong CloudTrail không có nghĩa event đó chắc chắn malicious. Khi phân tích cần xem thêm actor identity, source IP, resource, thời gian và các event liên quan.
