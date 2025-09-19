export function toHexByte(num: number): string {
  const rawHex = num.toString(16);
  const neededFiller = Math.max(2 - rawHex.length, 0);
  const filler = new Array(neededFiller).fill("0").join("");

  return `0x${filler}${rawHex}`;
}

export function toHexWord(num: number): string {
  const rawHex = num.toString(16);
  const neededFiller = Math.max(4 - rawHex.length, 0);
  const filler = new Array(neededFiller).fill("0").join("");

  return `0x${filler}${rawHex}`;
}
