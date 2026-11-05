CREATE TABLE IF NOT EXISTS spares (
    spare_code VARCHAR(50) PRIMARY KEY,
    spare_name VARCHAR(100) NOT NULL,
    spare_description TEXT,
    spare_type VARCHAR(50),
    spare_status VARCHAR(50),
    price INTEGER,
    quantity INTEGER,
    updated_at VARCHAR(50)
);
