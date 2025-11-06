
# Gara Bike Backend (Node.js)

This is a Node.js implementation of the Gara Bike backend.

## Prerequisites

* Node.js
* npm

## Getting Started

1. **Clone the repository:**

   ```bash
   git clone <repository-url>
   ```

2. **Install dependencies:**

   ```bash
   npm install
   ```

3. **Set up the database:**

   ```bash
   npx prisma migrate dev --name init
   ```

4. **Start the server:**

   ```bash
   npm start
   ```

   The server will be running on http://localhost:3000.

## API Endpoints

* `POST /api/register`: Register a new user.
* `POST /api/login`: Log in a user and get a JWT.
* `GET /api/bikes`: Get a list of available bikes.
* `POST /api/bikes/:id/reserve`: Reserve a bike.
* `POST /api/rides/start`: Start a ride.
* `POST /api/verify-otp`: Verify OTP for user registration.
* `GET /api/users/me/referral-code`: Get the user's referral code.
* `GET /api/users/me/statistics`: Get the user's statistics.
* `GET /api/users/me/active-reservation`: Check for an active reservation.
* `GET /api/users/me/active-ride`: Check for an active ride.
* `POST /api/bikes/:id/cancel-reservation`: Cancel a reservation and apply a cancellation fee.
