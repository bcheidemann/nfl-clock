import type { z } from "astro/zod";
import type { gameSchema } from "./schemas";

export type GameSchema = z.infer<typeof gameSchema>;

export type ScheduleSource = {
  name: string;
  fetchGames: () => Promise<GameSchema[]>;
};
