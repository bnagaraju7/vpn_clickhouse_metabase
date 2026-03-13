import type { Metadata } from 'next';
import { PageViewTracker } from './components/PageViewTracker';
import './globals.css';

export const metadata: Metadata = {
  title: 'Web Data Infrastructure',
  description: 'Sign Up, Sign In & User Acquisition tracking',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>
        <PageViewTracker />
        {children}
      </body>
    </html>
  );
}
