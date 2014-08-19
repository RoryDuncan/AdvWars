(function() {
  var Sprite;

  Sprite = function(spritesheet, options, game) {
    this.spritesheet = spritesheet;
    if (options == null) {
      options = {
        x: 0,
        y: 0,
        w: 50,
        h: 50
      };
    }
    this.game = game;
    this.position = this.pos = {
      x: options.x,
      y: options.y
    };
    this.dimensions = this.dim = {
      w: options.w,
      h: options.h
    };
    this.render = function(dx, dy, dw, dh, zoom) {
      if (zoom == null) {
        zoom = 1;
      }
      if (!this.game) {
        return;
      }
      return this.game.context.drawImage(this.spritesheet, this.position.x, this.position.y, this.dim.w, this.dim.h, dx, dy, dw * zoom, dh * zoom);
    };
    return this;
  };

  module.exports = Sprite;

}).call(this);

// Generated by CoffeeScript 1.5.0-pre