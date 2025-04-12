export const theme = {
  colors: {
    primary: '#2563eb',    // Blue
    secondary: '#4f46e5',  // Indigo
    accent: '#8b5cf6',     // Purple
    success: '#22c55e',    // Green
    warning: '#f59e0b',    // Amber
    error: '#ef4444',      // Red
    background: '#ffffff', 
    text: {
      primary: '#1f2937',  // Gray-800
      secondary: '#4b5563', // Gray-600
      light: '#9ca3af'     // Gray-400
    }
  },
  typography: {
    fontFamily: {
      sans: ['Inter', 'system-ui', 'sans-serif'],
      heading: ['Poppins', 'sans-serif']
    },
    fontSize: {
      xs: '0.75rem',
      sm: '0.875rem',
      base: '1rem',
      lg: '1.125rem',
      xl: '1.25rem',
      '2xl': '1.5rem',
      '3xl': '1.875rem',
      '4xl': '2.25rem'
    },
    fontWeight: {
      normal: 400,
      medium: 500,
      semibold: 600,
      bold: 700
    }
  },
  transitions: {
    default: 'all 0.3s ease',
    fast: 'all 0.15s ease',
    slow: 'all 0.5s ease'
  },
  shadows: {
    sm: '0 1px 2px 0 rgba(0, 0, 0, 0.05)',
    md: '0 4px 6px -1px rgba(0, 0, 0, 0.1)',
    lg: '0 10px 15px -3px rgba(0, 0, 0, 0.1)'
  }
} 