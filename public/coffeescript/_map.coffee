

utils = require "./_utils"

calculateTileRenderPositions = () ->
  size = @size # width and height of the tile
  zoom = @grid.zoom # zoom modifier

  #offsets
  xo = ( @grid.offset.x * size )
  yo = ( @grid.offset.y * size )

  #positions
  xp = ( @position.x * size ) * zoom
  yp = ( @position.y * size ) * zoom

  # widths (with fillRect / strokeRect it is the x and y coordinates on the canvas)
  xw = (xo + size + xp) * zoom
  yw = (xo + size + xp) * zoom



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
  xp = ( @position.x * size ) * zoom
  yp = ( @position.y * size ) * zoom

  # widths (with fillRect / strokeRect it is the x and y coordinates on the canvas)
  xw = (xo + size + xp) * zoom
  yw = (xo + size + xp) * zoom
  sprite.render.call(sprite, (xp + xo), (yp + yo), size, size, zoom)



module.exports.Tile = Tile



TileGrid = (@game, @data, @dimensions) ->

  Tile::game = game
  @tiles = []
  width = @dimensions.width
  height = @dimensions.height
  tilesize = @dimensions.tilesize

  ### Convert the data into a normalized grid data  ###

  evenOffset = utils.isInt(width / 2) ? 0 : 1 # even numbers wont have a perfect grid at 0,0; this fixes that
  x0 = ~~(width / 2)   # the boundery x value in the normalized grid
  y0 = ~~(height / 2)   # the first y value in the normalized grid
  centerIndex = null    # may be useful to know where the center is, store for later
  x = -1 * x0           # starting x value before iteration
  y = -1 * y0           # starting y value before iteration

  for i in [0...(dimensions.width * dimensions.height)]
    tilename = if @data[1] is "-all" then @data[0] else @data[i] 
    tile = new Tile(tilename, {x,y}, tilesize, @game, @)
    @tiles.push tile

    if x is 0 and y is 0
      tile.center = true # mark that node
      centerIndex = i # keep a reference, as well

    if x is (x0 - evenOffset)
      x = (-1 * x0)
      y += 1
    else x++

  @offset = {}
  @offset.x = x0 + 1
  @offset.y = y0 + 1
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

TileGrid::changeTile = (x,y, tilename) ->
  console.log "wow"

TileGrid::render = () ->

  @tiles.forEach (tile) ->
      tile.render.call(tile)

module.exports.TileGrid = TileGrid


# Map is a wrapper object

Map = (@name, @tilegrid, @game, @backgroundColor = "#48c") ->

  @drawBackground = () ->
    @game.context.fillStyle = @backgroundColor
    @game.context.fillRect 0, 0, @game.canvas.width, @game.canvas.height

  return @

Map::render = () ->

  @tilegrid.render.call(@tilegrid)

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

module.exports.Map = Map