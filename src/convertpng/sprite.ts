import { toAsm } from "./asm";
import { toC } from "./c";
import {
  createCanvasFromPath,
  forceCanvasToPalette,
  reduceColors,
} from "./canvas";
import {
  BasicSpriteSpec,
  Format,
  SharedPaletteSpriteSpec,
  SpriteSpec,
} from "./types";
import { extractPalette, reducePalettes } from "./palette";
import { extractTiles } from "./tile";
import { Canvas } from "canvas";

type ProcessSpriteResult = {
  canvas: Canvas;
  tilesSrc: string[] | number[];
  paletteSrc: string | number[];
};

function isBasicSpriteSpec(sprite: SpriteSpec): sprite is BasicSpriteSpec {
  return "file" in sprite;
}

async function processBasicSprite(
  sprite: BasicSpriteSpec,
  format: Format,
  forcedPalette?: Canvas
): Promise<ProcessSpriteResult> {
  let canvas = await reduceColors(await createCanvasFromPath(sprite.file), 16);

  let palette: number[];
  if (forcedPalette) {
    canvas = await forceCanvasToPalette(canvas, forcedPalette);
    palette = extractPalette(forcedPalette, false);
  } else {
    palette = extractPalette(canvas, !sprite.trimPalette);
  }

  const tiles = extractTiles(canvas, palette, sprite.frames).flat(1);

  if (format === "bin") {
    return {
      canvas,
      tilesSrc: tiles,
      paletteSrc: palette,
    };
  }

  const tileSrcFun = format === "z80" ? toAsm : toC;
  const paletteSrcFun = format === "z80" ? toAsm : toC;

  return {
    canvas,
    tilesSrc: [tileSrcFun(tiles, "b", 4)],
    paletteSrc: paletteSrcFun(palette, "w", 4),
  };
}

async function processSharedPaletteSprites(
  sharedPaletteSprite: SharedPaletteSpriteSpec,
  format: Format,
  forcedPalette?: Canvas
): Promise<ProcessSpriteResult> {
  const canvases: Canvas[] = [];
  const palettes: number[][] = [];

  for (let i = 0; i < sharedPaletteSprite.sharedPalette.length; ++i) {
    let c = await reduceColors(
      await createCanvasFromPath(sharedPaletteSprite.sharedPalette[i].file),
      16
    );
    if (forcedPalette) {
      c = await forceCanvasToPalette(c, forcedPalette);
    }
    canvases.push(c);
    palettes.push(extractPalette(c, !sharedPaletteSprite.trimPalette));
  }

  const commonPalette = forcedPalette
    ? extractPalette(forcedPalette, false)
    : reducePalettes(palettes);

  const tiles: number[][] = [];
  for (let i = 0; i < sharedPaletteSprite.sharedPalette.length; ++i) {
    const t = extractTiles(
      canvases[i],
      commonPalette,
      sharedPaletteSprite.sharedPalette[i].frames
    ).flat(1);
    tiles.push(t);
  }

  const tileSrcFun = format === "z80" ? toAsm : toC;
  const paletteSrcFun = format === "z80" ? toAsm : toC;

  return {
    // this is useless in this scenario, but canvas
    // really only exists for the puzzle generator
    canvas: canvases[0],
    tilesSrc: tiles.map((t) => tileSrcFun(t, "b", 4)),
    paletteSrc: paletteSrcFun(commonPalette, "w", 4),
  };
}

async function processSprite(
  sprite: SpriteSpec,
  format: Format,
  forcedPalettePath?: string
): Promise<ProcessSpriteResult> {
  const forcedPalette = forcedPalettePath
    ? await createCanvasFromPath(forcedPalettePath)
    : undefined;
  if (isBasicSpriteSpec(sprite)) {
    return processBasicSprite(sprite, format, forcedPalette);
  } else {
    return processSharedPaletteSprites(sprite, format, forcedPalette);
  }
}

export { isBasicSpriteSpec, processSprite };
export type { ProcessSpriteResult };
