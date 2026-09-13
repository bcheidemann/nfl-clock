import { sportsBlazeSource } from "./sportsblaze";
import type { GameSchema, ScheduleSource } from "./types";

const sources: ScheduleSource[] = [sportsBlazeSource];

export const loadSchedule = async (): Promise<GameSchema[]> => {
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
