import { GraduationCap, Stethoscope, Home, Zap, Store, type LucideIcon } from 'lucide-react';
import type { Category } from '@/types';
import { CATEGORY_META } from '@/types';

const ICONS: Record<Category, LucideIcon> = {
  School: GraduationCap,
  Clinic: Stethoscope,
  Landlord: Home,
  Utility: Zap,
  Merchant: Store,
};

/** A rounded tile with the category's lucide icon in its accent colour. */
export function CategoryIcon({ category, size = 48 }: { category: Category; size?: number }) {
  const Icon = ICONS[category];
  const color = CATEGORY_META[category].color;
  return (
    <div
      className="rounded-2xl flex items-center justify-center shrink-0"
      style={{ width: size, height: size, background: `${color}18`, border: `1px solid ${color}2e` }}
    >
      <Icon style={{ color, width: size * 0.46, height: size * 0.46 }} />
    </div>
  );
}

export function categoryIcon(category: Category): LucideIcon {
  return ICONS[category];
}
