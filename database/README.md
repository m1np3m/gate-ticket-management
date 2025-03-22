# Thiết kế Cơ sở dữ liệu cho Hệ thống Quản lý Ra Vào Cổng

Tài liệu này mô tả thiết kế cơ sở dữ liệu cho hệ thống quản lý ra vào cổng, bao gồm các bảng dữ liệu và mối quan hệ giữa chúng.

## Các bảng dữ liệu

### 1. Users
Bảng này lưu trữ thông tin về tất cả người dùng trong hệ thống.

- **id**: Khóa chính, định danh duy nhất cho mỗi người dùng
- **username**: Tên đăng nhập, duy nhất trong hệ thống
- **password**: Mật khẩu đã được mã hóa
- **email**: Địa chỉ email, duy nhất trong hệ thống
- **full_name**: Họ và tên đầy đủ
- **phone**: Số điện thoại liên hệ
- **department**: Phòng ban (đối với nhân viên công ty)
- **role**: Vai trò trong hệ thống ('admin', 'BGD', 'truong_phong', 'nhan_vien', 'khach')
- **created_at**: Thời điểm tạo tài khoản
- **updated_at**: Thời điểm cập nhật thông tin gần nhất
- **is_active**: Trạng thái hoạt động của tài khoản

### 2. GatePasses
Bảng này lưu trữ thông tin về các phiếu ra vào cổng.

- **id**: Khóa chính, định danh duy nhất cho mỗi phiếu
- **pass_number**: Số phiếu, duy nhất trong hệ thống
- **created_at**: Thời điểm tạo phiếu
- **valid_date**: Ngày có hiệu lực của phiếu
- **department_to_visit**: Phòng ban cần gặp
- **person_to_visit**: ID của người cần gặp (tham chiếu đến bảng Users)
- **visit_reason**: Lý do gặp
- **created_by**: ID của người tạo phiếu (tham chiếu đến bảng Users)
- **approved_by**: ID của người duyệt phiếu (tham chiếu đến bảng Users)
- **checked_by**: ID của người cho vào cổng (tham chiếu đến bảng Users)
- **approved_at**: Thời điểm phiếu được duyệt
- **check_in_at**: Thời điểm vào cổng
- **check_out_at**: Thời điểm ra cổng
- **status**: Trạng thái của phiếu ('created', 'approved', 'checked_in', 'checked_out')
- **notes**: Ghi chú bổ sung
- **updated_at**: Thời điểm cập nhật thông tin gần nhất

### 3. Visitors
Bảng này lưu trữ thông tin về khách vào cổng, mỗi phiếu ra vào cổng có thể có nhiều khách cùng vào.

- **id**: Khóa chính, định danh duy nhất cho mỗi khách
- **gate_pass_id**: ID của phiếu ra vào cổng (tham chiếu đến bảng GatePasses)
- **full_name**: Họ và tên đầy đủ của khách
- **phone**: Số điện thoại liên hệ
- **id_card_number**: Số CCCD/CMND
- **id_card_front_image**: Hình ảnh mặt trước CCCD/CMND
- **id_card_back_image**: Hình ảnh mặt sau CCCD/CMND
- **driver_license_number**: Số giấy phép lái xe
- **driver_license_front_image**: Hình ảnh mặt trước GPLX
- **driver_license_back_image**: Hình ảnh mặt sau GPLX
- **check_in_at**: Thời điểm vào cổng
- **check_out_at**: Thời điểm ra cổng
- **created_at**: Thời điểm tạo bản ghi
- **updated_at**: Thời điểm cập nhật thông tin gần nhất

### 4. LicensePlates
Bảng này lưu trữ thông tin về các biển số xe của phiếu vào cổng, mỗi phiếu có thể có nhiều xe cùng vào.

- **id**: Khóa chính, định danh duy nhất cho mỗi biển số xe
- **gate_pass_id**: ID của phiếu ra vào cổng (tham chiếu đến bảng GatePasses)
- **plate_number**: Biển số xe
- **vehicle_type**: Loại phương tiện (xe máy, ô tô, ...)
- **check_in_at**: Thời điểm vào cổng
- **check_out_at**: Thời điểm ra cổng
- **created_at**: Thời điểm tạo bản ghi
- **updated_at**: Thời điểm cập nhật thông tin gần nhất

### 5. Departments
Bảng này lưu trữ thông tin về các phòng ban trong công ty.

- **id**: Khóa chính, định danh duy nhất cho mỗi phòng ban
- **name**: Tên phòng ban, duy nhất trong hệ thống
- **description**: Mô tả về phòng ban
- **manager_id**: ID của trưởng phòng (tham chiếu đến bảng Users)
- **created_at**: Thời điểm tạo bản ghi
- **updated_at**: Thời điểm cập nhật thông tin gần nhất

### 6. Permissions
Bảng này lưu trữ các quyền trong hệ thống.

- **id**: Khóa chính, định danh duy nhất cho mỗi quyền
- **name**: Tên quyền, duy nhất trong hệ thống
- **description**: Mô tả về quyền
- **created_at**: Thời điểm tạo bản ghi

### 7. RolePermissions
Bảng này lưu trữ phân quyền theo vai trò.

- **id**: Khóa chính, định danh duy nhất cho mỗi bản ghi
- **role**: Vai trò ('admin', 'BGD', 'truong_phong', 'nhan_vien', 'khach')
- **permission_id**: ID của quyền (tham chiếu đến bảng Permissions)
- **created_at**: Thời điểm tạo bản ghi

### 8. AuditLogs
Bảng này lưu trữ nhật ký hoạt động trong hệ thống.

- **id**: Khóa chính, định danh duy nhất cho mỗi bản ghi nhật ký
- **user_id**: ID của người dùng thực hiện hành động (tham chiếu đến bảng Users)
- **action**: Loại hành động đã thực hiện
- **entity_type**: Loại đối tượng tác động ('gate_pass', 'user', ...)
- **entity_id**: ID của đối tượng tác động
- **details**: Chi tiết về hành động
- **created_at**: Thời điểm ghi nhật ký

## Mối quan hệ giữa các bảng

1. **Users - GatePasses**: Một-nhiều (1:n)
   - Một người dùng có thể tạo nhiều phiếu ra vào cổng
   - Một người dùng có thể duyệt nhiều phiếu ra vào cổng
   - Một người dùng có thể kiểm tra nhiều phiếu ra vào cổng

2. **GatePasses - Visitors**: Một-nhiều (1:n)
   - Một phiếu ra vào cổng có thể có nhiều khách cùng vào

3. **GatePasses - LicensePlates**: Một-nhiều (1:n)
   - Một phiếu ra vào cổng có thể có nhiều xe cùng vào

4. **Users - Departments**: Nhiều-một (n:1)
   - Một phòng ban có thể có nhiều nhân viên
   - Một phòng ban có một trưởng phòng

5. **Roles - Permissions**: Nhiều-nhiều (n:m) thông qua bảng RolePermissions
   - Một vai trò có thể có nhiều quyền
   - Một quyền có thể thuộc về nhiều vai trò

## Indexes
Để tối ưu hiệu suất truy vấn, các index sau đã được tạo:

- **idx_gatepasses_status**: Index cho trường status của bảng GatePasses
- **idx_gatepasses_created_by**: Index cho trường created_by của bảng GatePasses
- **idx_gatepasses_valid_date**: Index cho trường valid_date của bảng GatePasses
- **idx_visitors_gate_pass_id**: Index cho trường gate_pass_id của bảng Visitors
- **idx_licenseplates_gate_pass_id**: Index cho trường gate_pass_id của bảng LicensePlates
- **idx_licenseplates_plate_number**: Index cho trường plate_number của bảng LicensePlates

## Hướng dẫn triển khai (Deployment)

### 1. Triển khai lên PostgreSQL (Staging)

Để triển khai cơ sở dữ liệu lên máy chủ PostgreSQL staging, bạn có thể sử dụng một trong các cách sau:

#### 1.1. Sử dụng psql command line

```bash
# Kết nối đến máy chủ PostgreSQL
psql -h hostname -U username -d database_name -p port -f database/deploy_scripts/staging_postgres_deploy.sql
```

Thay thế `hostname`, `username`, `database_name`, và `port` bằng thông tin kết nối của bạn.

#### 1.2. Sử dụng pgAdmin hoặc DBeaver

1. Mở công cụ quản lý cơ sở dữ liệu (pgAdmin hoặc DBeaver)
2. Kết nối đến máy chủ PostgreSQL staging
3. Mở Query Tool/SQL Editor
4. Mở file `database/deploy_scripts/staging_postgres_deploy.sql`
5. Thực thi script

### 2. Triển khai lên Supabase (Dev)

Supabase được xây dựng trên PostgreSQL nên bạn có thể sử dụng cùng một schema. Tuy nhiên, có một số điểm cần lưu ý:

#### 2.1. Sử dụng Supabase SQL Editor

1. Đăng nhập vào Supabase Dashboard
2. Chọn dự án của bạn
3. Chọn SQL Editor từ menu bên trái
4. Tạo một SQL Query mới
5. Sao chép nội dung từ file `database/deploy_scripts/staging_postgres_deploy.sql` và dán vào SQL Editor
6. Thực thi script

#### 2.2. Sử dụng Supabase CLI

Nếu bạn đã cài đặt Supabase CLI, bạn có thể triển khai như sau:

```bash
# Đảm bảo bạn đã đăng nhập vào Supabase
supabase login

# Liên kết dự án local với dự án Supabase
supabase link --project-ref your-project-ref

# Đẩy schema lên Supabase
supabase db push
```

Thay thế `your-project-ref` bằng reference ID của dự án Supabase của bạn.

#### 2.3. Cấu hình RLS (Row Level Security) cho Supabase

Sau khi triển khai schema, bạn nên thiết lập RLS cho các bảng để bảo mật dữ liệu:

```sql
-- Ví dụ về thiết lập RLS cho bảng GatePasses
ALTER TABLE "GatePasses" ENABLE ROW LEVEL SECURITY;

-- Tạo policy cho GatePasses
CREATE POLICY "Users can view their own gate passes" ON "GatePasses"
FOR SELECT USING (auth.uid() = created_by);

CREATE POLICY "Managers can view all gate passes in their department" ON "GatePasses"
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM "Users" u
    JOIN "Departments" d ON u.department = d.name
    WHERE u.id = auth.uid() AND u.role IN ('truong_phong', 'BGD') 
    AND d.name = "GatePasses".department_to_visit
  )
);

-- Thêm các policy tương tự cho các bảng khác
```

### 3. Cập nhật dữ liệu mẫu (Sample Data)

Sau khi triển khai schema, bạn có thể chạy script dữ liệu mẫu:

```bash
# PostgreSQL
psql -h hostname -U username -d database_name -p port -f database/sample_data.sql

# Supabase
# Sử dụng SQL Editor để chạy nội dung của file sample_data.sql
```

### 4. Xác thực cài đặt

Sau khi triển khai, bạn có thể kiểm tra cài đặt bằng cách chạy một số truy vấn:

```sql
-- Kiểm tra các bảng đã được tạo
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public';

-- Kiểm tra dữ liệu mẫu
SELECT * FROM "Users" LIMIT 5;
SELECT * FROM "GatePasses" LIMIT 5;
``` 