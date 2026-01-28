# Contributing to Digital Banking Platform

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to this project.

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/yourusername/digitalbanking.git`
3. Create a feature branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test your changes thoroughly
6. Commit with clear messages
7. Push to your fork
8. Create a Pull Request

## Development Setup

### Prerequisites
- Node.js 18.x or higher
- Docker and Docker Compose
- Git

### Local Setup
```bash
# Install all dependencies
make install

# Or install individually
cd auth-api && npm install
cd accounts-api && npm install
cd transactions-api && npm install
cd digitalbank-frontend && npm install
```

## Project Structure

Each microservice follows this structure:
```
service-name/
├── src/
│   ├── config/       # Configuration files
│   ├── controllers/  # Business logic
│   ├── middleware/   # Custom middleware
│   ├── routes/       # API routes
│   └── server.js     # Entry point
├── Dockerfile
├── package.json
└── .env.example
```

## Coding Standards

### JavaScript/Node.js
- Use ES6+ features
- Follow async/await pattern for async operations
- Use meaningful variable and function names
- Add JSDoc comments for complex functions
- Keep functions small and focused

### React
- Use functional components with hooks
- Keep components small and reusable
- Use meaningful component names
- Implement proper error boundaries
- Handle loading and error states

### Database
- Use parameterized queries (no SQL injection)
- Add proper indexes
- Use transactions for multi-step operations
- Include rollback mechanisms

## API Design Guidelines

- Follow RESTful conventions
- Use proper HTTP methods (GET, POST, PUT, DELETE, PATCH)
- Return appropriate status codes
- Include error messages in responses
- Validate all input data
- Document new endpoints

## Testing

### Unit Tests
```bash
cd service-name
npm test
```

### Integration Tests
```bash
docker-compose up -d
# Run integration tests
```

## Security Guidelines

- Never commit secrets or API keys
- Use environment variables for sensitive data
- Validate and sanitize all user input
- Use parameterized queries
- Implement proper authentication/authorization
- Keep dependencies updated

## Pull Request Process

1. **Update Documentation**: Update README.md if needed
2. **Test Thoroughly**: Ensure all tests pass
3. **Follow Commit Conventions**: Use clear, descriptive commit messages
4. **Code Review**: Address review comments promptly
5. **CI/CD**: Ensure all checks pass

### Commit Message Format
```
type(scope): subject

body

footer
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test changes
- `chore`: Build/config changes

Example:
```
feat(auth): add password reset functionality

Implemented password reset via email with token expiration.
Added new endpoints and email service integration.

Closes #123
```

## Adding New Features

### New API Endpoint
1. Create route in appropriate routes file
2. Add controller method
3. Implement validation
4. Add tests
5. Update API documentation

### New Microservice
1. Create service directory
2. Set up Express server
3. Configure database
4. Add Dockerfile
5. Update docker-compose.yml
6. Document the service

## Common Issues

### Database Connection Errors
- Check DATABASE_URL environment variable
- Ensure PostgreSQL is running
- Verify credentials

### Authentication Errors
- Check JWT_SECRET is set
- Verify token format
- Check token expiration

### Docker Issues
- Run `docker-compose down -v` to clean up
- Rebuild images: `docker-compose build --no-cache`
- Check logs: `docker-compose logs -f service-name`

## Questions?

- Open an issue for bugs
- Start a discussion for features
- Ask questions in pull requests

## License

By contributing, you agree that your contributions will be licensed under the ISC License.
