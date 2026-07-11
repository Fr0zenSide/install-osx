# AAGENT.md - Universal Agent Development Guide

## Overview

This guide provides a comprehensive framework for developing software applications across any programming language and framework. It captures universal best practices, architecture patterns, and development methodologies that apply to web, mobile, desktop, and cloud applications.

## Core Principles

### 1. Architecture Patterns

#### Layered Architecture
```
┌─────────────────────────────────────┐
│   Presentation Layer                │
│   - Views/UI Components             │
│   - Controllers/Handlers            │
│   - State Management                │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│   Domain Layer                      │
│   - Business Logic                  │
│   - Use Cases                       │
│   - Protocols/Interfaces            │
│   - Error Types                     │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│   Data Layer                        │
│   - Repositories                    │
│   - Models                          │
│   - API Communication               │
│   - Database Access                 │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│   Infrastructure Layer              │
│   - Database                        │
│   - Cache                            │
│   - Message Queues                  │
│   - External Services               │
└─────────────────────────────────────┘
```

#### Common Patterns
- **MVVM/MVC/MVP**: Separation of concerns
- **Repository Pattern**: Data access abstraction
- **Service Layer**: Business logic encapsulation
- **Factory Pattern**: Object creation
- **Strategy Pattern**: Algorithm selection
- **Observer Pattern**: Event handling
- **Dependency Injection**: Loose coupling

### 2. Language-Agnostic Principles

#### Code Quality
- **DRY (Don't Repeat Yourself)**: Avoid duplication
- **KISS (Keep It Simple, Stupid)**: Simple solutions
- **YAGNI (You Aren't Gonna Need It)**: Avoid over-engineering
- **SOLID Principles**: Single responsibility, Open/closed, Liskov substitution, Interface segregation, Dependency inversion
- **Clean Code**: Readable, maintainable, testable

#### Naming Conventions
- Use descriptive names
- Follow language conventions
- Be consistent
- Avoid abbreviations
- Use meaningful variable names

#### Error Handling
- Handle errors explicitly
- Use appropriate error types
- Provide meaningful error messages
- Log errors appropriately
- Don't swallow errors

## Development Workflow

### 1. Planning Phase

#### Requirements Analysis
- Define clear requirements
- Identify user stories
- Prioritize features
- Define acceptance criteria

#### Architecture Design
- Choose appropriate architecture
- Design data models
- Plan API contracts
- Define interfaces

#### Technical Decisions
- Select technology stack
- Choose database
- Plan deployment strategy
- Define monitoring approach

### 2. Implementation Phase

#### Step 1: Data Layer
1. **Define Models**: Create data structures
2. **Repository Pattern**: Implement data access
3. **API Integration**: Connect to external services
4. **Database Schema**: Design database tables

#### Step 2: Domain Layer
1. **Business Logic**: Implement core functionality
2. **Use Cases**: Encapsulate workflows
3. **Protocols**: Define interfaces
4. **Error Types**: Create error definitions

#### Step 3: Presentation Layer
1. **UI Components**: Create user interface
2. **Controllers**: Handle user input
3. **State Management**: Manage application state
4. **Routing**: Handle navigation

#### Step 4: Integration
1. **Wire Dependencies**: Connect all layers
2. **API Endpoints**: Implement REST/gRPC
3. **Authentication**: Handle security
4. **Testing**: Verify functionality

### 3. Testing Phase

#### Unit Tests
- Test business logic in isolation
- Mock dependencies
- Test error paths
- Verify state transitions

#### Integration Tests
- Test component interactions
- Verify API contracts
- Test database operations
- Test external services

#### End-to-End Tests
- Test complete user journeys
- Verify workflows
- Test edge cases
- Validate requirements

#### Test Organization
- Separate test files
- Use descriptive names
- Test happy paths and error paths
- Maintain high coverage

### 4. Documentation Phase

#### Code Documentation
- Document public APIs
- Add inline comments
- Use documentation comments
- Keep documentation updated

#### API Documentation
- Document endpoints
- Define request/response formats
- Provide examples
- Include error responses

#### User Documentation
- Installation guide
- Usage instructions
- Troubleshooting guide
- API reference

## Common Pitfalls & Solutions

### 1. Architecture Issues

**Problem**: Tight coupling between components
**Solution**:
```typescript
// Use interfaces/protocols
interface UserRepository {
  findById(id: string): Promise<User>;
  save(user: User): Promise<void>;
}

// Dependency injection
class UserService {
  constructor(private repo: UserRepository) {}
}
```

**Problem**: God objects with too many responsibilities
**Solution**:
- Break down into smaller, focused components
- Apply Single Responsibility Principle
- Use composition over inheritance

### 2. Performance Issues

**Problem**: N+1 query problem
**Solution**:
```javascript
// Eager loading
const users = await User.findAll({
  include: [{ model: Post }]
});

// Or use batch operations
await Promise.all(users.map(u => u.save()));
```

**Problem**: Memory leaks
**Solution**:
- Clean up event listeners
- Cancel async operations
- Use weak references
- Monitor memory usage

**Problem**: Slow database queries
**Solution**:
- Add proper indexes
- Use query optimization
- Implement caching
- Consider database sharding

### 3. Security Issues

**Problem**: SQL injection
**Solution**:
```typescript
// Use parameterized queries
await db.query('SELECT * FROM users WHERE id = ?', [userId]);

// Or use ORM
const user = await User.findById(userId);
```

**Problem**: Authentication bypass
**Solution**:
- Implement proper authentication
- Use secure password hashing
- Implement rate limiting
- Use HTTPS

**Problem**: Data exposure
**Solution**:
- Validate all inputs
- Sanitize outputs
- Use encryption
- Implement access controls

### 4. Testing Issues

**Problem**: Tests are slow
**Solution**:
- Use test databases
- Mock external services
- Run tests in parallel
- Use CI/CD for testing

**Problem**: Tests are flaky
**Solution**:
- Use proper assertions
- Wait for async operations
- Clean up test data
- Use isolated test environments

**Problem**: Tests are hard to maintain
**Solution**:
- Keep tests simple
- Use descriptive names
- Test one thing at a time
- Maintain high coverage

### 5. Deployment Issues

**Problem**: Configuration management
**Solution**:
```typescript
// Use environment variables
const dbUrl = process.env.DATABASE_URL;
const apiKey = process.env.API_KEY;

// Use configuration files
// config/default.json
// config/production.json
```

**Problem**: Database migrations
**Solution**:
- Use migration tools
- Version control migrations
- Test migrations
- Rollback plan

**Problem**: Monitoring and logging
**Solution**:
- Implement structured logging
- Monitor key metrics
- Set up alerts
- Use APM tools

## Best Practices by Category

### 1. Code Quality

#### Linting
- Use linters for your language
- Configure rules
- Fix all warnings
- Keep linters updated

#### Formatting
- Use consistent formatting
- Configure formatters
- Auto-format on save
- Use pre-commit hooks

#### Type Safety
- Use static typing when available
- Define interfaces/types
- Avoid `any` types
- Use type guards

### 2. Error Handling

#### Error Types
```typescript
// Define custom error types
class ValidationError extends Error {
  constructor(message: string, public field: string) {
    super(message);
    this.name = 'ValidationError';
  }
}

class NotFoundError extends Error {
  constructor(resource: string) {
    super(`${resource} not found`);
    this.name = 'NotFoundError';
  }
}
```

#### Error Handling Patterns
```typescript
// Try-catch with proper handling
try {
  const result = await service.doSomething();
} catch (error) {
  if (error instanceof ValidationError) {
    // Handle validation error
  } else if (error instanceof NotFoundError) {
    // Handle not found error
  } else {
    // Handle unexpected error
    logger.error(error);
    throw new InternalServerError();
  }
}
```

### 3. State Management

#### Options
- **Local State**: Component-level state
- **Global State**: Application-wide state
- **Server State**: Data from backend

#### Patterns
```typescript
// Redux pattern
interface State {
  users: User[];
  loading: boolean;
  error: string | null;
}

// Context API pattern
const UserContext = createContext<UserContextType>(null);

// Event sourcing pattern
class UserAggregate {
  private events: Event[] = [];
  apply(event: Event) {
    this.events.push(event);
    // Apply event to state
  }
}
```

### 4. API Design

#### RESTful Principles
- Use proper HTTP methods (GET, POST, PUT, DELETE)
- Use appropriate status codes
- Implement pagination
- Use proper headers

#### GraphQL
- Define schema
- Use resolvers
- Implement caching
- Handle errors

#### gRPC
- Define protobuf
- Use streaming
- Implement authentication
- Use load balancing

### 5. Database Design

#### Schema Design
- Normalize data
- Use proper indexes
- Define relationships
- Plan migrations

#### Query Optimization
- Use indexes
- Avoid N+1 queries
- Use connection pooling
- Implement caching

#### Data Consistency
- Use transactions
- Handle concurrency
- Implement optimistic locking
- Use database constraints

### 6. Performance Optimization

#### Frontend
- Code splitting
- Lazy loading
- Image optimization
- Minimize re-renders

#### Backend
- Caching strategies
- Database optimization
- API response optimization
- Load balancing

#### Infrastructure
- CDN usage
- Auto-scaling
- Database sharding
- Microservices

### 7. Security Best Practices

#### Authentication
- Implement proper authentication
- Use secure password storage
- Implement JWT/OAuth
- Use session management

#### Authorization
- Implement role-based access
- Use permission checks
- Implement resource ownership
- Use access control lists

#### Data Protection
- Encrypt sensitive data
- Use HTTPS
- Implement input validation
- Sanitize outputs

### 8. Monitoring and Observability

#### Logging
- Structured logging
- Log levels
- Log context
- Log aggregation

#### Metrics
- Application metrics
- Performance metrics
- Error rates
- User metrics

#### Tracing
- Distributed tracing
- Request tracing
- Performance monitoring
- Error tracking

### 9. DevOps Practices

#### CI/CD
- Automated testing
- Automated deployment
- Code quality checks
- Release management

#### Infrastructure as Code
- Use IaC tools
- Version control infrastructure
- Automated provisioning
- Infrastructure testing

#### Containerization
- Docker containers
- Container orchestration
- Container security
- Container networking

### 10. Cloud Deployment

#### Cloud Providers
- AWS, Azure, GCP
- Serverless functions
- Managed services
- Auto-scaling

#### Deployment Strategies
- Blue-green deployment
- Canary releases
- Rolling updates
- Zero-downtime deployment

#### Cost Optimization
- Right-sizing resources
- Use spot instances
- Implement auto-scaling
- Monitor costs

## Technology Stack Selection

### Web Development

#### Frontend
- React, Vue, Angular
- Next.js, Nuxt.js
- Svelte, Solid
- TypeScript, JavaScript

#### Backend
- Node.js, Python, Go
- Java, C#
- Rust, Swift
- TypeScript, JavaScript

#### Database
- PostgreSQL, MySQL
- MongoDB, Redis
- Cassandra, DynamoDB
- Elasticsearch

### Mobile Development

#### iOS
- Swift, SwiftUI
- Objective-C
- React Native
- Flutter

#### Android
- Kotlin, Jetpack Compose
- Java
- React Native
- Flutter

### Desktop Development

#### Cross-platform
- Electron, Tauri
- React Native Desktop
- Flutter Desktop

#### Native
- Electron, Tauri
- React Native Desktop
- Flutter Desktop

### Backend Services

#### Microservices
- Go, Rust, Node.js
- Spring Boot, .NET
- Django, Flask
- FastAPI, NestJS

#### API Gateway
- Kong, AWS API Gateway
- Nginx, Traefik
- Envoy, HAProxy

#### Message Queues
- RabbitMQ, Kafka
- AWS SQS, Azure Service Bus
- Redis, Memcached

## Development Tools

### Code Editors
- VS Code, IntelliJ IDEA
- Sublime Text, Vim
- Atom, Visual Studio
- Cursor, Zed

### Version Control
- Git, GitHub, GitLab
- Bitbucket, Azure DevOps
- SourceTree, GitKraken

### CI/CD
- GitHub Actions, GitLab CI
- Jenkins, CircleCI
- Travis CI, Azure Pipelines
- Bitbucket Pipelines

### Testing
- Jest, Mocha, Jasmine
- Pytest, JUnit, NUnit
- Go testing, Testify
- XCTest, Espresso

### Documentation
- Swagger, OpenAPI
- JSDoc, TypeDoc
- MkDocs, Docusaurus
- Read the Docs

## Project Structure

### Standard Structure
```
project/
├── src/
│   ├── api/              # API layer
│   ├── components/       # UI components
│   ├── domain/           # Business logic
│   ├── models/           # Data models
│   ├── services/         # Service layer
│   ├── utils/            # Utility functions
│   └── config/           # Configuration
├── tests/                # Test files
├── docs/                 # Documentation
├── scripts/              # Build scripts
├── .github/              # GitHub workflows
├── .gitignore
├── package.json
├── tsconfig.json
└── README.md
```

### Monorepo Structure
```
monorepo/
├── packages/
│   ├── app/
│   ├── core/
│   ├── ui/
│   ├── api/
│   └── shared/
├── packages.json
├── lerna.json
└── nx.json
```

## Agile Development

### Scrum
- Sprint planning
- Daily standups
- Sprint reviews
- Retrospectives

### Kanban
- Visual workflow
- Limit work in progress
- Continuous flow
- Pull system

### DevOps
- CI/CD pipelines
- Infrastructure as code
- Monitoring and logging
- Incident response

## Code Review Process

### Checklist
- [ ] Code follows style guide
- [ ] All tests pass
- [ ] Documentation updated
- [ ] No security issues
- [ ] Performance considerations
- [ ] Error handling
- [ ] Code complexity
- [ ] Comments and explanations

### Review Guidelines
- Be constructive
- Focus on code quality
- Consider maintainability
- Suggest improvements
- Discuss trade-offs

## Continuous Improvement

### Metrics
- Code coverage
- Test execution time
- Build success rate
- Deployment frequency
- Mean time to recovery

### Retrospectives
- What went well?
- What didn't go well?
- What can be improved?
- Action items

### Learning
- Stay updated with trends
- Learn new technologies
- Share knowledge
- Attend conferences
- Read documentation

## Universal Patterns

### 1. Repository Pattern
```typescript
interface Repository<T> {
  findById(id: string): Promise<T>;
  findAll(): Promise<T[]>;
  save(entity: T): Promise<T>;
  update(id: string, entity: T): Promise<T>;
  delete(id: string): Promise<void>;
}
```

### 2. Service Layer
```typescript
class UserService {
  constructor(private repo: UserRepository) {}

  async getUser(id: string): Promise<User> {
    return this.repo.findById(id);
  }

  async createUser(data: CreateUserDTO): Promise<User> {
    // Business logic
    return this.repo.save(data);
  }
}
```

### 3. Factory Pattern
```typescript
class LoggerFactory {
  static createLogger(name: string): Logger {
    if (process.env.NODE_ENV === 'production') {
      return new ProductionLogger(name);
    }
    return new DevelopmentLogger(name);
  }
}
```

### 4. Observer Pattern
```typescript
class EventEmitter {
  private listeners: Map<string, Function[]> = new Map();

  on(event: string, callback: Function) {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, []);
    }
    this.listeners.get(event)!.push(callback);
  }

  emit(event: string, data: any) {
    const callbacks = this.listeners.get(event) || [];
    callbacks.forEach(cb => cb(data));
  }
}
```

### 5. Strategy Pattern
```typescript
interface PaymentStrategy {
  pay(amount: number): Promise<void>;
}

class CreditCardPayment implements PaymentStrategy {
  pay(amount: number) {
    // Credit card payment logic
  }
}

class PayPalPayment implements PaymentStrategy {
  pay(amount: number) {
    // PayPal payment logic
  }
}
```

## Error Handling Patterns

### 1. Try-Catch-Finally
```typescript
try {
  const result = await service.doSomething();
} catch (error) {
  // Handle error
} finally {
  // Cleanup
}
```

### 2. Error Boundary
```typescript
class ErrorBoundary extends React.Component {
  componentDidCatch(error: Error, info: React.ErrorInfo) {
    // Log error
    // Show error UI
  }

  render() {
    if (this.state.hasError) {
      return <ErrorFallback />;
    }
    return this.props.children;
  }
}
```

### 3. Error Interceptor
```typescript
class ErrorInterceptor {
  intercept(error: Error): Error {
    // Log error
    // Transform error
    // Return new error
    return error;
  }
}
```

## Performance Optimization

### 1. Caching
```typescript
// In-memory cache
const cache = new Map();

function getCached(key: string, fn: () => Promise<any>) {
  if (cache.has(key)) {
    return cache.get(key);
  }
  const result = await fn();
  cache.set(key, result);
  return result;
}

// Redis cache
const redis = new Redis();
async function getCached(key: string, fn: () => Promise<any>) {
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);
  const result = await fn();
  await redis.set(key, JSON.stringify(result));
  return result;
}
```

### 2. Lazy Loading
```typescript
// React lazy loading
const LazyComponent = React.lazy(() => import('./LazyComponent'));

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <LazyComponent />
    </Suspense>
  );
}

// Code splitting
const routes = [
  { path: '/', component: Home },
  { path: '/about', component: React.lazy(() => import('./About')) },
  { path: '/contact', component: React.lazy(() => import('./Contact')) },
];
```

### 3. Debouncing/Throttling
```typescript
// Debounce
function debounce<T extends (...args: any[]) => any>(
  fn: T,
  delay: number
): (...args: Parameters<T>) => void {
  let timeoutId: NodeJS.Timeout;
  return (...args: Parameters<T>) => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn(...args), delay);
  };
}

// Throttle
function throttle<T extends (...args: any[]) => any>(
  fn: T,
  limit: number
): (...args: Parameters<T>) => void {
  let inThrottle: boolean;
  return (...args: Parameters<T>) => {
    if (!inThrottle) {
      fn(...args);
      inThrottle = true;
      setTimeout(() => (inThrottle = false), limit);
    }
  };
}
```

## Security Checklist

### 1. Authentication
- [ ] Implement proper authentication
- [ ] Use secure password storage
- [ ] Implement JWT/OAuth
- [ ] Use session management

### 2. Authorization
- [ ] Implement role-based access
- [ ] Use permission checks
- [ ] Implement resource ownership
- [ ] Use access control lists

### 3. Data Protection
- [ ] Encrypt sensitive data
- [ ] Use HTTPS
- [ ] Implement input validation
- [ ] Sanitize outputs

### 4. Security Headers
- [ ] Content Security Policy
- [ ] X-Frame-Options
- [ ] X-Content-Type-Options
- [ ] CORS configuration

### 5. Dependencies
- [ ] Keep dependencies updated
- [ ] Use lock files
- [ ] Scan for vulnerabilities
- [ ] Use dependency management tools

## Monitoring and Logging

### 1. Structured Logging
```typescript
import winston from 'winston';

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' }),
  ],
});

logger.info('User logged in', { userId: '123', timestamp: new Date() });
logger.error('Database error', { error: err.message, stack: err.stack });
```

### 2. Metrics Collection
```typescript
import promClient from 'prom-client';

const register = new promClient.Registry();

const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'code'],
  buckets: [0.1, 0.5, 1, 1.5, 2, 5],
});

register.registerMetric(httpRequestDuration);

// Record metric
httpRequestDuration.observe(
  { method: 'GET', route: '/api/users', code: 200 },
  duration
);
```

### 3. Error Tracking
```typescript
import * as Sentry from '@sentry/node';

Sentry.init({
  dsn: 'YOUR_DSN',
  environment: process.env.NODE_ENV,
  tracesSampleRate: 1.0,
});

// Capture error
Sentry.captureException(error);

// Capture message
Sentry.captureMessage('User logged in', {
  level: 'info',
  tags: { userId: '123' },
});
```

## Deployment Strategies

### 1. Blue-Green Deployment
```yaml
# Kubernetes example
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-v1
spec:
  replicas: 3
  selector:
    matchLabels:
      app: app
      version: v1
  template:
    metadata:
      labels:
        app: app
        version: v1
    spec:
      containers:
      - name: app
        image: app:v1
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-v2
spec:
  replicas: 3
  selector:
    matchLabels:
      app: app
      version: v2
  template:
    metadata:
      labels:
        app: app
        version: v2
    spec:
      containers:
      - name: app
        image: app:v2
```

### 2. Canary Release
```yaml
# Kubernetes example
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-canary
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app
      version: canary
  template:
    metadata:
      labels:
        app: app
        version: canary
    spec:
      containers:
      - name: app
        image: app:canary
```

### 3. Rolling Update
```yaml
# Kubernetes example
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
    spec:
      containers:
      - name: app
        image: app:v2
```

## Infrastructure as Code

### Terraform Example
```hcl
# main.tf
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name = "web-server"
  }
}

resource "aws_security_group" "web" {
  name        = "web-server"
  description = "Allow web traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### Docker Example
```dockerfile
# Dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```

### Kubernetes Example
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
    spec:
      containers:
      - name: app
        image: app:latest
        ports:
        - containerPort: 3000
        resources:
          requests:
            memory: "128Mi"
            cpu: "250m"
          limits:
            memory: "256Mi"
            cpu: "500m"
```

## Cloud Deployment

### AWS Example
```typescript
import { EC2Client, RunInstancesCommand } from '@aws-sdk/client-ec2';

const client = new EC2Client({ region: 'us-east-1' });

const command = new RunInstancesCommand({
  ImageId: 'ami-0c55b159cbfafe1f0',
  InstanceType: 't2.micro',
  MinCount: 1,
  MaxCount: 1,
});

const response = await client.send(command);
```

### Azure Example
```typescript
import { ComputeManagementClient } from '@azure/arm-compute';

const client = new ComputeManagementClient(
  new DefaultAzureCredential(),
  'subscription-id'
);

const vm = await client.virtualMachines.beginCreateOrUpdateAndWait(
  'resource-group',
  'vm-name',
  {
    location: 'eastus',
    hardwareProfile: {
      vmSize: 'Standard_B1s',
    },
    osProfile: {
      computerName: 'vm-name',
      adminUsername: 'adminuser',
      linuxConfiguration: {
        enableSSHAuthentication: true,
        ssh: {
          publicKeys: [
            {
              keyData: 'ssh-rsa ...',
            },
          ],
        },
      },
    },
    storageProfile: {
      imageReference: {
        publisher: 'Canonical',
        offer: 'UbuntuServer',
        sku: '18.04-LTS',
        version: 'latest',
      },
    },
  }
);
```

### GCP Example
```typescript
import { ComputeClient } from '@google-cloud/compute';

const client = new ComputeClient();

const vm = await client.createInstance({
  project: 'my-project',
  zone: 'us-central1-a',
  instance: 'vm-name',
  machineType: 'zones/us-central1-a/machineTypes/n1-standard-1',
  disks: [
    {
      boot: true,
      initializeParams: {
        sourceImage: 'projects/debian-cloud/global/images/debian-11-bullseye-v20220622',
      },
    },
  ],
  networkInterfaces: [
    {
      accessConfigs: [
        {
          name: 'External NAT',
          type: 'ONE_TO_ONE_NAT',
        },
      ],
      network: 'global/networks/default',
    },
  ],
});
```

## Best Practices by Language

### JavaScript/TypeScript
- Use TypeScript for type safety
- Use ESLint and Prettier
- Use async/await for async code
- Use arrow functions
- Use const/let instead of var

### Python
- Use type hints
- Use virtual environments
- Use pytest for testing
- Use black for formatting
- Use pylint for linting

### Go
- Use interfaces for abstraction
- Use context for cancellation
- Use channels for concurrency
- Use proper error handling
- Use go fmt for formatting

### Java
- Use Java 8+ features
- Use streams for collections
- Use Optional for nullable values
- Use Lombok for boilerplate
- Use Spring Boot for web

### C#
- Use async/await
- Use LINQ for collections
- Use dependency injection
- Use async streams
- Use modern C# features

## Continuous Integration

### GitHub Actions Example
```yaml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [14, 16, 18]
    steps:
    - uses: actions/checkout@v2
    - name: Use Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v2
      with:
        node-version: ${{ matrix.node-version }}
    - run: npm ci
    - run: npm test
    - run: npm run lint
```

### GitLab CI Example
```yaml
stages:
  - test
  - build
  - deploy

test:
  stage: test
  image: node:18
  script:
    - npm ci
    - npm test
    - npm run lint

build:
  stage: build
  image: node:18
  script:
    - npm ci
    - npm run build
  artifacts:
    paths:
      - dist/

deploy:
  stage: deploy
  image: alpine:latest
  script:
    - apk add --no-cache rsync openssh
    - rsync -avz dist/ user@server:/var/www/html/
  only:
    - main
```

## Continuous Deployment

### Automated Deployment
```yaml
# GitHub Actions example
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Deploy to server
      uses: appleboy/ssh-action@master
      with:
        host: ${{ secrets.HOST }}
        username: ${{ secrets.USERNAME }}
        key: ${{ secrets.SSH_KEY }}
        script: |
          cd /var/www/app
          git pull
          npm ci
          npm run build
          pm2 restart app
```

## Performance Tuning

### Database Optimization
```sql
-- Create indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);

-- Use EXPLAIN to analyze queries
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com';

-- Use prepared statements
PREPARE stmt FROM 'SELECT * FROM users WHERE id = ?';
EXECUTE stmt USING 1;
```

### Application Optimization
```typescript
// Use caching
const cache = new NodeCache({ stdTTL: 60 });

function getData(id: string) {
  const cached = cache.get(id);
  if (cached) return cached;

  const data = fetchData(id);
  cache.set(id, data);
  return data;
}

// Use connection pooling
const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'mydb',
  max: 20,
  idleTimeoutMillis: 30000,
});
```

## Security Hardening

### Input Validation
```typescript
import { z } from 'zod';

const userSchema = z.object({
  email: z.string().email(),
  name: z.string().min(2).max(50),
  age: z.number().min(18).max(120),
});

function validateUser(data: any) {
  return userSchema.parse(data);
}
```

### Output Sanitization
```typescript
import DOMPurify from 'dompurify';

function sanitizeHTML(html: string): string {
  return DOMPurify.sanitize(html);
}

// Use in React
function SafeHTML({ html }: { html: string }) {
  return <div dangerouslySetInnerHTML={{ __html: sanitizeHTML(html) }} />;
}
```

### Rate Limiting
```typescript
import rateLimit from 'express-rate-limit';

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.',
});

app.use('/api', limiter);
```

## Monitoring and Alerting

### Prometheus Example
```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'app'
    static_configs:
      - targets: ['localhost:9090']
```

### Grafana Example
```json
{
  "dashboard": {
    "title": "Application Metrics",
    "panels": [
      {
        "title": "Request Rate",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])"
          }
        ]
      },
      {
        "title": "Error Rate",
        "targets": [
          {
            "expr": "rate(http_requests_total{status=~\"5..\"}[5m])"
          }
        ]
      },
      {
        "title": "Response Time",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))"
          }
        ]
      }
    ]
  }
}
```

## Documentation Standards

### API Documentation
```yaml
# OpenAPI/Swagger example
openapi: 3.0.0
info:
  title: User API
  version: 1.0.0
paths:
  /users:
    get:
      summary: Get all users
      responses:
        '200':
          description: A list of users
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/User'
components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: string
        name:
          type: string
        email:
          type: string
```

### Code Documentation
```typescript
/**
 * Creates a new user
 * @param data - User data
 * @returns Created user
 * @throws {ValidationError} If validation fails
 * @example
 * const user = await createUser({
 *   email: 'test@example.com',
 *   name: 'Test User'
 * });
 */
async function createUser(data: CreateUserDTO): Promise<User> {
  // Implementation
}
```

## Conclusion

This guide provides a comprehensive framework for developing software applications across any programming language and framework. By following these principles and best practices, you can create maintainable, scalable, and secure applications.

### Key Takeaways
- Use appropriate architecture patterns
- Follow coding standards
- Implement proper error handling
- Write comprehensive tests
- Document your code
- Monitor and optimize performance
- Stay updated with best practices
- Continuously improve

---

**Version**: 2.0.0
**Last Updated**: 2026-02-19
**Status**: Universal
**Applicable To**: All programming languages and frameworks