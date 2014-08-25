(function() {
  var Map, Selector, Tile, TileGrid, calculatePixelPosition, input, pixels, utils;

  utils = require("./_utils");

  input = require("./_input");

  calculatePixelPosition = pixels = function(size, position, offset, zoom) {
    var endx, endy, x, xo, xp, xw, y, yo, yp, yw;
    xo = offset.x * size;
    yo = offset.y * size;
    xp = position.x * size;
    yp = position.y * size;
    xw = (xo + size + xp) * zoom;
    yw = (yo + size + yp) * zoom;
    x = xp + xo;
    y = yp + yo;
    endx = xw;
    endy = yw;
    return {
      x: x,
      y: y,
      endx: endx,
      endy: endy,
      size: size,
      "offset": {
        "x": xo,
        "y": yo
      }
    };
  };

  Tile = function(name, position, size, game, grid) {
    this.name = name;
    this.position = position;
    this.size = size;
    this.game = game;
    this.grid = grid;
    this.Sprites = this.game.Sprites;
    this.name = this.name || "plain";
    return this;
  };

  Tile.prototype.render = function() {
    var size, sprite, xo, xp, xw, yo, yp, yw, zoom;
    sprite = this.Sprites[this.name];
    sprite.game = this.game;
    size = this.size;
    zoom = this.grid.zoom;
    xo = this.grid.offset.x * size;
    yo = this.grid.offset.y * size;
    xp = this.position.x * size;
    yp = this.position.y * size;
    xw = (xo + size + xp) * zoom;
    yw = (yo + size + yp) * zoom;
    sprite.render.call(sprite, xp + xo, yp + yo, size, size, zoom);
    this.game.context.font = "" + (size / 4) + "px Consolas";
    this.game.context.fillStyle = "#fff";
    return this.game.context.fillText("" + this.position.x + "," + this.position.y, xp + xo + (size / 4), yp + yo + (size / 2));
  };

  Tile.prototype.toString = function() {
    return "[object Tile]";
  };

  module.exports.Tile = Tile;

  TileGrid = function(game, data, dimensions) {
    var createTiles, height, tilesize, width;
    this.game = game;
    this.data = data;
    this.dimensions = dimensions;
    Tile.prototype.game = game;
    this.tiles = [];
    width = this.dimensions.width;
    height = this.dimensions.height;
    tilesize = this.dimensions.tilesize;
    /* Convert the data into a normalized grid data
    */

    createTiles = function(coords, i, isCenterIndex) {
      var tile, tilename;
      tilename = this.data[1] === "-all" ? this.data[0] : this.data[i];
      tile = new Tile(tilename, coords, tilesize, this.game, this);
      if (typeof isCenterIndex === "number") {
        tile.isCenter = true;
        this.centerIndex = isCenterIndex;
      }
      this.tiles.push(tile);
    };
    utils.generateNormalizedGrid(width, height, createTiles, this);
    this.offset = {};
    this.offset.origin = {};
    this.offset.x = this.offset.origin.x = ~~(width / 2);
    this.offset.y = this.offset.origin.y = ~~(height / 2);
    this.zoom = 1;
    return this;
  };

  TileGrid.prototype.setZoom = function(zoom) {
    if (zoom == null) {
      zoom = 1;
    }
    return this.zoom = zoom;
  };

  TileGrid.prototype.crossZoom = function(modifier) {
    return this.zoom = this.zoom * modifier;
  };

  TileGrid.prototype.move = function(x, y) {
    if (x == null) {
      x = 0;
    }
    if (y == null) {
      y = 0;
    }
    this.offset.x += x;
    this.offset.y += y;
    return this.render();
  };

  TileGrid.prototype.AlignToOrigin = function() {
    this.offset.origin.x = this.offset.origin.x;
    this.offset.origin.y = this.offset.origin.y;
  };

  TileGrid.prototype.changeTile = function(x, y, tilename) {
    return console.log("wow");
  };

  TileGrid.prototype.render = function() {
    return this.tiles.forEach(function(tile) {
      return tile.render.call(tile);
    });
  };

  module.exports.TileGrid = TileGrid;

  Map = function(name, tilegrid, game, backgroundColor) {
    this.name = name;
    this.tilegrid = tilegrid;
    this.game = game;
    this.backgroundColor = backgroundColor != null ? backgroundColor : "#48c";
    this.centerIndex = this.tilegrid.centerIndex;
    this.drawBackground = function() {
      this.game.context.fillStyle = this.backgroundColor;
      return this.game.context.fillRect(0, 0, this.game.canvas.width, this.game.canvas.height);
    };
    return this;
  };

  Map.prototype.render = function() {
    return this.tilegrid.render.call(this.tilegrid);
  };

  Map.prototype.panningBindings = function() {
    return {
      "keydown numpad8": this.up.bind(this),
      "keydown numpad2": this.down.bind(this),
      "keydown numpad4": this.left.bind(this),
      "keydown numpad6": this.right.bind(this)
    };
  };

  Map.prototype.move = function(x, y) {
    if (x == null) {
      x = 1;
    }
    if (y == null) {
      y = 1;
    }
    return this.tilegrid.move(x, y);
  };

  Map.prototype.up = function() {
    return this.move(0, -1);
  };

  Map.prototype.down = function() {
    return this.move(0, 1);
  };

  Map.prototype.left = function() {
    return this.move(-1, 0);
  };

  Map.prototype.right = function() {
    return this.move(1, 0);
  };

  Map.prototype.play = function() {
    var selector, selectorPanProfile;
    console.log("Playing " + this.name + "!");
    selector = new Selector(this.game, this, "select");
    selectorPanProfile = new input.InputProfile("selector-panning", this.game.inputHandler, selector.movementActionBindings());
    selectorPanProfile.enable();
    return this.game.Layers.add.call(this.game, {
      name: "selector",
      layer: 6,
      fn: selector.render,
      scope: selector
    });
  };

  Map.prototype.edit = function() {
    return console.log("Editing " + this.name + "!");
  };

  module.exports.Map = Map;

  Selector = function(game, map, type) {
    var src;
    this.game = game;
    this.map = map;
    this.type = type != null ? type : "select";
    console.log(this);
    this.Sprites = this.game.Sprites;
    this.centerIndex = this.map.centerIndex;
    this.grid = utils.generateNormalizedGrid(this.map.tilegrid.dimensions.width, this.map.tilegrid.dimensions.height);
    src = this.grid[this.centerIndex];
    this.position = {
      x: src.x,
      y: src.y,
      x0: src.x0,
      y0: src.y0
    };
    this.map.selector = this;
    return this;
  };

  Selector.prototype.getIndexOf = function(position) {
    var index, p;
    if (position == null) {
      position = {
        x: 0,
        y: 0
      };
    }
    p = position;
    index = null;
    this.grid.forEach(function(el, i) {
      if (el.x === p.x && el.y === p.y) {
        return index = i;
      }
    });
    return index;
  };

  Selector.prototype.getIndex = function() {
    return this.getIndexOf(this.position);
  };

  Selector.prototype.getTile = function() {
    return this.grid[this.getIndex()];
  };

  Selector.prototype.getUnit = function() {};

  Selector.prototype.isOutOfBounds = function() {
    var amount, dimensions, isOutOfBounds, outOfBounds, tg;
    console.log(this.getTile());
    outOfBounds = false;
    tg = this.map.tilegrid;
    dimensions = pixels(tg.dimensions.tilesize, this.position, tg.offset, tg.zoom);
    amount = 2;
    if (dimensions.x < 0) {
      this.map.move.call(this.map, amount, 0);
      isOutOfBounds = true;
    } else if (dimensions.endx > window.innerWidth) {
      this.map.move.call(this.map, -amount, 0);
      isOutOfBounds = true;
    }
    if (dimensions.y < 0) {
      this.map.move.call(this.map, 0, amount);
      isOutOfBounds = true;
    } else if (dimensions.endy > window.innerHeight) {
      this.map.move.call(this.map, 0, -amount);
      isOutOfBounds = true;
    }
    return isOutOfBounds;
  };

  Selector.prototype.move = function(x, y) {
    this.position.x += x;
    this.position.y += y;
  };

  Selector.prototype.movementActionBindings = function() {
    return {
      "keydown up": this.moveUp.bind(this),
      "keydown down": this.moveDown.bind(this),
      "keydown left": this.moveLeft.bind(this),
      "keydown right": this.moveRight.bind(this)
    };
  };

  Selector.prototype.moveUp = function() {
    var max, min, p;
    p = this.position;
    min = -1 * p.y0;
    max = p.y0;
    p.y = Math.max(min, Math.min(max, p.y - 1));
    return this.isOutOfBounds();
  };

  Selector.prototype.moveDown = function() {
    var max, min, p;
    p = this.position;
    min = -1 * p.y0;
    max = utils.isEven(p.y0) ? p.y0 : p.y0 - 1;
    p.y = Math.max(min, Math.min(max, p.y + 1));
    return this.isOutOfBounds();
  };

  Selector.prototype.moveLeft = function() {
    var max, min, p;
    p = this.position;
    min = -1 * p.x0;
    max = p.x0;
    p.x = Math.max(min, Math.min(max, p.x - 1));
    return this.isOutOfBounds();
  };

  Selector.prototype.moveRight = function() {
    var max, min, p;
    p = this.position;
    min = -1 * p.x0;
    max = utils.isEven(p.x0) ? p.x0 : p.x0;
    p.x = Math.max(min, Math.min(max, p.x + 1));
    return this.isOutOfBounds();
  };

  Selector.prototype.render = function() {
    var ctx, dimensions, tg;
    tg = this.map.tilegrid;
    dimensions = pixels(tg.dimensions.tilesize, this.position, tg.offset, tg.zoom);
    ctx = this.game.context;
    ctx.strokeStyle = this.color || "#eee";
    return ctx.strokeRect(dimensions.x - 1, dimensions.y - 1, dimensions.size + 1, dimensions.size + 1);
  };

  module.exports.Selector = Selector;

}).call(this);

// Generated by CoffeeScript 1.5.0-pre
