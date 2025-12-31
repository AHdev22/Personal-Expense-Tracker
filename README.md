# Personal Expense Tracker

!Build Status
!.NET Version
!React Version
!Flutter Version
!License

## 📖 Project Overview

The **Personal Expense Tracker** is a full-stack, cross-platform solution designed to provide a seamless experience for managing personal finances. It empowers users to track expenses, analyze spending habits, and achieve their financial goals from anywhere, whether on a web browser or a mobile device.

### Key Features

-   **Cross-Platform Sync:** Real-time data synchronization between the web dashboard and mobile application.
-   **Secure Authentication:** JWT-based authentication and authorization to protect user data.
-   **CRUD Operations:** Full create, read, update, and delete functionality for expenses, categories, and budgets.
-   **Interactive Dashboard:** Rich data visualizations and reports to analyze spending patterns by category, date, and more.
-   **Budget Management:** Set monthly or categorical budgets and receive alerts when approaching limits.
-   **Receipt Scanning (OCR):** (Future) Automatically parse expense details from uploaded receipt images.
-   **Multi-Currency Support:** Log expenses in different currencies with automatic conversion.

## 🏗️ System Architecture

This project follows a modern microservices-oriented architecture. The **Flutter mobile app** and **React web frontend** act as clients, consuming a secure RESTful API exposed by the **.NET backend**. This separation of concerns ensures scalability, maintainability, and independent development cycles for each module.

### Tech Stack

| Component    | Language   | Framework / Runtime  | Key Libraries/Packages                                  |
| :----------- | :--------- | :------------------- | :------------------------------------------------------ |
| **Backend**  | C#         | .NET 8, ASP.NET Core | Entity Framework Core, MediatR, JWT Bearer, Swashbuckle |
| **Frontend** | TypeScript | React 18, Vite       | Axios, Tailwind CSS, Recharts, TanStack Query           |
| **Mobile**   | Dart       | Flutter 3.x          | `http`, `provider`, `shared_preferences`, `go_router`   |

## 📂 Project Structure

The monorepo is organized into three primary modules, promoting clean separation and focused development.

```sh
personal-expense-tracker/
├── @backend/         # .NET 8 RESTful API
│   ├── Api/
│   ├── Application/
│   ├── Domain/
│   └── Infrastructure/
├── @frontend/        # React (Vite) Web Application
│   ├── public/
│   └── src/
├── @mobile/          # Flutter Mobile Application
│   ├── lib/
│   └── test/
└── README.md         # You are here!
```

## 🚀 Getting Started

Follow these instructions to get the entire system running on your local machine.

### Prerequisites

Ensure the following tools are installed and configured on your system:

-   **Git:** For version control.
-   **Docker & Docker Compose:** For running containerized services (e.g., PostgreSQL database).
-   **.NET SDK:** Version 8.0 or higher.
-   **Node.js:** Version 18.x (LTS) or higher.
-   **Flutter SDK:** Version 3.16 or higher.

### Installation Guide

---

#### 1. Backend Setup (`@backend`)

```bash
# Navigate to the backend directory
cd @backend/Api

# Restore .NET dependencies
dotnet restore

# Apply Entity Framework database migrations
# (Ensure your DB connection string is set in appsettings.Development.json or user secrets)
dotnet ef database update

# Run the backend server (defaults to https://localhost:7001 and http://localhost:5001)
dotnet run
```

---

#### 2. Frontend Setup (`@frontend`)

```bash
# Navigate to the frontend directory
cd @frontend

# Install npm packages
npm install

# Run the development server (defaults to http://localhost:5173)
npm run dev
```

---

#### 3. Mobile Setup (`@mobile`)

```bash
# Navigate to the mobile directory
cd @mobile

# Get Flutter packages
flutter pub get

# Run the app on a connected device or emulator
flutter run
```

## 🔐 Environment Configuration

Each module requires its own environment configuration. Copy the example file to create your local configuration and populate it with the necessary secrets.

-   **Backend (`@backend/Api`):**

    -   Copy `appsettings.json` to `appsettings.Development.json` or use .NET User Secrets.
    -   `ConnectionStrings:DefaultConnection`
    -   `Jwt:Key`
    -   `Jwt:Issuer`
    -   `Jwt:Audience`

-   **Frontend (`@frontend`):**

    -   Copy `.env.example` to `.env`.
    -   `VITE_API_BASE_URL="http://localhost:5001"`

-   **Mobile (`@mobile`):**
    -   Create a file at `@mobile/lib/config.dart` from an example.
    -   `API_BASE_URL="http://10.0.2.2:5001"` (For Android Emulator)

> **Note:** Never commit `.env`, `appsettings.Development.json`, or other files containing secrets to version control.

## 📸 Screen Captures

|            Mobile UI            |     Web Dashboard      |
| :-----------------------------: | :--------------------: |
|           !Mobile UI            |     !Web Dashboard     |
| **API Documentation (Swagger)** | **Expense Entry Form** |
|           !Swagger UI           |      !Entry Form       |

## 🤝 Contribution & License

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

This project is licensed under the **MIT License**. See the `LICENSE` file for more information.
