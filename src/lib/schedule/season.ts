export const getCurrentSeasonYear = (now: Date): number =>
  now.getMonth() >= 2 ? now.getFullYear() : now.getFullYear() - 1;
