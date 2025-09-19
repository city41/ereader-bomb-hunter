export type Format = "C" | "z80" | "bin";

export type BasicSpriteSpec = {
  file: string;
  frames: number;
  trimPalette?: boolean;
  forcePalette?: string;
};

export type SharedPaletteSpriteSpec = {
  name: string;
  trimPalette?: boolean;
  sharedPalette: BasicSpriteSpec[];
  forcePalette?: string;
};

export type SpriteSpec = BasicSpriteSpec | SharedPaletteSpriteSpec;

export type BackgroundSpec = {
  file: string;
  trimPalette?: boolean;
};

export type ImportedJsonSpec = {
  outputDir: string;
  format?: Format;

  sprites?: SpriteSpec[];
  backgrounds?: BackgroundSpec[];
};

export type JsonSpec = Required<ImportedJsonSpec>;
