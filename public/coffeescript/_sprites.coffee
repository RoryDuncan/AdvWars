
Sprite = (@spritesheet, options = {x:0, y:0, w:50, h:50}, @game) ->

  @position = @pos = { x:options.x, y:options.y}
  @dimensions = @dim = {w: options.w, h: options.h}
  @effects = {};
  return @

Sprite::render = (dx, dy, dw, dh, zoom = 1) ->
  console.assert @game isnt undefined, "Sprite::render called in wrong context.", @

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
    dh * zoom)

  @renderEffects()

Sprite::addEffect = (name, fn) ->
  # todo
  @effects = @effects or [];
  @effects.push = {name, fn};

Sprite::renderEffects = () ->
  return if @effects.length is 0




# NativeSprites are sprites drawn with the canvas

NativeSprite = (options = {x:0, y:0, w:50, h:50}, @game) ->
  @position = @pos = { x:options.x, y:options.y}
  @dimensions = @dim = {w: options.w, h: options.h}


NativeSprite::render = () ->
  console.assert @game isnt undefined, "Sprite::render called in wrong context.", @
  return unless @game

  ctx = @game.context
  ctx.fillStyle = "#4f9"
  ctx.fillRect(0,0, @dim.w, @dim.h)


module.exports = Sprite