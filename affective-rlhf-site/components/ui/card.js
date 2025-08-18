import React from 'react';

export function Card({ children, className = '', ...props }) {
  return (
    <div 
      className={`bg-gray-800 border border-gray-700 rounded-lg shadow-lg ${className}`}
      {...props}
    >
      {children}
    </div>
  );
}

export function CardContent({ children, className = '', ...props }) {
  return (
    <div className={`${className}`} {...props}>
      {children}
    </div>
  );
}
