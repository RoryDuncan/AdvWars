

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

# the object for selecting units, tiles, etc
Selector = (@game, @Map) ->
  @position = 
  @grid = utils.generateNormalizedGrid @Map.tilegrid.width, @Map.tilegrid.width

  return @

Selector::move = (x, y) ->

Selector::adjustMap = (x, y) ->

Selector::render = () ->
