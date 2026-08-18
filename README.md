# AWS Cloud Security Monitoring Lab
> Made by K0g4 with love <3333

**Lab bảo mật cloud thực hành, mô phỏng các sự kiện IAM persistence và S3 bucket policy tampering, thu thập CloudTrail log và phát hiện bằng Wazuh SIEM.**

## Mục Lục

- [Tổng quan](#tổng-quan)
- [Kiến trúc hệ thống](#kiến-trúc-hệ-thống)
- [Detection Scenario](#detection-scenario)
- [Thiết lập môi trường](#thiết-lập-môi-trường)

## Tổng Quan

Lab mô phỏng một môi trường giám sát bảo mật cloud trên AWS. CloudTrail được sử dụng để ghi nhận AWS account activity theo cấu hình của trail, log được lưu trên Amazon S3 và Wazuh thu thập các log này để phân tích, tạo alert và hỗ trợ investigation.

**Mục tiêu thực hành:**

- Bật và cấu hình AWS CloudTrail.
- Lưu CloudTrail log trên Amazon S3.
- Thu thập CloudTrail log bằng Wazuh AWS Integration.
- Mô phỏng IAM persistence và S3 bucket policy tampering.
- Viết và tinh chỉnh detection rule tùy chỉnh.
- Mapping các hành vi phù hợp với MITRE ATT&CK.
- Phân tích alert và đối chiếu với AWS Console.
- Đánh giá limitation và false positive của detection rule.

## Kiến Trúc Hệ Thống

<img width="3276" height="1688" alt="image" src="https://github.com/user-attachments/assets/0c768938-655c-46dc-b4e9-094249938760" />

| Thành phần | Vai trò |
| --- | --- |
| AWS CloudTrail | Ghi nhận AWS account activity theo cấu hình của trail. |
| Amazon S3 | Lưu trữ CloudTrail logs. |
| Wazuh AWS Integration | Thu thập CloudTrail logs từ S3. |
| Detection Rules | Phát hiện các event cần điều tra. |
| Dashboard And Alerts | Hiển thị alert và hỗ trợ quá trình investigation. |

## Detection Scenario

### Scenario 1: IAM Persistence via Privileged Backdoor Account

Giả định attacker đã có được credential của một privileged AWS identity. Attacker sử dụng quyền hiện có để tạo một IAM user mới, tạo access key cho user đó và gắn `AdministratorAccess` nhằm tạo thêm một privileged identity có credential riêng.

Các event chính:

1. `CreateUser`
2. `CreateAccessKey`
3. `AttachUserPolicy`

MITRE ATT&CK mapping:

| Event / Behavior | MITRE ATT&CK |
| --- | --- |
| Sử dụng compromised cloud credential | T1078.004 - Valid Accounts: Cloud Accounts |
| CreateUser | T1136.003 - Create Account: Cloud Account |
| CreateAccessKey | T1098.001 - Additional Cloud Credentials |
| AttachUserPolicy | T1098.003 - Additional Cloud Roles |

> **Lưu ý:** Việc credential ban đầu bị compromise là giả định của scenario. Lab không mô phỏng hoặc detect bước phishing/credential theft.

### Scenario 2: S3 Bucket Policy Tampering

Scenario tạo một S3 bucket và test object, sau đó thay đổi bucket policy bằng explicit `Deny` đối với `s3:GetObject`. Sau khi policy được áp dụng, request `HeadObject` tới object bị từ chối.

Các event chính:

1. `CreateBucket`
2. `PutObject`
3. `HeadObject`
4. `PutBucketPolicy`
5. `HeadObject` với `AccessDenied`

Scenario này tập trung vào configuration monitoring và investigation và tui không gắn MITRE ATT&CK technique nếu event không có mapping đủ chính xác.

## Thiết Lập Môi Trường

Hướng dẫn từng bước để tái tạo lab từ đầu:

| # | Thành phần | Hướng dẫn |
| --- | --- | --- |
| 1 | Bật CloudTrail và kết nối Wazuh | [docs/01-lab-setup.md](docs/01-lab-setup.md) |
| 2 | Mô phỏng IAM persistence và S3 policy tampering | [docs/02-simulation.md](docs/02-simulation.md) |
| 3 | Phân tích detection và kết quả | [docs/03-detection-analysis.md](docs/03-detection-analysis.md) |
