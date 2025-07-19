# AcqAdvantage

AcqAdvantage is a comprehensive, cross-platform productivity and research application built with Flutter. It is designed to assist users in their learning, research, and content creation workflows by providing a suite of powerful, integrated tools. The application leverages a robust backend from Backendless for user management and a custom API for its core functionalities, including a sophisticated chat-based research assistant.

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Dependencies](#dependencies)
- [API Integration](#api-integration)

## Features

AcqAdvantage offers a suite of features accessible through a clean, bottom-navigation-based interface:

*   **Research:** An interactive chat interface that connects to a custom API (`acqadvantage-api.onrender.com`) to provide intelligent responses and structured data in the form of "Briefing Cards."
*   **Apply:** A section dedicated to helping users apply the information they have gathered.
*   **Learn:** Tools and resources focused on knowledge acquisition and learning.
*   **Cite:** A utility for generating citations and managing sources, which can be used as a template for other chat-based functionalities.
*   **Simplify:** A feature designed to break down and simplify complex information.
*   **Tools:** A collection of additional productivity and research tools.
*   **User Authentication:** Secure user login and registration via email and Google, powered by Backendless.
*   **Subscription Management:** Integration with Stripe for handling user subscriptions and payments.

## Architecture

The application is built using the Flutter framework and follows a provider-based state management architecture.

*   **State Management:** The app uses the `provider` package for state management, with `AuthProvider` for handling user authentication and `ChatProvider` for managing the chat state.
*   **Backend:** User authentication and data management are handled by [Backendless](https://backendless.com/).
*   **API:** The core chat functionality is powered by a custom API hosted at `https://acqadvantage-api.onrender.com`.
*   **UI:** The user interface is built with Flutter's Material Design widgets, with a custom theme defined in `lib/theme.dart`. The main navigation is handled by a `BottomNavigationBar` in the `AppShell` widget.

## Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

*   Flutter SDK: [Installation Guide](https://flutter.dev/docs/get-started/install)
*   A code editor like VS Code or Android Studio.

### Installation

1.  Clone the repo:
    ```sh
    git clone https://github.com/keithclift24/AcqAdvantage.git
    ```
2.  Navigate to the project directory:
    ```sh
    cd AcqAdvantage
    ```
3.  Install dependencies:
    ```sh
    flutter pub get
    ```
4.  Run the app:
    ```sh
    flutter run
    ```

## Dependencies

The project relies on the following key dependencies:

*   `flutter`: The core Flutter framework.
*   `provider`: For state management.
*   `http`: For making HTTP requests to the custom API.
*   `google_fonts`: For custom fonts.
*   `backendless_sdk`: For integration with the Backendless platform.
*   `flutter_stripe`: For handling payments with Stripe.
*   `flutter_markdown`: For rendering Markdown content.
*   `url_launcher`: For launching URLs.
*   `share_plus`: For sharing content.

## API Integration

The application communicates with a custom backend API for its chat functionality. The API endpoints are hosted at `https://acqadvantage-api.onrender.com` and include:

*   `/start_chat`: Initializes a new chat session.
*   `/reset_thread`: Resets the current chat thread.
*   `/ask`: Sends a user's prompt to the API and receives a streamed response.
*   `/create-checkout-session`: Creates a Stripe checkout session for subscriptions.
*   `/verify-payment-session`: Verifies the status of a payment session.

All API requests are authenticated using a user token obtained from Backendless.
