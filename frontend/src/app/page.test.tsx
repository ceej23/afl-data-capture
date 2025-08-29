import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import Home from './page';

describe('Home Page', () => {
  it('renders the get started text', () => {
    render(<Home />);
    
    const getStartedText = screen.getByText(/get started by editing/i);
    
    expect(getStartedText).toBeDefined();
  });

  it('contains Next.js logo', () => {
    render(<Home />);
    
    const nextLogo = screen.getByAltText('Next.js logo');
    
    expect(nextLogo).toBeDefined();
  });

  it('has deploy and documentation links', () => {
    render(<Home />);
    
    const deployLink = screen.getByText(/deploy now/i);
    const docsLink = screen.getByText(/read our docs/i);
    const learnLink = screen.getByText(/learn/i);
    
    expect(deployLink).toBeDefined();
    expect(docsLink).toBeDefined();
    expect(learnLink).toBeDefined();
  });
});