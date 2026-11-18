package com.akt.order_orchestrator.repository.specification;

import com.akt.order_orchestrator.model.entity.Product;
import org.springframework.data.jpa.domain.Specification;

import java.math.BigDecimal;

public final class ProductSpecification {

    private ProductSpecification() {}

    public static Specification<Product> hasCategory(String category) {

        return ((root, query, criteriaBuilder) -> {
            if (category == null || category.isBlank()) {
                return null;
            }
            return criteriaBuilder.equal(criteriaBuilder.lower(root.get("category")), category.trim().toLowerCase());
        });
    }

    public static Specification<Product> priceGreaterThanOrEqual(BigDecimal minPrice){

        return (root, query, criteriaBuilder) ->  {
            if (minPrice == null || minPrice.compareTo(BigDecimal.ZERO) < 0) {
                return null;
            }
            return criteriaBuilder.greaterThanOrEqualTo(root.get("price"), minPrice);
        };
    }

    public static Specification<Product> priceLessThanOrEqual(BigDecimal maxPrice){

        return (root, query, criteriaBuilder) ->  {
            if (maxPrice == null || maxPrice.compareTo(BigDecimal.ZERO) < 0) {
                return null;
            }
            return criteriaBuilder.lessThanOrEqualTo(root.get("price"), maxPrice);
        };
    }

    public static Specification<Product> inStockOnly(Boolean inStockOnly) {

        return (root, query, criteriaBuilder) ->  {
            if (!Boolean.TRUE.equals(inStockOnly)) {
                return null;
            }
            return criteriaBuilder.greaterThan(root.get("availableStock"), 0);
        };
    }

    public static Specification<Product> searchByKeyword(String keyword) {

        return (root, query, criteriaBuilder) ->  {
            if (keyword == null || keyword.isBlank()) {
                return null;
            }
            String pattern = "%" + keyword.trim().toLowerCase() + "%";
            return criteriaBuilder.or(
                    criteriaBuilder.like(criteriaBuilder.lower(root.get("name")), pattern),
                    criteriaBuilder.like(criteriaBuilder.lower(root.get("sku")), pattern)
            );
        };
    }

    public static Specification<Product> filterBy(String category,
                                                  BigDecimal minPrice,
                                                  BigDecimal maxPrice,
                                                  Boolean inStockOnly,
                                                  String keyword) {

        return Specification.allOf(
                hasCategory(category),
                priceGreaterThanOrEqual(minPrice),
                priceLessThanOrEqual(maxPrice),
                inStockOnly(inStockOnly),
                searchByKeyword(keyword)
        );
    }
}
