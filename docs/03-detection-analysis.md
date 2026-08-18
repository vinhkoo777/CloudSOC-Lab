# 03 - Detection Analysis

## Mục đích

Phân tích các alert do Wazuh sinh ra tương ứng với 2 kịch bản đã mô phỏng ở [02-simulation.md](02-simulation.md), viết detection rule tùy chỉnh và đánh giá hiệu quả phát hiện.

> Log AWS trong lab được Wazuh decode và xử lý bằng AWS ruleset. Custom rule bên dưới sử dụng rule `80200` làm parent để tạo detection cụ thể cho từng event cần theo dõi.

## Rule 1: IAM Persistence via Privileged Backdoor Account

**Mục tiêu:** Phát hiện các event `CreateUser`, `CreateAccessKey` và `AttachUserPolicy` xuất hiện trong scenario tạo một privileged IAM identity thứ hai.

```xml
<!-- Modify it at your will. -->
<group name="aws,iam,amazon,">

  <rule id="111101" level="7">
    <if_sid>80200</if_sid>
    <field name="aws.eventName">^CreateUser$</field>
    <description>AWS IAM - New IAM user created</description>
    <mitre>
      <id>T1136.003</id>
    </mitre>
  </rule>

  <rule id="111102" level="9">
    <if_sid>80200</if_sid>
    <field name="aws.eventName">^CreateAccessKey$</field>
    <description>AWS IAM - Access key created for IAM user</description>
    <mitre>
      <id>T1098.001</id>
    </mitre>
  </rule>

  <rule id="111103" level="8">
    <if_sid>80200</if_sid>
    <field name="aws.eventName">^AttachUserPolicy$</field>
    <description>AWS IAM - Managed policy attached to IAM user</description>
    <mitre>
      <id>T1098.003</id>
    </mitre>
  </rule>

</group>
```

> Rule `111103` chỉ xác nhận có `AttachUserPolicy`. Rule này không tự khẳng định policy được gắn là `AdministratorAccess`. Trong simulation tôi kiểm tra thêm `requestParameters` trong CloudTrail event và đối chiếu AWS Console để xác nhận policy cụ thể.

- Bây giờ ta thực hiện lại **simulation** để kiểm tra các custom rule.

<img width="961" height="500" alt="image" src="https://github.com/user-attachments/assets/a82d6736-7e4f-4560-9c67-283667fa140e" />

<img width="1907" height="632" alt="image" src="https://github.com/user-attachments/assets/42127e57-5405-46d4-b462-936bfc87305e" />

### Phân tích từng event

**1. CreateUser**

- Theo scenario, attacker đang sử dụng credential của một privileged AWS identity và tạo một IAM user mới.

<img width="453" height="239" alt="image" src="https://github.com/user-attachments/assets/80176e19-3a8c-426b-adb1-b6465b01d937" />

- Kiểm tra trên AWS Console tại **IAM > Users**. Ảnh dưới cho thấy user mới được tạo sau khi chạy script.

<img width="1619" height="590" alt="image" src="https://github.com/user-attachments/assets/9a6aa0c3-9647-44b5-a781-a6fc736305f1" />

- Event này được mapping với `T1136.003 - Create Account: Cloud Account`.
- Tuy nhiên, `CreateUser` tự nó chưa đủ để kết luận malicious vì administrator có thể tạo IAM user hợp lệ trong hoạt động bình thường.

**2. CreateAccessKey**

<img width="551" height="446" alt="image" src="https://github.com/user-attachments/assets/0303fc55-927b-4489-abab-5a0cc0923110" />

- Sau khi user được tạo, script tạo access key cho user đó. Đây là programmatic credential có thể được sử dụng để truy cập AWS API.
- Event này được mapping với `T1098.001 - Additional Cloud Credentials`.
- Khi điều tra thực tế cần kiểm tra user nào được tạo key, principal nào thực hiện action, source IP và thời điểm xảy ra event.

**3. AttachUserPolicy**

<img width="596" height="106" alt="image" src="https://github.com/user-attachments/assets/4e64bb0a-ca6a-4122-a9ce-1a809c7ad0e3" />

- Tiếp theo, simulation gắn managed policy vào IAM user mới.
- Trong controlled simulation, policy được gắn là **AdministratorAccess**.
- Event `AttachUserPolicy` được mapping với `T1098.003 - Additional Cloud Roles` vì attacker đang thêm permissions cho cloud account do mình tạo.

### Kết luận

Ba event cung cấp đủ context để analyst reconstruct lại activity theo thứ tự thời gian:

1. Một IAM user mới được tạo.
2. User mới được tạo access key.
3. User mới được gắn `AdministratorAccess`.

Các custom rule hiện tại là **event-level detection**. Project chưa triển khai một Wazuh sequence correlation rule cho cả ba event. Việc liên kết ba alert được thực hiện trong quá trình investigation bằng cách so sánh `eventTime`, actor identity, target user, source IP và `requestParameters`.

### Detection Limitations

- `CreateUser` có thể là hoạt động administration hợp lệ.
- `CreateAccessKey` có thể được tạo cho một IAM user hợp lệ cần programmatic access.
- `AttachUserPolicy` không phải lúc nào cũng nguy hiểm. Ví dụ `ReadOnlyAccess` và `AdministratorAccess` có mức risk khác nhau.
- Rule hiện tại chưa tự động kiểm tra policy ARN để nâng severity cho high-privilege policy.
- Rule hiện tại chưa correlation các event trong một time window.

**Hướng cải thiện:**

- Kiểm tra `policyArn` và nâng severity khi gắn high-privilege policy.
- Correlation `CreateUser`, `CreateAccessKey` và high-privilege policy trong một khoảng thời gian ngắn.
- Baseline các IAM administrator và automation identity hợp lệ.
- Kiểm tra source IP, user agent và thời gian hoạt động bất thường.

## Rule 2: S3 Bucket Policy Tampering

**Mục tiêu:** Phát hiện `PutBucketPolicy` và ghi nhận `HeadObject` bị `AccessDenied` sau khi bucket policy được thay đổi trong controlled simulation.

```xml
<group name="aws,s3,amazon,">

  <rule id="112101" level="7">
    <if_sid>80200</if_sid>
    <field name="aws.eventName">^HeadObject$</field>
    <field name="aws.errorCode">^AccessDenied$</field>
    <description>AWS S3 - HeadObject request denied</description>
  </rule>

  <rule id="112102" level="5">
    <if_sid>80200</if_sid>
    <field name="aws.eventName">^CreateBucket$</field>
    <description>AWS S3 - New bucket created</description>
  </rule>

  <rule id="112103" level="7">
    <if_sid>80200</if_sid>
    <field name="aws.eventName">^PutBucketPolicy$</field>
    <description>AWS S3 - Bucket policy modified</description>
  </rule>

</group>
```

> Rule `112103` chỉ xác nhận bucket policy đã được thay đổi. Rule không tự chứng minh policy có `Effect: Deny`. Trong controlled simulation tôi biết nội dung policy vì chính script tạo policy đó. Khi investigation thực tế phải kiểm tra policy document hoặc cấu hình bucket hiện tại.

> Tôi không gắn MITRE ATT&CK technique cho `PutBucketPolicy`, `CreateBucket` hoặc `HeadObject + AccessDenied` vì các event trong scenario này không có mapping đủ chính xác để gắn technique chỉ dựa trên event name.

### Kiểm chứng

- Chạy lại **simulation**.

<img width="330" height="17" alt="Screenshot 2026-07-21 160318" src="https://github.com/user-attachments/assets/7ff6dbde-9bde-4be4-b896-ef1b17ec6ca5" />

- Kiểm tra custom rule trên Wazuh. Trong simulation cả 3 event đã được ghi nhận.

<img width="1782" height="746" alt="image" src="https://github.com/user-attachments/assets/9acab480-73c1-4ae1-acdd-67b7b088b93f" />

### Phân tích từng event

**1. CreateBucket**

- Bucket mới được tạo trong quá trình chuẩn bị scenario.

<img width="551" height="207" alt="image" src="https://github.com/user-attachments/assets/6e07846c-aa4f-4535-b540-f6c83dbb8c1a" />

- Thao tác được thực hiện trên bucket `lab-test-bucket-1784623638`.

<img width="520" height="48" alt="image" src="https://github.com/user-attachments/assets/5d9b7240-3da2-45d0-a9b3-052bbaa45742" />

- Đối chiếu trên AWS Console:

<img width="1512" height="265" alt="Screenshot 2026-07-21 160508" src="https://github.com/user-attachments/assets/aedec18f-27a1-457e-92ba-a513728ce630" />

- `CreateBucket` chỉ cung cấp context cho scenario. Việc tạo bucket tự nó không phải security finding vì bucket có thể được tạo hợp lệ bởi administrator, Terraform, CloudFormation hoặc application automation.

**2. PutBucketPolicy**

- Simulation sử dụng `PutBucketPolicy` để áp dụng policy có explicit `Deny` cho `s3:GetObject`.

<img width="652" height="185" alt="image" src="https://github.com/user-attachments/assets/d0f64fc6-167f-4553-bb58-568391525452" />

- Custom rule chỉ phát hiện việc bucket policy bị thay đổi. Để xác định policy có nguy hiểm hay không cần xem thêm policy document, actor identity, source IP, bucket name và context của thay đổi.

**3. HeadObject (AccessDenied)**

- Sau khi policy được áp dụng, simulation thực hiện `HeadObject` và request bị từ chối.

<img width="407" height="260" alt="image" src="https://github.com/user-attachments/assets/e19efbaa-0f36-49bb-bd0f-9bfbe192a797" />

- Đối chiếu trên AWS Console tại **S3 > bucket > Permissions** để xác nhận bucket policy đang được áp dụng.

<img width="1436" height="522" alt="Screenshot 2026-07-21 145621" src="https://github.com/user-attachments/assets/966b7057-f017-4bbc-8419-d63a1e320e6a" />

- `HeadObject + AccessDenied` không tự chứng minh bucket policy tampering. `AccessDenied` còn có thể liên quan tới IAM policy, bucket policy, Service Control Policy, permissions boundary hoặc encryption permissions. Trong lab event này có ý nghĩa vì ta biết chính xác configuration change vừa được simulation thực hiện.

### Kết luận

Controlled simulation cho thấy ba event chính xuất hiện theo đúng quá trình test:

1. Bucket được tạo.
2. Bucket policy được thay đổi.
3. `HeadObject` bị từ chối sau khi policy đã có hiệu lực.

Custom rules hiện tại giúp phát hiện từng event và hỗ trợ analyst investigation. Chúng chưa phải correlation rule và không tự chứng minh quan hệ nhân quả giữa `PutBucketPolicy` và `AccessDenied`.

### Detection Limitations

- `PutBucketPolicy` có thể là thay đổi hợp lệ.
- Rule hiện tại chưa inspect nội dung policy để xác định `Allow`, `Deny`, `Principal` hoặc resource cụ thể.
- `HeadObject + AccessDenied` có nhiều nguyên nhân khác nhau.
- Chưa có baseline cho các administrator hoặc automation identity thường xuyên thay đổi S3 configuration.

**Hướng cải thiện:**

- Parse và kiểm tra policy content nếu telemetry thực tế expose đầy đủ field cần thiết.
- Nâng severity khi policy có thay đổi ảnh hưởng lớn tới access control.
- Correlation configuration change với access failure trong một time window.
- Baseline actor identity và source IP hợp lệ.
