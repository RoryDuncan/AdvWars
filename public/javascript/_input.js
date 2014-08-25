(function() {
  var $, InputProfile, consoleColor, utils;

  $ = require("jquery");

  utils = require("./_utils");

  consoleColor = "color:#8b8";

  module.exports.InputHandler = function(el) {
    var $el, bound, handler, key, mousemoveHandler;
    if (!$) {
      return;
    }
    $el = $(el);
    key = {
      "leftClick": 1,
      "scrollwheel": 2,
      "rightClick": 3,
      'backspace': 8,
      'tab': 9,
      'enter': 13,
      'shift': 16,
      'ctrl': 17,
      'alt': 18,
      'pause': 19,
      'capslock': 20,
      'esc': 27,
      'pageup': 33,
      'pagedown': 34,
      'end': 35,
      'home': 36,
      'left': 37,
      'up': 38,
      'right': 39,
      'down': 40,
      'insert': 45,
      'delete': 46,
      '0': 48,
      '1': 49,
      '2': 50,
      '3': 51,
      '4': 52,
      '5': 53,
      '6': 54,
      '7': 55,
      '8': 56,
      '9': 57,
      'a': 65,
      'b': 66,
      'c': 67,
      'd': 68,
      'e': 69,
      'f': 70,
      'g': 71,
      'h': 72,
      'i': 73,
      'j': 74,
      'k': 75,
      'l': 76,
      'm': 77,
      'n': 78,
      'o': 79,
      'p': 80,
      'q': 81,
      'r': 82,
      's': 83,
      't': 84,
      'u': 85,
      'v': 86,
      'w': 87,
      'x': 88,
      'y': 89,
      'z': 90,
      'numpad0': 96,
      'numpad1': 97,
      'numpad2': 98,
      'numpad3': 99,
      'numpad4': 100,
      'numpad5': 101,
      'numpad6': 102,
      'numpad7': 103,
      'numpad8': 104,
      'numpad9': 105,
      'multiply': 106,
      'plus': 107,
      'minut': 109,
      'dot': 110,
      'slash1': 111,
      'F1': 112,
      'F2': 113,
      'F3': 114,
      'F4': 115,
      'F5': 116,
      'F6': 117,
      'F7': 118,
      'F8': 119,
      'F9': 120,
      'F10': 121,
      'F11': 122,
      'F12': 123,
      'equal': 187,
      'coma': 188,
      'slash': 191,
      'backslash': 220
    };
    bound = {};
    handler = function(e) {
      var b, keyname;
      b = bound[e.type];
      if (!b) {
        return;
      }
      for (keyname in b) {
        if (key[keyname] === e.which) {
          e.preventDefault();
          b[keyname].callback.call(b[keyname], e, b[keyname]);
          return;
        }
      }
    };
    mousemoveHandler = function(e) {
      var b, data;
      e.preventDefault();
      e.position = utils.getMousePosition(e);
      b = bound["mousemove"];
      data = b.data || {};
      b.callback.call(stage, e, data);
    };
    this.bind = this.on = function(events, keyname, callback, data) {
      var eventType, _events, _i, _len;
      if (!(arguments.length >= 2)) {
        return;
      }
      _events = events.split(" ");
      if (_events[0] === "mousemove") {
        bound["mousemove"] = {
          "callback": keyname,
          "data": callback
        };
        $el.on("mousemove", mousemoveHandler);
      }
      for (_i = 0, _len = _events.length; _i < _len; _i++) {
        eventType = _events[_i];
        if (bound[eventType]) {
          bound[eventType][keyname] = {
            callback: callback,
            data: data,
            scope: (data || {}).scope
          };
        } else {
          bound[eventType] = {};
          bound[eventType][keyname] = {
            callback: callback,
            data: data,
            scope: (data || {}).scope
          };
          $el.on(eventType, handler);
          console.log("%cAssigning new key('" + keyname + "') to " + eventType + " and adding an Event Listener.", consoleColor);
        }
      }
      return this;
    };
    this.unbind = this.off = function(events, keyname) {
      var eventType, _events, _i, _len;
      _events = events.split(" ");
      for (_i = 0, _len = _events.length; _i < _len; _i++) {
        eventType = _events[_i];
        $el.off(eventType, handler);
        delete bound[eventType][keyname];
      }
      return this;
    };
    this.trigger = function(event) {
      $el.trigger(event);
      return bound[event];
    };
    return this;
  };

  /*
  @InputProfiles are used to 
  keep track of certain keybinding configurations
  */


  InputProfile = function(name, inputHandler, actions, scope) {
    this.name = name;
    this.inputHandler = inputHandler;
    this.actions = actions;
    this.scope = scope;
    this._state = "off";
    this._combined = [];
    this.combinedWith = [];
    this.inputHandler.profiles = this.inputHandler.profiles || {};
    this.inputHandler.profiles[this.name] = this;
    return this;
  };

  InputProfile.prototype.multipleInputActions = function(inputMethod) {
    var eventdetails, inputProf, key, value, _i, _len, _ref, _ref1;
    console.log("%cProfile " + this.name + " is " + inputMethod + ".", consoleColor);
    this._state = inputMethod;
    _ref = this.actions;
    for (key in _ref) {
      value = _ref[key];
      eventdetails = key.split(" ");
      if (eventdetails.length === 1) {
        eventdetails = key;
      }
      this.inputHandler[inputMethod](eventdetails[0], eventdetails[1], value);
    }
    _ref1 = this._combined;
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      inputProf = _ref1[_i];
      inputProf.multipleInputActions.call(inputProf, inputMethod);
    }
    return this.actions;
  };

  InputProfile.prototype.toggle = function() {
    if (this._state === "on") {
      return this.disable();
    } else if (this._state === "off") {
      return this.enable();
    }
  };

  InputProfile.prototype.enable = function() {
    return this.multipleInputActions("on");
  };

  InputProfile.prototype.disable = function() {
    return this.multipleInputActions("off");
  };

  InputProfile.prototype.add = function(inputProf) {
    this._combined.push(inputProf);
    return this.combinedWith.push(inputProf.name);
  };

  InputProfile.prototype.remove = function(inputProfname) {
    var index, item;
    index = this._combinedWith.indexOf(inputProfname);
    delete this.combinedWith[index];
    item = this._combined[index];
    item.multipleInputActions("off");
    delete this._combined[index];
    return item;
  };

  module.exports.InputProfile = InputProfile;

}).call(this);

// Generated by CoffeeScript 1.5.0-pre
