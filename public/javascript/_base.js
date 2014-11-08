// Generated by CoffeeScript 1.8.0
var $, Clock, EventEmitter, Game, Player, Sprite, UI, Unit, UnitManager, Units, canvas, extend, game, input, mapUtils, utils;

console.log("%cAdvanced Wars Clone", "color: #b44");

require("./_rafPolyfill");

utils = require("./_utils");

extend = utils.extend;

Units = require("./_units");

Unit = Units.Unit;

UnitManager = Units.UnitManager;

EventEmitter = utils.EventEmitter;

Sprite = require("./_sprites");

mapUtils = require("./_map");

input = require("./_input");

Clock = require("./_clock");

$ = require("jquery");

UI = require("./_ui");

Player = require("./_players").Player;

Game = function(canvas, width, height) {
  var frames, gameloop, render, start, that;
  this.canvas = canvas;
  this.width = width;
  this.height = height;
  gameloop = Clock.Loop;
  this.__events = {};
  this.width = this.width || window.innerWidth;
  this.height = this.height || window.innerHeight;
  this.context = this.canvas.getContext("2d");
  this.canvas.width = this.width;
  this.canvas.height = this.height;
  this.Layers = new utils.RenderList(this);
  this.Sprites = {};
  this.maps = {};
  this.inputHandler = new input.InputHandler(document);
  this.profiles = this.inputHandler.profiles = {};
  this.clock = new Clock();
  this.UnitManager = new UnitManager(this);
  this.UI = new UI.Manager(this);
  frames = 0;
  start = Date.now();
  that = this;
  render = function() {
    var fps;
    that.Layers.renderAll.call(that.Layers);
    frames++;
    fps = (frames / (Date.now() - start)) * 1000;
    that.context.fillStyle = '#fff';
    that.context.fillText("FRAMES:" + frames, 25, 12);
    return that.context.fillText("FPS: " + (~~fps), 25, 25);
  };
  this.__loop = this.clock.loop("render", render, [], this);
  this.__loop["for"]({
    interval: 17
  });
  return this;
};

extend(Game.prototype, EventEmitter.prototype);

Game.prototype.initialize = function() {
  var check, left, that;
  console.group("Initializing");
  that = this;
  left = 4;
  check = function() {
    left--;
    if (left === 0) {
      console.log("%c\nGame is Initialized.\n", 'text-decoration: underline;');
      that.trigger("initialize");
      return console.groupEnd("Initializing");
    }
  };
  this.loadAllImages().then(function() {
    check();
    that.loadUnitData("./json/units.json").then(function(unitData) {
      console.log("%cAsynchronously loaded unit data.", "color: #808");
      that.UnitManager.data = unitData;
      check();
    });
    that.getSpriteListJSON("./json/spritelist.json").then(function() {
      check();
    });
    that.getMapFromUrl("./json/testmap.json").then(function() {
      return check();
    });
  });
  return this;
};

Game.prototype.loadAllImages = function() {
  var loader, promise, that;
  that = this;
  promise = {
    then: function(x) {
      return this.then = x;
    }
  };
  loader = new utils.ImageLoader(["./sprites/spritesheet.png"], function(loadedArray) {
    that.Sprites.spritesheet = loadedArray[0];
    return promise.then.call(null);
  });
  return promise;
};

Game.prototype.loadUnitData = function(url) {
  var promise;
  promise = $.getJSON(url);
  return promise;
};

Game.prototype.getPlayerCount = function() {
  var i, player, playerCount, _i, _results;
  playerCount = 1;
  _results = [];
  for (i = _i = 0; 0 <= playerCount ? _i < playerCount : _i > playerCount; i = 0 <= playerCount ? ++_i : --_i) {
    player = new Player(this, "Player" + i, []);
    _results.push(this.UnitManager.addPlayer(player));
  }
  return _results;
};

Game.prototype.start = function(mode) {
  var map, testUnit, that;
  console.log("Starting...");
  this.clock.start();
  that = this;
  map = this.currentMap;
  this.getPlayerCount();
  map.play.call(map);

  /* TESTING  FUNCTIONALITY */
  console.group("%cUnit Object Test", "text-decoration: underline");
  console.log(this.UnitManager);
  testUnit = this.UnitManager.create("soldier");
  testUnit.show();
  testUnit.showMovementRange();
  console.log(testUnit);
  return console.groupEnd("%cUnit Object Test", "text-decoration: underline");
};

Game.prototype.pause = function() {
  console.log("Game Paused");
  return this.clock.pause();
};

Game.prototype.getMapJSON = function(url) {
  var promise, that;
  console.log("Getting Map Data...");
  that = this;
  promise = $.getJSON(url);
  return promise;
};

Game.prototype.getMapFromUrl = function(url) {
  var promise, that;
  that = this;
  promise = this.getMapJSON(url);
  return promise.then(function(e) {
    return that._createMap.call(that, e);
  });
};

Game.prototype.loadMap = function(name) {
  var map;
  if (this.maps[name] === void 0) {
    console.log("Map '" + name + "' wasn't found.");
    return;
  }
  this.currentMap = this.maps[name];
  map = this.maps[name];
  this.Layers.add({
    name: "backdrop",
    layer: 0,
    fn: map.drawBackground,
    scope: map
  });
  this.Layers.add({
    name: "map",
    layer: 2,
    fn: map.render,
    scope: map
  });
  console.log("Loading Map '" + name + "'... Done.");
  return this.trigger("ready");
};

Game.prototype.getSpriteListJSON = function(url, callback) {
  var promise, that;
  console.log("Getting SpriteList...");
  that = this;
  promise = $.getJSON(url);
  promise.then(function(responseText) {
    console.log("%cLoaded spritelist data.", 'color:#808');
    that.Sprites._list = responseText;
    return that._createSpriteList.call(that, responseText);
  });
  return promise;
};

Game.prototype._createSpriteList = function(spritelist, callback) {
  var computeSprite, context, elapsed, item, key, list, name, start, val;
  start = Date.now();
  list = this.Sprites;
  context = this;
  computeSprite = function(o, name, i) {
    var key, s;
    if (o.x === void 0) {
      return;
    }
    key = name + (i || "");
    s = this.Sprites.spritesheet;
    console.groupCollapsed("" + key);
    list[key] = new Sprite(s, {
      x: o.x,
      y: o.y,
      w: o.w,
      h: o.h
    }, context);
    list[key].name = key;
    console.log(list[key]);
    console.log("Testing Sprite Render");
    list[key].render({
      x: 1,
      y: 1
    });
    console.log("Adding Sprite for '" + key + "'");
    return console.groupEnd("%c" + key);
  };
  console.groupCollapsed("%cCreating Sprites From JSON data", "color: #808");
  for (key in spritelist) {
    item = spritelist[key];
    for (name in item) {
      val = item[name];
      if (utils.isArray(val)) {
        val.forEach(function(el, index) {
          return computeSprite.call(context, el, name, index);
        });
      } else {
        computeSprite.call(context, val, name);
      }
    }
  }
  elapsed = Date.now() - start;
  console.log("%cDone. Elapsed Time: " + elapsed + "ms", "color: #800");
  console.groupEnd("%cCreating Sprites From JSON data", "color: #0b7");
  if (callback) {
    return callback.call(context);
  }
};

Game.prototype._createMap = function(mapData) {
  var name, tilegrid;
  name = mapData.name;
  tilegrid = new mapUtils.TileGrid(this, mapData.tiles, mapData.dimensions);
  return this.maps[name] = new mapUtils.Map(name, tilegrid, this);
};


/*                      @TESTING */

canvas = document.getElementById("game");

game = new Game(canvas);

Sprite.prototype.game = game;

Sprite.prototype.ctx = game.context;

console.log(game);

game.initialize();

game.on("initialize", function() {
  return game.loadMap("testmap");
});

game.on("ready", game.start, game);
