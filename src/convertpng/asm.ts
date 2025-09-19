import { toHexByte, toHexWord } from "./toHex";

function toAsm(
  data: number[],
  width: "b" | "w",
  numbersPerRow: number
): string {
  const hexFn = width === "b" ? toHexByte : toHexWord;
  const rows: string[] = [];

  let row: string[] = [];

  for (let i = 0; i < data.length; ++i) {
    if (row.length === numbersPerRow) {
      rows.push(` .d${width} ${row.join(",")}`);
      row = [];
    }
    row.push(hexFn(data[i]));
  }

  rows.push(` .d${width} ${row.join(",")}`);
  return rows.join("\r\n") + "\r\n";
}

export { toAsm };
