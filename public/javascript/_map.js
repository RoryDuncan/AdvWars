(function() {
  var Map, Tile, TileGrid, calculateTileRenderPositions, utils;

  utils = require("./_utils");

  calculateTileRenderPositions = function() {
    var size, xo, xp, xw, yo, yp, yw, zoom;
    size = this.size;
    zoom = this.grid.zoom;
    xo = this.grid.offset.x * size;
    yo = this.grid.offset.y * size;
    xp = (this.position.x * size) * zoom;
    yp = (this.position.y * size) * zoom;
    xw = (xo + size + xp) * zoom;
    return yw = (xo + size + xp) * zoom;
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
    xp = (this.position.x * size) * zoom;
    yp = (this.position.y * size) * zoom;
    xw = (xo + size + xp) * zoom;
    yw = (xo + size + xp) * zoom;
    return sprite.render.call(sprite, xp + xo, yp + yo, size, size, zoom);
  };

  module.exports.Tile = Tile;

  TileGrid = function(game, data, dimensions) {
    var centerIndex, evenOffset, height, i, tile, tilename, tilesize, width, x, x0, y, y0, _i, _ref, _ref1;
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

    evenOffset = (_ref = utils.isInt(width / 2)) != null ? _ref : {
      0: 1
    };
    x0 = ~~(width / 2);
    y0 = ~~(height / 2);
    centerIndex = null;
    x = -1 * x0;
    y = -1 * y0;
    for (i = _i = 0, _ref1 = dimensions.width * dimensions.height; 0 <= _ref1 ? _i < _ref1 : _i > _ref1; i = 0 <= _ref1 ? ++_i : --_i) {
      tilename = this.data[1] === "-all" ? this.data[0] : this.data[i];
      tile = new Tile(tilename, {
        x: x,
        y: y
      }, tilesize, this.game, this);
      this.tiles.push(tile);
      if (x === 0 && y === 0) {
        tile.center = true;
        centerIndex = i;
      }
      if (x === (x0 - evenOffset)) {
        x = -1 * x0;
        y += 1;
      } else {
        x++;
      }
    }
    this.offset = {};
    this.offset.x = x0 + 1;
    this.offset.y = y0 + 1;
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
    this.drawBackground = function() {
      this.game.context.fillStyle = this.backgroundColor;
      return this.game.context.fillRect(0, 0, this.game.canvas.width, this.game.canvas.height);
    };
    return this;
  };

  Map.prototype.render = function() {
    return this.tilegrid.render.call(this.tilegrid);
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

  module.exports.Map = Map;

}).call(this);

// Generated by CoffeeScript 1.5.0-pre