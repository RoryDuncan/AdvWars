(function() {
  var Map, Selector, Tile, TileGrid, currentRadian, extend, input, lines, pixels, utils;

  utils = require("./_utils");

  extend = utils.extend;

  pixels = utils.calculatePixelPosition;

  input = require("./_input");

  Tile = function(game, name, position, size, grid) {
    this.game = game;
    this.name = name;
    this.position = position;
    this.size = size;
    this.grid = grid;
    this.Sprites = this.game.Sprites;
    this.name = this.name || "plain";
    return this;
  };

  Tile.prototype.render = function() {
    var size, sprite, xo, xp, xw, yo, yp, yw, zoom;
    sprite = this.Sprites[this.name];
    if (!sprite) {
      return;
    }
    size = this.size;
    zoom = this.grid.zoom;
    xo = this.grid.offset.x * size;
    yo = this.grid.offset.y * size;
    xp = this.position.x * size;
    yp = this.position.y * size;
    xw = (xo + size + xp) * zoom;
    yw = (yo + size + yp) * zoom;
    return sprite.render.call(sprite, xp + xo, yp + yo, size, size, zoom);
  };

  Tile.prototype.showPosition = function(xp, xo, yp, yo, size, zoom) {
    this.game.context.font = "" + (size / 4) + "px Helvetica";
    this.game.context.fillStyle = "#444";
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
      tile = new Tile(this.game, tilename, coords, tilesize, this);
      if (typeof isCenterIndex === "number") {
        tile.isCenter = true;
        this.centerIndex = isCenterIndex;
      }
      this.tiles.push(tile);
    };
    utils.generateNormalizedGrid(width, height, createTiles, this);
    this.offset = {};
    this.offset.origin = {};
    this.offset.x = this.offset.origin.x = ~~width;
    this.offset.y = this.offset.origin.y = ~~height;
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
    this.backgroundColor = backgroundColor != null ? backgroundColor : "#476ca1";
    this.centerIndex = this.tilegrid.centerIndex;
    return this;
  };

  Map.prototype.render = function() {
    return this.tilegrid.render.call(this.tilegrid);
  };

  currentRadian = 0;

  lines = 90;

  Map.prototype.drawBackground = function() {
    var calc_x, calc_y, ctx, game, line, lineColor, lineWidth, max, middle, pi, previousStroke, radius, rayWidth, space, _i;
    game = this.game;
    ctx = game.context;
    lineWidth = game.canvas.width / lines;
    lineColor = this.backgroundColor2 || "#6393d8";
    previousStroke = game.context.strokeStyle;
    max = 6;
    pi = 22 / 7;
    rayWidth = 25;
    radius = game.canvas.width;
    space = (360 / lines) * (pi / 180);
    middle = {
      x: game.canvas.width / 2,
      y: game.canvas.height / 2
    };
    ctx.fillStyle = this.backgroundColor;
    ctx.fillRect(0, 0, game.canvas.width, game.canvas.height);
    ctx.strokeStyle = lineColor;
    for (line = _i = 0; 0 <= lines ? _i <= lines : _i >= lines; line = 0 <= lines ? ++_i : --_i) {
      ctx.beginPath();
      ctx.moveTo(middle.x, middle.y);
      calc_x = (radius * Math.sin(currentRadian + (space * line))) + middle.x;
      calc_y = (radius * Math.cos(currentRadian + (space * line))) + middle.y;
      ctx.lineTo(calc_x, calc_y);
      ctx.lineWidth = lineWidth;
      ctx.stroke();
      ctx.closePath();
    }
    currentRadian += 0.002;
    if (currentRadian > max) {
      currentRadian = -1 * max;
    }
    ctx.globalAlpha = 1;
    return ctx.strokeStyle = previousStroke;
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
    this.Sprites = this.game.Sprites;
    this.centerIndex = this.map.centerIndex;
    this.grid = utils.generateNormalizedGrid(this.map.tilegrid.dimensions.width, this.map.tilegrid.dimensions.height);
    src = this.grid[this.centerIndex];
    this.position = extend({}, src);
    this.map.selector = this;
    return this;
  };

  Selector.prototype.getGameObjectsHere = function(p) {
    var selected;
    selected = this.getUnitAt(this.position) || this.getTile();
    return selected;
  };

  Selector.prototype.getIndexOf = function(position) {
    var index;
    if (position == null) {
      position = {
        x: 0,
        y: 0,
        id: 0
      };
    }
    index = null;
    this.grid.forEach(function(el, i) {
      if (el.x === position.x && el.y === position.y) {
        return index = i;
      }
    });
    return index;
  };

  Selector.prototype.getIndex = function() {
    return this.position.id || 0;
  };

  Selector.prototype.getTile = function() {
    return this.grid[this.getIndex()];
  };

  Selector.prototype.getUnitAt = function(position) {
    if (!this.game.UnitManager) {
      return {};
    }
    return this.game.UnitManager.getUnitAt(position);
  };

  Selector.prototype.isOutOfBounds = function(move) {
    var amount, dimensions, isOutOfBounds, outOfBounds, tg;
    if (move == null) {
      move = true;
    }
    outOfBounds = false;
    tg = this.map.tilegrid;
    dimensions = pixels(tg.dimensions.tilesize, this.position, tg.offset, tg.zoom);
    amount = 2;
    if (move) {
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
    } else {
      if (dimensions.x < 0) {
        return true;
      } else if (dimensions.endx > window.innerWidth) {
        return true;
      }
      if (dimensions.y < 0) {
        return true;
      } else if (dimensions.endy > window.innerHeight) {
        return true;
      }
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
    var p;
    p = this.position;
    p.y = utils.limitToRange(p.y - 1, p.start.y, p.end.y);
    return this.isOutOfBounds();
  };

  Selector.prototype.moveDown = function() {
    var p;
    p = this.position;
    p.y = utils.limitToRange(p.y + 1, p.start.y, p.end.y);
    return this.isOutOfBounds();
  };

  Selector.prototype.moveLeft = function() {
    var p;
    p = this.position;
    p.x = utils.limitToRange(p.x - 1, p.start.x, p.end.x);
    return this.isOutOfBounds();
  };

  Selector.prototype.moveRight = function() {
    var p;
    p = this.position;
    p.x = utils.limitToRange(p.x + 1, p.start.x, p.end.x);
    return this.isOutOfBounds();
  };

  Selector.prototype.render = function() {
    var ctx, dimensions, ls, tg;
    ls = 1;
    tg = this.map.tilegrid;
    dimensions = pixels(tg.dimensions.tilesize, this.position, tg.offset, tg.zoom);
    ctx = this.game.context;
    ctx.strokeStyle = this.color || "#eee";
    ctx.lineWidth = ls;
    return ctx.strokeRect(dimensions.x - ls, dimensions.y - ls, dimensions.size + ls, dimensions.size + ls);
  };

  module.exports.Selector = Selector;

}).call(this);

// Generated by CoffeeScript 1.5.0-pre
