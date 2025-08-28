# AFL Data Capture Platform - Accessibility Implementation Guide

## Overview

This guide ensures the AFL Data Capture Platform meets WCAG 2.1 Level AA compliance, providing an inclusive experience for all users including those using assistive technologies. Every feature must be accessible via keyboard, screen reader compatible, and usable by people with various disabilities.

## WCAG 2.1 AA Requirements

### Core Principles (POUR)

1. **Perceivable** - Information must be presentable in ways users can perceive
2. **Operable** - Interface components must be operable by all users
3. **Understandable** - Information and UI operation must be understandable
4. **Robust** - Content must be robust enough for various assistive technologies

## Implementation Standards

### 1. Semantic HTML

```typescript
// ❌ BAD - Non-semantic markup
<div className="button" onClick={handleClick}>
  <span>Submit</span>
</div>

// ✅ GOOD - Semantic HTML
<button type="submit" onClick={handleClick}>
  Submit
</button>

// ❌ BAD - Improper heading hierarchy
<h1>Page Title</h1>
<h3>Section Title</h3>  // Skipped h2

// ✅ GOOD - Proper heading hierarchy
<h1>Page Title</h1>
<h2>Section Title</h2>
<h3>Subsection Title</h3>
```

### 2. ARIA Implementation

```typescript
// Formula Builder Component with ARIA
export const FormulaBuilder: React.FC = () => {
  return (
    <div 
      role="application"
      aria-label="Formula Builder"
      aria-describedby="formula-instructions"
    >
      <h1 id="formula-title">Create Your Formula</h1>
      
      <div id="formula-instructions" className="sr-only">
        Drag metrics from the library to the canvas to build your formula. 
        Use arrow keys to navigate and space to select.
      </div>
      
      <div 
        role="region"
        aria-label="Metrics Library"
        tabIndex={0}
        aria-live="polite"
      >
        {metrics.map(metric => (
          <div
            key={metric.id}
            role="button"
            tabIndex={0}
            aria-label={`${metric.name}. ${metric.description}`}
            aria-grabbed={isDragging === metric.id}
            draggable
            onKeyDown={(e) => handleKeyboardDrag(e, metric)}
          >
            {metric.name}
          </div>
        ))}
      </div>
      
      <div 
        role="region"
        aria-label="Formula Canvas"
        aria-dropeffect="move"
        aria-live="assertive"
        aria-relevant="additions removals"
      >
        {/* Canvas content */}
      </div>
    </div>
  );
};
```

### 3. Keyboard Navigation

```typescript
// Complete keyboard navigation implementation
export const useKeyboardNavigation = () => {
  const handleKeyDown = (event: KeyboardEvent) => {
    const { key, shiftKey, ctrlKey } = event;
    
    switch (key) {
      case 'Tab':
        // Natural tab flow, ensure logical order
        break;
        
      case 'Enter':
      case ' ':
        // Activate current element
        event.preventDefault();
        (event.target as HTMLElement).click();
        break;
        
      case 'Escape':
        // Close modals, cancel operations
        closeModal();
        break;
        
      case 'ArrowUp':
      case 'ArrowDown':
        // Navigate lists
        navigateList(key === 'ArrowUp' ? -1 : 1);
        break;
        
      case 'ArrowLeft':
      case 'ArrowRight':
        // Navigate horizontal items
        navigateTabs(key === 'ArrowLeft' ? -1 : 1);
        break;
        
      case 'Home':
        // Jump to first item
        focusFirstItem();
        break;
        
      case 'End':
        // Jump to last item
        focusLastItem();
        break;
    }
    
    // Keyboard shortcuts with modifiers
    if (ctrlKey || metaKey) {
      switch (key) {
        case 's':
          event.preventDefault();
          saveFormula();
          break;
        case 'z':
          event.preventDefault();
          undo();
          break;
      }
    }
  };
  
  return { handleKeyDown };
};
```

### 4. Focus Management

```typescript
// Focus trap for modals
export const Modal: React.FC<ModalProps> = ({ isOpen, onClose, children }) => {
  const modalRef = useRef<HTMLDivElement>(null);
  const previousFocus = useRef<HTMLElement | null>(null);
  
  useEffect(() => {
    if (isOpen) {
      // Store current focus
      previousFocus.current = document.activeElement as HTMLElement;
      
      // Focus first focusable element in modal
      const focusableElements = modalRef.current?.querySelectorAll(
        'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
      );
      
      if (focusableElements?.length) {
        (focusableElements[0] as HTMLElement).focus();
      }
    } else {
      // Restore focus on close
      previousFocus.current?.focus();
    }
  }, [isOpen]);
  
  // Trap focus within modal
  const handleKeyDown = (e: KeyboardEvent) => {
    if (e.key === 'Tab') {
      const focusableElements = modalRef.current?.querySelectorAll(
        'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
      );
      
      if (!focusableElements?.length) return;
      
      const firstElement = focusableElements[0] as HTMLElement;
      const lastElement = focusableElements[focusableElements.length - 1] as HTMLElement;
      
      if (e.shiftKey && document.activeElement === firstElement) {
        e.preventDefault();
        lastElement.focus();
      } else if (!e.shiftKey && document.activeElement === lastElement) {
        e.preventDefault();
        firstElement.focus();
      }
    }
  };
  
  return (
    <div
      ref={modalRef}
      role="dialog"
      aria-modal="true"
      aria-labelledby="modal-title"
      onKeyDown={handleKeyDown}
    >
      {children}
    </div>
  );
};
```

### 5. Color Contrast & Visual Design

```css
/* Ensure WCAG AA contrast ratios */
:root {
  /* Normal text (4.5:1 minimum) */
  --text-primary: #1a1a1a;      /* on white: 19.5:1 ✅ */
  --text-secondary: #595959;    /* on white: 7.5:1 ✅ */
  
  /* Large text (3:1 minimum) */
  --heading-color: #2d2d2d;     /* on white: 14.5:1 ✅ */
  
  /* Interactive elements */
  --link-color: #0066cc;        /* on white: 5.1:1 ✅ */
  --link-hover: #0052a3;        /* on white: 7.2:1 ✅ */
  
  /* Error states */
  --error-text: #b91c1c;        /* on white: 5.9:1 ✅ */
  --error-bg: #fef2f2;          /* with error text: 5.2:1 ✅ */
  
  /* Focus indicators */
  --focus-ring: #2563eb;        /* 3px solid, high visibility */
}

/* Focus visible styles */
*:focus-visible {
  outline: 3px solid var(--focus-ring);
  outline-offset: 2px;
  border-radius: 2px;
}

/* Don't rely on color alone */
.error-state {
  color: var(--error-text);
  border-left: 4px solid var(--error-text);
  padding-left: 12px;
}

.error-state::before {
  content: "⚠ Error: ";  /* Text indicator */
  font-weight: bold;
}
```

### 6. Form Accessibility

```typescript
// Accessible form implementation
export const AccessibleForm: React.FC = () => {
  const [errors, setErrors] = useState<Record<string, string>>({});
  
  return (
    <form aria-label="Create Formula Form" noValidate>
      <fieldset>
        <legend>Formula Details</legend>
        
        {/* Text input with label */}
        <div className="form-group">
          <label htmlFor="formula-name">
            Formula Name
            <span aria-label="required" className="required">*</span>
          </label>
          <input
            id="formula-name"
            name="formulaName"
            type="text"
            required
            aria-required="true"
            aria-invalid={!!errors.formulaName}
            aria-describedby={errors.formulaName ? "formula-name-error" : "formula-name-hint"}
          />
          <span id="formula-name-hint" className="hint">
            Choose a descriptive name for your formula
          </span>
          {errors.formulaName && (
            <span id="formula-name-error" role="alert" className="error">
              {errors.formulaName}
            </span>
          )}
        </div>
        
        {/* Radio group */}
        <fieldset>
          <legend>Formula Type</legend>
          <div role="radiogroup" aria-required="true">
            <label>
              <input type="radio" name="type" value="offensive" />
              Offensive Focus
            </label>
            <label>
              <input type="radio" name="type" value="defensive" />
              Defensive Focus
            </label>
            <label>
              <input type="radio" name="type" value="balanced" />
              Balanced
            </label>
          </div>
        </fieldset>
        
        {/* Checkbox group */}
        <fieldset>
          <legend>Select Metrics (Choose up to 10)</legend>
          <div role="group" aria-describedby="metrics-description">
            <p id="metrics-description">
              Select the metrics you want to include in your formula
            </p>
            {metrics.map(metric => (
              <label key={metric.id}>
                <input
                  type="checkbox"
                  name="metrics"
                  value={metric.id}
                  aria-describedby={`metric-${metric.id}-description`}
                />
                {metric.name}
                <span id={`metric-${metric.id}-description`} className="sr-only">
                  {metric.description}
                </span>
              </label>
            ))}
          </div>
        </fieldset>
      </fieldset>
      
      {/* Form actions */}
      <div className="form-actions">
        <button type="submit">
          Save Formula
        </button>
        <button type="button" onClick={handleCancel}>
          Cancel
        </button>
      </div>
    </form>
  );
};
```

### 7. Screen Reader Announcements

```typescript
// Live region announcements
export const useAnnouncement = () => {
  const announce = (message: string, priority: 'polite' | 'assertive' = 'polite') => {
    const announcement = document.createElement('div');
    announcement.setAttribute('role', 'status');
    announcement.setAttribute('aria-live', priority);
    announcement.setAttribute('aria-atomic', 'true');
    announcement.className = 'sr-only';
    announcement.textContent = message;
    
    document.body.appendChild(announcement);
    
    // Remove after announcement
    setTimeout(() => {
      document.body.removeChild(announcement);
    }, 1000);
  };
  
  return { announce };
};

// Usage in components
const FormulaBuilder = () => {
  const { announce } = useAnnouncement();
  
  const handleMetricAdd = (metric: Metric) => {
    addMetric(metric);
    announce(`${metric.name} added to formula`);
  };
  
  const handleMetricRemove = (metric: Metric) => {
    removeMetric(metric);
    announce(`${metric.name} removed from formula`);
  };
  
  const handleSave = async () => {
    try {
      await saveFormula();
      announce('Formula saved successfully', 'assertive');
    } catch (error) {
      announce('Error saving formula. Please try again.', 'assertive');
    }
  };
};
```

### 8. Responsive and Adaptive Design

```typescript
// Responsive utilities with accessibility
export const ResponsiveTable: React.FC<TableProps> = ({ data, columns }) => {
  const isMobile = useMediaQuery('(max-width: 768px)');
  
  if (isMobile) {
    // Card layout for mobile
    return (
      <div role="list" aria-label="Predictions">
        {data.map((row, index) => (
          <div
            key={index}
            role="listitem"
            className="card"
            aria-label={`Prediction ${index + 1}`}
          >
            {columns.map(column => (
              <div key={column.key}>
                <span className="label">{column.label}:</span>
                <span className="value">{row[column.key]}</span>
              </div>
            ))}
          </div>
        ))}
      </div>
    );
  }
  
  // Table layout for desktop
  return (
    <table role="table" aria-label="Predictions">
      <thead>
        <tr role="row">
          {columns.map(column => (
            <th key={column.key} role="columnheader" scope="col">
              {column.label}
            </th>
          ))}
        </tr>
      </thead>
      <tbody>
        {data.map((row, index) => (
          <tr key={index} role="row">
            {columns.map(column => (
              <td key={column.key} role="cell">
                {row[column.key]}
              </td>
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  );
};
```

## Testing Accessibility

### 1. Automated Testing

```typescript
// Jest + Testing Library accessibility tests
import { render } from '@testing-library/react';
import { axe, toHaveNoViolations } from 'jest-axe';

expect.extend(toHaveNoViolations);

describe('FormulaBuilder Accessibility', () => {
  it('should have no accessibility violations', async () => {
    const { container } = render(<FormulaBuilder />);
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });
  
  it('should have proper ARIA labels', () => {
    const { getByRole } = render(<FormulaBuilder />);
    
    expect(getByRole('application')).toHaveAttribute(
      'aria-label',
      'Formula Builder'
    );
    
    expect(getByRole('region', { name: 'Metrics Library' })).toBeInTheDocument();
    expect(getByRole('region', { name: 'Formula Canvas' })).toBeInTheDocument();
  });
  
  it('should be keyboard navigable', () => {
    const { getByRole } = render(<FormulaBuilder />);
    const firstMetric = getByRole('button', { name: /Recent Form/i });
    
    firstMetric.focus();
    expect(document.activeElement).toBe(firstMetric);
    
    fireEvent.keyDown(firstMetric, { key: 'Enter' });
    // Assert metric is selected
  });
});
```

### 2. Manual Testing Checklist

#### Keyboard Testing
- [ ] Can navigate entire application using only keyboard
- [ ] Tab order is logical and predictable
- [ ] Focus indicators are always visible
- [ ] Can activate all interactive elements with Enter/Space
- [ ] Can exit modals and dropdowns with Escape
- [ ] Keyboard shortcuts don't conflict with screen reader shortcuts

#### Screen Reader Testing
- [ ] All images have appropriate alt text
- [ ] Form fields have associated labels
- [ ] Error messages are announced
- [ ] Dynamic content updates are announced
- [ ] Page structure is logical when CSS is disabled
- [ ] Headings create meaningful document outline

#### Visual Testing
- [ ] Text has sufficient color contrast (4.5:1 normal, 3:1 large)
- [ ] Information isn't conveyed by color alone
- [ ] Interactive elements have hover and focus states
- [ ] Text can be resized to 200% without loss of functionality
- [ ] Layout works with browser zoom at 400%

### 3. Testing Tools

```javascript
// Playwright accessibility testing
import { test, expect } from '@playwright/test';
import { injectAxe, checkA11y } from 'axe-playwright';

test.describe('Accessibility Tests', () => {
  test('Formula page should be accessible', async ({ page }) => {
    await page.goto('/formulas/new');
    await injectAxe(page);
    await checkA11y(page, null, {
      detailedReport: true,
      detailedReportOptions: {
        html: true,
      },
    });
  });
  
  test('Keyboard navigation flow', async ({ page }) => {
    await page.goto('/formulas/new');
    
    // Tab through interface
    await page.keyboard.press('Tab');
    const focusedElement = await page.evaluate(() => document.activeElement?.tagName);
    expect(focusedElement).toBe('BUTTON');
    
    // Activate with keyboard
    await page.keyboard.press('Enter');
    // Assert action occurred
  });
});
```

## Component Accessibility Patterns

### 1. Drag and Drop

```typescript
// Accessible drag and drop implementation
export const AccessibleDragDrop: React.FC = () => {
  const [draggedItem, setDraggedItem] = useState<string | null>(null);
  
  const handleKeyboardMove = (item: string, direction: 'up' | 'down') => {
    // Implement keyboard-based reordering
    const announcement = `${item} moved ${direction}`;
    announceToScreenReader(announcement);
  };
  
  return (
    <div role="application" aria-label="Reorderable list">
      <div className="instructions" id="dnd-instructions">
        Use arrow keys to reorder items. Press space to select, arrow keys to move, 
        and space again to drop.
      </div>
      
      <ul role="list" aria-describedby="dnd-instructions">
        {items.map((item, index) => (
          <li
            key={item.id}
            role="listitem"
            tabIndex={0}
            aria-grabbed={draggedItem === item.id}
            draggable
            onDragStart={() => setDraggedItem(item.id)}
            onKeyDown={(e) => {
              if (e.key === ' ') {
                e.preventDefault();
                setDraggedItem(draggedItem === item.id ? null : item.id);
              } else if (e.key === 'ArrowUp' && draggedItem === item.id) {
                e.preventDefault();
                handleKeyboardMove(item.name, 'up');
              } else if (e.key === 'ArrowDown' && draggedItem === item.id) {
                e.preventDefault();
                handleKeyboardMove(item.name, 'down');
              }
            }}
          >
            <span className="drag-handle" aria-hidden="true">⋮⋮</span>
            {item.name}
          </li>
        ))}
      </ul>
    </div>
  );
};
```

### 2. Loading States

```typescript
// Accessible loading states
export const LoadingSpinner: React.FC<{ label?: string }> = ({ 
  label = 'Loading...' 
}) => {
  return (
    <div
      role="status"
      aria-live="polite"
      aria-label={label}
      className="loading-spinner"
    >
      <span className="sr-only">{label}</span>
      <div className="spinner" aria-hidden="true" />
    </div>
  );
};

// Skeleton loader with announcement
export const SkeletonLoader: React.FC = () => {
  useEffect(() => {
    announceToScreenReader('Content is loading');
  }, []);
  
  return (
    <div role="status" aria-busy="true" aria-label="Loading content">
      <div className="skeleton-line" aria-hidden="true" />
      <div className="skeleton-line" aria-hidden="true" />
      <div className="skeleton-line" aria-hidden="true" />
    </div>
  );
};
```

### 3. Error Messages

```typescript
// Accessible error handling
export const ErrorMessage: React.FC<{ error: string; fieldId: string }> = ({ 
  error, 
  fieldId 
}) => {
  return (
    <div
      id={`${fieldId}-error`}
      role="alert"
      aria-live="assertive"
      className="error-message"
    >
      <svg aria-hidden="true" className="error-icon">
        {/* Error icon */}
      </svg>
      <span>{error}</span>
    </div>
  );
};
```

## Accessibility Compliance Checklist

### Level A (Must Have)
- [x] Images have text alternatives
- [x] Videos have captions
- [x] Content is keyboard accessible
- [x] Page has a language attribute
- [x] Pages have descriptive titles
- [x] Heading hierarchy is logical
- [x] Links have descriptive text
- [x] Form fields have labels

### Level AA (Required for Compliance)
- [x] Color contrast meets minimums (4.5:1 normal, 3:1 large)
- [x] Text can resize to 200% without horizontal scrolling
- [x] Images of text are avoided (except logos)
- [x] Focus order is logical
- [x] Focus is visible
- [x] Navigation is consistent
- [x] Error identification is clear
- [x] Labels and instructions are provided

### Additional Best Practices
- [x] Skip navigation links provided
- [x] ARIA landmarks used appropriately
- [x] Loading states announced
- [x] Error recovery is possible
- [x] Time limits can be extended
- [x] Animations can be paused
- [x] High contrast mode supported

## Resources

### Testing Tools
- **axe DevTools**: Browser extension for accessibility testing
- **WAVE**: Web Accessibility Evaluation Tool
- **NVDA**: Free Windows screen reader
- **JAWS**: Professional screen reader
- **VoiceOver**: Built-in macOS/iOS screen reader
- **Lighthouse**: Chrome DevTools accessibility audit

### References
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [ARIA Authoring Practices Guide](https://www.w3.org/WAI/ARIA/apg/)
- [WebAIM Resources](https://webaim.org/)
- [A11y Project Checklist](https://www.a11yproject.com/checklist/)

---

*Accessibility Guide Version 1.0 - Created 2025-08-28*
*Ensures WCAG 2.1 Level AA compliance for the AFL Data Capture Platform*