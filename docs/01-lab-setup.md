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

### Tạo IAM user riêng cho lab

- Theo Best Practice của AWS, nên tạo một IAM user riêng để thực hiện các công việc hàng ngày, tránh dùng tài khoản root cho việc này.
- Đầu tiên, tìm kiếm dịch vụ **IAM** trên thanh tìm kiếm.

<img width="1147" height="866" alt="image" src="https://github.com/user-attachments/assets/3e8ec7f0-9aae-4ac9-9e52-4cd9928fb613" />

- Tiếp đó, vào **IAM user** ở menu bên trái. (Trước khi tạo user mới, nên tạo **Account Alias**.)

<img width="336" height="775" alt="image" src="https://github.com/user-attachments/assets/90b60cb7-d50a-406b-a6cc-63765bdcdc9f" />

- Nhấn vào nút **Create User**.

<img width="1906" height="194" alt="image" src="https://github.com/user-attachments/assets/440ac34f-81b0-4977-b182-a694d3a39efa" />

- Như hình dưới, cần cung cấp **Username** (đặt tên tùy ý). Sau đó tick thêm **Provide user access to the AWS Management Console - optional** để có thể thao tác trên giao diện web nếu không tick, account này chỉ dùng được qua CLI. Tôi chọn **Custom password** và đặt mật khẩu riêng, đồng thời bỏ tick **Users must create a new password at next sign-in - Recommended** vì đây là môi trường lab mô phỏng nên không cần thiết. Sau đó nhấn **Next** để tiếp tục.

<img width="1885" height="845" alt="image" src="https://github.com/user-attachments/assets/ebe96ba2-08ca-43f2-844b-df72ec9fe057" />

- Tại đây ta sẽ để mặc định trước và chưa cấu hình gì ở bước này hết.

<img width="1908" height="799" alt="image" src="https://github.com/user-attachments/assets/c1f16205-64c3-4e21-98e7-ae6a700738e4" />

- Nhấn **Create user**.

<img width="1900" height="838" alt="image" src="https://github.com/user-attachments/assets/c8cb49f9-227e-47a9-aa0e-516f4bc919e4" />

- Sau khi tạo user xong, nên thiết lập thêm xác thực 2 lớp (MFA).

<img width="525" height="192" alt="image" src="https://github.com/user-attachments/assets/8bd4c01d-fa6b-45a8-9bea-34327765d8f4" />

- Hình dưới là kết quả sau khi thêm MFA thành công.

<img width="530" height="216" alt="image" src="https://github.com/user-attachments/assets/53ff1055-1522-44f3-994f-1573e6ab222e" />

- Bây giờ tôi sẽ thêm các policy cần thiết để cho user mà tôi vừa mới tạo được có các quyền sử dụng các hành động của s3 như **GetObject**, **ListBucket**
- Dưới đây là đoạn Policy

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

<img width="327" height="517" alt="image" src="https://github.com/user-attachments/assets/ccda34b5-ebfb-464b-b049-8f05066d4319" />

- Tiếp theo ta sẽ chọn vào user ta vừa mới tạo kéo xuống. Và mục **Add permission** xong rồi ấn vào **create inline police**.

<img width="1861" height="402" alt="image" src="https://github.com/user-attachments/assets/83c0c1ef-c502-470b-b96d-03e797fa0af9" />

- Ta sẽ tiến hành đổi qua tab json. và nhập đoạn policy ở trên. thay **<bucket_cua_ban>** thành tên bucket của ta.

<img width="1887" height="745" alt="image" src="https://github.com/user-attachments/assets/5668e655-11bf-426a-b591-9d440bfe2cb9" />

**- Ví dụ như này.**

<img width="1915" height="727" alt="image" src="https://github.com/user-attachments/assets/55adf059-5811-431e-98e7-998de997f77b" />

- Ta kéo xuống nhấn **Next** để tiếp tục.

<img width="1857" height="437" alt="image" src="https://github.com/user-attachments/assets/bac1d13b-9e9a-4b59-a5f4-5974227d9580" />

- Sau khi đặt tên policy ta tiến hành nhấn vào **Creat Policy**

<img width="1890" height="735" alt="image" src="https://github.com/user-attachments/assets/84b387ef-40e8-4bd8-b8d1-972392f5472c" />

- Hình dưới thì ta đã tạo thành công.

<img width="1560" height="605" alt="image" src="https://github.com/user-attachments/assets/00dbcc8f-142e-4aa9-a8cf-51e9fbe082ce" />


## Bật CloudTrail

### Tạo Trail mới, log vào S3 bucket riêng

- Trước hết ta sẽ cần tạo S3 bucket. Đầu tiên ta lên thanh search tìm kiếm dịch vụ **S3**

<img width="1156" height="868" alt="image" src="https://github.com/user-attachments/assets/389d2d8b-14c8-4673-8428-a237816beedf" />

- Tiếp theo đó ta sẽ ấn vào **Create Bucket**

<img width="1900" height="341" alt="image" src="https://github.com/user-attachments/assets/3a064591-1bb9-444b-b8cc-830d2fabc4a3" />

- Ở đây tôi sẽ chọn **General Purpose**. Và tiếp đó bọn **Global namespace**. Với tùy chọn này bạn nên đặt tên bucket với 1 cái tên chưa từng ai đặt trước đó. Các setting dưới ta sẽ để mặc định và nhấn vào **Create Bucket** để tạo bucket mới.

<img width="1897" height="790" alt="image" src="https://github.com/user-attachments/assets/12517a99-9b6a-42ba-81a5-2b2b090b5b20" />

- Và như dưới ảnh tôi đã tạo bucket thành công.

<img width="1907" height="623" alt="image" src="https://github.com/user-attachments/assets/c1fe576d-08ca-4828-b475-9ebe481d66de" />

- Bây giờ ta sẽ tạo Trail mới và log vào bucket mà ta vừa mới tạo trước đó. Ta search tìm dịch vụ **CloudTrail**

<img width="945" height="817" alt="image" src="https://github.com/user-attachments/assets/45d0fc63-21cd-4f62-a5c0-0da87884f403" />

- Bây giờ ta sẽ thực hiện tạo 1 Trail mới. Chọn **Create trail**

<img width="1900" height="867" alt="image" src="https://github.com/user-attachments/assets/913da66c-75c9-45f5-91c2-82eb9f3bfd31" />

- Tiếp đó ta sẽ đặt tên Trail. Sau đó chọn option **Use existing S3 bucket** và chọn bucket mà ta đã tạo trước đó. 

<img width="1572" height="542" alt="image" src="https://github.com/user-attachments/assets/048c9590-e5dc-4f66-947a-65bd874130cd" />

- Ta tạo AWS KMS alias. Xong rồi kéo xuống dưới nhấn **Next** để qua bước tiếp theo 

<img width="622" height="147" alt="image" src="https://github.com/user-attachments/assets/7cbae6ce-6248-4a31-b1d9-d78ef61a7132" />

- Trong phần **Choose log events** ta sẽ để mặc định và nhấn **Next**.
- Cuối cung phần cuối là **Review and create** sau khi kiểm tra tất cả mọi thứ ổn thì ta kéo xuống nhấn **Create Trail** để tiến hành tạo **Trail**
- Sau khi tạo xong thì nó sẽ tự động logging và tui thì không muốn mất tiền oan nên tôi sẽ stop logging rồi khi thực hiện giả lập mới bật sau.

<img width="1646" height="90" alt="image" src="https://github.com/user-attachments/assets/681dbdb5-96e0-4a82-a8d1-abea91d642bf" />

- Bây giờ ta sẽ tiến hành bật **Data events**. Ta kéo xuống dưới mục **Data events** chọn **Edit**

<img width="1887" height="276" alt="image" src="https://github.com/user-attachments/assets/a36cc91e-fea4-4182-9c94-1de142bfd4a0" />

- Ta tick vào **Data Events**

<img width="1902" height="350" alt="image" src="https://github.com/user-attachments/assets/4b51e045-6e8b-4c45-b1a6-c3711e6478f9" />

- Chọn **Resource Type** là **S3**

<img width="1860" height="387" alt="image" src="https://github.com/user-attachments/assets/6cab4aa5-2010-4de3-9858-98487d99ccab" />

- **Log selector template** là **log all events**

<img width="1860" height="387" alt="image" src="https://github.com/user-attachments/assets/d564282f-dcd8-4161-83d1-d8ae4929860b" />

- Và ta đã xong. 

## Kết nối SIEM
### Cấu hình Wazuh AWS module đọc CloudTrail từ S3
 
**Chuẩn bị máy ảo Wazuh**
 
- Để tiết kiệm credit tối đa, tôi sẽ không cài Wazuh trên EC2 mà thay vào đó cài trên local, sau đó tích hợp CloudTrail vào.
- Ở đây tôi sử dụng VMware Workstation để tạo máy ảo, và đã chuẩn bị sẵn một máy ảo Ubuntu có cài sẵn Wazuh để tiết kiệm thời gian. (Nếu bạn tò mò về cách cài đặt Wazuh, có thể xem các project khác của tôi ở bài này tôi sẽ tập trung chủ yếu vào phần tích hợp AWS.)
 
**Cài đặt và đăng nhập AWS CLI sử dụng Access Key**
 
- Trên máy ảo Ubuntu, cần đăng nhập AWS CLI. Nếu chưa cài đặt AWS CLI, thực hiện các lệnh sau:
 
```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

- Ta sử dụng lệnh dưới để cấu hình Access Key.

```
aws configure
```

- Sau khi nhập lệnh trên xong thì câu lệnh sẽ yêu cầu ta nhập **Access key**. Bạn có thể xem cách lấy [**Access key tại đây**](https://www.youtube.com/watch?v=lntWTStctIE). Sau khi lấy xong thì điền vào dòng lệnh dưới. Enter để tiếp tục.

<img width="658" height="200" alt="image" src="https://github.com/user-attachments/assets/0d9b3c76-b6d7-4474-9dcb-d0f809c0a359" />

- Tiếp đó ta sẽ nhập **Secret key**. Sau khi nhập xong nhấn enter để tiếp tục.

<img width="242" height="20" alt="image" src="https://github.com/user-attachments/assets/c2e24cce-f738-42a4-a6ef-3bcffabef08e" />

- Ta sẽ nhập region. Thì dưới ảnh mặc định là singapore. Nên tôi sẽ để mặc định. Nhấn Enter để tiếp tục.

<img width="311" height="20" alt="image" src="https://github.com/user-attachments/assets/95b3c034-cbb4-4e42-a6d1-f3fc1b56b9e2" />

- Tiếp theo tại phần **Default output format [None]:** ta cũng sẽ để mặc định. Và ta đã xong.

- bây giờ ta sẽ cần set up để cho wazuh đọc được cái **access key**. Trước hết tạo thư mục.

```
sudo mkdir -p /root/.aws
```

- Xong rồi copy credentials

```
sudo cp ~/.aws/credentials /root/.aws/
```

- Copy file config luôn

```
sudo cp ~/.aws/config /root/.aws/
```

- Kiểm tra:

```
sudo ls -l /root/.aws
```

> **Lưu ý bảo mật:** Vì Wazuh chạy trên máy local (không phải EC2), không thể dùng IAM Instance Role nên buộc phải dùng Access Key tĩnh. Trong môi trường production, nên ưu tiên IAM Role hoặc ít nhất xoay vòng (rotate) access key định kỳ.

**Cấu hình module AWS S3**
 
- Vào **Server management > Settings**:
 
<img width="1912" height="940" alt="image" src="https://github.com/user-attachments/assets/a056b4ea-6387-46fe-b5c7-c65e28a4f700" />

- Tiếp tục chọn **Edit configuration** :
 
<img width="1902" height="872" alt="image" src="https://github.com/user-attachments/assets/4eae7bfb-af1f-40ee-aed1-bf1b580ca7dc" />

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
 
<img width="1917" height="822" alt="image" src="https://github.com/user-attachments/assets/69ebebbc-822f-4726-93c1-520504672d61" />

**Lưu cấu hình và khởi động lại**
 
- Sau khi lưu lại, khởi động lại Wazuh manager để áp dụng cấu hình:
 
```
sudo systemctl restart wazuh-manager
```

## Test

- Bây giờ tôi sẽ thực hiện khởi động 1 intance EC2. Xong rồi tắt nó ta vào dịch vụ **EC2**.
- Xong rồi ấn vào **Lauch Instance**. 
<img width="1897" height="756" alt="image" src="https://github.com/user-attachments/assets/430d3ec6-dfc0-4ffc-85d5-191d40ddd4d8" />

- Sau khi chọn cấu hình xong rồi ta ấn vào **Lauch Instance**. (Nhớ xóa luôn Instance nếu xong bước test)
<img width="606" height="571" alt="image" src="https://github.com/user-attachments/assets/c5dd6acb-5646-4230-811f-ab49b8502894" />

- Tiếp đó ta sễ đợi Wazuh nhận log thì đợi khá lâu tầm 5 - 15p. Tiếp theo ta sẽ vào mục **Cloud Security** trên **Wazuh** rồi vào **Amazon Web Service**

<img width="1917" height="862" alt="image" src="https://github.com/user-attachments/assets/65cd41e1-bd5f-41e5-8acf-c55a787c13c1" />

- Và dưới ảnh là các Dashboard có sẳng.

<img width="1906" height="927" alt="image" src="https://github.com/user-attachments/assets/b37cf504-3490-403f-945a-08a55d6a8ce4" />

- Ta qua tag **Event**. Và như hình dưới là các log về **EC2**.

<img width="1912" height="731" alt="image" src="https://github.com/user-attachments/assets/776b1bc7-52dd-4a5e-a0d6-9caa457859b6" />

- Mình sẽ mở một event bất kỳ. Ở đây có thể thấy data.aws.eventName là RunInstances, nghĩa là đã có một API call để tạo EC2 instance. Đây là lý do CloudTrail rất quan trọng, vì nó ghi lại toàn bộ API activity, giúp chúng ta giám sát và phát hiện các hành động bất thường hoặc đáng ngờ trên AWS.

<img width="942" height="362" alt="image" src="https://github.com/user-attachments/assets/bd68b96f-0c05-4c0d-b2c7-aac5bc8b65e5" />

