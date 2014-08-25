

utils = require "./_utils"
input = require "./_input"


calculatePixelPosition = pixels = (size, position, offset, zoom) ->
  

  #offsets
  xo = ( offset.x * size )
  yo = ( offset.y * size )

  #positions
  xp = ( position.x * size )
  yp = ( position.y * size )

  # widths (with fillRect / strokeRect it is the x and y coordinates on the canvas)
  xw = (xo + size + xp) * zoom
  yw = (yo + size + yp) * zoom

  x = xp + xo
  y = yp + yo
  endx = xw
  endy = yw

  return {x, y, endx, endy, size, "offset": {"x":xo, "y":yo}}

Tile  = (@name, @position, @size, @game, @grid) ->

  @Sprites = @game.Sprites
  @name = @name or "plain"

  return @

Tile::render = () ->

  sprite = @Sprites[@name]
  sprite.game = @game

  size = @size # width and height of the tile
  zoom = @grid.zoom # zoom modifier

  #offsets
  xo = ( @grid.offset.x * size )
  yo = ( @grid.offset.y * size )

  #positions
  xp = ( @position.x * size )
  yp = ( @position.y * size )

  # widths (with fillRect / strokeRect it is the x and y coordinates on the canvas)
  xw = (xo + size + xp) * zoom
  yw = (yo + size + yp) * zoom
  sprite.render.call(sprite, (xp + xo), (yp + yo), size, size, zoom)
  @game.context.font = "#{size/4}px Consolas";
  @game.context.fillStyle = "#fff"
  @game.context.fillText("#{@position.x},#{@position.y}", xp + xo + (size/4), yp + yo + (size/2))

Tile::toString = () ->
  return "[object Tile]"

module.exports.Tile = Tile



TileGrid = (@game, @data, @dimensions) ->

  Tile::game = game
  @tiles = []
  width = @dimensions.width
  height = @dimensions.height
  tilesize = @dimensions.tilesize

  ### Convert the data into a normalized grid data  ###

  # iterator Fn
  createTiles = (coords, i, isCenterIndex) ->
    
    tilename = if @data[1] is "-all" then @data[0] else @data[i] 
    tile = new Tile(tilename, coords, tilesize, @game, @)
    if typeof isCenterIndex is "number"
      tile.isCenter = true
      @centerIndex = isCenterIndex
    @tiles.push tile
    return

  # the magic
  utils.generateNormalizedGrid width, height, createTiles, @

  @offset = {}
  @offset.origin = {}
  @offset.x = @offset.origin.x = ~~(width / 2) 
  @offset.y = @offset.origin.y = ~~(height / 2) 
  @zoom = 1

  return @


TileGrid::setZoom = (zoom = 1) ->
  @zoom = zoom

TileGrid::crossZoom = (modifier) ->
  @zoom = @zoom * modifier

TileGrid::move = (x = 0, y = 0) ->
  @offset.x += x
  @offset.y += y
  @render()

TileGrid::AlignToOrigin = () ->
  @offset.origin.x = @offset.origin.x
  @offset.origin.y = @offset.origin.y
  return



TileGrid::changeTile = (x,y, tilename) ->
  console.log "wow"

TileGrid::render = () ->

  @tiles.forEach (tile) ->
      tile.render.call(tile)

module.exports.TileGrid = TileGrid


# Map is a wrapper object

Map = (@name, @tilegrid, @game, @backgroundColor = "#48c") ->
  
  @centerIndex = @tilegrid.centerIndex

  @drawBackground = () ->
    @game.context.fillStyle = @backgroundColor
    @game.context.fillRect 0, 0, @game.canvas.width, @game.canvas.height

  return @

Map::render = () ->
  # maybe have Map as an event emitter.. maybe 
  @tilegrid.render.call(@tilegrid)

Map::panningBindings = () ->
  return {
    "keydown numpad8": (@up).bind(@),
    "keydown numpad2": (@down).bind(@),
    "keydown numpad4": (@left).bind(@),
    "keydown numpad6": (@right).bind(@)
  }
Map::move = (x = 1,y = 1) ->
  @tilegrid.move x,y

Map::up = () ->
  @move 0, -1

Map::down = () ->
  @move 0, 1

Map::left = () ->
  @move -1, 0

Map::right = () ->
  @move 1,0

Map::play = () ->
  console.log "Playing #{@name}!"
  selector = new Selector @game, @, "select"
  selectorPanProfile = new input.InputProfile "selector-panning", @game.inputHandler,  selector.movementActionBindings()
  selectorPanProfile.enable();
  @game.Layers.add.call @game, 
    name: "selector",
    layer: 6,
    fn:  selector.render,
    scope: selector

Map::edit = () ->
  console.log "Editing #{@name}!"
  #@selector = new Selector(@game)

module.exports.Map = Map


# the object for selecting units, tiles, etc

Selector = (@game, @map, @type = "select") ->

  console.log @
  @Sprites = @game.Sprites
  @centerIndex = @map.centerIndex
  # has it's own array to keep track of positioning
  @grid = utils.generateNormalizedGrid @map.tilegrid.dimensions.width, @map.tilegrid.dimensions.height
  
  src = @grid[ @centerIndex ]
  @position = {x: src.x, y:src.y, x0: src.x0, y0:src.y0}

  @map.selector = @

  return @


Selector::getIndexOf = (position = {x:0, y:0}) ->

  p = position
  index = null
  @grid.forEach (el, i) ->
    # I would transform into a cat if I could.
    if el.x is p.x and el.y is p.y
      index = i
      

  return index

Selector::getIndex = () ->
  return @getIndexOf(@position)

Selector::getTile = () ->
  return @grid[ @getIndex() ] 

Selector::getUnit = () ->
  # todo, after units are implemented

Selector::isOutOfBounds = () ->
  
  console.log ( @getTile() ) #, @getTile()
  outOfBounds = false
  tg = @map.tilegrid
  dimensions = pixels( tg.dimensions.tilesize, @position, tg.offset, tg.zoom )
  amount = 2
  if dimensions.x < 0
    @map.move.call(@map, amount, 0)
    isOutOfBounds = true
  else if dimensions.endx > window.innerWidth
    @map.move.call(@map, -amount, 0)
    isOutOfBounds = true
  if dimensions.y < 0
    @map.move.call(@map, 0, amount)
    isOutOfBounds = true
  else if dimensions.endy > window.innerHeight
    @map.move.call(@map, 0, -amount)
    isOutOfBounds = true

  return isOutOfBounds

Selector::move = (x, y) ->
  @position.x += x
  @position.y += y
  return

Selector::movementActionBindings = () ->
  return {
    "keydown up": @moveUp.bind(@),
    "keydown down": @moveDown.bind(@),
    "keydown left": @moveLeft.bind(@),
    "keydown right": @moveRight.bind(@)
  }

Selector::moveUp = () ->
  p = @position
  min = -1*p.y0
  max = p.y0
  p.y = Math.max(min, Math.min(max, p.y - 1))
  @isOutOfBounds()

Selector::moveDown = () ->
  p = @position
  min = -1*p.y0
  max = if utils.isEven p.y0 then p.y0 else p.y0 - 1
  p.y = Math.max(min, Math.min(max, p.y + 1))
  @isOutOfBounds()

Selector::moveLeft = () ->
  p = @position
  min = -1*p.x0
  max = p.x0
  p.x = Math.max(min, Math.min(max, p.x - 1))
  @isOutOfBounds()

Selector::moveRight = () ->
  p = @position
  min = -1*p.x0
  max = if utils.isEven p.x0 then p.x0 else p.x0
  p.x = Math.max(min, Math.min(max, p.x + 1))
  @isOutOfBounds()

Selector::render = () ->
  
  tg = @map.tilegrid
  dimensions = pixels( tg.dimensions.tilesize, @position, tg.offset, tg.zoom )
  ctx = @game.context
  ctx.strokeStyle = @color or "#eee"
  ctx.strokeRect dimensions.x - 1, dimensions.y - 1, dimensions.size + 1, dimensions.size + 1

module.exports.Selector = Selector
