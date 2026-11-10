package com.akt.order_orchestrator.model.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.SQLRestriction;

import java.math.BigDecimal;
import java.util.UUID;

@Entity
@Table(name = "products")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@SQLRestriction("deleted = false")
public class Product extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, unique = true)
    private String sku;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String category;

    @Column(nullable = false, precision = 19, scale = 4)
    private BigDecimal price;

    @Column(nullable = false)
    private Integer availableStock;

    @Column(nullable = false)
    private Integer reservedStock;

    @Version
    private Long version;

    @Column(nullable = false)
    @Builder.Default
    private boolean deleted = false;

    public void reserveStock(int quantity) {

        if (quantity <= 0) throw new IllegalArgumentException("Quantity must be greater than zero");
        if (this.availableStock < quantity) throw new IllegalArgumentException("Insufficient available stock");
        this.availableStock -= quantity;
        this.reservedStock += quantity;
    }

    public void releaseReservedStock(int quantity) {

        if (quantity <= 0) throw new IllegalArgumentException("Quantity must be greater than zero");
        if (this.reservedStock < quantity) throw new IllegalArgumentException("Insufficient reserved stock");
        this.reservedStock -= quantity;
        this.availableStock += quantity;
    }

    public void confirmSale(int quantity) {

        if (quantity <= 0) throw new IllegalArgumentException("Quantity must be greater than zero");
        if (this.reservedStock < quantity) throw new IllegalArgumentException("Insufficient reserved stock");
        this.reservedStock -= quantity;
    }
}
