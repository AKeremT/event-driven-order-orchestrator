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

-- ORDER ITEMS
CREATE TABLE order_items(
    id UUID PRIMARY KEY,
    order_id UUID NOT NULL REFERENCES orders(id),
    product_id UUID NOT NULL REFERENCES products(id),
    sku_snapshot VARCHAR(255) NOT NULL,
    product_name_snapshot VARCHAR(255) NOT NULL,
    unit_price_snapshot NUMERIC(19, 4) NOT NULL,
    quantity INTEGER NOT NULL,
    sub_total NUMERIC(19, 4) NOT NULL,

    CONSTRAINT chk_order_items_quantity_positive CHECK ( quantity > 0 ),
    CONSTRAINT chk_order_items_unit_price_snapshot_positive CHECK ( unit_price_snapshot > 0 ),
    CONSTRAINT chk_order_items_sub_total_positive CHECK ( sub_total > 0 )
);

CREATE INDEX idx_order_items_order_id
    ON order_items(order_id);

CREATE INDEX idx_order_items_product_id
    ON order_items(product_id);

-- OUTBOX EVENT
CREATE TABLE outbox_events(
    id UUID PRIMARY KEY,
    aggregate_type VARCHAR(255) NOT NULL,
    aggregate_id UUID NOT NULL,
    event_type VARCHAR(255) NOT NULL,
    payload JSONB NOT NULL,
    status VARCHAR(255) NOT NULL,
    retry_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL,
    processed_at TIMESTAMPTZ,

    CONSTRAINT chk_outbox_event_retry_count_non_negative CHECK ( retry_count >= 0 )
);

CREATE INDEX idx_outbox_events_created_at
    ON outbox_events(created_at)
    WHERE status = 'PENDING';

-- PROCESSED EVENT
CREATE TABLE processed_events(
    id UUID PRIMARY KEY,
    consumer_group VARCHAR(255) NOT NULL,
    processed_at TIMESTAMPTZ NOT NULL
);