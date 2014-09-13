

utils = require "./_utils"
extend = utils.extend
pixels = utils.calculatePixelPosition
input = require "./_input"



Tile  = (@game, @name, @position, @size, @grid) ->

  @Sprites = @game.Sprites
  @name = @name or "plain"

  return @

Tile::render = () ->

  sprite = @Sprites[@name]
  return unless sprite

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
  #@showPosition(xp, xo, yp, yo, size, zoom)

Tile::showPosition = (xp, xo, yp, yo, size, zoom) ->
  @game.context.font = "#{size/4}px Helvetica";
  @game.context.fillStyle = "#444"
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

  # iterator Function for utils.generateNormalizedGrid
  createTiles = (coords, i, isCenterIndex) ->
    
    tilename = if @data[1] is "-all" then @data[0] else @data[i] 
    tile = new Tile( @game, tilename, coords, tilesize, @)
    if typeof isCenterIndex is "number"
      tile.isCenter = true
      @centerIndex = isCenterIndex
    @tiles.push tile
    return

  # the magic
  utils.generateNormalizedGrid width, height, createTiles, @

  @offset = {}
  @offset.origin = {}
  @offset.x = @offset.origin.x = ~~(width) 
  @offset.y = @offset.origin.y = ~~(height) 
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

Map = (@name, @tilegrid, @game, @backgroundColor = "#476ca1") ->
  
  @centerIndex = @tilegrid.centerIndex

  return @

Map::render = () ->
  # maybe have Map as an event emitter.. maybe 
  @tilegrid.render.call(@tilegrid)

currentRadian = 0;
lines = 90
Map::drawBackground = () ->
  
  game = @game
  ctx = game.context

  #styles
  lineWidth = game.canvas.width / (lines)
  lineColor =  @backgroundColor2 or "#6393d8"
  # to be restored afterwards
  previousStroke = game.context.strokeStyle

  # animation or math related
  max = 6
  pi = 22 / 7;
  rayWidth = 25
  radius = game.canvas.width
  space = (360 / lines) * (pi / 180)
  middle = { x: game.canvas.width / 2, y: game.canvas.height / 2}

  # The plain background color
  ctx.fillStyle = @backgroundColor
  ctx.fillRect 0, 0, game.canvas.width, game.canvas.height

  # the style of the line
  ctx.strokeStyle = lineColor
  for line in [0..lines]
    # draw a line
    ctx.beginPath()
    ctx.moveTo(middle.x, middle.y)
    
    calc_x = (radius * Math.sin(currentRadian + (space * line))) + middle.x
    calc_y = (radius * Math.cos(currentRadian + (space * line))) + middle.y
    ctx.lineTo(calc_x, calc_y)
    ctx.lineWidth = lineWidth;
    ctx.stroke()
    ctx.closePath()
  
  #important part
  currentRadian += 0.002
  currentRadian = (-1*max) if currentRadian > max

  # restorations
  ctx.globalAlpha = 1
  ctx.strokeStyle = previousStroke

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
  # the selector instance
  selector = new Selector @game, @, "select"

  # the profile that keeps track of movement is initialised, and enabled
  selectorPanProfile = new input.InputProfile "selector-panning", @game.inputHandler, selector.movementActionBindings()
  selectorPanProfile.enable();
  # then

  @game.Layers.add.call @game, 
    name: "selector",
    layer: 6,
    fn:  selector.render,
    scope: selector

Map::edit = () ->
  console.log "Editing #{@name}!"
  # todo
  #@selector = new Selector(@game)

module.exports.Map = Map


# the object for selecting units, tiles, etc

Selector = (@game, @map, @type = "select") ->

  @Sprites = @game.Sprites
  @centerIndex = @map.centerIndex
  # has it's own array to keep track of positioning
  @grid = utils.generateNormalizedGrid @map.tilegrid.dimensions.width, @map.tilegrid.dimensions.height
  
  src = @grid[ @centerIndex ]
  @position = extend {}, src

  @map.selector = @

  return @


Selector::getGameObjectsHere = (p) ->

  # get units,
  # if none, get buildings(todo)
  # if none, then
  # get the tile at that position.

  selected = @getUnitAt(@position) or @getTile()
  return selected

Selector::getIndexOf = (position = {x:0, y:0, id:0}) ->
  index = null
  @grid.forEach (el, i) ->
    # I would transform into a cat if I could.
    if el.x is position.x and el.y is position.y
      index = i
      

  return index

Selector::getIndex = () ->
  return @position.id or 0

Selector::getTile = () ->
  return @grid[ @getIndex() ] 

Selector::getUnitAt = (position) ->
  return {} unless @game.UnitManager
  @game.UnitManager.getUnitAt(position)


Selector::isOutOfBounds = (move = true) ->
  
  # move and non-move version can probably be seperated
  outOfBounds = false
  tg = @map.tilegrid
  dimensions = pixels( tg.dimensions.tilesize, @position, tg.offset, tg.zoom )
  amount = 2
  if move 
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
  else
    if dimensions.x < 0
      return true
    else if dimensions.endx > window.innerWidth
      return true
    if dimensions.y < 0
      return true
    else if dimensions.endy > window.innerHeight
      return true
    
  return isOutOfBounds

Selector::move = (x, y) ->
  # todo...
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
  p.y = utils.limitToRange( (p.y-1), p.start.y, p.end.y )
  @isOutOfBounds()

Selector::moveDown = () ->
  p = @position
  p.y = utils.limitToRange( (p.y+1), p.start.y, p.end.y )
  @isOutOfBounds()

Selector::moveLeft = () ->
  p = @position
  p.x = utils.limitToRange( (p.x-1), p.start.x, p.end.x )
  @isOutOfBounds()

Selector::moveRight = () ->
  p = @position
  p.x = utils.limitToRange( (p.x+1), p.start.x, p.end.x )
  @isOutOfBounds()

Selector::render = () ->
  # line size
  ls = 1

  tg = @map.tilegrid
  dimensions = pixels( tg.dimensions.tilesize, @position, tg.offset, tg.zoom )
  ctx = @game.context
  ctx.strokeStyle = @color or "#eee"
  ctx.lineWidth = ls
  ctx.strokeRect dimensions.x - ls, dimensions.y - ls, dimensions.size + ls, dimensions.size + ls

module.exports.Selector = Selector
