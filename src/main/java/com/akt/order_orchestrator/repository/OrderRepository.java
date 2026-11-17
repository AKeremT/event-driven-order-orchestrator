package com.akt.order_orchestrator.repository;

import com.akt.order_orchestrator.model.entity.Order;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface OrderRepository extends JpaRepository<Order, UUID> {

    @EntityGraph(attributePaths = {"orderItems"})
    Optional<Order> findByIdempotencyKey(String idempotencyKey);

    @EntityGraph(attributePaths = {"orderItems"})
    Optional<Order> findWithItemsById(UUID id);

    Page<Order> findByUserIdOrderByCreatedAtDesc(UUID userId, Pageable pageable);

    @Query(value = """
            SELECT * FROM orders
            WHERE status = 'PENDING_PAYMENT'
                AND expires_at < :now
            ORDER BY expires_at ASC
            LIMIT :batchSize
            FOR UPDATE SKIP LOCKED
            """, nativeQuery = true)
    List<Order> findExpiredPendingOrdersForUpdate(@Param("now")Instant now,
                                                  @Param("batchSize") int batchSize);
}
