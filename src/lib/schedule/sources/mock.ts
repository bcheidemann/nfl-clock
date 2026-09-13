import { teams } from "../../../teams";
import { getCurrentSeasonYear } from "../season";
import type { ScheduleSource } from "../types";

const getFirstSundayOfSeptember = (year: number): Date => {
  const date = new Date(year, 8, 1, 13, 0, 0, 0);
  date.setDate(date.getDate() + ((7 - date.getDay()) % 7));
  return date;
};

// Circle method round-robin: fix one team, rotate the rest. Every team plays
// every week (no bye weeks modeled) to keep the mock schedule simple; this
// trades fidelity to the real NFL schedule for determinism and simplicity.
const buildRoundRobinWeeks = (teamNames: string[]): [string, string][][] => {
  const rotating = teamNames.slice(1);
  const fixed = teamNames[0];
  const weeks: [string, string][][] = [];

  for (let round = 0; round < teamNames.length - 1; round++) {
    const week: [string, string][] = [
      round % 2 === 0
        ? [fixed, rotating[0]]
        : [rotating[0], fixed],
    ];

    for (let i = 1; i < rotating.length / 2; i++) {
      const home = rotating[i];
      const away = rotating[rotating.length - i];
      week.push(round % 2 === 0 ? [home, away] : [away, home]);
    }

    weeks.push(week);
    rotating.unshift(rotating.pop() as string);
  }

  return weeks;
};

export const mockSource: ScheduleSource = {
  name: "Mock",
  fetchGames: async () => {
    const now = new Date();
    const seasonYear = getCurrentSeasonYear(now);
    const week1Date = getFirstSundayOfSeptember(seasonYear);
    const teamNames = teams.map((team) => team.name);

    const weeks = buildRoundRobinWeeks(teamNames).slice(0, 17);

    return weeks.flatMap((week, weekIndex) => {
      const date = new Date(week1Date);
      date.setDate(date.getDate() + weekIndex * 7);

      return week.map(([home, away], indexInWeek) => ({
        id: `mock-${weekIndex}-${indexInWeek}`,
        season: { type: "Regular Season" },
        teams: {
          away: { name: away },
          home: { name: home },
        },
        date,
        status: date.getTime() < Date.now() ? "Final" : "Scheduled",
      }));
    });
  },
};
