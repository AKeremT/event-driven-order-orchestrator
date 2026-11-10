package com.akt.order_orchestrator.model.enums;

public enum OutboxEventType {

    ORDER_CREATED,
    ORDER_PAID,
    ORDER_CANCELLED,
    ORDER_EXPIRED,
    ORDER_SHIPPED,
    ORDER_DELIVERED
}
