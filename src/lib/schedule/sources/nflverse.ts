import parquet from "@dsnp/parquetjs";
import { Temporal } from "temporal-polyfill";
import { z } from "astro/zod";
import { teams } from "../../../teams";
import { getCurrentSeasonYear } from "../season";
import type { GameSchema, ScheduleSource } from "../types";

const GAMES_PARQUET_URL =
  "https://github.com/nflverse/nflverse-data/releases/download/schedules/games.parquet";

// nflverse uses "LA" for the Rams; this app uses "LAR" (src/teams.ts).
const TEAM_ABBREVIATION_ALIASES: Record<string, string> = {
  LA: "LAR",
};

const teamNamesById = new Map(teams.map((team) => [team.id, team.name]));

const resolveTeamName = (abbreviation: string): string => {
  const id = TEAM_ABBREVIATION_ALIASES[abbreviation] ?? abbreviation;
  const name = teamNamesById.get(id);
  if (!name) {
    throw new Error(`Unknown nflverse team abbreviation: ${abbreviation}`);
  }
  return name;
};

const GAME_TYPE_NAMES: Record<string, string> = {
  REG: "Regular Season",
  WC: "Wild Card",
  DIV: "Divisional Round",
  CON: "Conference Championship",
  SB: "Super Bowl",
};

const resolveGameTypeName = (gameType: string): string => {
  const name = GAME_TYPE_NAMES[gameType];
  if (!name) {
    throw new Error(`Unknown nflverse game_type: ${gameType}`);
  }
  return name;
};

const seasonSchema = z.object({ season: z.number() });

const rowSchema = z.object({
  game_id: z.string(),
  game_type: z.string(),
  gameday: z.string(),
  gametime: z.string(),
  away_team: z.string(),
  home_team: z.string(),
  home_score: z.number().nullable(),
  away_score: z.number().nullable(),
});

// gameday/gametime are wall-clock US/Eastern with no explicit offset.
const easternToDate = (gameday: string, gametime: string): Date =>
  new Date(
    Temporal.PlainDateTime.from(`${gameday}T${gametime}`)
      .toZonedDateTime("America/New_York")
      .epochMilliseconds,
  );

export const nflverseSource: ScheduleSource = {
  name: "Nflverse",
  fetchGames: async () => {
    const response = await fetch(GAMES_PARQUET_URL);

    if (!response.ok) {
      throw new Error(
        `[${response.status}] Error fetching schedule from nflverse: ${await response.text().catch(() => null)}`,
      );
    }

    const buffer = Buffer.from(await response.arrayBuffer());
    const reader = await parquet.ParquetReader.openBuffer(buffer);
    const currentSeason = getCurrentSeasonYear(new Date());
    const games: GameSchema[] = [];

    try {
      const cursor = reader.getCursor();
      let record: unknown;
      while ((record = await cursor.next())) {
        if (seasonSchema.parse(record).season !== currentSeason) {
          continue;
        }
        const row = rowSchema.parse(record);

        games.push({
          id: row.game_id,
          season: { type: resolveGameTypeName(row.game_type) },
          teams: {
            away: { name: resolveTeamName(row.away_team) },
            home: { name: resolveTeamName(row.home_team) },
          },
          date: easternToDate(row.gameday, row.gametime),
          status:
            row.home_score !== null && row.away_score !== null
              ? "Final"
              : "Scheduled",
        });
      }
    } finally {
      await reader.close();
    }

    return games;
  },
};
