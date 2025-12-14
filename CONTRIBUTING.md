# Contributing to VibeCheck

Thank you for your interest in contributing to VibeCheck! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Code Style Guidelines](#code-style-guidelines)
- [Commit Message Guidelines](#commit-message-guidelines)
- [Pull Request Process](#pull-request-process)
- [Testing](#testing)

## Code of Conduct

We expect all contributors to:
- Be respectful and inclusive
- Provide constructive feedback
- Focus on the issue, not the person
- Accept responsibility for mistakes

## Getting Started

### Prerequisites

1. **Node.js** (v18 or later)
2. **Flutter SDK** (3.0 or later)
3. **Docker & Docker Compose**
4. **Git**

### Setting Up the Development Environment

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ommanoj88/PT.git
   cd PT
   ```

2. **Start the database services:**
   ```bash
   docker-compose up -d
   ```

3. **Set up the backend:**
   ```bash
   cd backend
   npm install
   cp .env.example .env
   npm run dev
   ```

4. **Set up the frontend (in a new terminal):**
   ```bash
   cd frontend
   flutter pub get
   flutter run
   ```

## Development Workflow

### Branch Naming Convention

- `feature/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation updates
- `refactor/description` - Code refactoring
- `test/description` - Test additions/updates

### Creating a Feature

1. Create a new branch from `main`:
   ```bash
   git checkout main
   git pull origin main
   git checkout -b feature/your-feature-name
   ```

2. Make your changes with clear, focused commits

3. Push your branch and create a Pull Request

## Code Style Guidelines

### Backend (TypeScript/Node.js)

- Use **ESLint** and **Prettier** for code formatting
- Run linting before committing:
  ```bash
  npm run lint
  npm run format
  ```
- Use `async/await` over callbacks
- Always handle errors with try/catch
- Use descriptive variable names
- Add JSDoc comments for public functions

### Frontend (Flutter/Dart)

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Run `flutter analyze` before committing
- Use `const` constructors where possible
- Keep widgets small and focused
- Document public APIs with `///` comments

### General Guidelines

- Keep functions small and focused (single responsibility)
- Write self-documenting code
- Add comments only when necessary to explain *why*, not *what*
- Use meaningful variable and function names

## Commit Message Guidelines

We follow conventional commits:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Code style changes (formatting, semicolons, etc.)
- `refactor`: Code changes that neither fix a bug nor add a feature
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples

```
feat(auth): add mock authentication endpoint

fix(chat): resolve message ordering issue

docs(readme): update installation instructions

refactor(feed): simplify discovery algorithm
```

## Pull Request Process

1. **Before submitting:**
   - Ensure all tests pass
   - Run linting and fix any issues
   - Update documentation if needed
   - Rebase on latest `main` if needed

2. **PR Description should include:**
   - Summary of changes
   - Related issue number (if applicable)
   - Screenshots for UI changes
   - Testing steps

3. **Review Process:**
   - At least one approval required
   - All CI checks must pass
   - Address review feedback promptly

4. **After Merge:**
   - Delete your feature branch
   - Celebrate! 🎉

## Testing

### Backend

Currently, the backend uses manual testing. Future improvements include:
- Unit tests with Jest
- Integration tests for API endpoints
- Database migration tests

### Frontend

Flutter tests are located in the `test/` directory:

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

### Manual Testing Checklist

Before submitting a PR, verify:

- [ ] Health check endpoint responds
- [ ] Login/authentication works
- [ ] Profile creation and updates work
- [ ] Feed displays correctly
- [ ] Like/Pass interactions work
- [ ] Matches are created correctly
- [ ] Chat messages can be sent/received
- [ ] Wallet credits update correctly
- [ ] Notifications appear correctly

## Project Structure

```
PT/
├── backend/           # Node.js API server
│   ├── src/
│   │   ├── config/    # Database configuration
│   │   ├── middleware/# Auth middleware
│   │   ├── models/    # Data models
│   │   ├── routes/    # API routes
│   │   └── server.ts  # Main entry point
│   └── package.json
├── frontend/          # Flutter mobile app
│   ├── lib/
│   │   ├── config.dart    # API configuration
│   │   ├── main.dart      # App entry point
│   │   ├── models/        # Data models
│   │   ├── screens/       # UI screens
│   │   ├── services/      # API services
│   │   └── widgets/       # Reusable widgets
│   └── pubspec.yaml
├── docs/              # Documentation
├── docker-compose.yml # Database services
└── README.md
```

## Questions?

If you have questions about contributing, please open an issue with the `question` label.

Thank you for contributing to VibeCheck! 💜
