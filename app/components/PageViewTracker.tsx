'use client';

import { useEffect } from 'react';
import { usePathname } from 'next/navigation';
import { trackPageView } from '@/lib/analytics-client';
import type { LandingPage } from '@/types/events';

/** Map pathname to landing_page enum */
function pathToLandingPage(pathname: string): LandingPage {
  if (pathname === '/' || pathname === '') return 'homepage';
  if (pathname.includes('pricing')) return 'pricing';
  if (pathname.includes('sign') || pathname.includes('auth')) return 'sign up page';
  if (pathname.includes('checkout')) return 'checkout';
  return 'Other';
}

interface PageViewTrackerProps {
  /** Override auto-detected page (optional) */
  page?: LandingPage;
}

/**
 * Client component that tracks page views on route change.
 * Add to layout or _app.
 */
export function PageViewTracker({ page }: PageViewTrackerProps) {
  const pathname = usePathname();

  useEffect(() => {
    if (!pathname) return;

    const landingPage = page ?? pathToLandingPage(pathname);
    trackPageView(landingPage);
  }, [pathname, page]);

  return null;
}
