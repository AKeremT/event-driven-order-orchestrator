-- PRODUCTS
CREATE TABLE products(
    id UUID PRIMARY KEY,
    sku VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    price NUMERIC(19, 4) NOT NULL,
    available_stock INTEGER NOT NULL,
    reserved_stock INTEGER NOT NULL,
    version BIGINT NOT NULL DEFAULT 0,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ,

    CONSTRAINT chk_products_price_positive CHECK ( price > 0 ),
    CONSTRAINT chk_products_available_stock_non_negative CHECK ( available_stock >= 0 ),
    CONSTRAINT chk_products_reserved_stock_non_negative CHECK ( reserved_stock >= 0 )
);

CREATE INDEX idx_products_category_active
    ON products (category)
    WHERE deleted = FALSE;

-- USERS
CREATE TABLE users(
    id UUID PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ
);

-- ORDERS
CREATE TABLE orders(
    id UUID PRIMARY KEY,
    order_number VARCHAR(100) NOT NULL UNIQUE,
    user_id UUID NOT NULL REFERENCES users(id),
    idempotency_key VARCHAR(100) NOT NULL UNIQUE,
    status VARCHAR(100) NOT NULL,
    total_amount NUMERIC(19, 4) NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    version BIGINT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ,

    CONSTRAINT chk_orders_total_amount_non_negative CHECK ( total_amount >= 0 )
);

CREATE INDEX idx_orders_user_id_created_at
    ON orders(user_id, created_at DESC);

CREATE INDEX idx_orders_pending_expires_at
    ON orders(expires_at)
    WHERE status = 'PENDING_PAYMENT';