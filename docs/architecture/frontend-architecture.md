# AFL Data Capture Platform - Frontend Architecture

## Overview

This document details the frontend architecture for the AFL Data Capture Platform, a Progressive Web App (PWA) built with Next.js 14+ that provides a visual drag-and-drop interface for creating sports prediction formulas. The frontend emphasizes performance, accessibility, and user experience across all devices.

## Core Technology Stack

| Category | Technology | Version | Justification |
|----------|------------|---------|---------------|
| **Framework** | Next.js | 14+ | App Router, RSC, optimal performance, SEO |
| **UI Library** | React | 18+ | Industry standard, component ecosystem |
| **Language** | TypeScript | 5+ | Type safety, better developer experience |
| **Styling** | Tailwind CSS | 3.4+ | Utility-first, consistent design, small bundle |
| **State Management** | Zustand | 4.5+ | Lightweight, TypeScript-first, simple API |
| **Drag & Drop** | @dnd-kit | 6.1+ | Accessible, performant, touch-friendly |
| **Data Fetching** | TanStack Query | 5.0+ | Caching, optimistic updates, background sync |
| **Forms** | React Hook Form | 7.48+ | Performance, minimal re-renders |
| **Validation** | Zod | 3.22+ | TypeScript integration, schema validation |
| **Charts** | Recharts | 2.10+ | Responsive, React-native, customizable |
| **PWA** | next-pwa | 5.6+ | Service workers, offline support |
| **Animation** | Framer Motion | 11.0+ | Smooth interactions, gesture support |
| **Testing** | Vitest + Testing Library | Latest | Fast, React Testing Library patterns |

## Architecture Principles

### 1. Component-Driven Development
- **Atomic Design Pattern**: Components organized from atoms to pages
- **Single Responsibility**: Each component has one clear purpose
- **Composition over Inheritance**: Build complex UIs from simple components
- **Props Interface Design**: Clear, typed interfaces for all components

### 2. Performance First
- **Code Splitting**: Route-based and component-based splitting
- **Lazy Loading**: Components loaded on demand
- **Image Optimization**: Next.js Image component with responsive sizes
- **Bundle Optimization**: Tree shaking, minification, compression

### 3. Accessibility by Default
- **Semantic HTML**: Proper element usage for screen readers
- **ARIA Labels**: Comprehensive labeling for interactive elements
- **Keyboard Navigation**: Full keyboard support for all features
- **Focus Management**: Logical focus flow and visible indicators

## Project Structure

```
src/
├── app/                          # Next.js App Router
│   ├── (auth)/                  # Authentication group
│   │   ├── login/              
│   │   ├── register/           
│   │   └── layout.tsx          
│   ├── (dashboard)/             # Protected routes group
│   │   ├── formulas/           
│   │   │   ├── page.tsx        # Formula list
│   │   │   ├── [id]/           # Formula detail
│   │   │   └── new/            # Create formula
│   │   ├── predictions/        
│   │   ├── backtest/           
│   │   └── layout.tsx          # Dashboard layout
│   ├── api/                     # API routes (BFF)
│   │   ├── auth/               
│   │   └── formulas/           
│   ├── layout.tsx               # Root layout
│   ├── page.tsx                 # Landing page
│   └── global.css              # Global styles
│
├── components/
│   ├── ui/                      # Base UI components (atoms)
│   │   ├── Button/
│   │   │   ├── Button.tsx
│   │   │   ├── Button.test.tsx
│   │   │   ├── Button.stories.tsx
│   │   │   └── index.ts
│   │   ├── Input/
│   │   ├── Card/
│   │   ├── Modal/
│   │   └── Slider/
│   │
│   ├── formula/                 # Formula domain components
│   │   ├── FormulaBuilder/
│   │   │   ├── FormulaBuilder.tsx
│   │   │   ├── FormulaCanvas.tsx
│   │   │   ├── MetricLibrary.tsx
│   │   │   └── WeightControl.tsx
│   │   ├── MetricCard/
│   │   └── FormulaPreview/
│   │
│   ├── predictions/             # Predictions domain
│   │   ├── PredictionList/
│   │   ├── PredictionCard/
│   │   └── ConfidenceIndicator/
│   │
│   ├── layout/                  # Layout components
│   │   ├── Header/
│   │   ├── Navigation/
│   │   ├── Footer/
│   │   └── MobileMenu/
│   │
│   └── shared/                  # Shared/common components
│       ├── ErrorBoundary/
│       ├── LoadingSpinner/
│       ├── SEO/
│       └── Analytics/
│
├── hooks/                        # Custom React hooks
│   ├── useFormula.ts
│   ├── usePredictions.ts
│   ├── useAuth.ts
│   ├── useMediaQuery.ts
│   └── useDebounce.ts
│
├── stores/                       # Zustand state stores
│   ├── formulaStore.ts          # Formula state management
│   ├── userStore.ts             # User/auth state
│   ├── uiStore.ts               # UI state (modals, sidebar)
│   └── types.ts                 # Store type definitions
│
├── services/                     # API and external services
│   ├── api/
│   │   ├── client.ts            # Axios/fetch wrapper
│   │   ├── formulas.ts          # Formula API calls
│   │   ├── predictions.ts       # Predictions API
│   │   ├── auth.ts              # Auth API
│   │   └── types.ts             # API type definitions
│   ├── websocket/               # Real-time updates
│   └── analytics/               # Analytics service
│
├── lib/                          # Utility libraries
│   ├── constants.ts             # App constants
│   ├── validators.ts            # Zod schemas
│   ├── formatters.ts            # Data formatters
│   └── calculations.ts          # Formula calculations
│
├── types/                        # TypeScript type definitions
│   ├── formula.ts
│   ├── prediction.ts
│   ├── user.ts
│   └── global.d.ts
│
└── styles/                       # Global styles
    ├── variables.css            # CSS variables
    └── utilities.css            # Utility classes
```

## Component Architecture

### Component Template

```typescript
// components/ui/Button/Button.tsx
import { forwardRef } from 'react';
import { cn } from '@/lib/utils';
import type { ButtonProps } from './Button.types';

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant = 'primary', size = 'md', children, ...props }, ref) => {
    return (
      <button
        ref={ref}
        className={cn(
          'inline-flex items-center justify-center rounded-md font-medium transition-colors',
          'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2',
          'disabled:pointer-events-none disabled:opacity-50',
          variants[variant],
          sizes[size],
          className
        )}
        {...props}
      >
        {children}
      </button>
    );
  }
);

Button.displayName = 'Button';
```

### Component Organization Rules

1. **One component per file**: Each component in its own file
2. **Barrel exports**: Use index.ts for clean imports
3. **Co-located tests**: Tests alongside components
4. **Stories for complex components**: Storybook for documentation
5. **Type definitions**: Separate .types.ts files for complex types

## State Management

### Zustand Store Pattern

```typescript
// stores/formulaStore.ts
import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';
import type { Formula, Metric } from '@/types/formula';

interface FormulaState {
  // State
  formulas: Formula[];
  activeFormula: Formula | null;
  selectedMetrics: Metric[];
  isDragging: boolean;
  
  // Actions
  addMetric: (metric: Metric) => void;
  removeMetric: (metricId: string) => void;
  updateWeight: (metricId: string, weight: number) => void;
  saveFormula: (formula: Formula) => void;
  loadFormula: (formulaId: string) => void;
  resetFormula: () => void;
}

export const useFormulaStore = create<FormulaState>()(
  devtools(
    persist(
      (set, get) => ({
        // Initial state
        formulas: [],
        activeFormula: null,
        selectedMetrics: [],
        isDragging: false,
        
        // Action implementations
        addMetric: (metric) => {
          const { selectedMetrics } = get();
          if (selectedMetrics.length >= 10) {
            throw new Error('Maximum 10 metrics allowed');
          }
          set({ selectedMetrics: [...selectedMetrics, metric] });
        },
        
        removeMetric: (metricId) => {
          set((state) => ({
            selectedMetrics: state.selectedMetrics.filter(m => m.id !== metricId)
          }));
        },
        
        updateWeight: (metricId, weight) => {
          set((state) => ({
            selectedMetrics: state.selectedMetrics.map(m =>
              m.id === metricId ? { ...m, weight } : m
            )
          }));
        },
        
        // ... other actions
      }),
      {
        name: 'formula-storage',
        partialize: (state) => ({ formulas: state.formulas })
      }
    )
  )
);
```

### State Management Principles

1. **Minimal Global State**: Only truly global state in stores
2. **Local Component State**: Use useState for component-specific state
3. **Server State**: TanStack Query for server data
4. **Form State**: React Hook Form for form management
5. **URL State**: Query params for shareable state

## Data Fetching Strategy

### TanStack Query Configuration

```typescript
// services/api/client.ts
import { QueryClient } from '@tanstack/react-query';

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5, // 5 minutes
      gcTime: 1000 * 60 * 10, // 10 minutes
      retry: 3,
      refetchOnWindowFocus: false,
    },
    mutations: {
      retry: 1,
      onError: (error) => {
        console.error('Mutation error:', error);
        // Show toast notification
      },
    },
  },
});

// Hook example
export const useFormulas = () => {
  return useQuery({
    queryKey: ['formulas'],
    queryFn: fetchFormulas,
    staleTime: 1000 * 60 * 10, // 10 minutes
  });
};
```

### Data Fetching Patterns

1. **Prefetching**: Prefetch on hover/focus
2. **Optimistic Updates**: Update UI before server confirms
3. **Infinite Queries**: For paginated lists
4. **Parallel Queries**: Fetch related data simultaneously
5. **Background Refetching**: Keep data fresh automatically

## Routing & Navigation

### Route Organization

```typescript
// Route structure with layouts and groups
app/
├── (public)/                    # Public routes (no auth required)
│   ├── page.tsx                # Landing page
│   ├── about/page.tsx
│   └── layout.tsx              # Public layout
├── (auth)/                     # Auth routes (redirect if logged in)
│   ├── login/page.tsx
│   ├── register/page.tsx
│   └── layout.tsx              # Auth layout
├── (dashboard)/                # Protected routes
│   ├── formulas/
│   │   ├── page.tsx           # /formulas
│   │   ├── new/page.tsx       # /formulas/new
│   │   └── [id]/
│   │       ├── page.tsx       # /formulas/[id]
│   │       └── edit/page.tsx  # /formulas/[id]/edit
│   └── layout.tsx             # Dashboard layout with sidebar
```

### Navigation Guards

```typescript
// middleware.ts
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  const token = request.cookies.get('auth-token');
  const isAuthPage = request.nextUrl.pathname.startsWith('/(auth)');
  const isDashboard = request.nextUrl.pathname.startsWith('/(dashboard)');
  
  if (isDashboard && !token) {
    return NextResponse.redirect(new URL('/login', request.url));
  }
  
  if (isAuthPage && token) {
    return NextResponse.redirect(new URL('/formulas', request.url));
  }
  
  return NextResponse.next();
}

export const config = {
  matcher: ['/(dashboard)/:path*', '/(auth)/:path*'],
};
```

## Performance Optimization

### Code Splitting Strategy

```typescript
// Dynamic imports for heavy components
const FormulaBuilder = dynamic(
  () => import('@/components/formula/FormulaBuilder'),
  {
    loading: () => <FormulaBuilderSkeleton />,
    ssr: false, // Disable SSR for interactive components
  }
);

// Route-based splitting (automatic with App Router)
// Component-based splitting for modals
const HeavyModal = lazy(() => import('./HeavyModal'));
```

### Image Optimization

```typescript
import Image from 'next/image';

<Image
  src="/team-logo.png"
  alt="Team Logo"
  width={100}
  height={100}
  placeholder="blur"
  blurDataURL={blurDataUrl}
  sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
  priority={false} // true for above-the-fold images
/>
```

### Performance Monitoring

```typescript
// lib/performance.ts
export const measurePerformance = (metricName: string) => {
  if (typeof window !== 'undefined' && window.performance) {
    const measure = performance.measure(
      metricName,
      `${metricName}-start`,
      `${metricName}-end`
    );
    
    // Send to analytics
    sendToAnalytics({
      metric: metricName,
      value: measure.duration,
      timestamp: Date.now(),
    });
  }
};
```

## Testing Strategy

### Component Testing

```typescript
// Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from './Button';

describe('Button', () => {
  it('renders with children', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByRole('button')).toHaveTextContent('Click me');
  });
  
  it('handles click events', () => {
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>Click</Button>);
    fireEvent.click(screen.getByRole('button'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
  
  it('applies variant styles', () => {
    render(<Button variant="secondary">Button</Button>);
    expect(screen.getByRole('button')).toHaveClass('bg-gray-200');
  });
});
```

### Integration Testing

```typescript
// Formula creation flow test
describe('Formula Creation', () => {
  it('creates a formula successfully', async () => {
    render(<FormulaBuilder />);
    
    // Drag metrics
    const metric = screen.getByText('Recent Form');
    const dropZone = screen.getByTestId('formula-canvas');
    
    fireEvent.dragStart(metric);
    fireEvent.drop(dropZone);
    
    // Adjust weight
    const slider = screen.getByRole('slider');
    fireEvent.change(slider, { target: { value: '75' } });
    
    // Save formula
    const saveButton = screen.getByText('Save Formula');
    fireEvent.click(saveButton);
    
    await waitFor(() => {
      expect(screen.getByText('Formula saved successfully')).toBeInTheDocument();
    });
  });
});
```

## Error Handling

### Error Boundary Implementation

```typescript
// components/shared/ErrorBoundary.tsx
class ErrorBoundary extends Component<Props, State> {
  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }
  
  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
    // Send to error tracking service
    captureException(error, { extra: errorInfo });
  }
  
  render() {
    if (this.state.hasError) {
      return (
        <ErrorFallback
          error={this.state.error}
          resetError={() => this.setState({ hasError: false })}
        />
      );
    }
    
    return this.props.children;
  }
}
```

### API Error Handling

```typescript
// services/api/client.ts
class ApiError extends Error {
  constructor(
    message: string,
    public statusCode: number,
    public errors?: Record<string, string[]>
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

export const apiClient = {
  async request<T>(config: RequestConfig): Promise<T> {
    try {
      const response = await fetch(config.url, {
        ...config,
        headers: {
          'Content-Type': 'application/json',
          ...config.headers,
        },
      });
      
      if (!response.ok) {
        const error = await response.json();
        throw new ApiError(
          error.message || 'Request failed',
          response.status,
          error.errors
        );
      }
      
      return response.json();
    } catch (error) {
      if (error instanceof ApiError) throw error;
      throw new ApiError('Network error', 0);
    }
  },
};
```

## PWA Configuration

### Service Worker Setup

```javascript
// next.config.js
const withPWA = require('next-pwa')({
  dest: 'public',
  register: true,
  skipWaiting: true,
  disable: process.env.NODE_ENV === 'development',
  runtimeCaching: [
    {
      urlPattern: /^https:\/\/api\.example\.com\/.*$/,
      handler: 'NetworkFirst',
      options: {
        cacheName: 'api-cache',
        expiration: {
          maxEntries: 50,
          maxAgeSeconds: 60 * 60, // 1 hour
        },
      },
    },
    {
      urlPattern: /\.(?:png|jpg|jpeg|svg|gif|webp)$/,
      handler: 'CacheFirst',
      options: {
        cacheName: 'image-cache',
        expiration: {
          maxEntries: 100,
          maxAgeSeconds: 60 * 60 * 24 * 30, // 30 days
        },
      },
    },
  ],
});

module.exports = withPWA({
  // Next.js config
});
```

## Mobile Optimization

### Touch Interactions

```typescript
// Drag and drop with touch support
const sensors = useSensors(
  useSensor(PointerSensor, {
    activationConstraint: {
      distance: 8,
    },
  }),
  useSensor(KeyboardSensor, {
    coordinateGetter: sortableKeyboardCoordinates,
  }),
  useSensor(TouchSensor, {
    activationConstraint: {
      delay: 250,
      tolerance: 5,
    },
  })
);
```

### Responsive Design Utilities

```typescript
// hooks/useMediaQuery.ts
export const useMediaQuery = (query: string): boolean => {
  const [matches, setMatches] = useState(false);
  
  useEffect(() => {
    const media = window.matchMedia(query);
    setMatches(media.matches);
    
    const listener = (e: MediaQueryListEvent) => setMatches(e.matches);
    media.addEventListener('change', listener);
    
    return () => media.removeEventListener('change', listener);
  }, [query]);
  
  return matches;
};

// Usage
const isMobile = useMediaQuery('(max-width: 768px)');
const isTablet = useMediaQuery('(min-width: 769px) and (max-width: 1024px)');
```

## Development Guidelines

### Component Development Checklist

- [ ] TypeScript interfaces defined
- [ ] Props documented with JSDoc
- [ ] Accessibility attributes added (ARIA labels, roles)
- [ ] Keyboard navigation implemented
- [ ] Error states handled
- [ ] Loading states implemented
- [ ] Mobile responsive
- [ ] Unit tests written
- [ ] Storybook story created (if complex)
- [ ] Performance optimized (memo, useMemo, useCallback)

### Code Style Rules

```typescript
// .eslintrc.js
module.exports = {
  extends: [
    'next/core-web-vitals',
    'plugin:@typescript-eslint/recommended',
    'plugin:jsx-a11y/recommended',
    'prettier',
  ],
  rules: {
    '@typescript-eslint/explicit-function-return-type': 'warn',
    '@typescript-eslint/no-unused-vars': 'error',
    'react/prop-types': 'off', // TypeScript handles this
    'react/react-in-jsx-scope': 'off', // Next.js handles this
    'jsx-a11y/anchor-is-valid': 'off', // Next.js Link component
  },
};
```

## Monitoring & Analytics

### Performance Monitoring

```typescript
// app/layout.tsx
import { Analytics } from '@vercel/analytics/react';
import { SpeedInsights } from '@vercel/speed-insights/next';

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        <Analytics />
        <SpeedInsights />
      </body>
    </html>
  );
}
```

### Custom Event Tracking

```typescript
// lib/analytics.ts
export const trackEvent = (eventName: string, properties?: Record<string, any>) => {
  // Google Analytics
  if (typeof window !== 'undefined' && window.gtag) {
    window.gtag('event', eventName, properties);
  }
  
  // Custom analytics
  fetch('/api/analytics', {
    method: 'POST',
    body: JSON.stringify({ event: eventName, properties }),
  });
};

// Usage
trackEvent('formula_created', {
  metrics_count: 5,
  formula_name: 'My Formula',
});
```

---

*Frontend Architecture Version 1.0 - Created 2025-08-28*
*Aligned with main architecture.md for the AFL Data Capture Platform*