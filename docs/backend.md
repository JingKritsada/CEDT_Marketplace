# CEDT Community Marketplace Backend

## Project Title and Description

CEDT Community Marketplace Backend is a Node.js REST API for an iOS marketplace that helps engineering students buy, sell, and give away robotics and hardware equipment. It provides authentication, listing management, reviews, carts, and pickup locations, with Prisma + PostgreSQL as the data layer.

## Tech Stack

- Runtime: Node.js (v18+)
- Framework: Express.js
- Language: TypeScript
- Database: PostgreSQL (Prisma ORM)
- Auth: JWT (access + refresh)
- Validation: Zod
- Docs: Swagger (OpenAPI 3.0)
- Realtime: Socket.IO
- Testing: Node test runner + Supertest

## Getting Started

### Prerequisites

- Node.js v18+
- PostgreSQL database
- npm (or compatible package manager)

### Install

```bash
cd backend
npm install
```

### Setup Environment Variables

Create a `.env` file in `backend/` using the variables below.

### Database

```bash
npm run prisma:generate
npm run prisma:migrate
npm run prisma:seed
```

### Run the Server

```bash
npm run dev
```

## Environment Variables

```env
NODE_ENV=development
PORT=3003
CORS_ORIGIN=http://localhost:3000

DATABASE_URL="postgresql://username:password@localhost:5432/cedt_marketplace?schema=public"

BCRYPT_SALT_ROUNDS=12
JWT_SECRET="your-access-secret"
JWT_REFRESH_SECRET="your-refresh-secret"
STUDENT_EMAIL_DOMAIN="student.chula.ac.th"
```

## API Documentation

- Swagger UI: `http://localhost:3003/api-docs`
- Postman collection: [docs/api.postman_collection.json](docs/api.postman_collection.json)

### Auth

| Method | Path           | Description                  | Auth |
| ------ | -------------- | ---------------------------- | ---- |
| POST   | /auth/register | Register a student account   | No   |
| POST   | /auth/login    | Login and issue tokens       | No   |
| POST   | /auth/refresh  | Rotate access/refresh tokens | No   |
| POST   | /auth/logout   | Revoke refresh token         | No   |

### Users

| Method | Path      | Description                     | Auth |
| ------ | --------- | ------------------------------- | ---- |
| GET    | /users/me | Current user profile            | Yes  |
| PATCH  | /users/me | Update profile and social links | Yes  |

### Listings

| Method | Path                           | Description              | Auth        |
| ------ | ------------------------------ | ------------------------ | ----------- |
| GET    | /listings                      | List/filter listings     | No          |
| GET    | /listings/search               | Full-text search         | No          |
| GET    | /listings/:id                  | Listing detail           | No          |
| POST   | /listings                      | Create listing           | Yes         |
| PATCH  | /listings/:id                  | Update listing or status | Yes (owner) |
| POST   | /listings/:id/confirm-received | Buyer confirms receipt   | Yes (buyer) |
| DELETE | /listings/:id                  | Delete listing           | Yes (owner) |

### Categories and Pickup Locations

| Method | Path              | Description       | Auth |
| ------ | ----------------- | ----------------- | ---- |
| GET    | /categories       | List categories   | No   |
| GET    | /pickup-locations | List pickup spots | No   |

### Cart

| Method | Path                   | Description         | Auth |
| ------ | ---------------------- | ------------------- | ---- |
| GET    | /cart                  | Get current cart    | Yes  |
| POST   | /cart/items            | Add listing to cart | Yes  |
| DELETE | /cart/items/:listingId | Remove item         | Yes  |
| DELETE | /cart/clear            | Clear cart          | Yes  |

### Reviews

| Method | Path                | Description        | Auth |
| ------ | ------------------- | ------------------ | ---- |
| GET    | /reviews?listingId= | Reviews by listing | No   |
| GET    | /reviews?sellerId=  | Reviews by seller  | No   |
| POST   | /reviews            | Create review      | Yes  |

## Request/Response Examples

### Register

```http
POST /auth/register
Content-Type: application/json

{
	"studentId": "666776766767",
	"email": "test66676@student.chula.ac.th",
	"displayName": "Phachara1234",
	"password": "12345678"
}
```

```json
{
	"message": "User registered successfully",
	"accessToken": "<jwt>",
	"refreshToken": "<jwt>",
	"user": {
		"id": "cuid",
		"email": "test66676@student.chula.ac.th",
		"displayName": "Phachara1234",
		"studentId": "666776766767"
	}
}
```

### Create Listing

```http
POST /listings
Authorization: Bearer <token>
Content-Type: application/json

{
	"title": "[Free] Engineering Mathematics 1",
	"description": "Condition 80%",
	"price": 0,
	"isFree": true,
	"courseCode": "2110101",
	"categoryId": "<categoryId>",
	"pickupLocationId": "<pickupLocationId>",
	"images": ["https://example.com/calculus-book.jpg"]
}
```

```json
{
	"id": "cuid",
	"title": "[Free] Engineering Mathematics 1",
	"status": "AVAILABLE",
	"seller": {
		"id": "cuid",
		"displayName": "Phachara1234"
	}
}
```

### Add to Cart

```http
POST /cart/items
Authorization: Bearer <token>
Content-Type: application/json

{
	"listingId": "<listingId>"
}
```

```json
{
	"id": "cuid",
	"listingId": "<listingId>",
	"quantity": 1
}
```

### Create Review

```http
POST /reviews
Authorization: Bearer <token>
Content-Type: application/json

{
	"listingId": "<listingId>",
	"rating": 5,
	"comment": "Great seller, smooth transaction."
}
```

```json
{
	"id": "cuid",
	"rating": 5,
	"comment": "Great seller, smooth transaction.",
	"reviewer": {
		"id": "cuid",
		"displayName": "Buyer Name"
	}
}
```
