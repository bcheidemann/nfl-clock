import { defineCollection } from "astro:content";

import { loadSchedule } from "./lib/schedule";
import { gameSchema } from "./lib/schedule/schemas";

const schedule = defineCollection({
  loader: loadSchedule,
  schema: gameSchema,
});

export const collections = { schedule };
