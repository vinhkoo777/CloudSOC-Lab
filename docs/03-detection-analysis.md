# 03 - Detection Analysis

## Mục đích

Phân tích các alert do Wazuh sinh ra tương ứng với 2 kịch bản đã mô phỏng ở [02-simulation.md](02-simulation.md), viết detection rule tùy chỉnh và đánh giá hiệu quả phát hiện.

> Hiện tại, log AWS đang được Wazuh nhận diện qua rule mặc định **`80200`** (rule chung cho mọi CloudTrail event). Mục tiêu của phần này là viết rule riêng, cụ thể hơn cho từng use case, thay vì chỉ dừng ở rule mặc định.

## Rule 1: IAM Privilege Escalation

**Mục tiêu:** Bắt các event `CreateUser`, `AttachUserPolicy` (đặc biệt với `AdministratorAccess`), `PutUserPolicy` - dấu hiệu tạo user/gán quyền cao bất thường.

```xml
<!-- Modify it at your will. -->
<group name="aws,iam,amazon">

  <rule id="111101" level="10">
    <if_sid>80200</if_sid>
    <field name="aws.eventName">PutUserPolicy</field>
    <description>AWS IAM - Inline policy attached to IAM user</description>
    <mitre>
      <id>T1098</id>
    </mitre>
  </rule>

  <rule id="111102" level="10">
    <if_sid>80200</if_sid>
    <field name="aws.eventName">AttachUserPolicy</field>
    <description>AWS IAM - Managed policy attached to IAM user</description>
    <mitre>
      <id>T1098</id>
    </mitre>
  </rule>

  <rule id="111103" level="10">
    <if_sid>80200</if_sid>
    <field name="aws.eventName">CreateUser</field>
    <description>AWS IAM - New IAM user created</description>
    <mitre>
      <id>T1136.003</id>
    </mitre>
  </rule>

</group>
```

- Bây giờ ta sẽ thực hiện lại **simulation** để kiểm tra rule trên đã viết đúng hay chưa. Như ảnh dưới, tất cả rule đã trigger.

<img width="1890" height="868" alt="image" src="https://github.com/user-attachments/assets/343ff485-0def-4e5e-88a1-cde97b286025" />

- Bây giờ, tôi tiến hành phân tích. Theo kịch bản, tài khoản admin đã bị chiếm quyền và attacker muốn tạo một tài khoản mới để duy trì sự hiện diện của mình trên hệ thống cloud. Kẻ tấn công đã sử dụng API **CreateUser**.

<img width="918" height="267" alt="image" src="https://github.com/user-attachments/assets/d8833d27-b0f1-4bde-a8c6-39842de789ac" />

- Kiểm tra trên AWS Console vào dịch vụ **IAM > IAM User**. Ảnh dưới cho thấy user mới được tạo sau khi chạy script.

<img width="937" height="107" alt="image" src="https://github.com/user-attachments/assets/90d968be-4900-49cd-b831-80a55b3df06b" />

- Phân tích tiếp: như ảnh dưới, user đã được gán policy.

<img width="952" height="165" alt="image" src="https://github.com/user-attachments/assets/2bbe7cb9-7ee4-4d33-8f3c-eca9a1702f4a" />

<img width="915" height="152" alt="image" src="https://github.com/user-attachments/assets/51f60f62-1705-4745-a631-eb67d240cc7f" />

- Vào lại dịch vụ **IAM**:

<img width="1518" height="431" alt="Screenshot 2026-07-21 104355" src="https://github.com/user-attachments/assets/06a19f16-84a0-4a9a-9cf0-242feae524d4" />

- Như trong ảnh, attacker gắn 2 policy: 1 cái là **AdministratorAccess** tương ứng với event **AttachUserPolicy**, và cái thứ 2 là **lab-escalation-policy-1784603631** tương ứng với event **PutUserPolicy**.

**Kết luận**

- Cả 3 rule đều trigger đúng, phản ánh chuỗi hành vi attacker: tạo user -> gắn quyền có sẵn (AdministratorAccess) -> mở rộng quyền qua inline policy. Đối chiếu AWS Console khớp hoàn toàn với log CloudTrail được tích hợp trong Wazuh - rule cho phép dựng lại toàn bộ chuỗi privilege escalation từ 3 alert liên tiếp.

## Rule 2: S3 Bucket Policy Tampering

**Mục tiêu:** Bắt hành vi thay đổi bucket policy nguy hiểm (`PutBucketPolicy` với `Effect: Deny`) và hệ quả thực tế của nó (`HeadObject` bị `AccessDenied`).

```xml
<group name="aws,s3,amazon">
  <rule id="211101" level="8">
    <if_sid>80200</if_sid>
    <field name="aws.eventName">HeadObject</field>
    <field name="aws.errorCode">AccessDenied</field>
    <description>AWS S3 - Attempted object access denied after bucket policy tampering</description>
  </rule>
  <rule id="211102" level="5">
    <if_sid>80200</if_sid>
    <field name="aws.eventName">CreateBucket</field>
    <description>AWS S3 - New bucket created</description>
  </rule>
  <rule id="211103" level="8">
    <if_sid>80200</if_sid>
    <field name="aws.eventName">PutBucketPolicy</field>
    <description>AWS S3 - Bucket policy tampered with Deny statement (possible access lockout)</description>
    <mitre>
      <id>T1562</id>
    </mitre>
  </rule>
</group>
```

> **Về MITRE mapping:** Chỉ rule `PutBucketPolicy` được gắn `T1562 - Impair Defenses`, vì đây đúng là hành vi thay đổi cấu hình bảo mật. Rule `CreateBucket` và `HeadObject` không gắn MITRE `CreateBucket` không khớp kỹ thuật nào trong MITRE Cloud Matrix (T1578 chỉ áp dụng cho compute resource, không áp dụng cho S3), còn `HeadObject (AccessDenied)` là một **request bị từ chối**, không phải truy cập thành công, nên không dùng T1530 (Data from Cloud Storage Object kỹ thuật mô tả việc *lấy được* dữ liệu).

**Kiểm chứng:**

- Chạy lại **simulation**.

<img width="330" height="17" alt="Screenshot 2026-07-21 160318" src="https://github.com/user-attachments/assets/7ff6dbde-9bde-4be4-b896-ef1b17ec6ca5" />

- Kiểm tra xem rule đã được kích hoạt đầy đủ chưa. Như hình dưới, cả 3 rule đều đã trigger.

<img width="1782" height="746" alt="image" src="https://github.com/user-attachments/assets/9acab480-73c1-4ae1-acdd-67b7b088b93f" />

**Phân tích từng event:**

**1. CreateBucket** Bucket mới được tạo.

<img width="551" height="207" alt="image" src="https://github.com/user-attachments/assets/6e07846c-aa4f-4535-b540-f6c83dbb8c1a" />

- Thao tác trên bucket tên `lab-test-bucket-1784623638`.

<img width="520" height="48" alt="image" src="https://github.com/user-attachments/assets/5d9b7240-3da2-45d0-a9b3-052bbaa45742" />

- Đối chiếu trên AWS Console để kiểm tra:

<img width="1512" height="265" alt="Screenshot 2026-07-21 160508" src="https://github.com/user-attachments/assets/aedec18f-27a1-457e-92ba-a513728ce630" />

**2. PutBucketPolicy** Bucket được gắn policy Deny `s3:GetObject` cho `Principal: *`. Bất thường vì bucket mới thường không cần Deny ngay, trừ khi có chủ đích khóa quyền truy cập hoặc che giấu hoạt động.

<img width="652" height="185" alt="image" src="https://github.com/user-attachments/assets/d0f64fc6-167f-4553-bb58-568391525452" />

**3. HeadObject (AccessDenied)** Sau khi policy Deny có hiệu lực, request `HeadObject` bị từ chối bằng chứng cho hệ quả thực tế của việc tamper policy.

<img width="407" height="260" alt="image" src="https://github.com/user-attachments/assets/e19efbaa-0f36-49bb-bd0f-9bfbe192a797" />

- Ta có thể đối chiếu trên AWS Console (S3 > bucket > Permissions) và xác nhận bucket policy đúng như log ghi nhận!. Ví dụ như này:

<img width="1436" height="522" alt="Screenshot 2026-07-21 145621" src="https://github.com/user-attachments/assets/966b7057-f017-4bbc-8419-d63a1e320e6a" />

**Kết luận:**

Cả 3 rule trigger đúng thứ tự: tạo bucket -> khóa quyền bằng Deny policy -> request bị chặn thực tế. Rule xác nhận được cả hành vi thay đổi cấu hình lẫn hệ quả thực tế của nó.
