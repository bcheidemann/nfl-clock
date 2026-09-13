import { defineCollection } from "astro:content";
import { z } from "astro/zod";

const gameSchema = z.object({
  season: z.object({ type: z.string() }),
  teams: z.object({
    away: z.object({ name: z.string() }),
    home: z.object({ name: z.string() }),
  }),
  date: z.coerce.date(),
  status: z.string(),
});

const schedule = defineCollection({
  loader: async () => {
    const response = await fetch(
      `https://api.sportsblaze.com/nfl/v1/schedule/season/2025.json?key=${import.meta.env.SPORTS_BLAZE_API_KEY}`,
    );

    if (!response.ok) {
      throw Error(
        `[${response.status}] Error fetching schedule: ${await response.text().catch(() => null)}`,
      );
    }

    const { games } = (await response.json()) as { games: unknown[] };

    return games.map((game, index) => ({ id: String(index), ...(game as object) }));
  },
  schema: gameSchema,
});

export const collections = { schedule };
