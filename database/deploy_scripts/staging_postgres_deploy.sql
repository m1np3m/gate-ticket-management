-- Kết hợp từ schema.sql và sample_data.sql cho Supabase
-- Tất cả bảng đã được đổi tên thành chữ thường

-- Database schema for Gate Pass Management System

-- Bảng users: danh sách các user được phép sử dụng phần mềm
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    department VARCHAR(100),
    role VARCHAR(20) NOT NULL, -- 'admin', 'BGD', 'truong_phong', 'nhan_vien', 'khach'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Bảng gatepasses: danh sách các phiếu ra vào cổng
CREATE TABLE gatepasses (
    id SERIAL PRIMARY KEY,
    pass_number VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_date DATE NOT NULL,
    department_to_visit VARCHAR(100) NOT NULL,
    person_to_visit INTEGER REFERENCES users(id),
    visit_reason TEXT NOT NULL,
    created_by INTEGER REFERENCES users(id) NOT NULL,
    approved_by INTEGER REFERENCES users(id),
    checked_by INTEGER REFERENCES users(id),
    approved_at TIMESTAMP,
    check_in_at TIMESTAMP,
    check_out_at TIMESTAMP,
    status VARCHAR(20) NOT NULL, -- 'created', 'approved', 'checked_in', 'checked_out'
    notes TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng visitors: danh sách khách vào cổng (mỗi phiếu vào cổng có thể có nhiều khách cùng vào)
CREATE TABLE visitors (
    id SERIAL PRIMARY KEY,
    gate_pass_id INTEGER REFERENCES gatepasses(id) ON DELETE CASCADE,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    id_card_number VARCHAR(50),
    id_card_front_image TEXT, -- URL hoặc đường dẫn đến hình ảnh
    id_card_back_image TEXT, -- URL hoặc đường dẫn đến hình ảnh
    driver_license_number VARCHAR(50),
    driver_license_front_image TEXT, -- URL hoặc đường dẫn đến hình ảnh
    driver_license_back_image TEXT, -- URL hoặc đường dẫn đến hình ảnh
    check_in_at TIMESTAMP,
    check_out_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng licenseplates: danh sách biển số xe của phiếu vào cổng (mỗi phiếu vào cổng có thể có nhiều xe cùng vào)
CREATE TABLE licenseplates (
    id SERIAL PRIMARY KEY,
    gate_pass_id INTEGER REFERENCES gatepasses(id) ON DELETE CASCADE,
    plate_number VARCHAR(20) NOT NULL,
    vehicle_type VARCHAR(50), -- loại phương tiện (xe máy, ô tô, etc.)
    check_in_at TIMESTAMP,
    check_out_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng departments: danh sách các phòng ban
CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    manager_id INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng permission: quản lý phân quyền
CREATE TABLE permissions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng rolepermissions: phân quyền theo vai trò
CREATE TABLE rolepermissions (
    id SERIAL PRIMARY KEY,
    role VARCHAR(20) NOT NULL, -- 'admin', 'BGD', 'truong_phong', 'nhan_vien', 'khach'
    permission_id INTEGER REFERENCES permissions(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(role, permission_id)
);

-- Bảng auditlogs: lưu lại các hoạt động trong hệ thống
CREATE TABLE auditlogs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NOT NULL, -- 'gate_pass', 'user', etc.
    entity_id INTEGER,
    details TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_gatepasses_status ON gatepasses(status);
CREATE INDEX idx_gatepasses_created_by ON gatepasses(created_by);
CREATE INDEX idx_gatepasses_valid_date ON gatepasses(valid_date);
CREATE INDEX idx_visitors_gate_pass_id ON visitors(gate_pass_id);
CREATE INDEX idx_licenseplates_gate_pass_id ON licenseplates(gate_pass_id);
CREATE INDEX idx_licenseplates_plate_number ON licenseplates(plate_number);

-- Dữ liệu mẫu cho hệ thống quản lý ra vào cổng

-- Dữ liệu cho bảng departments
INSERT INTO departments (name, description) VALUES
('Ban Giám Đốc', 'Ban lãnh đạo công ty'),
('Phòng Nhân Sự', 'Quản lý nhân sự và tuyển dụng'),
('Phòng Kế Toán', 'Quản lý tài chính và kế toán'),
('Phòng IT', 'Quản lý hệ thống công nghệ thông tin'),
('Phòng Kinh Doanh', 'Phát triển kinh doanh và quan hệ khách hàng'),
('Phòng Bảo Vệ', 'Bảo vệ an ninh công ty');

-- Dữ liệu cho bảng users (mật khẩu mẫu: 'password123')
INSERT INTO users (username, password, email, full_name, phone, department, role, is_active) VALUES
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

-- Cập nhật manager_id cho bảng departments
UPDATE departments SET manager_id = (SELECT id FROM users WHERE username = 'giamdoc') WHERE name = 'Ban Giám Đốc';
UPDATE departments SET manager_id = (SELECT id FROM users WHERE username = 'truongns') WHERE name = 'Phòng Nhân Sự';
UPDATE departments SET manager_id = (SELECT id FROM users WHERE username = 'truongkt') WHERE name = 'Phòng Kế Toán';
UPDATE departments SET manager_id = (SELECT id FROM users WHERE username = 'truongit') WHERE name = 'Phòng IT';
UPDATE departments SET manager_id = (SELECT id FROM users WHERE username = 'truongkd') WHERE name = 'Phòng Kinh Doanh';
UPDATE departments SET manager_id = (SELECT id FROM users WHERE username = 'truongbv') WHERE name = 'Phòng Bảo Vệ';

-- Dữ liệu cho bảng permissions
INSERT INTO permissions (name, description) VALUES
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

-- Dữ liệu cho bảng rolepermissions
-- Admin có tất cả các quyền
INSERT INTO rolepermissions (role, permission_id)
SELECT 'admin', id FROM permissions;

-- BGD có tất cả các quyền trừ manage_permissions
INSERT INTO rolepermissions (role, permission_id)
SELECT 'BGD', id FROM permissions WHERE name != 'manage_permissions';

-- Trưởng phòng
INSERT INTO rolepermissions (role, permission_id)
SELECT 'truong_phong', id FROM permissions WHERE name IN (
    'create_gate_pass', 'edit_gate_pass', 'view_gate_pass', 'approve_gate_pass',
    'create_user', 'view_user', 'view_reports'
);

-- Nhân viên
INSERT INTO rolepermissions (role, permission_id)
SELECT 'nhan_vien', id FROM permissions WHERE name IN (
    'create_gate_pass', 'edit_gate_pass', 'view_gate_pass'
);

-- Bảo vệ (là nhân viên của phòng bảo vệ) - Tạo vai trò mới 'bao_ve' thay vì dùng 'nhan_vien'
INSERT INTO rolepermissions (role, permission_id)
SELECT 'bao_ve', id FROM permissions WHERE name IN (
    'view_gate_pass', 'check_in_gate_pass', 'check_out_gate_pass'
);

-- Khách
INSERT INTO rolepermissions (role, permission_id)
SELECT 'khach', id FROM permissions WHERE name IN (
    'create_gate_pass', 'view_gate_pass'
);

-- Cập nhật role cho nhân viên bảo vệ từ 'nhan_vien' thành 'bao_ve'
UPDATE users SET role = 'bao_ve' WHERE username IN ('baove1', 'baove2');

-- Dữ liệu cho bảng gatepasses
INSERT INTO gatepasses (
    pass_number, valid_date, department_to_visit, person_to_visit,
    visit_reason, created_by, status
) VALUES
(
    'GP-2023-001',
    CURRENT_DATE + INTERVAL '1 day',
    'Phòng IT',
    (SELECT id FROM users WHERE username = 'truongit'),
    'Bàn giao dự án phần mềm',
    (SELECT id FROM users WHERE username = 'khach1'),
    'created'
),
(
    'GP-2023-002',
    CURRENT_DATE,
    'Phòng Kinh Doanh',
    (SELECT id FROM users WHERE username = 'nhanvien2'),
    'Thảo luận hợp đồng mới',
    (SELECT id FROM users WHERE username = 'khach2'),
    'created'
),
(
    'GP-2023-003',
    CURRENT_DATE - INTERVAL '1 day',
    'Phòng IT',
    (SELECT id FROM users WHERE username = 'nhanvien1'),
    'Bảo trì hệ thống',
    (SELECT id FROM users WHERE username = 'nhanvien1'),
    'approved'
);

-- Cập nhật trạng thái cho phiếu đã duyệt
UPDATE gatepasses 
SET 
    approved_by = (SELECT id FROM users WHERE username = 'truongit'),
    approved_at = CURRENT_TIMESTAMP - INTERVAL '1 hour'
WHERE pass_number = 'GP-2023-003';

-- Dữ liệu cho bảng visitors
INSERT INTO visitors (
    gate_pass_id, full_name, phone, id_card_number,
    id_card_front_image, id_card_back_image
) VALUES
(
    (SELECT id FROM gatepasses WHERE pass_number = 'GP-2023-001'),
    'Trần Văn L',
    '0901234578',
    '001234567890',
    '/uploads/id_cards/front_001234567890.jpg',
    '/uploads/id_cards/back_001234567890.jpg'
),
(
    (SELECT id FROM gatepasses WHERE pass_number = 'GP-2023-001'),
    'Hoàng Thị N',
    '0901234580',
    '001234567891',
    '/uploads/id_cards/front_001234567891.jpg',
    '/uploads/id_cards/back_001234567891.jpg'
),
(
    (SELECT id FROM gatepasses WHERE pass_number = 'GP-2023-002'),
    'Nguyễn Thị M',
    '0901234579',
    '001234567892',
    '/uploads/id_cards/front_001234567892.jpg',
    '/uploads/id_cards/back_001234567892.jpg'
),
(
    (SELECT id FROM gatepasses WHERE pass_number = 'GP-2023-003'),
    'Phạm Văn O',
    '0901234581',
    '001234567893',
    '/uploads/id_cards/front_001234567893.jpg',
    '/uploads/id_cards/back_001234567893.jpg'
);

-- Dữ liệu cho bảng licenseplates
INSERT INTO licenseplates (
    gate_pass_id, plate_number, vehicle_type
) VALUES
(
    (SELECT id FROM gatepasses WHERE pass_number = 'GP-2023-001'),
    '51F-12345',
    'Ô tô'
),
(
    (SELECT id FROM gatepasses WHERE pass_number = 'GP-2023-002'),
    '59P1-23456',
    'Xe máy'
),
(
    (SELECT id FROM gatepasses WHERE pass_number = 'GP-2023-003'),
    '51A-67890',
    'Ô tô'
);

-- Dữ liệu cho bảng auditlogs
INSERT INTO auditlogs (
    user_id, action, entity_type, entity_id, details
) VALUES
(
    (SELECT id FROM users WHERE username = 'khach1'),
    'CREATE',
    'gate_pass',
    (SELECT id FROM gatepasses WHERE pass_number = 'GP-2023-001'),
    'Tạo phiếu ra vào cổng mới'
),
(
    (SELECT id FROM users WHERE username = 'khach2'),
    'CREATE',
    'gate_pass',
    (SELECT id FROM gatepasses WHERE pass_number = 'GP-2023-002'),
    'Tạo phiếu ra vào cổng mới'
),
(
    (SELECT id FROM users WHERE username = 'nhanvien1'),
    'CREATE',
    'gate_pass',
    (SELECT id FROM gatepasses WHERE pass_number = 'GP-2023-003'),
    'Tạo phiếu ra vào cổng mới'
),
(
    (SELECT id FROM users WHERE username = 'truongit'),
    'APPROVE',
    'gate_pass',
    (SELECT id FROM gatepasses WHERE pass_number = 'GP-2023-003'),
    'Duyệt phiếu ra vào cổng'
); 