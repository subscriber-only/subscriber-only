
export function cssVar(name) {
  return window
    .getComputedStyle(document.documentElement)
    .getPropertyValue(name);
}
