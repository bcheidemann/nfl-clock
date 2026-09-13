import { z } from "astro/zod";

export const gameSchema = z.object({
  id: z.string(),
  season: z.object({ type: z.string() }),
  teams: z.object({
    away: z.object({ name: z.string() }),
    home: z.object({ name: z.string() }),
  }),
  date: z.coerce.date(),
  status: z.string(),
});
