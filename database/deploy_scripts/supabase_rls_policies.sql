-- Row Level Security (RLS) policies cho Supabase
-- Script này cần được chạy sau khi đã tạo schema và dữ liệu mẫu

-- Bật RLS cho tất cả các bảng
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE gatepasses ENABLE ROW LEVEL SECURITY;
ALTER TABLE visitors ENABLE ROW LEVEL SECURITY;
ALTER TABLE licenseplates ENABLE ROW LEVEL SECURITY;
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE rolepermissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE auditlogs ENABLE ROW LEVEL SECURITY;

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

-- Tạo function kiểm tra quyền của user
CREATE OR REPLACE FUNCTION check_user_permission(permission_name TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    has_permission BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM users u
        JOIN rolepermissions rp ON u.role = rp.role
        JOIN permissions p ON rp.permission_id = p.id
        WHERE u.id = get_auth_user_id() AND p.name = permission_name
    ) INTO has_permission;
    
    RETURN has_permission;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Policy cho bảng users
-- Admin và BGD có thể xem tất cả users
CREATE POLICY "Admins and BGD can view all users" ON users
FOR SELECT USING (
    get_auth_user_id() IN (SELECT id FROM users WHERE role IN ('admin', 'BGD'))
);

-- Trưởng phòng có thể xem users trong phòng ban của mình
CREATE POLICY "Department managers can view users in their department" ON users
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM users u
        WHERE u.id = get_auth_user_id() AND u.role = 'truong_phong' 
        AND u.department = users.department
    )
);

-- Mọi người dùng có thể xem thông tin của chính mình
CREATE POLICY "Users can view their own information" ON users
FOR SELECT USING (get_auth_user_id() = id);

-- Admin và BGD có thể chỉnh sửa tất cả users
CREATE POLICY "Admins and BGD can update all users" ON users
FOR UPDATE USING (
    get_auth_user_id() IN (SELECT id FROM users WHERE role IN ('admin', 'BGD'))
);

-- Trưởng phòng có thể chỉnh sửa users trong phòng ban của mình
CREATE POLICY "Department managers can update users in their department" ON users
FOR UPDATE USING (
    EXISTS (
        SELECT 1 FROM users u
        WHERE u.id = get_auth_user_id() AND u.role = 'truong_phong' 
        AND u.department = users.department
    )
);

-- Mọi người dùng có thể chỉnh sửa thông tin của chính mình
CREATE POLICY "Users can update their own information" ON users
FOR UPDATE USING (get_auth_user_id() = id);

-- Policy cho bảng gatepasses
-- Mọi người dùng có thể xem phiếu ra vào cổng của chính mình
CREATE POLICY "Users can view their own gate passes" ON gatepasses
FOR SELECT USING (
    get_auth_user_id() = created_by OR 
    get_auth_user_id() = approved_by OR 
    get_auth_user_id() = checked_by OR
    get_auth_user_id() = person_to_visit
);

-- Admin, BGD và Trưởng phòng có thể xem tất cả phiếu ra vào cổng trong phòng ban của mình
CREATE POLICY "Managers can view all gate passes in their department" ON gatepasses
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM users u
        WHERE u.id = get_auth_user_id() 
        AND u.role IN ('admin', 'BGD', 'truong_phong') 
        AND (u.role IN ('admin', 'BGD') OR u.department = gatepasses.department_to_visit)
    )
);

-- Bảo vệ có thể xem tất cả phiếu ra vào cổng
CREATE POLICY "Security staff can view all gate passes" ON gatepasses
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM users u
        WHERE u.id = get_auth_user_id() AND u.department = 'Phòng Bảo Vệ'
    )
);

-- Người dùng có thể tạo phiếu ra vào cổng
CREATE POLICY "Users can create gate passes" ON gatepasses
FOR INSERT WITH CHECK (
    check_user_permission('create_gate_pass')
);

-- Người dùng có thể chỉnh sửa phiếu ra vào cổng do chính mình tạo
CREATE POLICY "Users can update their own gate passes" ON gatepasses
FOR UPDATE USING (
    get_auth_user_id() = created_by AND 
    check_user_permission('edit_gate_pass')
);

-- Trưởng phòng có thể duyệt phiếu ra vào cổng cho phòng ban của mình
CREATE POLICY "Department managers can approve gate passes" ON gatepasses
FOR UPDATE USING (
    EXISTS (
        SELECT 1 FROM users u
        WHERE u.id = get_auth_user_id() 
        AND u.role IN ('truong_phong', 'admin', 'BGD') 
        AND (u.role IN ('admin', 'BGD') OR u.department = gatepasses.department_to_visit)
    ) AND
    check_user_permission('approve_gate_pass')
);

-- Bảo vệ có thể cập nhật trạng thái vào/ra cổng
CREATE POLICY "Security staff can update check-in/check-out status" ON gatepasses
FOR UPDATE USING (
    EXISTS (
        SELECT 1 FROM users u
        WHERE u.id = get_auth_user_id() AND u.department = 'Phòng Bảo Vệ'
    ) AND
    (check_user_permission('check_in_gate_pass') OR check_user_permission('check_out_gate_pass'))
);

-- Policy cho bảng visitors
-- Mọi người dùng có thể xem thông tin khách thuộc phiếu của mình
CREATE POLICY "Users can view visitors of their gate passes" ON visitors
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM gatepasses gp
        WHERE gp.id = visitors.gate_pass_id
        AND (gp.created_by = get_auth_user_id() OR gp.person_to_visit = get_auth_user_id())
    )
);

-- Admin, BGD và Trưởng phòng có thể xem tất cả thông tin khách trong phòng ban
CREATE POLICY "Managers can view all visitors" ON visitors
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM users u
        JOIN gatepasses gp ON visitors.gate_pass_id = gp.id
        WHERE u.id = get_auth_user_id() 
        AND u.role IN ('admin', 'BGD', 'truong_phong') 
        AND (u.role IN ('admin', 'BGD') OR u.department = gp.department_to_visit)
    )
);

-- Bảo vệ có thể xem tất cả thông tin khách
CREATE POLICY "Security staff can view all visitors" ON visitors
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM users u
        WHERE u.id = get_auth_user_id() AND u.department = 'Phòng Bảo Vệ'
    )
);

-- Người dùng có thể tạo thông tin khách cho phiếu của mình
CREATE POLICY "Users can create visitors for their gate passes" ON visitors
FOR INSERT WITH CHECK (
    EXISTS (
        SELECT 1 FROM gatepasses gp
        WHERE gp.id = visitors.gate_pass_id
        AND gp.created_by = get_auth_user_id()
    )
);

-- Bảo vệ có thể cập nhật thông tin ra/vào cổng của khách
CREATE POLICY "Security staff can update visitor check-in/check-out" ON visitors
FOR UPDATE USING (
    EXISTS (
        SELECT 1 FROM users u
        WHERE u.id = get_auth_user_id() AND u.department = 'Phòng Bảo Vệ'
    ) AND
    (check_user_permission('check_in_gate_pass') OR check_user_permission('check_out_gate_pass'))
);

-- Policy tương tự cho bảng licenseplates
-- Mọi người dùng có thể xem thông tin biển số xe thuộc phiếu của mình
CREATE POLICY "Users can view license plates of their gate passes" ON licenseplates
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM gatepasses gp
        WHERE gp.id = licenseplates.gate_pass_id
        AND (gp.created_by = get_auth_user_id() OR gp.person_to_visit = get_auth_user_id())
    )
);

-- Admin, BGD và Trưởng phòng có thể xem tất cả thông tin biển số xe
CREATE POLICY "Managers can view all license plates" ON licenseplates
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM users u
        JOIN gatepasses gp ON licenseplates.gate_pass_id = gp.id
        WHERE u.id = get_auth_user_id() 
        AND u.role IN ('admin', 'BGD', 'truong_phong') 
        AND (u.role IN ('admin', 'BGD') OR u.department = gp.department_to_visit)
    )
);

-- Bảo vệ có thể xem tất cả thông tin biển số xe
CREATE POLICY "Security staff can view all license plates" ON licenseplates
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM users u
        WHERE u.id = get_auth_user_id() AND u.department = 'Phòng Bảo Vệ'
    )
);

-- Người dùng có thể tạo thông tin biển số xe cho phiếu của mình
CREATE POLICY "Users can create license plates for their gate passes" ON licenseplates
FOR INSERT WITH CHECK (
    EXISTS (
        SELECT 1 FROM gatepasses gp
        WHERE gp.id = licenseplates.gate_pass_id
        AND gp.created_by = get_auth_user_id()
    )
);

-- Bảo vệ có thể cập nhật thông tin ra/vào cổng của biển số xe
CREATE POLICY "Security staff can update license plate check-in/check-out" ON licenseplates
FOR UPDATE USING (
    EXISTS (
        SELECT 1 FROM users u
        WHERE u.id = get_auth_user_id() AND u.department = 'Phòng Bảo Vệ'
    ) AND
    (check_user_permission('check_in_gate_pass') OR check_user_permission('check_out_gate_pass'))
);

-- Policy cho bảng departments
-- Admin và BGD có thể xem và quản lý tất cả phòng ban
CREATE POLICY "Admins and BGD can manage departments" ON departments
FOR ALL USING (
    get_auth_user_id() IN (SELECT id FROM users WHERE role IN ('admin', 'BGD'))
);

-- Mọi người dùng có thể xem thông tin phòng ban
CREATE POLICY "All users can view departments" ON departments
FOR SELECT USING (true);

-- Policy cho bảng permissions và rolepermissions
-- Chỉ Admin có thể quản lý permissions và role permissions
CREATE POLICY "Only admins can manage permissions" ON permissions
FOR ALL USING (
    get_auth_user_id() IN (SELECT id FROM users WHERE role = 'admin')
);

CREATE POLICY "Only admins can manage role permissions" ON rolepermissions
FOR ALL USING (
    get_auth_user_id() IN (SELECT id FROM users WHERE role = 'admin')
);

-- Policy cho bảng auditlogs
-- Admin và BGD có thể xem tất cả nhật ký
CREATE POLICY "Admins and BGD can view all audit logs" ON auditlogs
FOR SELECT USING (
    get_auth_user_id() IN (SELECT id FROM users WHERE role IN ('admin', 'BGD'))
);

-- Trưởng phòng có thể xem nhật ký của phòng ban mình
CREATE POLICY "Department managers can view audit logs of their department" ON auditlogs
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM users u
        JOIN users au ON auditlogs.user_id = au.id
        WHERE u.id = get_auth_user_id() AND u.role = 'truong_phong' 
        AND u.department = au.department
    )
);

-- Mọi người dùng có thể xem nhật ký của chính mình
CREATE POLICY "Users can view their own audit logs" ON auditlogs
FOR SELECT USING (
    get_auth_user_id() = user_id
);

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