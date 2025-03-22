# ER Diagram cho Hệ thống Quản lý Ra Vào Cổng

Dưới đây là mô tả ER diagram cho hệ thống dưới dạng Mermaid syntax:

```mermaid
erDiagram
    Users ||--o{ GatePasses : "creates"
    Users ||--o{ GatePasses : "approves"
    Users ||--o{ GatePasses : "checks"
    Users }|--|| Departments : "belongs_to"
    Users ||--o{ Departments : "manages"
    GatePasses ||--o{ Visitors : "includes"
    GatePasses ||--o{ LicensePlates : "includes"
    Permissions }o--o{ RolePermissions : "has"
    Users }o--o{ AuditLogs : "performs"

    Users {
        int id PK
        string username UK
        string password
        string email UK
        string full_name
        string phone
        string department
        string role
        datetime created_at
        datetime updated_at
        boolean is_active
    }

    GatePasses {
        int id PK
        string pass_number UK
        datetime created_at
        date valid_date
        string department_to_visit
        int person_to_visit FK
        string visit_reason
        int created_by FK
        int approved_by FK
        int checked_by FK
        datetime approved_at
        datetime check_in_at
        datetime check_out_at
        string status
        string notes
        datetime updated_at
    }

    Visitors {
        int id PK
        int gate_pass_id FK
        string full_name
        string phone
        string id_card_number
        string id_card_front_image
        string id_card_back_image
        string driver_license_number
        string driver_license_front_image
        string driver_license_back_image
        datetime check_in_at
        datetime check_out_at
        datetime created_at
        datetime updated_at
    }

    LicensePlates {
        int id PK
        int gate_pass_id FK
        string plate_number
        string vehicle_type
        datetime check_in_at
        datetime check_out_at
        datetime created_at
        datetime updated_at
    }

    Departments {
        int id PK
        string name UK
        string description
        int manager_id FK
        datetime created_at
        datetime updated_at
    }

    Permissions {
        int id PK
        string name UK
        string description
        datetime created_at
    }

    RolePermissions {
        int id PK
        string role
        int permission_id FK
        datetime created_at
    }

    AuditLogs {
        int id PK
        int user_id FK
        string action
        string entity_type
        int entity_id
        string details
        datetime created_at
    }
```

## Chú thích

- **PK**: Primary Key (Khóa chính)
- **FK**: Foreign Key (Khóa ngoại)
- **UK**: Unique Key (Khóa duy nhất)

## Các mối quan hệ chính

1. **Users - GatePasses**:
   - Một người dùng có thể tạo nhiều phiếu (1:n)
   - Một người dùng có thể duyệt nhiều phiếu (1:n)
   - Một người dùng có thể kiểm tra nhiều phiếu (1:n)

2. **Users - Departments**:
   - Một người dùng thuộc về một phòng ban (n:1)
   - Một phòng ban có thể có một người quản lý (1:1)

3. **GatePasses - Visitors**:
   - Một phiếu có thể có nhiều khách (1:n)

4. **GatePasses - LicensePlates**:
   - Một phiếu có thể có nhiều biển số xe (1:n)

5. **Permissions - RolePermissions**:
   - Một quyền có thể thuộc về nhiều vai trò (1:n)

6. **Users - AuditLogs**:
   - Một người dùng có thể có nhiều hoạt động được ghi nhật ký (1:n) 