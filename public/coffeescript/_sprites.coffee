
Sprite = (@spritesheet, options = {x:0, y:0, w:50, h:50}, @game) ->

  @position = @pos = { x:options.x, y:options.y}
  @dimensions = @dim = {w: options.w, h: options.h}

  @render = (dx, dy, dw, dh, zoom = 1) ->

    return unless @game
    @game.context.drawImage(
      @spritesheet,
      @position.x,
      @position.y,
      @dim.w,
      @dim.h,
      dx,
      dy,
      dw * zoom,
      dh * zoom,
      
    )



  return @


module.exports = Sprite