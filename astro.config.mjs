// @ts-check
import { defineConfig, envField } from "astro/config";

// https://astro.build/config
export default defineConfig({
  site: "https://nflclock.com",
  base: "/",
  env: {
    schema: {
      SCHEDULE_SOURCE: envField.string({
        context: "server",
        access: "public",
        optional: false,
      }),
      SPORTS_BLAZE_API_KEY: envField.string({
        context: "server",
        access: "secret",
        optional: true,
      }),
    },
  },
});
