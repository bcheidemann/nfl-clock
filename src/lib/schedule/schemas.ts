import { z } from "astro/zod";

export const gameSchema = z.object({
  id: z.string(),
  season: z.object({ type: z.string() }),
  teams: z.object({
    away: z.object({ name: z.string(), score: z.number().optional() }),
    home: z.object({ name: z.string(), score: z.number().optional() }),
  }),
  date: z.coerce.date(),
  status: z.string(),
});
