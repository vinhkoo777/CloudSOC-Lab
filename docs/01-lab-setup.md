# 01 - Lab Setup
> Một vài lưu ý trước khi thực hiện là ta nên xem bảng giá từng dịch vụ và khi làm xong lab phải xóa hết tất cả mọi thứ nếu không ta sẽ không muốn mất credit đâu =))

## Chuẩn bị AWS account

### Tạo/dùng AWS Free Tier account

- Trước hết, cần chuẩn bị một tài khoản AWS Free Tier ở đây tôi đã chuẩn bị sẵn. Bạn có thể tạo tài khoản [tại đây](https://aws.amazon.com/console/).

<img width="1908" height="962" alt="image" src="https://github.com/user-attachments/assets/a29d9b00-6b62-4b7d-8905-aded0ccdb82e" />

- Sau khi tạo tài khoản, bạn sẽ được AWS cấp 100$ credit. Sau đó, bạn nên hoàn thành các nhiệm vụ được gợi ý để nhận thêm 100$ nữa, tổng cộng ta sẽ có 200$ credit.
- Dưới đây là giao diện Home Console của AWS:

<img width="1908" height="822" alt="image" src="https://github.com/user-attachments/assets/1a7b849a-1a8e-47c5-aa2a-90d77d51af91" />

### Bật Billing Alert / Budget alarm

- Tiếp theo, ta sẽ bật **Billing Alert / Budget alarm**. Mục đích là khi chi phí sử dụng vượt qua ngưỡng đã cấu hình từ trước, AWS sẽ gửi email thông báo.

- Đầu tiên, tìm kiếm dịch vụ **Billing and Cost Management** trên thanh tìm kiếm rồi nhấn vào.

<img width="1195" height="868" alt="image" src="https://github.com/user-attachments/assets/dfaa6dc8-441f-4e69-889e-06ddd26bc922" />

- Tiếp đó, ở thanh menu bên trái, chọn **Budgets**.

<img width="1910" height="874" alt="image" src="https://github.com/user-attachments/assets/96ce9511-b3e6-4ddb-8417-c867ea358625" />

- Chọn **Create budget**.

<img width="1902" height="820" alt="image" src="https://github.com/user-attachments/assets/b36c8afd-1bc6-4549-86d3-e1abb303517c" />

- Cấu hình các thiết lập như hình dưới.

<img width="1904" height="870" alt="image" src="https://github.com/user-attachments/assets/0b21d475-b6ed-4271-8820-dbecf07de028" />

- Ở đây tôi dùng Template có sẵn cho đơn giản, và muốn nhận thông báo mỗi tháng một lần.

<img width="1887" height="807" alt="image" src="https://github.com/user-attachments/assets/6d165fb9-106c-4f7a-9669-b56f21aebb7d" />

- Tiếp theo, đặt tên cho budget và nhập email sẽ nhận thông báo. Tôi đặt ngân sách dự kiến là không quá 20$ mỗi tháng.

- Sau khi tạo xong, vào lại budget vừa tạo.

<img width="1911" height="871" alt="image" src="https://github.com/user-attachments/assets/41b4bf1d-9c18-4347-8e20-b373208d317b" />

- Bây giờ ta sẽ tạo thêm alert. Kéo xuống và chọn tab **Alert**.

<img width="1901" height="836" alt="image" src="https://github.com/user-attachments/assets/75868b36-a66c-475f-8c96-caf9b413f41d" />

- Ở đây tôi đã tạo sẵn.

<img width="1886" height="835" alt="image" src="https://github.com/user-attachments/assets/475957bc-05d7-43a4-af01-1824fd5f3abb" />

- Nếu muốn tạo thêm, nhấn vào **Edit alert**.

<img width="1868" height="779" alt="image" src="https://github.com/user-attachments/assets/3557ecaf-88ae-4117-8b14-68e4cb32eb0b" />

- Ở đây, nhấn vào **Add alert threshold**.

<img width="1893" height="735" alt="image" src="https://github.com/user-attachments/assets/0ebc7d5d-58cb-4a45-81f0-04806eb66499" />

- Ví dụ trong hình dưới, tôi đặt ngưỡng để alert này kích hoạt khi chi phí thực tế vượt quá 100% ngân sách (tức trên 20$), và gửi thông báo đến email đã cung cấp.

<img width="1130" height="783" alt="image" src="https://github.com/user-attachments/assets/8f62d653-f19b-432f-959d-7ec5d2048a69" />

- Tiếp đó, nhấn **Next** để chuyển sang bước tiếp theo.

<img width="913" height="685" alt="image" src="https://github.com/user-attachments/assets/cb62744c-2cf0-42cf-9159-d79265a18b5f" />

- Ở bước **Attach actions**, đây là bước tùy chọn nên tôi để mặc định và chuyển sang bước tiếp theo.

<img width="1892" height="840" alt="image" src="https://github.com/user-attachments/assets/f53051ba-efb5-4ce7-ab78-5f98540b2bb9" />

- Ở bước cuối cùng, review lại toàn bộ cấu hình. Khi thấy ổn, nhấn **Save** để lưu lại.

<img width="1919" height="770" alt="image" src="https://github.com/user-attachments/assets/f5b61979-18e6-46c7-bb49-b866e10251a2" />

### Tạo IAM user cho Wazuh collector

- Trong lab này tôi tạo một IAM user riêng để Wazuh đọc CloudTrail log từ S3. User này được dùng như **collector identity**, không dùng chung với attacker machine hoặc tài khoản quản trị.
- AWS hiện khuyến nghị human user sử dụng federation/IAM Identity Center và temporary credentials. Việc sử dụng IAM user với long-lived access key ở đây là lựa chọn đơn giản cho môi trường lab local.
- Đầu tiên, tìm kiếm dịch vụ **IAM** trên thanh tìm kiếm.

<img width="1147" height="866" alt="image" src="https://github.com/user-attachments/assets/3e8ec7f0-9aae-4ac9-9e52-4cd9928fb613" />

- Tiếp đó, vào **IAM user** ở menu bên trái. (Trước khi tạo user mới, nên tạo **Account Alias**.)

<img width="336" height="775" alt="image" src="https://github.com/user-attachments/assets/90b60cb7-d50a-406b-a6cc-63765bdcdc9f" />

- Nhấn vào nút **Create User**.

<img width="1906" height="194" alt="image" src="https://github.com/user-attachments/assets/440ac34f-81b0-4977-b182-a694d3a39efa" />

- Như hình dưới, cần cung cấp **Username**. Trong lúc dựng lab tôi có bật **Provide user access to the AWS Management Console** để tiện kiểm tra cấu hình bằng giao diện web. Tuy nhiên, một collector identity chỉ dùng cho Wazuh đọc log không bắt buộc phải có console password. Trong production nên chỉ cấp đúng loại credential thực sự cần thiết. Sau đó nhấn **Next** để tiếp tục.

<img width="1885" height="845" alt="image" src="https://github.com/user-attachments/assets/ebe96ba2-08ca-43f2-844b-df72ec9fe057" />

- Tại đây ta sẽ để mặc định trước và chưa cấu hình gì ở bước này hết.

<img width="1908" height="799" alt="image" src="https://github.com/user-attachments/assets/c1f16205-64c3-4e21-98e7-ae6a700738e4" />

- Nhấn **Create user**.

<img width="1900" height="838" alt="image" src="https://github.com/user-attachments/assets/c8cb49f9-227e-47a9-aa0e-516f4bc919e4" />

- Sau khi tạo user xong, nên thiết lập thêm xác thực 2 lớp (MFA).

<img width="525" height="192" alt="image" src="https://github.com/user-attachments/assets/8bd4c01d-fa6b-45a8-9bea-34327765d8f4" />

- Hình dưới là kết quả sau khi thêm MFA thành công.

<img width="530" height="216" alt="image" src="https://github.com/user-attachments/assets/53ff1055-1522-44f3-994f-1573e6ab222e" />

- Bây giờ tôi sẽ cấp quyền tối thiểu để collector đọc CloudTrail log trong S3. Hai action chính cần dùng trong lab là **s3:GetObject** và **s3:ListBucket**.
- Không cấp `AdministratorAccess`, `s3:PutObject` hoặc `s3:DeleteObject` cho collector vì các quyền đó không cần thiết cho việc đọc log.
- Dưới đây là đoạn policy:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "GetS3Logs",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::<bucket_cua_ban>/*",
                "arn:aws:s3:::<bucket_cua_ban>"
            ]
        }
    ]
}
```

- Đầu tiên ta vào **IAM user** trong dịch vụ **IAM**

<img width="282" height="645" alt="image" src="https://github.com/user-attachments/assets/4a53af36-a4c3-413b-9e71-91c87fa75277" />

- Tiếp theo chọn user vừa tạo, kéo xuống mục **Add permissions** và chọn **Create inline policy**.

<img width="1401" height="357" alt="image" src="https://github.com/user-attachments/assets/337a72b6-c904-4b28-8ae0-77ab5d008a07" />

- Chuyển sang tab **JSON** và nhập policy ở trên. Thay **<bucket_cua_ban>** bằng tên bucket dùng để lưu CloudTrail log.

<img width="1377" height="542" alt="image" src="https://github.com/user-attachments/assets/0b05fc17-03a1-4d71-9e7b-f91e62ea5edc" />

**- Ví dụ như này.**

<img width="1396" height="535" alt="image" src="https://github.com/user-attachments/assets/7645262f-6818-4a79-a95b-97221d2fa889" />

- Ta kéo xuống nhấn **Next** để tiếp tục.

<img width="1332" height="295" alt="image" src="https://github.com/user-attachments/assets/b3742a01-9cd2-412f-918b-f18a38615f48" />

- Sau khi đặt tên policy, nhấn **Create policy**.

<img width="1377" height="532" alt="image" src="https://github.com/user-attachments/assets/20f831cc-8fc3-4d49-9efc-8f17368acf7d" />

- Hình dưới thì ta đã tạo thành công.

<img width="1402" height="540" alt="image" src="https://github.com/user-attachments/assets/ca37a7bc-d519-4e87-976e-1b7ba9bed033" />

## Bật CloudTrail

### Tạo Trail mới, log vào S3 bucket riêng

- Trước hết ta sẽ cần tạo S3 bucket. Đầu tiên ta lên thanh search tìm kiếm dịch vụ **S3**

<img width="1151" height="855" alt="image" src="https://github.com/user-attachments/assets/c8a0fb9c-52c7-4cad-b90c-c10c52e44dd8" />

- Tiếp theo đó ta sẽ ấn vào **Create Bucket**

<img width="1407" height="247" alt="image" src="https://github.com/user-attachments/assets/76265878-4948-4d86-880b-668d11d01378" />

- Ở đây tôi sẽ chọn **General Purpose**. Và tiếp đó chọn **Global namespace**. Với tùy chọn này bạn nên đặt tên bucket với 1 cái tên chưa từng ai đặt trước đó. Các setting dưới ta sẽ để mặc định và nhấn vào **Create Bucket** để tạo bucket mới.

<img width="1377" height="567" alt="image" src="https://github.com/user-attachments/assets/2804ddd9-ab90-45a9-b717-3f22bbe42b84" />

- Và như dưới ảnh tôi đã tạo bucket thành công.

<img width="1381" height="462" alt="image" src="https://github.com/user-attachments/assets/401617c4-7116-4434-9d2a-4891d30cff68" />

- Trong lab này tôi giữ **Default encryption** của bucket ở **Server-side encryption with Amazon S3 managed keys (SSE-S3)**. Amazon S3 mặc định mã hóa các object mới bằng SSE-S3, vì vậy không cần tạo thêm KMS key cho mục tiêu của lab này.

- Bây giờ ta sẽ tạo Trail mới và log vào bucket mà ta vừa mới tạo trước đó. Ta search tìm dịch vụ **CloudTrail**

<img width="752" height="655" alt="image" src="https://github.com/user-attachments/assets/e5654c96-9ec7-4b42-8f14-4fabd0aeb198" />

- Bây giờ ta sẽ thực hiện tạo 1 Trail mới. Chọn **Create trail**

<img width="1382" height="625" alt="image" src="https://github.com/user-attachments/assets/4378ff96-ede5-4803-8e66-9ab94f6b83c8" />

- Tiếp đó ta sẽ đặt tên Trail. Sau đó chọn option **Use existing S3 bucket** và chọn bucket mà ta đã tạo trước đó. 

<img width="1377" height="482" alt="image" src="https://github.com/user-attachments/assets/794e862f-ed54-46c1-9cf1-f98b448326c6" />

- Tại phần **Log file SSE-KMS encryption**, tui để **Disabled** và không tạo KMS alias. Khi SSE-KMS không được bật, CloudTrail log file và digest file được mã hóa bằng **SSE-S3**, phù hợp với mục tiêu của lab và giúp Wazuh collector chỉ cần quyền đọc S3.

<img width="1303" height="86" alt="image" src="https://github.com/user-attachments/assets/54b28a32-10e2-4c62-a04a-8904de6242f0" />

- Sau đó kéo xuống và nhấn **Next** để qua bước tiếp theo.
- 
<img width="1882" height="785" alt="image" src="https://github.com/user-attachments/assets/54b31e53-5c12-47be-980c-76d5f61f129e" />

- Trong phần **Choose log events**, Management Events được dùng để ghi nhận các control-plane action như IAM và thay đổi cấu hình S3. Ta giữ cấu hình phù hợp với lab rồi nhấn **Next**.
- S3 object-level operation là Data Events và không được log mặc định, vì vậy phần Data Events sẽ được bật riêng ở bước bên dưới.
- Cuối cùng là **Review and create**. Sau khi kiểm tra cấu hình, nhấn **Create trail**. Và như hình dưới thì ta đã tạo xong.

<img width="539" height="416" alt="image" src="https://github.com/user-attachments/assets/cba907e0-ac17-4e2a-bc02-93ba8ba7d8f6" />

- Sau khi tạo xong thì nó sẽ tự động logging và tui thì không muốn mất tiền oan nên tôi sẽ stop logging rồi khi thực hiện giả lập mới bật sau.

<img width="937" height="45" alt="image" src="https://github.com/user-attachments/assets/84f493a4-a549-4795-8e62-06cf80f47490" />

- Bây giờ ta sẽ tiến hành bật **Data events**. Ta kéo xuống dưới mục **Data events** chọn **Edit**

<img width="1855" height="267" alt="image" src="https://github.com/user-attachments/assets/5a2b3021-d3e5-4f63-bcbe-a7b62a1564c8" />

- Ta tick vào **Data Events**

<img width="1821" height="250" alt="image" src="https://github.com/user-attachments/assets/77f92ab9-4850-4bb7-ba02-273a58bacc9d" />

- Chọn **Resource Type** là **S3**

<img width="983" height="162" alt="image" src="https://github.com/user-attachments/assets/29e51a7f-3e32-4f88-9d06-8c62e6a99933" />

- **Log selector template** là **log all events**

<img width="1831" height="233" alt="image" src="https://github.com/user-attachments/assets/1941a1ad-79b5-4e95-a76c-54ba887f788e" />

- Và ta đã xong. 

## Kết nối SIEM
### Cấu hình Wazuh AWS module đọc CloudTrail từ S3
 
**Chuẩn bị máy ảo Wazuh**
 
- Để tiết kiệm credit tối đa, tôi sẽ không cài Wazuh trên EC2 mà thay vào đó cài trên local, sau đó tích hợp CloudTrail vào.
- Ở đây tôi sử dụng VMware Workstation để tạo máy ảo, và đã chuẩn bị sẵn một máy ảo Ubuntu có cài sẵn Wazuh để tiết kiệm thời gian. (Nếu bạn tò mò về cách cài đặt Wazuh, có thể xem các project khác của tôi ở bài này tôi sẽ tập trung chủ yếu vào phần tích hợp AWS.)
 
**Cài đặt AWS CLI và cấu hình credential cho Wazuh collector**
 
- Trên máy ảo Ubuntu, Wazuh cần AWS credential có quyền đọc CloudTrail log trong S3. Nếu chưa cài AWS CLI, thực hiện các lệnh sau:
 
```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

- Trong lab local này tôi sử dụng access key của collector identity và lưu ở AWS CLI profile `default`:

```
aws configure
```

- Lệnh sẽ yêu cầu **Access Key ID** và **Secret Access Key** của collector identity. Không sử dụng credential của attacker identity hoặc tài khoản root cho bước này.

<img width="601" height="72" alt="Screenshot 2026-07-20 141806" src="https://github.com/user-attachments/assets/9c03d6a5-2b1a-441f-b4c5-52efb09eed22" />

- Tiếp đó ta sẽ nhập **Secret key**. Sau khi nhập xong nhấn enter để tiếp tục.

<img width="242" height="20" alt="Screenshot 2026-07-20 142233" src="https://github.com/user-attachments/assets/aa4434ac-b269-465f-8be9-911cd74bafac" />

- Ta sẽ nhập region. Thì dưới ảnh mặc định là singapore. Nên tui sẽ để mặc định. Nhấn Enter để tiếp tục.

<img width="311" height="20" alt="Screenshot 2026-07-20 142329" src="https://github.com/user-attachments/assets/18f2d9b2-3ddf-42fd-9d7b-9cac22f36694" />

- Tiếp theo tại phần **Default output format [None]:** ta cũng sẽ để mặc định. Và ta đã xong.

- Vì Wazuh manager chạy dưới context của `root`, ta copy AWS CLI credential/config vào `/root/.aws` để module có thể đọc profile `default`. Trước hết tạo thư mục:

```
sudo mkdir -p /root/.aws
```

- Copy file credentials:

```
sudo cp ~/.aws/credentials /root/.aws/
```

- Copy file config:

```
sudo cp ~/.aws/config /root/.aws/
```

- Giới hạn permission của credential files và kiểm tra lại:

```
sudo chmod 600 /root/.aws/credentials
sudo chmod 600 /root/.aws/config
sudo ls -l /root/.aws
```

> **Lưu ý bảo mật:** Access key tĩnh không phải phương án authentication duy nhất của Wazuh. Tui dùng AWS profile vì lab chạy local và dễ tái tạo. Nếu triển khai Wazuh trên AWS hoặc môi trường hỗ trợ role-based authentication thì nên ưu tiên temporary credential/IAM role để hạn chế long-lived credential.

**Cấu hình module AWS S3**
 
- Vào **Server management > Settings**:
 
<img width="1324" height="642" alt="image" src="https://github.com/user-attachments/assets/99a9156d-bda0-43a6-b301-3b09c5e08d33" />

- Tiếp tục chọn **Edit configuration** :
 
<img width="1402" height="637" alt="image" src="https://github.com/user-attachments/assets/5c40e25b-b93c-4926-9a03-0a28d847f109" />

- Thêm đoạn cấu hình sau vào file:
 
```xml
<wodle name="aws-s3">
  <disabled>no</disabled>
  <interval>1m</interval>
  <run_on_start>yes</run_on_start>
  <skip_on_error>yes</skip_on_error>
  <bucket type="cloudtrail">
    <name><TEN_BUCKET_CUA_BAN></name>
    <aws_profile>default</aws_profile>
  </bucket>
</wodle>
```
 
<img width="1917" height="822" alt="Screenshot 2026-07-19 155120" src="https://github.com/user-attachments/assets/38a9dcc5-ff2e-49a0-b60f-29f253afc34a" />

**Lưu cấu hình và khởi động lại**
 
- Sau khi lưu lại, khởi động lại Wazuh manager để áp dụng cấu hình:
 
```
sudo systemctl restart wazuh-manager
```

## Test

- Bây giờ tôi sẽ khởi tạo một EC2 instance để kiểm tra CloudTrail và Wazuh có nhận event hay không. Sau khi test xong cần terminate instance để tránh phát sinh chi phí.
- Chọn **Launch instance**. 

<img width="1395" height="556" alt="image" src="https://github.com/user-attachments/assets/82710f0c-b8bf-49ba-855d-ffd50d6074f7" />

- Sau khi chọn cấu hình, nhấn **Launch instance**. Nhớ terminate instance sau khi hoàn thành bước test.
  
<img width="587" height="552" alt="image" src="https://github.com/user-attachments/assets/58dc551f-28d9-4568-b97d-464810fc7e44" />

- Sau đó đợi Wazuh thu thập CloudTrail log. Thời gian hiển thị có thể không tức thời. Tiếp theo vào **Cloud Security** trên Wazuh rồi chọn **Amazon Web Services**.

<img width="1411" height="637" alt="image" src="https://github.com/user-attachments/assets/33b0af58-45e2-47cd-bce8-d5fad7cc0d58" />

- Ảnh dưới là dashboard sau khi Wazuh đã nhận AWS event.

<img width="1906" height="927" alt="Screenshot 2026-07-20 154713" src="https://github.com/user-attachments/assets/11922c91-42dd-4ef6-ae73-ceacdbceba85" />

- Chuyển sang tab **Events**. Hình dưới cho thấy các event liên quan đến EC2.

<img width="1423" height="582" alt="image" src="https://github.com/user-attachments/assets/025b57bb-ffbe-473a-b42f-67fa0a7a1236" />

- Mở một event và kiểm tra `data.aws.eventName`. Trong ví dụ này giá trị là `RunInstances`, cho thấy CloudTrail đã ghi nhận API activity liên quan tới việc tạo EC2 instance. CloudTrail cung cấp audit telemetry, còn Wazuh sử dụng telemetry đó để tạo alert và hỗ trợ quá trình monitoring/investigation.

<img width="942" height="362" alt="Screenshot 2026-07-20 154935" src="https://github.com/user-attachments/assets/c16f776a-5636-4dfb-b414-11284b1c30e7" />
