-- Script để tích hợp cơ sở dữ liệu với Supabase Auth
-- Chạy script này sau khi đã tạo schema, dữ liệu mẫu và RLS policies

-- Tạo function để đồng bộ dữ liệu từ auth.users vào bảng users
CREATE OR REPLACE FUNCTION sync_auth_users()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO users (
      username, 
      password, 
      email, 
      full_name, 
      phone,
      role, 
      is_active
    )
    VALUES (
      NEW.email, 
      '********', -- Mật khẩu đã được quản lý bởi Supabase Auth
      NEW.email, 
      COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
      COALESCE(NEW.raw_user_meta_data->>'phone', NULL),
      COALESCE(NEW.raw_user_meta_data->>'role', 'khach'),
      TRUE
    );
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE users 
    SET 
      email = NEW.email,
      full_name = COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
      phone = COALESCE(NEW.raw_user_meta_data->>'phone', phone),
      role = COALESCE(NEW.raw_user_meta_data->>'role', role),
      updated_at = CURRENT_TIMESTAMP
    WHERE email = OLD.email;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE users 
    SET 
      is_active = FALSE,
      updated_at = CURRENT_TIMESTAMP
    WHERE email = OLD.email;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Tạo trigger khi có user mới được tạo trong auth.users
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE sync_auth_users();

-- Tạo trigger khi user trong auth.users được cập nhật
CREATE TRIGGER on_auth_user_updated
  AFTER UPDATE ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE sync_auth_users();

-- Tạo trigger khi user trong auth.users bị xóa
CREATE TRIGGER on_auth_user_deleted
  AFTER DELETE ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE sync_auth_users();

-- Tạo function để tự động cập nhật user_id trong các RLS policies
CREATE OR REPLACE FUNCTION get_auth_user_id() 
RETURNS INTEGER AS $$
DECLARE
  user_id INTEGER;
BEGIN
  SELECT id INTO user_id FROM users WHERE email = auth.email();
  RETURN user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Cập nhật các RLS policy sử dụng Supabase Auth
-- Các policy này thay thế auth.uid() = id bằng get_auth_user_id() = id
-- Lưu ý: Đây chỉ là ví dụ, bạn cần cập nhật tất cả các policy

-- Ví dụ cập nhật policy cho bảng users
DROP POLICY IF EXISTS "Users can view their own information" ON users;
CREATE POLICY "Users can view their own information" ON users
FOR SELECT USING (get_auth_user_id() = id);

-- Ví dụ cập nhật policy cho bảng gatepasses
DROP POLICY IF EXISTS "Users can view their own gate passes" ON gatepasses;
CREATE POLICY "Users can view their own gate passes" ON gatepasses
FOR SELECT USING (
    get_auth_user_id() = created_by OR 
    get_auth_user_id() = approved_by OR 
    get_auth_user_id() = checked_by OR
    get_auth_user_id() = person_to_visit
);

-- Tạo function để đồng bộ dữ liệu từ users vào auth.users
-- Function này được sử dụng khi bạn tạo user từ bảng users và muốn tự động tạo auth.users
CREATE OR REPLACE FUNCTION sync_users_to_auth()
RETURNS TRIGGER AS $$
DECLARE
  auth_uid UUID;
BEGIN
  -- Kiểm tra xem user đã tồn tại trong auth.users chưa
  SELECT id INTO auth_uid FROM auth.users WHERE email = NEW.email;
  
  IF auth_uid IS NULL THEN
    -- Tạo mới user trong auth.users
    INSERT INTO auth.users (
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at
    )
    VALUES (
      NEW.email,
      -- Sử dụng mật khẩu mặc định (thay đổi tùy theo nhu cầu)
      crypt('password123', gen_salt('bf')),
      CURRENT_TIMESTAMP,
      '{"provider": "email", "providers": ["email"]}',
      jsonb_build_object(
        'full_name', NEW.full_name,
        'phone', NEW.phone,
        'role', NEW.role
      ),
      CURRENT_TIMESTAMP,
      CURRENT_TIMESTAMP
    )
    RETURNING id INTO auth_uid;
    
    -- Tạm thời disable trigger sync_auth_users để tránh vòng lặp vô hạn
    ALTER TABLE auth.users DISABLE TRIGGER on_auth_user_created;
    ALTER TABLE auth.users DISABLE TRIGGER on_auth_user_updated;
    
    -- Enable lại trigger sau khi hoàn tất
    ALTER TABLE auth.users ENABLE TRIGGER on_auth_user_created;
    ALTER TABLE auth.users ENABLE TRIGGER on_auth_user_updated;
  ELSE
    -- Cập nhật thông tin trong auth.users
    UPDATE auth.users
    SET
      raw_user_meta_data = jsonb_build_object(
        'full_name', NEW.full_name,
        'phone', NEW.phone,
        'role', NEW.role
      ),
      updated_at = CURRENT_TIMESTAMP
    WHERE id = auth_uid;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Tạo trigger khi có user mới được tạo trong users
CREATE TRIGGER on_user_created
  AFTER INSERT ON users
  FOR EACH ROW EXECUTE PROCEDURE sync_users_to_auth();

-- Tạo trigger khi user trong users được cập nhật
CREATE TRIGGER on_user_updated
  AFTER UPDATE ON users
  FOR EACH ROW EXECUTE PROCEDURE sync_users_to_auth(); 