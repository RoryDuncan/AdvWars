// Generated by CoffeeScript 1.8.0
var EventEmitter, Unit, UnitManager, UnitRangeManager, extend, pixels, utils;

utils = require("./_utils");

extend = utils.extend;

pixels = utils.calculatePixelPositions;

EventEmitter = utils.EventEmitter;


/*
    The base to all unit objects
 */

Unit = function(game, name, position, options) {
  this.game = game;
  this.name = name;
  this.position = position != null ? position : {
    x: 0,
    y: 0
  };
  if (options == null) {
    options = {};
  }
  return this.init(options);
};

extend(Unit.prototype, EventEmitter.prototype);

Unit.prototype.init = function(options) {
  if (options == null) {
    options = {};
  }
  this.id = utils.UID("units", true);
  this.visible = false;
  this.sprite = this.game.Sprites[this.name];
  this.map = this.game.currentMap;
  this.offset = this.map.tilegrid.offset;
  this.size = this.map.tilegrid.dimensions.tilesize;
  this.zoom = this.map.tilegrid.zoom;
  return extend(this, options);
};

Unit.prototype.render = function() {
  var map, size, sprite, xo, xp, xw, yo, yp, yw, zoom;
  map = this.map || this.game.currentMap;
  if (!map) {
    return;
  }
  if (!this.sprite) {
    return;
  }
  if (!this.visible) {
    return;
  }
  sprite = this.sprite;
  size = this.size;
  zoom = this.zoom;
  xo = this.offset.x * size;
  yo = this.offset.y * size;
  xp = this.position.x * size;
  yp = this.position.y * size;
  xw = (xo + size + xp) * zoom;
  yw = (yo + size + yp) * zoom;
  sprite.render.call(sprite, xp + xo, yp + yo, size, size, zoom);
};

Unit.prototype.renderRange = function() {
  if (!(this.selected && this.visible)) {
    return this;
  }
  return this;
};

Unit.prototype.show = function() {
  this.visible = true;
  return this;
};

Unit.prototype.hide = function() {
  this.visible = false;
  return this;
};

Unit.prototype.addToManagement = function(player) {
  if (!this.game) {
    return;
  }
  return this.game.UnitManager.addUnit(this, player);
};

Unit.prototype.showMovementRange = function() {
  var p, range, tilesInRange;
  if (!(this.visible && this.map)) {
    return this;
  }
  this.selected = true;
  range = this.data.moveRange;
  p = this.position;
  tilesInRange = this.map.tilegrid.filter(function(Tile, i, tiles) {
    if (Tile.distanceFrom(p.x, p.y) <= range) {
      return true;
    }
  });
  tilesInRange.forEach(function(T) {
    return T.highlight = true;
  });
  return this;
};

module.exports.Unit = Unit;

UnitRangeManager = function() {
  this.range = void 0;
  return this;
};

UnitManager = function(game) {
  var cpi, players;
  this.game = game;
  this.currentPlayerIndex = cpi = 0;
  players = [];
  this.addUnit = function(UnitObject, playerIndex) {
    if (playerIndex === void 0 || playerIndex === cpi) {
      players[cpi].units.push(UnitObject);
      UnitObject.data = players[cpi].data[UnitObject.name];
    } else {
      players[playerIndex].units.push(UnitObject);
      UnitObject.data = players[playerIndex].data;
    }
    return Unit;
  };
  this.get = function() {
    return players;
  };
  this.addPlayer = function(PlayerObject) {
    players.push(PlayerObject);
    return PlayerObject.data = this.data;
  };
  this.game.Layers.add({
    name: "units",
    layer: 5,
    fn: this.render,
    scope: this
  });
  return this;
};

extend(UnitManager.prototype, EventEmitter.prototype);

UnitManager.prototype.isTileTaken = function() {
  return true;
};

UnitManager.prototype.getUnitById = function(id) {};

UnitManager.prototype.getUnitAtTile = function() {};

UnitManager.prototype.getUnitAt = function(position) {
  var index, playername, players, result, unit, unitIndex, _i, _len, _ref;
  players = this.get();
  console.log(players);
  result;
  for (playername in players) {
    index = players[playername];
    console.log("getting player:", playername, index);
    _ref = players[playername];
    for (unitIndex = _i = 0, _len = _ref.length; _i < _len; unitIndex = ++_i) {
      unit = _ref[unitIndex];
      if (unit.visible !== true) {
        continue;
      }
      if (unit.position.x === position.x && unit.position.y === position.y) {
        result = unit;
        break;
      }
    }
  }
  return result;
};

UnitManager.prototype.reset = function() {
  var players;
  players = this.get();
  return player.forEach(function(el) {
    return player.units = [];
  });
};

UnitManager.prototype.render = function() {
  var player, players, _i, _len, _results;
  players = this.get();
  _results = [];
  for (_i = 0, _len = players.length; _i < _len; _i++) {
    player = players[_i];
    _results.push(player.units.forEach(function(unit) {
      return unit.renderRange().render();
    }));
  }
  return _results;
};

UnitManager.prototype.create = function(type, position, player) {
  var unit;
  if (position == null) {
    position = {
      x: 0,
      y: 0
    };
  }
  if (!(this.data && this.data[type])) {
    return;
  }
  unit = new Unit(this.game, type, position);
  unit.addToManagement(player);
  return unit;
};

module.exports.UnitManager = UnitManager;
