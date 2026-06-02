# Search Service

Search Service is a Spring Boot application for indexing product data and exposing simple search APIs for keyword and category lookup.
It persists records in Oracle through Spring Data JPA and returns every response in a consistent `ApiResponse<T>` envelope.

## What This Service Does

- Index a product by `productId`
- Search indexed products by keyword or category
- Fetch all indexed products
- Return validation and duplicate-record errors in a stable format
- Expose health and info endpoints through Spring Boot Actuator

## Why It Exists

- Keeps searchable product data separate from the source catalog
- Gives other services and clients a focused search API
- Centralizes duplicate protection, validation, and error handling

## How It Works

- `SearchController` exposes the REST endpoints under `/api/search`
- `SearchServiceImpl` contains the search and indexing rules
- `SearchProductRepository` uses Spring Data JPA to query Oracle
- `SearchProduct` maps to the `search_products` table
- `GlobalExceptionHandler` converts exceptions into API responses with the same response shape as successful calls

## Tech Stack

- Java 21
- Spring Boot
- Spring Web
- Spring Data JPA
- Spring Validation
- Spring Boot Actuator
- Oracle JDBC
- Lombok

## Project Structure

- `src/main/java/com/shopopedia/search/SearchServiceApplication.java`
- `src/main/java/com/shopopedia/search/controller/SearchController.java`
- `src/main/java/com/shopopedia/search/service/SearchService.java`
- `src/main/java/com/shopopedia/search/service/SearchServiceImpl.java`
- `src/main/java/com/shopopedia/search/repository/SearchProductRepository.java`
- `src/main/java/com/shopopedia/search/entity/SearchProduct.java`
- `src/main/java/com/shopopedia/search/dto/*`
- `src/main/java/com/shopopedia/search/exception/*`
- `src/main/resources/application.yml`

## Configuration

The application is configured in `src/main/resources/application.yml`.

Key defaults:

- Server port: `8084`
- Application name: `search-service`
- Oracle database URL: `jdbc:oracle:thin:@localhost:1521/FREEPDB1`
- Database username: `search_service`
- Database password: `search_service_pass`
- JPA schema mode: `update`
- Actuator exposure: `health`, `info`

Adjust those values before running against a different environment.

## API Reference

Base URL:

```text
http://localhost:8084
```

All endpoints return the same response wrapper:

```json
{
  "timestamp": "2026-06-02T10:15:30.123",
  "status": 200,
  "message": "Products fetched successfully",
  "data": []
}
```

### POST `/api/search/products/index`

Indexes a new product.

Request body:

- `productId` - required, unique `Long`
- `name` - required
- `description` - optional
- `category` - required
- `price` - optional
- `stock` - optional

Behavior:

- Returns `201 Created` on success
- Rejects duplicate `productId` values with `409 Conflict`
- Runs validation before the product is saved

Example:

```bash
curl -X POST "http://localhost:8084/api/search/products/index" \
  -H "Content-Type: application/json" \
  -d '{
    "productId": 1001,
    "name": "Wireless Mouse",
    "description": "2.4 GHz ergonomic mouse",
    "category": "electronics",
    "price": 1299.0,
    "stock": 25
  }'
```

Example response:

```json
{
  "timestamp": "2026-06-02T10:15:30.123",
  "status": 201,
  "message": "Product indexed successfully",
  "data": {
    "id": 1,
    "productId": 1001,
    "name": "Wireless Mouse",
    "description": "2.4 GHz ergonomic mouse",
    "category": "electronics",
    "price": 1299.0,
    "stock": 25
  }
}
```

### GET `/api/search/products`

Searches products.

Query parameters:

- `keyword` - optional
- `category` - optional

Search behavior:

- If `keyword` is present and not blank, the service searches by `name` or `description`
- If `keyword` is missing or blank and `category` is present, the service searches by category
- If both are missing, the service returns all indexed products
- If both are present, `keyword` takes precedence

Example:

```bash
curl "http://localhost:8084/api/search/products?keyword=mouse"
```

### GET `/api/search/products/all`

Returns every indexed product without filtering.

Example:

```bash
curl "http://localhost:8084/api/search/products/all"
```

### Actuator Endpoints

- `GET /actuator/health`
- `GET /actuator/info`

## Error Responses

### 400 Bad Request

Returned when validation fails.

Example:

```json
{
  "timestamp": "2026-06-02T10:15:30.123",
  "status": 400,
  "message": "Validation failed",
  "data": {
    "name": "Product name is required",
    "category": "Category is required"
  }
}
```

### 409 Conflict

Returned when the same `productId` has already been indexed.

Example:

```json
{
  "timestamp": "2026-06-02T10:15:30.123",
  "status": 409,
  "message": "Product already indexed with productId: 1001",
  "data": null
}
```

## Local Run Instructions

1. Install JDK 21.
2. Make sure Oracle is running and the datasource values in `application.yml` are correct.
3. Start the application:

```bash
./gradlew bootRun
```

4. Build the project:

```bash
./gradlew clean build
```

5. Verify the service:

```bash
curl http://localhost:8084/actuator/health
```

If the Gradle wrapper needs to download its distribution the first time, make sure the machine has network access or use a locally installed Gradle distribution.

## Data Model Notes

- Database table: `search_products`
- Primary key: `id`
- Business uniqueness key: `productId`
- `indexedAt` is populated automatically before insert

## Current Search Rules

- Keyword search uses `name` and `description`
- Category search uses `category`
- If neither query parameter is provided, all indexed products are returned

