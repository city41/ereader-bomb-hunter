# Tile Data Format

Goal: fit everything needed for a tile in one byte

## All needed things

- whether it is discovered or undiscovered
- how many bombs it is next to
- whether it has a bomb
- whether it has been flagged

## byte format

```
 76543210
[SBFxCCCC]
```

S - state = 1 undiscovered, 0 discovered
B - bomb = 0 no bomb, 1 bomb
F - flagged = 0 not flagged, 1 flagged
C - bomb adjacency count, 0-8 inclusive
x - unused

## all tiles

### byte values

```
- undiscovered                                 - [10000000] - 0x80 - 128
- undiscovered, flagged (incorrectly, no bomb) - [10100000] - 0xa0 - 160
- undiscovered, flagged (correctly, bomb)      - [11100000] - 0xd0 - 224
- discovered, bomb                             - [01000000] - 0x40 - 64
- discovered, empty                            - [00000000] - 0
- discovered, bomb count 1                     - [00000001] - 1
- discovered, bomb count 2                     - [00000010] - 2
- discovered, bomb count 3                     - [00000011] - 3
- discovered, bomb count 4                     - [00000100] - 4
- discovered, bomb count 5                     - [00000101] - 5
- discovered, bomb count 6                     - [00000110] - 6
- discovered, bomb count 7                     - [00000111] - 7
- discovered, bomb count 8                     - [00001000] - 8
```

### graphics

0 - discovered, empty
1 - discovered, bomb count 1
2 - discovered, bomb count 2
3 - discovered, bomb count 3
4 - discovered, bomb count 4
5 - discovered, bomb count 5
6 - discovered, bomb count 6
7 - discovered, bomb count 7
8 - discovered, bomb count 8
9 - discovered, bomb
10 - undiscovered, flagged
11 - undiscovered
12 - outside of playfield (ie transparent, or a checkerboard, etc)

TODO: when hitting a bomb, it should randomly choose to show a mad bomb, timid bomb, goofy bomb, etc
