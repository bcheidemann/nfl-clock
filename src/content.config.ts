import { defineCollection } from "astro:content";

import { loadSchedule } from "./lib/schedule-sources";
import { gameSchema } from "./lib/schedule-sources/schemas";

const schedule = defineCollection({
  loader: loadSchedule,
  schema: gameSchema,
});

export const collections = { schedule };
