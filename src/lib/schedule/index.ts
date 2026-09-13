import { SCHEDULE_SOURCE } from "astro:env/server";
import { mockSource } from "./sources/mock";
import { sportsBlazeSource } from "./sources/sportsblaze";
import type { GameSchema, ScheduleSource } from "./types";

const sourcesByName: Record<string, ScheduleSource> = {
  mock: mockSource,
  sportsblaze: sportsBlazeSource,
};

const resolveSources = (): ScheduleSource[] => {
  const names = SCHEDULE_SOURCE
    .split(",")
    .map((name) => name.trim())
    .filter(Boolean);

  if (names.length === 0) {
    throw new Error("No schedule sources configured");
  }

  const sources: ScheduleSource[] = [];
  const errors: unknown[] = [];

  for (const name of names) {
    const source = sourcesByName[name];
    if (!source) {
      errors.push(
        new Error(
          `Unknown schedule source "${name}". Valid options: ${Object.keys(sourcesByName).join(", ")}`,
        ),
      );
      continue;
    }
    sources.push(source);
  }

  if (errors.length > 0) {
    throw new AggregateError(errors, "Failed to resolve schedule sources");
  }

  return sources;
};

export const loadSchedule = async (): Promise<GameSchema[]> => {
  const sources = resolveSources();
  const errors: unknown[] = [];

  for (const source of sources) {
    try {
      return await source.fetchGames();
    } catch (error) {
      errors.push(error);
    }
  }

  throw new AggregateError(
    errors,
    `All schedule sources failed: ${sources.map((source) => source.name).join(", ")}`,
  );
};
