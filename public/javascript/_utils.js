(function() {
  var EventEmitter, ImageLoader, extend,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  module.exports.EventEmitter = EventEmitter = (function() {

    function EventEmitter() {
      this.__events = {};
    }

    EventEmitter.prototype.on = function(name, fn, context) {
      if (this.__events === void 0) {
        this.__events = {};
      }
      this.__events[name] = {
        fn: fn,
        context: context
      };
      return this;
    };

    EventEmitter.prototype.off = function(name) {
      delete this.__events[name];
      return this;
    };

    EventEmitter.prototype.get = function(name) {
      if (this.__events === void 0) {
        return;
      }
      return this.__events[name];
    };

    EventEmitter.prototype.trigger = function(name, args) {
      var f;
      if (args == null) {
        args = [];
      }
      if (this.__events === void 0) {
        return;
      }
      f = this.get(name);
      if (f === void 0) {
        return;
      }
      f.fn.apply(f.context, args);
      return this;
    };

    return EventEmitter;

  })();

  module.exports.RenderList = function(game) {
    var list;
    this.game = game;
    list = [];
    this.set = this.add = function(options) {
      var fn, name;
      name = options.name;
      fn = options.fn || new Function("console.log('blank fn')");
      list[options.layer] = {
        name: name,
        fn: fn,
        scope: options.scope
      };
    };
    this.remove = this["delete"] = function(layer) {
      var del;
      del = list[layer];
      delete list[layer];
      return del;
    };
    this.render = function(layer) {
      var lyr;
      lyr = list[layer];
      return lyr.fn.call(lyr.scope || lyr.fn || null, lyr);
    };
    this.renderAll = function() {
      var index, item, _i, _len, _results;
      _results = [];
      for (index = _i = 0, _len = list.length; _i < _len; index = ++_i) {
        item = list[index];
        if (!item) {
          continue;
        }
        _results.push(item.fn.call(item.scope || item.fn || null, item));
      }
      return _results;
    };
    return this;
  };

  module.exports.extend = extend = function() {
    var extended, key, obj, objs, _i, _len;
    extended = arguments[0], objs = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    if (!objs) {
      return extended;
    }
    for (_i = 0, _len = objs.length; _i < _len; _i++) {
      obj = objs[_i];
      for (key in obj) {
        extended[key] = obj[key];
      }
    }
    return extended;
  };

  module.exports.ImageLoader = ImageLoader = (function(_super) {

    __extends(ImageLoader, _super);

    function ImageLoader(items, callback, individualFileCallback) {
      var count, filetype, finished, itemDone, load, results, startTime, total;
      if (!items) {
        return;
      }
      startTime = Date.now();
      count = 0;
      total = items.length;
      results = [];
      filetype = this.filetype;
      console.groupCollapsed("%cLoading Images.", "color: #0b7");
      console.log("%cProgress: 0%", "color:#ccc");
      load = function(path) {
        var i;
        i = new window[filetype]();
        i.addEventListener("load", itemDone);
        i.src = path;
        return results.push(i);
      };
      finished = function(e) {
        this.duration = Date.now() - startTime;
        console.log(("%c" + total + " Images Loaded. Time Elapsed: ") + this.duration + " milliseconds.", "color: #800");
        this.results = results;
        console.groupEnd("%cLoading Images.", "color: #0b7");
        if (callback) {
          return callback.call(this, results);
        }
      };
      itemDone = function(e) {
        var percentage;
        count++;
        percentage = 100 / (total / count) + "%";
        console.log("%cProgress: " + percentage, "color:#ccc");
        if (individualFileCallback) {
          individualFileCallback.call(this, e);
        }
        if (count === total) {
          return finished();
        }
      };
      this.on("itemDone", itemDone);
      this.on("done", finished);
      items.forEach(load);
    }

    ImageLoader.prototype.filetype = "Image";

    return ImageLoader;

  })(EventEmitter);

  module.exports.getJSON = function(url, callbacks) {
    var ajax, data, options;
    options = callbacks || {};
    data = void 0;
    ajax = $.getJSON(url);
    return ajax.complete(function() {
      try {
        data = $.parseJSON(ajax.responseText);
      } catch (e) {
        options.error.call(options.scope || null, e, ajax);
        return;
      }
      options.success.call(options.scope || null, data, ajax);
    });
  };

  module.exports.isArray = Array.isArray || function(thing) {
    return Object.prototype.toString.call(thing === "[object Array]");
  };

  module.exports.isInt = function(n) {
    if (n / Math.floor(n) === 1 || n / Math.floor(n) === -1) {
      return true;
    }
    return false;
  };

  module.exports.isEven = function(n) {
    if (n % 2 === 0) {
      return true;
    } else {
      return false;
    }
  };

  module.exports.has = function(obj, key) {
    return Object.hasOwnProperty.call(obj, key);
  };

  module.exports.generateNormalizedGrid = function(width, height, iterator, scope) {
    var basicGrid, centerIndex, evenOffset, i, normalData, x, x0, y, y0, _i, _ref, _ref1;
    if (iterator == null) {
      iterator = new Function();
    }
    evenOffset = (_ref = module.exports.isInt(width / 2)) != null ? _ref : {
      0: 1
    };
    x0 = ~~(width / 2) - evenOffset;
    y0 = ~~(height / 2) - evenOffset;
    centerIndex = false;
    x = -1 * x0;
    y = -1 * y0;
    basicGrid = [];
    for (i = _i = 0, _ref1 = width * height; 0 <= _ref1 ? _i < _ref1 : _i > _ref1; i = 0 <= _ref1 ? ++_i : --_i) {
      normalData = {
        x: x,
        y: y,
        x0: x0,
        y0: y0,
        "id": i
      };
      if (x === 0 && y === 0) {
        normalData.centerIndex = true;
        centerIndex = i;
      } else {
        centerIndex = false;
      }
      basicGrid.push(normalData);
      iterator.call(scope || null, normalData, i, centerIndex);
      if (x === (x0 - evenOffset)) {
        x = -1 * x0;
        y += 1;
      } else {
        x++;
      }
    }
    basicGrid.centerIndex = centerIndex;
    return basicGrid;
  };

}).call(this);

// Generated by CoffeeScript 1.5.0-pre
