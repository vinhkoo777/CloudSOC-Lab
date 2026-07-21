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

- Bây giờ ta sẽ thực hiện lại **simulation** liệu rule trên đã viết đúng hay chưa. Thì như ảnh dưới tất cả các rule đã triggered.

<img width="647" height="28" alt="image" src="https://github.com/user-attachments/assets/a92642a3-fa62-4935-9e97-7306d1b52497" />
<img width="1904" height="870" alt="image" src="https://github.com/user-attachments/assets/c210f2bb-65f9-4034-9abc-a80bc400f77d" />

- Bây giờ tôi sẽ tiến hành phân tích. Thì như trong case là tài khoản admin đã bị chiếm quyền và bây giờ attacker đang muốn tạo một tài khoản mới để duyu trì sự hiện diện của mình trên hệ thống cloud. Và kẻ tấn công đã sử dụng api **CreateUser**

<img width="930" height="277" alt="image" src="https://github.com/user-attachments/assets/b7589826-05e9-49d5-9c08-4f54248ff66c" />

- Tên user được tạo trong log

<img width="596" height="81" alt="image" src="https://github.com/user-attachments/assets/2acc6fca-e08d-4936-a000-da4aede5b77a" />

- Ta tiến hành kiểm tra trên AWS console manager. Vào dịch dụ **IAM** và **IAM User**. Và ảnh dưới cho ta thấy tên của user mới được tạo sau khi thực hiện script trên. 

<img width="1907" height="212" alt="image" src="https://github.com/user-attachments/assets/61d326d1-4fa0-47f6-b862-d99c7f1bb91b" />

- Ta phân tích tiếp. Thì như ảnh dưới thì user đã được gán policy vào ta tiến hành kiểm tra tiếp 

<img width="932" height="161" alt="image" src="https://github.com/user-attachments/assets/d7faa27c-98c5-4571-9cbf-31d2fa003e67" />
<img width="911" height="150" alt="image" src="https://github.com/user-attachments/assets/1aceb8e2-75c2-4097-9bd7-6e4111e870cd" />

- Cả 2 log trên điều thao tác trên user.

<img width="593" height="82" alt="image" src="https://github.com/user-attachments/assets/a8378b4c-00fa-4db8-8c89-96d053e7487a" />

- Ta vào lại dịch vụ **IAM**

<img width="1517" height="431" alt="image" src="https://github.com/user-attachments/assets/4c7ca0b3-5af3-453e-beea-18b65e389ebb" />

- Thì như ta thấy như trong ảnh attacker gắn 2 policy 1 cái là **AdministratorAccess** tương ứng là **PutUserPolicy** và cái thứ 2 là **lab-escalation-policy-1784603631** tương ứng với **AttachUserPolicy**

**Kết luận**

- Cả 3 rule đều trigger đúng, phản ánh chuỗi hành vi attacker: tạo user -> gắn quyền có sẵn (AdministratorAccess) -> mở rộng quyền qua inline policy. Đối chiếu AWS Console khớp hoàn toàn với log Cloudtrail được tích hợp trong Wazuh - rule cho phép dựng lại toàn bộ chuỗi privilege escalation từ 3 alert liên tiếp.

## Rule 2: S3 Bucket Policy Tampering
 
**Mục tiêu:** Bắt hành vi thay đổi bucket policy nguy hiểm (`PutBucketPolicy` với `Effect: Deny`) và hệ quả thực tế của nó (`HeadObject` bị `AccessDenied`).
 
```xml
<group name="aws,s3,amazon">
  <rule id="211101" level="8">
    <if_sid>80200</if_sid>
    <field name="aws.eventName">HeadObject</field>
    <field name="aws.errorCode">AccessDenied</field>
    <description>AWS S3 - Access denied after bucket policy tampering</description>
    <mitre>
      <id>T1530</id>
    </mitre>
  </rule>
  <rule id="211102" level="5">
    <if_sid>80200</if_sid>
    <field name="aws.eventName">CreateBucket</field>
    <description>AWS S3 - New bucket created</description>
    <mitre>
      <id>T1578</id>
    </mitre>
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
 
**Kiểm chứng:**
 
- Chạy lại **simulation**.

<img width="330" height="17" alt="image" src="https://github.com/user-attachments/assets/84d51caf-b05d-4ac4-8e9e-0600a1e1d7a9" />

- Kiểm tra xem rule đã được kích hoạt đầy đủ chưa. Như hình dưới, cả 3 rule đều đã trigger.

<img width="1913" height="755" alt="image" src="https://github.com/user-attachments/assets/fd924d66-77d4-49df-8267-3dd3aea6ca20" />

**Phân tích từng event:**
 
**1. CreateBucket** Bucket mới được tạo.
 
<img width="642" height="187" alt="image" src="https://github.com/user-attachments/assets/fb5367f8-622f-4ae2-aefe-508261ea7144" />

- Thao tác trên bucket tên `lab-test-bucket-1784623638`.
  
<img width="522" height="57" alt="image" src="https://github.com/user-attachments/assets/5a445062-3b69-41cc-a4f6-d6bda986f2ce" />

- Đối chiếu trên AWS Console để kiểm tra:
  
<img width="1512" height="265" alt="image" src="https://github.com/user-attachments/assets/7748d20a-a7e9-4a78-8cc8-311050133212" />

**2. PutBucketPolicy** Bucket được gắn policy Deny `s3:GetObject` cho `Principal: *`. Bất thường vì bucket mới thường không cần Deny ngay, trừ khi có chủ đích khóa quyền truy cập hoặc che giấu hoạt động.
 
<img width="656" height="188" alt="image" src="https://github.com/user-attachments/assets/b2a43205-2b52-4aaf-80fe-a98686218638" />

**3. HeadObject (AccessDenied)** Sau khi policy Deny có hiệu lực, request `HeadObject` bị từ chối bằng chứng cho hệ quả thực tế của việc tamper policy.
 
<img width="424" height="257" alt="image" src="https://github.com/user-attachments/assets/5a12cf57-5dc2-4f0a-b288-4d00dae64345" />

- Đối chiếu trên AWS Console (S3 > bucket > Permissions) xác nhận bucket policy đúng như log ghi nhận:

<img width="1436" height="522" alt="image" src="https://github.com/user-attachments/assets/9ff29261-5310-4943-9d55-7eb6943732f0" />

**Kết luận:**
 
Cả 3 rule trigger đúng thứ tự: tạo bucket → khóa quyền bằng Deny policy -> request bị chặn thực tế. Rule xác nhận được cả hành vi thay đổi cấu hình lẫn hệ quả thực tế của nó.


