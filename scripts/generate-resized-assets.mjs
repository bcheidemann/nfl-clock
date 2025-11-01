import sharp from "sharp";
import { existsSync } from "fs";
import { join } from "path";

const teams = [
  "ARI",
  "ATL",
  "BAL",
  "BUF",
  "CAR",
  "CHI",
  "CIN",
  "CLE",
  "DAL",
  "DEN",
  "DET",
  "GB",
  "HOU",
  "IND",
  "JAX",
  "KC",
  "LAC",
  "LAR",
  "LV",
  "MIA",
  "MIN",
  "NE",
  "NO",
  "NYG",
  "NYJ",
  "PHI",
  "PIT",
  "SEA",
  "SF",
  "TB",
  "TEN",
  "WAS",
];

const config = [
  {
    src: "banner.png",
    out: "banner-w360.png",
    width: 360,
  },
];

async function resizeAssets() {
  for (const team of teams) {
    for (const asset of config) {
      const inputPath = join("public", team, asset.src);

      if (!existsSync(inputPath)) {
        console.log(`⚠️  Skipping ${team}: ${asset.src} not found`);
        continue;
      }

      try {
        await sharp(inputPath)
          .resize(asset.width, null, {
            fit: "contain",
            withoutEnlargement: false,
          })
          .toFile(join("public", team, asset.out));

        console.log(`✅ Resized ${team}/${asset.src} -> ${asset.out}`);
      } catch (error) {
        console.error(`❌ Error resizing ${team}/${asset.src}:`, error.message);
      }
    }
  }

  console.log("\n🎉 Done!");
}

resizeAssets();
