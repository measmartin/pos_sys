# POS Web - React Frontend

A React-based web frontend for the POS system. Built with Vite, TypeScript, and Tailwind CSS.

## Features

- **React 19** with TypeScript
- **Vite** for fast development and building
- **Tailwind CSS** for styling
- **shadcn/ui** components
- **JWT Authentication** with login/register
- **API Key Fallback** for backward compatibility
- **Auto-logout** on 401 responses
- **Dashboard** with sales overview and charts
- **Product Management** with categories and units
- **Sales POS** with cart and checkout
- **Reports** with date range filtering
- **Customer Management**

## Getting Started

### Prerequisites

- Node.js 20+
- npm or yarn

### Installation

```bash
cd pos_web
npm install
```

### Configuration

Create a `.env` file or use environment variables:

```env
VITE_API_BASE_URL=http://localhost:5010
VITE_API_KEY=dev-api-key-12345
```

### Running the Application

```bash
npm run dev
```

The app will be available at `http://localhost:5173`.

### Building for Production

```bash
npm run build
```

## Authentication

The app supports JWT authentication:

1. **Login**: Enter username and password to obtain a JWT token
2. **Register**: Create a new account
3. **Auto-logout**: The app automatically redirects to login on 401 responses
4. **API Key Fallback**: If no JWT token is present, the API key is used for backward compatibility

## Project Structure

```
pos_web/
├── src/
│   ├── api/            # API client and auth utilities
│   ├── components/      # Reusable UI components
│   ├── pages/           # Page components
│   ├── layouts/         # Layout components
│   └── lib/             # Utilities
├── @PosApi/            # Shared API types
└── public/             # Static assets
```

## API Client

The API client (`src/api/client.ts`) automatically:
- Attaches JWT `Authorization` header when authenticated
- Falls back to `X-API-Key` header when no token is present
- Redirects to `/login` on 401 responses

## License

Internal use only.
