(function() {
  var Dialogue, EventEmitter, Manager, Menu, extend, pixels, utils;

  utils = require("./_utils");

  extend = utils.extend;

  pixels = utils.calculatePixelPosition;

  EventEmitter = utils.EventEmitter;

  /*
    @NAME Dialogue
    @DESCRIPTION Returns an object for rendering text to the Canvas
    @PAREMS Passed in as options object
      @options,data: object
  */


  Dialogue = function(game, options) {
    this.game = game;
    this.data = {
      text: {
        color: "#fff",
        size: "14px",
        family: "Helvetica",
        value: ""
      },
      heading: {
        color: "#fff",
        size: "20px",
        family: "Helvetica",
        value: ""
      }
    };
    this.position = {
      x: 1,
      y: 1,
      absolute: true,
      calc: {
        x: 0,
        y: 0
      }
    };
    this.separator = "|";
    this.id = utils.UID("dialogue", true);
    this.style = {};
    this.visible = true;
    this.has = {};
    return extend(this, options);
  };

  extend(Dialogue.prototype, EventEmitter.prototype);

  Dialogue.prototype.verify = function() {};

  Dialogue.prototype.heading = function(value, size, color, family) {
    this.has.heading = true;
    this.data.heading.size = size || this.data.heading.size;
    this.data.heading.color = color || this.data.heading.color;
    this.data.heading.family = family || this.data.heading.family;
    this.data.heading.value = value;
    return this;
  };

  Dialogue.prototype.text = function(text, size, color, family) {
    this.has.text = true;
    this.data.text.size = size || this.data.text.size;
    this.data.text.color = color || this.data.text.color;
    this.data.text.family = family || this.data.text.family;
    this.data.text.value = text;
    return this;
  };

  Dialogue.prototype.drawBorder = function(color) {
    this.has.border = true;
  };

  Dialogue.prototype.drawBackground = function(color) {
    this.has.background = true;
  };

  Dialogue.prototype.hide = function() {
    this.visible = false;
    return this;
  };

  Dialogue.prototype.show = function() {
    this.visible = true;
    return this;
  };

  Dialogue.prototype.toggle = function() {
    this.visible = !this.visible;
    return this;
  };

  Dialogue.prototype.relativeTo = function(obj) {
    this.attachedTo = obj;
    this.tilegrid = obj.tilegrid || obj.map.tilegrid;
    this.getRelativePositions();
    return this.position.absolute = false;
  };

  Dialogue.prototype.getRelativePositions = function() {
    var a, dimensions, p;
    a = this.attachedTo;
    p = {
      x: this.position.x + a.position.x,
      y: this.position.y + a.position.y
    };
    dimensions = pixels(this.tilegrid.dimensions.tilesize, p, this.tilegrid.offset, this.tilegrid.zoom);
    this.position.calc.x = dimensions.x;
    return this.position.calc.y = dimensions.y;
  };

  Dialogue.prototype.getFont = function(type) {
    var family, size;
    size = parseFloat(this.data[type].size);
    family = this.data[type].family;
    return "" + size + "px " + family;
  };

  Dialogue.prototype._renderHeading = function() {
    var ctx, font;
    font = this.getFont("heading");
    ctx = this.game.context;
    ctx.fillStyle = this.data.heading.color;
    ctx.font = font;
    ctx.fillText(this.data.heading.value, this.position.calc.x || this.position.x, this.position.calc.y || this.position.y);
    return parseFloat(this.data.heading.size);
  };

  Dialogue.prototype._renderLines = function() {
    var ctx, family, i, line, lines, margin, marginTop, size, x, y, _i, _len, _results;
    lines = this.data.text.value.split(this.separator);
    margin = 2;
    marginTop = 0;
    if (this.has.heading) {
      marginTop = this._renderHeading();
    }
    x = this.position.calc.x || this.position.x;
    y = this.position.calc.y || this.position.y;
    ctx = this.game.context;
    ctx.fillStyle = this.data.text.color;
    size = parseFloat(this.data.text.size);
    family = this.data.text.family;
    ctx.font = "" + size + "px " + family;
    _results = [];
    for (i = _i = 0, _len = lines.length; _i < _len; i = ++_i) {
      line = lines[i];
      _results.push(ctx.fillText(lines[i], x, marginTop + y + i * (margin + size)));
    }
    return _results;
  };

  Dialogue.prototype.render = function() {
    var ctx, marginTop;
    if (!this.visible) {
      return;
    }
    if (!this.position.absolute) {
      this.getRelativePositions();
    }
    if ((this.data.text.value.split(this.separator)).length > 1) {
      this._renderLines();
      return;
    }
    marginTop = 0;
    if (this.has.heading) {
      marginTop = this._renderHeading();
    }
    ctx = this.game.context;
    ctx.fillStyle = this.data.text.color || "#000";
    ctx.font = this.getFont("text");
    ctx.fillText(this.data.text.value, this.position.calc.x || this.position.x, marginTop + (this.position.calc.y || this.position.y));
  };

  module.exports.Dialogue = Dialogue;

  /*
      Menu
  */


  Menu = function(game, options) {
    this.game = game;
    return this;
  };

  extend(Menu.prototype, EventEmitter.prototype);

  Menu.prototype.render = function() {};

  module.exports.Menu = Menu;

  /*
    @name Manager
    The object to manage instances of 'Dialogue' or 'Menu',
    and makes sure they get rendered.
  */


  Manager = function(game) {
    this.game = game;
    this.list = [];
    this.game.Layers.add({
      name: "UserInterface",
      layer: 7,
      fn: this.render,
      scope: this
    });
    return this;
  };

  extend(Manager.prototype, EventEmitter.prototype);

  Manager.prototype.Dialogue = function(options) {
    var length;
    length = this.list.push(new Dialogue(this.game, options));
    return this.list[length - 1];
  };

  Manager.prototype.Menu = function(options) {
    return new Menu(this.game, options);
  };

  Manager.prototype.render = function() {
    var item, _i, _len, _ref, _results;
    _ref = this.list;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      _results.push(item.render.call(item));
    }
    return _results;
  };

  module.exports.Manager = Manager;

}).call(this);

// Generated by CoffeeScript 1.5.0-pre
