# CEDT Community Marketplace Backend

Backend service for the CEDT Community Marketplace mobile app. It provides REST APIs for authentication, listings, categories, pickup locations, and user profiles, plus Socket.io events for chat updates.

## Tech Stack

- **Runtime**: Node.js 18+
- **Language**: TypeScript
- **Framework**: Express.js (REST API)
- **Database**: PostgreSQL
- **ORM**: Prisma
- **Auth**: JWT (access + refresh tokens), bcryptjs
- **Validation**: Zod
- **Real-time**: Socket.io
- **Docs**: Swagger (OpenAPI 3.0)
- **Security**: Helmet, CORS, rate limiting

## Prerequisites

- Node.js 18+
- PostgreSQL database

## Getting Started

```bash
cd backend
npm install

# Configure environment variables (see below)

npx prisma migrate dev
npm run prisma:generate
npm run dev
```

The server will start on `http://localhost:3003` by default.

## Environment Variables

Create a `.env` file in the `backend` directory:

```env
NODE_ENV=development
PORT=3003
CORS_ORIGIN=http://localhost:3003
DATABASE_URL=postgresql://user:pass@localhost:5432/cedt_marketplace
JWT_SECRET=your-strong-access-secret
JWT_REFRESH_SECRET=your-strong-refresh-secret
BCRYPT_SALT_ROUNDS=12
ALLOWED_EMAIL_DOMAINS=student.chula.ac.th
```

| Variable | Description |
| --- | --- |
| `NODE_ENV` | `development`, `test`, or `production`. |
| `PORT` | API port (default: 3003). |
| `CORS_ORIGIN` | Allowed origins, comma-separated. |
| `DATABASE_URL` | PostgreSQL connection string for Prisma. |
| `JWT_SECRET` | Access token signing secret (32+ chars). |
| `JWT_REFRESH_SECRET` | Refresh token signing secret (32+ chars). |
| `BCRYPT_SALT_ROUNDS` | Password hashing rounds (10-15 recommended). |
| `ALLOWED_EMAIL_DOMAINS` | Comma-separated domains allowed to authenticate. |

## API Documentation

Swagger UI is available at:

- `GET /api-docs` (local: `http://localhost:3003/api-docs`)

### Core Endpoints

| Method | Path | Description | Auth |
| --- | --- | --- | --- |
| POST | `/auth/register` | Register a new user | No |
| POST | `/auth/login` | Login and receive tokens | No |
| POST | `/auth/refresh` | Refresh access token | No |
| POST | `/auth/logout` | Revoke refresh token | No |
| GET | `/listings` | List listings (filterable) | No |
| GET | `/listings/search` | Search listings by text | No |
| POST | `/listings` | Create listing | Yes |
| GET | `/listings/:id` | Get listing by ID | No |
| PATCH | `/listings/:id` | Update listing | Yes (owner) |
| DELETE | `/listings/:id` | Delete listing | Yes (owner) |
| GET | `/categories` | List categories | No |
| GET | `/pickup-locations` | List pickup locations | No |
| GET | `/users/me` | Current user profile | Yes |

## Request/Response Examples

### Login

**Request**

```http
POST /auth/login
Content-Type: application/json

{
  "email": "student001@student.chula.ac.th",
  "password": "strongpassword"
}
```

**Response**

```json
{
  "accessToken": "<jwt>",
  "refreshToken": "<jwt>",
  "user": {
    "id": "cuid",
    "email": "student001@student.chula.ac.th",
    "displayName": "student001",
    "studentId": "student001"
  }
}
```

### Create Listing

**Request**

```http
POST /listings
Authorization: Bearer <accessToken>
Content-Type: application/json

{
  "title": "Robotics Starter Kit",
  "description": "Complete kit with motors and sensors.",
  "price": 850,
  "isFree": false,
  "courseCode": "2110316",
  "categoryId": "categoryId",
  "pickupLocationId": "pickupId",
  "images": ["https://example.com/robot-kit.jpg"]
}
```

**Response**

```json
{
  "id": "listingId",
  "title": "Robotics Starter Kit",
  "status": "AVAILABLE",
  "price": 850,
  "isFree": false,
  "seller": {
    "id": "sellerId",
    "displayName": "student001"
  }
}
```

### Get Listings

**Request**

```http
GET /listings?status=AVAILABLE&minPrice=100&maxPrice=1000
```

**Response**

```json
[
  {
    "id": "listingId",
    "title": "Robotics Starter Kit",
    "status": "AVAILABLE",
    "price": 850,
    "isFree": false
  }
]
```

### Get Current User

**Request**

```http
GET /users/me
Authorization: Bearer <accessToken>
```

**Response**

```json
{
  "id": "userId",
  "email": "student001@student.chula.ac.th",
  "displayName": "student001",
  "studentId": "student001",
  "listings": []
}
```
