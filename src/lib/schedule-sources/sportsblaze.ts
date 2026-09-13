import { z } from "astro/zod";
import type { ScheduleSource } from "./types";

const responseSchema = z.object({
  games: z.array(
    z.object({
      season: z.object({ type: z.string() }),
      teams: z.object({
        away: z.object({ name: z.string() }),
        home: z.object({ name: z.string() }),
      }),
      date: z.coerce.date(),
      status: z.string(),
    }),
  ),
});

export const sportsBlazeSource: ScheduleSource = {
  name: "SportsBlaze",
  fetchGames: async () => {
    const response = await fetch(
      `https://api.sportsblaze.com/nfl/v1/schedule/season/2025.json?key=${import.meta.env.SPORTS_BLAZE_API_KEY}`,
    );

    if (!response.ok) {
      throw new Error(
        `[${response.status}] Error fetching schedule from SportsBlaze: ${await response.text().catch(() => null)}`,
      );
    }

    const responseJson = await response.json();
    const schedule = responseSchema.parse(responseJson);

    return schedule.games.map((game, index) => ({
      ...game,
      id: String(index),
    }));
  },
};
