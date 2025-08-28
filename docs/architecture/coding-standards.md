# Coding Standards

## Overview

This document defines coding standards and best practices for the AFL Data Capture Platform to ensure consistent, maintainable, and high-quality code across the entire codebase.

## TypeScript Standards

### General Rules

```typescript
// ✅ GOOD: Use const for immutable values
const MAX_RETRIES = 3;
const config = Object.freeze({ api: 'https://...' });

// ❌ BAD: Using let when const would work
let MAX_RETRIES = 3;

// ✅ GOOD: Explicit types for function parameters and return values
function calculateScore(home: number, away: number): number {
  return home - away;
}

// ❌ BAD: Implicit any types
function calculateScore(home, away) {
  return home - away;
}

// ✅ GOOD: Interface for object types
interface User {
  id: string;
  email: string;
  role: UserRole;
}

// ❌ BAD: Using type for simple objects (use interface)
type User = {
  id: string;
  email: string;
  role: UserRole;
};

// ✅ GOOD: Type for unions and intersections
type UserRole = 'user' | 'premium' | 'admin';
type ApiResponse<T> = SuccessResponse<T> | ErrorResponse;

// ✅ GOOD: Enum for fixed sets
enum Status {
  PENDING = 'pending',
  ACTIVE = 'active',
  COMPLETED = 'completed'
}
```

### Naming Conventions

```typescript
// PascalCase: Classes, Interfaces, Types, Enums
class FormulaService {}
interface Formula {}
type FormulaType = 'custom' | 'template';
enum Role {}

// camelCase: Variables, Functions, Methods
const userFormula = {};
function calculatePrediction() {}

// UPPER_SNAKE_CASE: Constants
const MAX_FORMULA_METRICS = 10;
const API_BASE_URL = 'https://api.example.com';

// Private members: Prefix with underscore
class Service {
  private _cache: Map<string, any>;
  private _isInitialized = false;
}

// Boolean variables: Use is/has/can/should prefixes
const isLoading = true;
const hasPermission = false;
const canEdit = true;
const shouldRefetch = false;
```

## React/Next.js Standards

### Component Structure

```typescript
// ✅ GOOD: Functional component with proper typing
import { FC, useState, useEffect } from 'react';

interface FormulaBuilderProps {
  initialFormula?: Formula;
  onSave: (formula: Formula) => Promise<void>;
  readonly?: boolean;
}

export const FormulaBuilder: FC<FormulaBuilderProps> = ({
  initialFormula,
  onSave,
  readonly = false
}) => {
  // State declarations
  const [formula, setFormula] = useState<Formula | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  
  // Custom hooks
  const { user } = useAuth();
  const { metrics } = useMetrics();
  
  // Effects
  useEffect(() => {
    // Effect logic
  }, [dependency]);
  
  // Event handlers
  const handleSave = async () => {
    try {
      setIsLoading(true);
      await onSave(formula!);
    } catch (err) {
      setError(err.message);
    } finally {
      setIsLoading(false);
    }
  };
  
  // Render helpers
  const renderMetric = (metric: Metric) => (
    <MetricCard key={metric.id} metric={metric} />
  );
  
  // Early returns for edge cases
  if (isLoading) return <LoadingSpinner />;
  if (error) return <ErrorMessage error={error} />;
  
  // Main render
  return (
    <div className="formula-builder">
      {/* JSX content */}
    </div>
  );
};

// Default export only for pages
export default FormulaBuilder;
```

### Hooks Standards

```typescript
// ✅ GOOD: Custom hook with proper naming and return type
export function useFormula(formulaId: string): UseFormulaReturn {
  const [formula, setFormula] = useState<Formula | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);
  
  useEffect(() => {
    let cancelled = false;
    
    const loadFormula = async () => {
      try {
        const data = await fetchFormula(formulaId);
        if (!cancelled) {
          setFormula(data);
        }
      } catch (err) {
        if (!cancelled) {
          setError(err);
        }
      } finally {
        if (!cancelled) {
          setIsLoading(false);
        }
      }
    };
    
    loadFormula();
    
    // Cleanup function
    return () => {
      cancelled = true;
    };
  }, [formulaId]);
  
  return { formula, isLoading, error };
}

interface UseFormulaReturn {
  formula: Formula | null;
  isLoading: boolean;
  error: Error | null;
}
```

## Node.js/Backend Standards

### Service Pattern

```typescript
// ✅ GOOD: Service class with dependency injection
export class FormulaService {
  constructor(
    private readonly repository: FormulaRepository,
    private readonly cache: CacheService,
    private readonly eventBus: EventBus
  ) {}
  
  async createFormula(
    userId: string,
    input: CreateFormulaInput
  ): Promise<Formula> {
    // Validation
    this.validateFormulaInput(input);
    
    // Business logic
    const formula = await this.repository.create({
      userId,
      ...input,
      createdAt: new Date()
    });
    
    // Side effects
    await this.cache.invalidate(`user:${userId}:formulas`);
    await this.eventBus.publish('formula.created', formula);
    
    return formula;
  }
  
  private validateFormulaInput(input: CreateFormulaInput): void {
    if (input.metrics.length > MAX_FORMULA_METRICS) {
      throw new ValidationError(
        `Formula cannot have more than ${MAX_FORMULA_METRICS} metrics`
      );
    }
  }
}
```

### Error Handling

```typescript
// ✅ GOOD: Proper error handling with custom errors
export class DomainError extends Error {
  constructor(
    message: string,
    public readonly code: string,
    public readonly statusCode: number = 400
  ) {
    super(message);
    this.name = this.constructor.name;
  }
}

export class ValidationError extends DomainError {
  constructor(message: string) {
    super(message, 'VALIDATION_ERROR', 400);
  }
}

// Usage
async function handleRequest(req: Request, res: Response) {
  try {
    const result = await processRequest(req.body);
    res.json({ success: true, data: result });
  } catch (error) {
    if (error instanceof DomainError) {
      res.status(error.statusCode).json({
        success: false,
        error: {
          code: error.code,
          message: error.message
        }
      });
    } else {
      // Log unexpected errors
      logger.error('Unexpected error', error);
      res.status(500).json({
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: 'An unexpected error occurred'
        }
      });
    }
  }
}
```

## Testing Standards

### Unit Tests

```typescript
// ✅ GOOD: Descriptive test with proper structure
import { describe, it, expect, beforeEach, vi } from 'vitest';

describe('FormulaService', () => {
  let service: FormulaService;
  let mockRepository: MockFormulaRepository;
  
  beforeEach(() => {
    mockRepository = new MockFormulaRepository();
    service = new FormulaService(mockRepository);
  });
  
  describe('createFormula', () => {
    it('should create a formula with valid input', async () => {
      // Arrange
      const input = {
        name: 'Test Formula',
        metrics: [{ id: '1', weight: 100 }]
      };
      
      // Act
      const result = await service.createFormula('user123', input);
      
      // Assert
      expect(result).toMatchObject({
        name: 'Test Formula',
        userId: 'user123'
      });
      expect(mockRepository.create).toHaveBeenCalledWith(
        expect.objectContaining({ name: 'Test Formula' })
      );
    });
    
    it('should throw error when metrics exceed limit', async () => {
      // Arrange
      const input = {
        name: 'Test Formula',
        metrics: Array(11).fill({ id: '1', weight: 10 })
      };
      
      // Act & Assert
      await expect(
        service.createFormula('user123', input)
      ).rejects.toThrow(ValidationError);
    });
  });
});
```

## Git Commit Standards

### Commit Message Format

```bash
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding tests
- `chore`: Maintenance tasks
- `ci`: CI/CD changes

### Examples

```bash
feat(formula): add drag-and-drop formula builder

Implemented @dnd-kit for accessible drag-and-drop functionality.
Users can now visually build formulas by dragging metrics.

Closes #123

---

fix(predictions): correct confidence score calculation

The confidence score was not properly normalized when multiple
metrics had different weight scales. Now normalizes to 0-100.

Fixes #456
```

## Code Quality Tools

### ESLint Configuration

```javascript
// .eslintrc.js
module.exports = {
  extends: [
    'next/core-web-vitals',
    'plugin:@typescript-eslint/recommended',
    'plugin:@typescript-eslint/recommended-requiring-type-checking',
    'prettier'
  ],
  rules: {
    '@typescript-eslint/explicit-function-return-type': 'warn',
    '@typescript-eslint/no-unused-vars': 'error',
    '@typescript-eslint/no-explicit-any': 'error',
    '@typescript-eslint/strict-boolean-expressions': 'warn',
    'no-console': ['error', { allow: ['warn', 'error'] }],
    'prefer-const': 'error'
  }
};
```

### Prettier Configuration

```javascript
// .prettierrc.js
module.exports = {
  semi: true,
  trailingComma: 'es5',
  singleQuote: true,
  printWidth: 80,
  tabWidth: 2,
  useTabs: false,
  bracketSpacing: true,
  arrowParens: 'always',
  endOfLine: 'lf'
};
```

## Documentation Standards

### Code Comments

```typescript
/**
 * Calculates the prediction confidence based on formula metrics.
 * 
 * @param formula - The formula containing metrics and weights
 * @param matchData - Current match statistics
 * @returns Confidence score between 0 and 100
 * @throws {ValidationError} If formula has no metrics
 * 
 * @example
 * const confidence = calculateConfidence(formula, matchData);
 * console.log(`Confidence: ${confidence}%`);
 */
export function calculateConfidence(
  formula: Formula,
  matchData: MatchData
): number {
  if (formula.metrics.length === 0) {
    throw new ValidationError('Formula must have at least one metric');
  }
  
  // Implementation...
  return confidence;
}

// Use single-line comments for clarification
const normalizedWeight = weight / 100; // Convert percentage to decimal

// TODO: Implement caching for performance
// FIXME: Handle edge case when data is null
// NOTE: This uses the new calculation algorithm
```

### README Structure

```markdown
# Component/Service Name

## Overview
Brief description of what this component/service does.

## Installation
```bash
npm install
```

## Usage
```typescript
import { Component } from './Component';

// Usage example
```

## API Reference
### Methods
- `methodName(params)`: Description

## Testing
```bash
npm test
```

## Contributing
See [CONTRIBUTING.md](./CONTRIBUTING.md)
```

## Performance Guidelines

### React Performance

```typescript
// ✅ GOOD: Memoize expensive calculations
const expensiveValue = useMemo(() => {
  return calculateExpensiveValue(data);
}, [data]);

// ✅ GOOD: Memoize callbacks passed to children
const handleClick = useCallback(() => {
  doSomething(id);
}, [id]);

// ✅ GOOD: Memo for pure components
export const PureComponent = memo(({ data }) => {
  return <div>{data}</div>;
});

// ❌ BAD: Creating functions in render
return <button onClick={() => handleClick(id)}>Click</button>;

// ✅ GOOD: Lazy load heavy components
const HeavyComponent = lazy(() => import('./HeavyComponent'));
```

### Backend Performance

```typescript
// ✅ GOOD: Use database transactions
await db.transaction(async (tx) => {
  await tx.formulas.create(formula);
  await tx.audit.create(auditLog);
});

// ✅ GOOD: Batch operations
const promises = items.map(item => processItem(item));
await Promise.all(promises);

// ✅ GOOD: Use caching
const cached = await cache.get(key);
if (cached) return cached;

const result = await expensive();
await cache.set(key, result, TTL);
return result;
```

## Security Best Practices

```typescript
// ✅ GOOD: Input validation
const schema = z.object({
  email: z.string().email(),
  password: z.string().min(8)
});

const validated = schema.parse(input);

// ✅ GOOD: SQL injection prevention
const result = await db.query(
  'SELECT * FROM users WHERE id = $1',
  [userId]
);

// ❌ BAD: String concatenation in queries
const result = await db.query(
  `SELECT * FROM users WHERE id = ${userId}`
);

// ✅ GOOD: Sanitize user input
import DOMPurify from 'isomorphic-dompurify';
const clean = DOMPurify.sanitize(userInput);

// ✅ GOOD: Use environment variables
const apiKey = process.env.API_KEY;

// ❌ BAD: Hardcoded secrets
const apiKey = 'sk_live_abcd1234';
```

---

*Coding Standards Version 1.0 - Created 2025-08-28*