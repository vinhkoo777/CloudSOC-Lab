# AWS Cloud Security Monitoring Lab
> Make by K0g4 with love <3333

**Lab bảo mật cloud thực hành, mô phỏng các sự kiện lạm dụng IAM và truy cập S3 trái phép, phát hiện tự động bằng Wazuh SIEM trên AWS.**

## Mục Lục

- [Tổng quan](#tổng-quan)
- [Kiến trúc hệ thống](#kiến-trúc-hệ-thống)
- [Thiết lập môi trường](#thiết-lập-môi-trường)
- [Cấu trúc thư mục](#cấu-trúc-thư-mục)

## Tổng Quan

Lab mô phỏng môi trường giám sát bảo mật cloud của một tổ chức nhỏ trên AWS Free Tier, sử dụng CloudTrail để ghi log/phát hiện threat, đẩy về Wazuh SIEM tự triển khai để phân tích và cảnh báo.

**Mục tiêu thực hành:**

- Bật và cấu hình logging AWS CloudTrail
- Mô phỏng sự kiện lạm dụng IAM và truy cập S3 trái phép
- Thu thập, tương quan log bằng Wazuh
- Viết và tinh chỉnh detection rule tùy chỉnh
- Phân tích alert 

## Kiến Trúc Hệ Thống

<img width="3272" height="1684" alt="image" src="https://github.com/user-attachments/assets/b0ea3fdc-7ad1-42a2-91d0-aab0c3335f41" />

| Thành phần              | Vai trò                                      |
|-------------------------|----------------------------------------------|
| AWS CloudTrail          | Ghi lại toàn bộ AWS API calls. |
| Amazon S3              | Lưu trữ CloudTrail logs. |
| AWS Integration        | Thu thập CloudTrail logs từ S3.   |
| Detection Rules | Phát hiện các hành vi đáng ngờ. |
| Dashboard And Alerts     | Hiển thị và cảnh báo sự kiện bảo mật.|

## Thiết Lập Môi Trường

Hướng dẫn từng bước để tái tạo lab từ đầu:

| #   | Thành phần                                  | Hướng dẫn                                                       |
| --- | -------------------------------------------- | ---------------------------------------------------------------- |
| 1   | Bật CloudTrail                  | [docs/01-lab-setup.md](docs/01-lab-setup.md)                     |
| 2   | Mô phỏng tấn công (IAM abuse, S3 trái phép)  | [docs/02-simulation.md](docs/02-simulation.md)     |
| 3   | Phân tích detection và kết quả               | [docs/03-detection-analysis.md](docs/03-detection-analysis.md)   |

> **Lưu ý:** CloudTrail phải được bật **trước tiên** ở chế độ All Regions và trỏ về S3 bucket log trước khi cấu hình Wazuh AWS module.
