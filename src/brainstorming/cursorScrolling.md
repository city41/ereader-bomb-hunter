# Cursor Scrolling

Today the cursor always just stays in the middle of the screen and the playfield moves around to accomplish scrolling that technically works but is unsatisfying.

Instead what we want is the cursor to freely move around in a bounding area in the center of the screen and if it pushes beyond that bounding box, instead scroll the screen

```javascript
let cursorBoard = { x: 4, y: 4 };
let cursorScreen = { x: 7, y: 4 };
let camera = { x: 0, y: 0 };

const boundingArea = {
  top: 3,
  left: 3,
  right: 10,
  bottom: 6,
};

function withinBoundingArea(p) {
  return (
    p.x >= boundingArea.left &&
    p.x <= boundingArea.right &&
    p.y >= boundingArea.top &&
    p.y <= boundingArea.bottom
  );
}

function handleGoRight() {
  // TODO: if we are going to go out of bounds, bail
  cursorBoard.x += 1;

  if (withingBoundingArea({ ...cursorScreen, x: cursorScreen.x + 1 })) {
    cursorScreen.x += 1;
    cursorRender();
  } else {
    camera.x += 1;
    boardRender();
  }
}
```
