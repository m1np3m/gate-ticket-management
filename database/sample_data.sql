-- Dữ liệu mẫu cho hệ thống quản lý ra vào cổng

-- Dữ liệu cho bảng Departments
INSERT INTO Departments (name, description) VALUES
('Ban Giám Đốc', 'Ban lãnh đạo công ty'),
('Phòng Nhân Sự', 'Quản lý nhân sự và tuyển dụng'),
('Phòng Kế Toán', 'Quản lý tài chính và kế toán'),
('Phòng IT', 'Quản lý hệ thống công nghệ thông tin'),
('Phòng Kinh Doanh', 'Phát triển kinh doanh và quan hệ khách hàng'),
('Phòng Bảo Vệ', 'Bảo vệ an ninh công ty');

-- Dữ liệu cho bảng Users (mật khẩu mẫu: 'password123')
INSERT INTO Users (username, password, email, full_name, phone, department, role, is_active) VALUES
('admin', '$2a$10$rTH8DcQqeNwYwV9YBBqBxem.iyRXFe9IodL63LfMPnFu7aYpPNmhC', 'admin@company.com', 'Admin', '0901234567', NULL, 'admin', TRUE),
('giamdoc', '$2a$10$rTH8DcQqeNwYwV9YBBqBxem.iyRXFe9IodL63LfMPnFu7aYpPNmhC', 'giamdoc@company.com', 'Nguyễn Văn A', '0901234568', 'Ban Giám Đốc', 'BGD', TRUE),
('truongns', '$2a$10$rTH8DcQqeNwYwV9YBBqBxem.iyRXFe9IodL63LfMPnFu7aYpPNmhC', 'truongns@company.com', 'Trần Thị B', '0901234569', 'Phòng Nhân Sự', 'truong_phong', TRUE),
('truongkt', '$2a$10$rTH8DcQqeNwYwV9YBBqBxem.iyRXFe9IodL63LfMPnFu7aYpPNmhC', 'truongkt@company.com', 'Lê Văn C', '0901234570', 'Phòng Kế Toán', 'truong_phong', TRUE),
('truongit', '$2a$10$rTH8DcQqeNwYwV9YBBqBxem.iyRXFe9IodL63LfMPnFu7aYpPNmhC', 'truongit@company.com', 'Phạm Thị D', '0901234571', 'Phòng IT', 'truong_phong', TRUE),
('truongkd', '$2a$10$rTH8DcQqeNwYwV9YBBqBxem.iyRXFe9IodL63LfMPnFu7aYpPNmhC', 'truongkd@company.com', 'Hoàng Văn E', '0901234572', 'Phòng Kinh Doanh', 'truong_phong', TRUE),
('truongbv', '$2a$10$rTH8DcQqeNwYwV9YBBqBxem.iyRXFe9IodL63LfMPnFu7aYpPNmhC', 'truongbv@company.com', 'Vũ Thị F', '0901234573', 'Phòng Bảo Vệ', 'truong_phong', TRUE),
('nhanvien1', '$2a$10$rTH8DcQqeNwYwV9YBBqBxem.iyRXFe9IodL63LfMPnFu7aYpPNmhC', 'nhanvien1@company.com', 'Nguyễn Văn G', '0901234574', 'Phòng IT', 'nhan_vien', TRUE),
('nhanvien2', '$2a$10$rTH8DcQqeNwYwV9YBBqBxem.iyRXFe9IodL63LfMPnFu7aYpPNmhC', 'nhanvien2@company.com', 'Trần Thị H', '0901234575', 'Phòng Kinh Doanh', 'nhan_vien', TRUE),
('baove1', '$2a$10$rTH8DcQqeNwYwV9YBBqBxem.iyRXFe9IodL63LfMPnFu7aYpPNmhC', 'baove1@company.com', 'Lê Văn I', '0901234576', 'Phòng Bảo Vệ', 'nhan_vien', TRUE),
('baove2', '$2a$10$rTH8DcQqeNwYwV9YBBqBxem.iyRXFe9IodL63LfMPnFu7aYpPNmhC', 'baove2@company.com', 'Phạm Thị K', '0901234577', 'Phòng Bảo Vệ', 'nhan_vien', TRUE),
('khach1', '$2a$10$rTH8DcQqeNwYwV9YBBqBxem.iyRXFe9IodL63LfMPnFu7aYpPNmhC', 'khach1@example.com', 'Trần Văn L', '0901234578', NULL, 'khach', TRUE),
('khach2', '$2a$10$rTH8DcQqeNwYwV9YBBqBxem.iyRXFe9IodL63LfMPnFu7aYpPNmhC', 'khach2@example.com', 'Nguyễn Thị M', '0901234579', NULL, 'khach', TRUE);

-- Cập nhật manager_id cho bảng Departments
UPDATE Departments SET manager_id = (SELECT id FROM Users WHERE username = 'giamdoc') WHERE name = 'Ban Giám Đốc';
UPDATE Departments SET manager_id = (SELECT id FROM Users WHERE username = 'truongns') WHERE name = 'Phòng Nhân Sự';
UPDATE Departments SET manager_id = (SELECT id FROM Users WHERE username = 'truongkt') WHERE name = 'Phòng Kế Toán';
UPDATE Departments SET manager_id = (SELECT id FROM Users WHERE username = 'truongit') WHERE name = 'Phòng IT';
UPDATE Departments SET manager_id = (SELECT id FROM Users WHERE username = 'truongkd') WHERE name = 'Phòng Kinh Doanh';
UPDATE Departments SET manager_id = (SELECT id FROM Users WHERE username = 'truongbv') WHERE name = 'Phòng Bảo Vệ';

-- Dữ liệu cho bảng Permissions
INSERT INTO Permissions (name, description) VALUES
('create_gate_pass', 'Tạo phiếu ra vào cổng'),
('edit_gate_pass', 'Chỉnh sửa phiếu ra vào cổng'),
('delete_gate_pass', 'Xóa phiếu ra vào cổng'),
('view_gate_pass', 'Xem phiếu ra vào cổng'),
('approve_gate_pass', 'Duyệt phiếu ra vào cổng'),
('check_in_gate_pass', 'Xác nhận vào cổng'),
('check_out_gate_pass', 'Xác nhận ra cổng'),
('create_user', 'Tạo tài khoản người dùng'),
('edit_user', 'Chỉnh sửa thông tin người dùng'),
('delete_user', 'Xóa tài khoản người dùng'),
('view_user', 'Xem thông tin người dùng'),
('view_reports', 'Xem báo cáo'),
('manage_departments', 'Quản lý phòng ban'),
('manage_permissions', 'Quản lý phân quyền');

-- Dữ liệu cho bảng RolePermissions
-- Admin có tất cả các quyền
INSERT INTO RolePermissions (role, permission_id)
SELECT 'admin', id FROM Permissions;

-- BGD có tất cả các quyền trừ manage_permissions
INSERT INTO RolePermissions (role, permission_id)
SELECT 'BGD', id FROM Permissions WHERE name != 'manage_permissions';

-- Trưởng phòng
INSERT INTO RolePermissions (role, permission_id)
SELECT 'truong_phong', id FROM Permissions WHERE name IN (
    'create_gate_pass', 'edit_gate_pass', 'view_gate_pass', 'approve_gate_pass',
    'create_user', 'view_user', 'view_reports'
);

-- Nhân viên
INSERT INTO RolePermissions (role, permission_id)
SELECT 'nhan_vien', id FROM Permissions WHERE name IN (
    'create_gate_pass', 'edit_gate_pass', 'view_gate_pass'
);

-- Bảo vệ (là nhân viên của phòng bảo vệ)
INSERT INTO RolePermissions (role, permission_id)
SELECT 'nhan_vien', id FROM Permissions WHERE name IN (
    'view_gate_pass', 'check_in_gate_pass', 'check_out_gate_pass'
);

-- Khách
INSERT INTO RolePermissions (role, permission_id)
SELECT 'khach', id FROM Permissions WHERE name IN (
    'create_gate_pass', 'view_gate_pass'
);

-- Dữ liệu cho bảng GatePasses
INSERT INTO GatePasses (
    pass_number, valid_date, department_to_visit, person_to_visit,
    visit_reason, created_by, status
) VALUES
(
    'GP-2023-001',
    CURRENT_DATE + INTERVAL '1 day',
    'Phòng IT',
    (SELECT id FROM Users WHERE username = 'truongit'),
    'Bàn giao dự án phần mềm',
    (SELECT id FROM Users WHERE username = 'khach1'),
    'created'
),
(
    'GP-2023-002',
    CURRENT_DATE,
    'Phòng Kinh Doanh',
    (SELECT id FROM Users WHERE username = 'nhanvien2'),
    'Thảo luận hợp đồng mới',
    (SELECT id FROM Users WHERE username = 'khach2'),
    'created'
),
(
    'GP-2023-003',
    CURRENT_DATE - INTERVAL '1 day',
    'Phòng IT',
    (SELECT id FROM Users WHERE username = 'nhanvien1'),
    'Bảo trì hệ thống',
    (SELECT id FROM Users WHERE username = 'nhanvien1'),
    'approved'
);

-- Cập nhật trạng thái cho phiếu đã duyệt
UPDATE GatePasses 
SET 
    approved_by = (SELECT id FROM Users WHERE username = 'truongit'),
    approved_at = CURRENT_TIMESTAMP - INTERVAL '1 hour'
WHERE pass_number = 'GP-2023-003';

-- Dữ liệu cho bảng Visitors
INSERT INTO Visitors (
    gate_pass_id, full_name, phone, id_card_number,
    id_card_front_image, id_card_back_image
) VALUES
(
    (SELECT id FROM GatePasses WHERE pass_number = 'GP-2023-001'),
    'Trần Văn L',
    '0901234578',
    '001234567890',
    '/uploads/id_cards/front_001234567890.jpg',
    '/uploads/id_cards/back_001234567890.jpg'
),
(
    (SELECT id FROM GatePasses WHERE pass_number = 'GP-2023-001'),
    'Hoàng Thị N',
    '0901234580',
    '001234567891',
    '/uploads/id_cards/front_001234567891.jpg',
    '/uploads/id_cards/back_001234567891.jpg'
),
(
    (SELECT id FROM GatePasses WHERE pass_number = 'GP-2023-002'),
    'Nguyễn Thị M',
    '0901234579',
    '001234567892',
    '/uploads/id_cards/front_001234567892.jpg',
    '/uploads/id_cards/back_001234567892.jpg'
),
(
    (SELECT id FROM GatePasses WHERE pass_number = 'GP-2023-003'),
    'Phạm Văn O',
    '0901234581',
    '001234567893',
    '/uploads/id_cards/front_001234567893.jpg',
    '/uploads/id_cards/back_001234567893.jpg'
);

-- Dữ liệu cho bảng LicensePlates
INSERT INTO LicensePlates (
    gate_pass_id, plate_number, vehicle_type
) VALUES
(
    (SELECT id FROM GatePasses WHERE pass_number = 'GP-2023-001'),
    '51F-12345',
    'Ô tô'
),
(
    (SELECT id FROM GatePasses WHERE pass_number = 'GP-2023-002'),
    '59P1-23456',
    'Xe máy'
),
(
    (SELECT id FROM GatePasses WHERE pass_number = 'GP-2023-003'),
    '51A-67890',
    'Ô tô'
);

-- Dữ liệu cho bảng AuditLogs
INSERT INTO AuditLogs (
    user_id, action, entity_type, entity_id, details
) VALUES
(
    (SELECT id FROM Users WHERE username = 'khach1'),
    'CREATE',
    'gate_pass',
    (SELECT id FROM GatePasses WHERE pass_number = 'GP-2023-001'),
    'Tạo phiếu ra vào cổng mới'
),
(
    (SELECT id FROM Users WHERE username = 'khach2'),
    'CREATE',
    'gate_pass',
    (SELECT id FROM GatePasses WHERE pass_number = 'GP-2023-002'),
    'Tạo phiếu ra vào cổng mới'
),
(
    (SELECT id FROM Users WHERE username = 'nhanvien1'),
    'CREATE',
    'gate_pass',
    (SELECT id FROM GatePasses WHERE pass_number = 'GP-2023-003'),
    'Tạo phiếu ra vào cổng mới'
),
(
    (SELECT id FROM Users WHERE username = 'truongit'),
    'APPROVE',
    'gate_pass',
    (SELECT id FROM GatePasses WHERE pass_number = 'GP-2023-003'),
    'Duyệt phiếu ra vào cổng'
); 