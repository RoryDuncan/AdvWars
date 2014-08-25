(function() {
  var $, Clock, EventEmitter, Game, Sprite, canvas, finishedLoadingImages, game, input, loader, mapUtils, utils;

  console.log("%cAdvanced Wars Clone", "color: #c88");

  require("./_rafPolyfill");

  utils = require("./_utils");

  EventEmitter = utils.EventEmitter;

  Sprite = require("./_sprites");

  mapUtils = require("./_map");

  input = require("./_input");

  Clock = require("./_clock");

  $ = require("jquery");

  Game = function(canvas, width, height) {
    var gameloop, render;
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
    this.context.fillStyle = "#48c";
    this.context.fillRect(0, 0, this.width, this.height);
    this.Layers = new utils.RenderList(this);
    this.Sprites = {};
    this.maps = {};
    this.inputHandler = new input.InputHandler(document);
    this.inputHandler.profiles = {};
    this.clock = new Clock();
    render = function() {
      return this.Layers.renderAll.call(this.Layers);
    };
    this.__loop = this.clock.loop("render", render, [], this);
    this.__loop["for"]({
      interval: 17
    });
    return this;
  };

  Game.prototype = EventEmitter.prototype;

  Game.prototype.start = function(mode) {
    var mapPanProfile, mapPanning, that;
    console.log("Starting...");
    this.clock.start();
    that = this;
    this.currentMap.map.play.call(this.currentMap.map);
    mapPanning = this.currentMap.map.panningBindings.call(this.currentMap.map);
    mapPanProfile = new input.InputProfile("map-panning", this.inputHandler, mapPanning);
    return mapPanProfile.enable();
  };

  Game.prototype.pause = function() {
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
    this.currentMap = {
      name: name,
      map: this.maps[name]
    };
    map = this.maps[name];
    this.Layers.add({
      name: "backdrop",
      layer: 0,
      fn: map.drawBackground,
      scope: map
    });
    this.Layers.add({
      name: "map render",
      layer: 3,
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
      list[key] = new Sprite(s, {
        x: o.x,
        y: o.y,
        w: o.w,
        h: o.h
      });
      list[key].name = key;
      list[key].render({
        x: 100,
        y: 100
      });
      return console.log("Adding Sprite for '" + key + "'");
    };
    console.groupCollapsed("%cCreating Sprites From JSON data", "color: #0b7");
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

  /*                      @TESTING
  */


  canvas = document.getElementById("game");

  game = new Game(canvas);

  Sprite.prototype.game = game;

  Sprite.prototype.ctx = game.context;

  console.log(game);

  game.on("ready", game.start, game);

  finishedLoadingImages = function(loadedImages) {
    var mapPromise, spritelistPromise;
    game.Sprites.spritesheet = loadedImages[0];
    spritelistPromise = game.getSpriteListJSON("/JSON/spritelist.json");
    mapPromise = null;
    spritelistPromise.then(function(e) {
      mapPromise = game.getMapFromUrl("/JSON/testmap.json");
      return mapPromise.then(function() {
        return game.loadMap("testmap");
      });
    });
  };

  loader = new utils.ImageLoader(["sprites/spritesheet.png"], finishedLoadingImages);

  /*
  
    movementAmount = 1
  */


}).call(this);

// Generated by CoffeeScript 1.5.0-pre
