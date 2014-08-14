

utils = require "./_utils"

Tile  = (@tilename, @position, SpriteHash) ->

  Tile::SpriteHash = if SpriteHash then SpriteHash else {}

  @setSpriteHash = (SpriteHash) ->
    Tile::SpriteHash = SpriteHash

  @tilename = @tilename or "blank"
  @tilesize = @game.canvas.width / 20
  @renderBlank = () ->

    @game.context.strokeStyle = "#fff"

    t = @tilesize # width and height of the tile
    z = @zoom # zoom modifier
    #offsets
    xo = ( @offset.x * t )
    yo = ( @offset.y * t )

    #positions
    xp = ( @position.x * t ) * z
    yp = ( @position.y * t ) * z

    # widths (with fillRect / strokeRect it is the x and y coordinates on the canvas)
    xw = (xo + t + xp) * z
    yw = (xo + t + xp) * z

    #console.log xp, yp
    @game.context.fillStyle = "#f0f"
    @game.context.strokeRect( xp + xo, yp + yo, t, t)

  @render = () ->
    @renderBlank.call(@) if @tilename is "blank"

  return @


# zooming in / out of tiles
Tile::zoom = 1
# the values that change where the grid is panned
Tile::offset = {x:0, y: 0}

module.exports.Tile = Tile



TileGrid = (game, @data, dimensions, SpriteHash) ->

  Tile::game = game
  TileGrid::game = game
  @tiles = []
  width = dimensions.width
  height = dimensions.height

  ### Convert the data into a normalized grid data  ###

  evenOffset = utils.isInt(width / 2) ? 0 : 1 # even numbers wont have a perfect grid at 0,0; this fixes that
  x0 = ~~(width / 2)   # the boundery x value in the normalized grid
  y0 = ~~(height / 2)   # the first y value in the normalized grid
  centerIndex = null    # may be useful to know where the center is, store for later
  x = -1 * x0           # starting x value before iteration
  y = -1 * y0           # starting y value before iteration

  for i in [0...(dimensions.width * dimensions.height)]
    tile = new Tile(null, {x,y}, SpriteHash)
    @tiles.push tile

    if x is 0 and y is 0
      tile.center = true # mark that node
      centerIndex = i # keep a reference, as well

    if x is (x0 - evenOffset)
      x = (-1 * x0)
      y += 1
    else x++

  return @


TileGrid::setZoom = (i = 1) ->
  Tile::zoom = i

TileGrid::crossZoom = (modifier) ->
  Tile::zoom = i * modifier

TileGrid::move = (x = 0, y = 0) ->
  Tile::offset.x += x
  Tile::offset.y += y

TileGrid::changeTile = (x,y, tilename) ->
  console.log "wow"

TileGrid::render = () ->

  @game.context.fillStyle = "#000"
  @game.context.fillRect(0,0,@game.canvas.width,@game.canvas.height)

  @tiles.forEach (tile) ->
    tile.render.call(tile)

module.exports.TileGrid = TileGrid