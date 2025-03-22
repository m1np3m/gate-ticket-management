-- Database schema for Gate Pass Management System

-- Bảng Users: danh sách các user được phép sử dụng phần mềm
CREATE TABLE Users (
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

-- Bảng GatePasses: danh sách các phiếu ra vào cổng
CREATE TABLE GatePasses (
    id SERIAL PRIMARY KEY,
    pass_number VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_date DATE NOT NULL,
    department_to_visit VARCHAR(100) NOT NULL,
    person_to_visit INTEGER REFERENCES Users(id),
    visit_reason TEXT NOT NULL,
    created_by INTEGER REFERENCES Users(id) NOT NULL,
    approved_by INTEGER REFERENCES Users(id),
    checked_by INTEGER REFERENCES Users(id),
    approved_at TIMESTAMP,
    check_in_at TIMESTAMP,
    check_out_at TIMESTAMP,
    status VARCHAR(20) NOT NULL, -- 'created', 'approved', 'checked_in', 'checked_out'
    notes TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng Visitors: danh sách khách vào cổng (mỗi phiếu vào cổng có thể có nhiều khách cùng vào)
CREATE TABLE Visitors (
    id SERIAL PRIMARY KEY,
    gate_pass_id INTEGER REFERENCES GatePasses(id) ON DELETE CASCADE,
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

-- Bảng LicensePlates: danh sách biển số xe của phiếu vào cổng (mỗi phiếu vào cổng có thể có nhiều xe cùng vào)
CREATE TABLE LicensePlates (
    id SERIAL PRIMARY KEY,
    gate_pass_id INTEGER REFERENCES GatePasses(id) ON DELETE CASCADE,
    plate_number VARCHAR(20) NOT NULL,
    vehicle_type VARCHAR(50), -- loại phương tiện (xe máy, ô tô, etc.)
    check_in_at TIMESTAMP,
    check_out_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng Departments: danh sách các phòng ban
CREATE TABLE Departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    manager_id INTEGER REFERENCES Users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng Permission: quản lý phân quyền
CREATE TABLE Permissions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng RolePermissions: phân quyền theo vai trò
CREATE TABLE RolePermissions (
    id SERIAL PRIMARY KEY,
    role VARCHAR(20) NOT NULL, -- 'admin', 'BGD', 'truong_phong', 'nhan_vien', 'khach'
    permission_id INTEGER REFERENCES Permissions(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(role, permission_id)
);

-- Bảng AuditLog: lưu lại các hoạt động trong hệ thống
CREATE TABLE AuditLogs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES Users(id),
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NOT NULL, -- 'gate_pass', 'user', etc.
    entity_id INTEGER,
    details TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_gatepasses_status ON GatePasses(status);
CREATE INDEX idx_gatepasses_created_by ON GatePasses(created_by);
CREATE INDEX idx_gatepasses_valid_date ON GatePasses(valid_date);
CREATE INDEX idx_visitors_gate_pass_id ON Visitors(gate_pass_id);
CREATE INDEX idx_licenseplates_gate_pass_id ON LicensePlates(gate_pass_id);
CREATE INDEX idx_licenseplates_plate_number ON LicensePlates(plate_number); 