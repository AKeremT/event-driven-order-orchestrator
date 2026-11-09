# 📦 Event-Driven Order & Inventory Orchestrator

[![Java](https://img.shields.io/badge/Java-21-orange.svg?style=for-the-badge&logo=openjdk)](https://www.oracle.com/java/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-4.1.2-brightgreen.svg?style=for-the-badge&logo=springboot)](https://spring.io/projects/spring-boot)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue.svg?style=for-the-badge&logo=postgresql)](https://www.postgresql.org/)
[![Redis](https://img.shields.io/badge/Redis-7-DC382D.svg?style=for-the-badge&logo=redis&logoColor=white)](https://redis.io/)
[![Apache Kafka](https://img.shields.io/badge/Apache%20Kafka-KRaft-231F20.svg?style=for-the-badge&logo=apachekafka)](https://kafka.apache.org/)
[![Testcontainers](https://img.shields.io/badge/Testcontainers-JUnit5-darkblue.svg?style=for-the-badge&logo=testcontainers)](https://testcontainers.com/)

High-concurrency e-commerce order and inventory orchestration engine built with **Java 21** and **Spring Boot 4**. Designed to solve **Overselling (Race Conditions)**, **Dual-Write Inconsistency (Transactional Outbox Pattern)**, **Inventory Starvation (Reservation TTL)**, and **Duplicate Event Processing (Idempotent Kafka Consumers)**.

---

## 🗺️ Engineering Roadmap

- [x] **Phase 1: Project Initialization & Architecture Blueprint**
  - [x] Case study specification & domain modeling (`Product`, `Order`, `OrderItem`, `OutboxEvent`, `ProcessedEvent`, `User`)
  - [x] Spring Boot 4.1.2 & Java 21 LTS skeleton setup
- [ ] **Phase 2: Infrastructure & Database Schema (Flyway)**
  - [ ] Docker Compose orchestration (`PostgreSQL 16`, `Redis 7`, `Apache Kafka KRaft`)
  - [ ] Flyway physical DDL migrations (`ddl-auto=validate`), composite indexes & DB check constraints (`available_stock >= 0`)
- [ ] **Phase 3: Domain Layer, Soft Delete & JPA Performance**
  - [ ] Core entities with Optimistic Locking (`@Version`), JPA Auditing (`@CreatedDate`, `@LastModifiedDate`), and Soft Delete (`@SQLRestriction`)
  - [ ] Zero `N+1` query guarantee using `@EntityGraph` / `JOIN FETCH`
  - [ ] Dynamic catalog search with Spring Data JPA `Specification` API & `Pageable`
- [ ] **Phase 4: Redis Cache-Aside & Catalog Engine**
  - [ ] Product lookup caching (`@Cacheable` / TTL) and automatic cache eviction (`@CacheEvict`) on price/stock updates
- [ ] **Phase 5: Concurrency-Safe Inventory Reservation & Order State Machine**
  - [ ] 3-Dimensional Stock Management (`availableStock`, `reservedStock`, `sold`)
  - [ ] Overselling prevention via Optimistic Locking (`@Version`) & Atomic Conditional SQL updates
  - [ ] Strict Order State Machine (`PENDING_PAYMENT` $\rightarrow$ `PAID` $\rightarrow$ `SHIPPED` $\rightarrow$ `DELIVERED` / `CANCELLED` / `EXPIRED`)
  - [ ] Client-level Idempotency shield (`Idempotency-Key` header) & Historical Price Snapshot on `OrderItem`
- [ ] **Phase 6: Order Expiration Scheduler (`SKIP LOCKED`)**
  - [ ] Background TTL job releasing unpaid reserved stock back to available pool using `SELECT ... FOR UPDATE SKIP LOCKED`
- [ ] **Phase 7: Transactional Outbox Pattern & Apache Kafka (Event-Driven)**
  - [ ] Atomic persistence of `Order` + `OutboxEvent` (JSONB) within a single transaction to eliminate Dual-Write problem
  - [ ] Outbox Relay / Poller publishing events to Kafka with `orderId` Partition Key (FIFO Ordering Guarantee)
  - [ ] Idempotent Kafka Consumer (`processed_events` deduplication), Non-Blocking Retry (`@RetryableTopic`) & Dead Letter Topic (`DLT`)
- [ ] **Phase 8: Enterprise Security (Stateless JWT, RBAC & BOLA Protection)**
  - [ ] Role-based access control (`ROLE_CUSTOMER`, `ROLE_SELLER`, `ROLE_ADMIN`)
  - [ ] Resource ownership verification (preventing Broken Object Level Authorization / IDOR on orders)
- [ ] **Phase 9: Verification & Multi-Container Stress Testing (Testcontainers)**
  - [ ] Mockito unit test suite for State Machine & Inventory rules
  - [ ] 100-Thread Overselling Concurrency Stress Test on real PostgreSQL container
  - [ ] End-to-End Outbox $\rightarrow$ Kafka $\rightarrow$ Idempotent Consumer verification with `Awaitility`
- [ ] **Phase 10: Observability, Containerization & CI/CD**
  - [ ] MDC Correlation ID tracing, Custom Micrometer business metrics, Prometheus & Grafana
  - [ ] OpenAPI 3 / Swagger UI documentation, Multi-stage production `Dockerfile` & GitHub Actions CI pipeline
