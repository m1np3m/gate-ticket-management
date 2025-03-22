# Hướng dẫn triển khai cơ sở dữ liệu

Tài liệu này hướng dẫn cách triển khai cơ sở dữ liệu cho hệ thống quản lý ra vào cổng trên PostgreSQL và Supabase.

## Nội dung thư mục

- `staging_postgres_deploy.sql`: Script để triển khai schema và dữ liệu mẫu lên PostgreSQL/Supabase
- `supabase_rls_policies.sql`: Script cấu hình Row Level Security (RLS) cho Supabase
- `supabase_auth_integration.sql`: Script tích hợp với Supabase Auth

## Lưu ý quan trọng

- **Tên bảng viết thường**: Tất cả các bảng trong Supabase đều được đặt tên bằng chữ thường (users, gatepasses, visitors, v.v.) thay vì viết hoa (Users, GatePasses, Visitors).
- **Thứ tự chạy các script**:
  1. `staging_postgres_deploy.sql` - Tạo schema và dữ liệu mẫu
  2. `supabase_auth_integration.sql` - Tích hợp với Supabase Auth (để tạo hàm get_auth_user_id)
  3. `supabase_rls_policies.sql` - Thiết lập các chính sách RLS
- **Phụ thuộc giữa các script**: File `supabase_rls_policies.sql` sử dụng hàm `get_auth_user_id()` được định nghĩa trong `supabase_auth_integration.sql`, vì vậy phải chạy `supabase_auth_integration.sql` trước.

## Triển khai trên Supabase

### Bước 1: Đăng nhập vào Supabase Dashboard

1. Truy cập [https://app.supabase.io](https://app.supabase.io)
2. Đăng nhập vào tài khoản của bạn
3. Chọn dự án của bạn hoặc tạo một dự án mới

### Bước 2: Reset database (nếu cần)

Nếu bạn cần reset database:

1. Chọn "SQL Editor" từ menu bên trái
2. Tạo một SQL Query mới
3. Thực thi đoạn code sau để xóa tất cả bảng trong schema public:

```sql
DO $$ 
DECLARE
  r RECORD;
BEGIN
  -- Tắt tạm thời các trigger
  SET session_replication_role = 'replica';
  
  -- Xóa tất cả các bảng trong schema public
  FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
    EXECUTE 'DROP TABLE IF EXISTS public.' || quote_ident(r.tablename) || ' CASCADE';
  END LOOP;
  
  -- Bật lại các trigger
  SET session_replication_role = 'origin';
END $$;
```

### Bước 3: Triển khai schema và dữ liệu mẫu

1. Chọn "SQL Editor" từ menu bên trái
2. Tạo một SQL Query mới
3. Sao chép nội dung từ file `staging_postgres_deploy.sql` và dán vào SQL Editor
4. Thực thi script

### Bước 4: Tích hợp với Supabase Auth

1. Tạo một SQL Query mới
2. Sao chép nội dung từ file `supabase_auth_integration.sql` và dán vào SQL Editor
3. Thực thi script
4. **Quan trọng**: Xác minh hàm `get_auth_user_id()` đã được tạo bằng cách chạy lệnh sau:
   ```sql
   SELECT * FROM pg_proc WHERE proname = 'get_auth_user_id';
   ```

### Bước 5: Cấu hình Row Level Security (RLS)

1. Tạo một SQL Query mới
2. Sao chép nội dung từ file `supabase_rls_policies.sql` và dán vào SQL Editor
3. Thực thi script

### Bước 6: Kiểm tra cấu hình RLS

1. Chọn "Authentication" > "Policies" từ menu bên trái
2. Kiểm tra xem các RLS policies đã được áp dụng cho tất cả các bảng

## Triển khai trên PostgreSQL (Staging)

### Bước 1: Kết nối đến máy chủ PostgreSQL

Sử dụng lệnh `psql` để kết nối đến máy chủ PostgreSQL:

```bash
psql -h hostname -U username -d database_name -p port
```

Thay thế `hostname`, `username`, `database_name`, và `port` bằng thông tin kết nối của bạn.

### Bước 2: Chạy script triển khai

```bash
psql -h hostname -U username -d database_name -p port -f staging_postgres_deploy.sql
```

Hoặc nếu bạn đã kết nối đến PostgreSQL, bạn có thể sử dụng lệnh sau:

```sql
\i staging_postgres_deploy.sql
```

Lưu ý: Các chức năng RLS chỉ áp dụng cho Supabase, không cần thiết cho triển khai PostgreSQL thông thường.

## Sử dụng Supabase CLI (Tùy chọn)

Bạn cũng có thể sử dụng Supabase CLI để triển khai cơ sở dữ liệu:

### Bước 1: Cài đặt Supabase CLI

```bash
# Sử dụng npm
npm install -g supabase

# Hoặc sử dụng Homebrew (macOS)
brew install supabase/tap/supabase
```

### Bước 2: Đăng nhập và liên kết dự án

```bash
# Đăng nhập vào Supabase
supabase login

# Liên kết dự án local với dự án Supabase
supabase link --project-ref your-project-ref
```

### Bước 3: Đẩy schema lên Supabase

```bash
# Từ thư mục gốc của dự án
supabase db push
```

## Kiểm tra cài đặt

Sau khi triển khai, bạn có thể kiểm tra cài đặt bằng cách chạy các truy vấn sau:

```sql
-- Kiểm tra các bảng đã được tạo
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public';

-- Kiểm tra dữ liệu mẫu
SELECT * FROM users LIMIT 5;
SELECT * FROM gatepasses LIMIT 5;
```

## Xử lý lỗi phổ biến

### Lỗi "relation does not exist"

Nếu gặp lỗi "relation does not exist" khi chạy các script RLS, hãy kiểm tra:
1. Bạn đã chạy script `staging_postgres_deploy.sql` chưa
2. Tên bảng sử dụng trong script RLS đã đúng chưa (phải là chữ thường)
3. Script RLS đã được cập nhật cho phù hợp với tên bảng viết thường chưa

### Lỗi "function get_auth_user_id() does not exist"

Nếu gặp lỗi về hàm `get_auth_user_id()` không tồn tại:
1. Kiểm tra xem bạn đã chạy script `supabase_auth_integration.sql` chưa
2. Xác minh hàm đã được tạo bằng cách chạy: `SELECT * FROM pg_proc WHERE proname = 'get_auth_user_id';`
3. Nếu hàm chưa được định nghĩa, kiểm tra script `supabase_auth_integration.sql` để đảm bảo nó có định nghĩa hàm này
4. Thứ tự chạy các script rất quan trọng: phải chạy `supabase_auth_integration.sql` trước `supabase_rls_policies.sql`

### Lỗi "operator does not exist: uuid = integer"

Nếu gặp lỗi "ERROR: 42883: operator does not exist: uuid = integer", nguyên nhân là do không khớp kiểu dữ liệu:
1. Trong Supabase, `auth.uid()` trả về kiểu UUID, trong khi ID trong các bảng là INTEGER
2. Cần đảm bảo rằng tất cả các policies đều sử dụng hàm `get_auth_user_id()` thay vì `auth.uid()`

Để khắc phục:
1. Đảm bảo bạn đã chạy script `supabase_auth_integration.sql` để tạo hàm `get_auth_user_id()`
2. Thay thế tất cả `auth.uid()` trong script `supabase_rls_policies.sql` thành `get_auth_user_id()`
3. Chạy lại script `supabase_rls_policies.sql`

### Lỗi trùng lặp quyền trong RolePermissions

Nếu gặp lỗi vi phạm ràng buộc duy nhất trong bảng rolepermissions, nguyên nhân có thể do:
1. Dữ liệu đã tồn tại trong bảng
2. Script insert có dữ liệu trùng lặp

Giải pháp:
- Xóa dữ liệu hiện có: `TRUNCATE TABLE rolepermissions CASCADE;`
- Hoặc sử dụng vai trò 'bao_ve' riêng biệt thay vì 'nhan_vien' cho nhân viên bảo vệ 