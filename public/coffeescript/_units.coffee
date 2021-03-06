
utils = require("./_utils")
extend = utils.extend
pixels = utils.calculatePixelPositions
EventEmitter = utils.EventEmitter



###
    The base to all unit objects
###

Unit = (@game, @name, @position = {x: 0, y: 0}, options = {}) ->
  # The actual constructor is init,
  # that all extended objects should
  # call in their own constructor.
  return @init(options)

extend Unit::, EventEmitter::

Unit::init = (options = {}) ->
  # needs to generate an UID
  @id = utils.UID("units", true)
  @visible = false
  @sprite = @game.Sprites[@name]
  @map = @game.currentMap
  @offset = @map.tilegrid.offset
  @size = @map.tilegrid.dimensions.tilesize
  @zoom = @map.tilegrid.zoom
  

  return extend @, options

Unit::render = () ->
  map = @map or @game.currentMap
  return unless map
  return unless @sprite
  return unless @visible

  sprite = @sprite
  size = @size # width and height of the tile
  zoom = @zoom # zoom modifier

  #offsets
  xo = ( @offset.x * size )
  yo = ( @offset.y * size )

  #positions
  xp = ( @position.x * size )
  yp = ( @position.y * size )

  # widths (with fillRect / strokeRect it is the x and y coordinates on the canvas)
  xw = (xo + size + xp) * zoom
  yw = (yo + size + yp) * zoom
  sprite.render.call(sprite, (xp + xo), (yp + yo), size, size, zoom)
  return

Unit::renderRange = () ->
  return @ unless @selected and @visible
  
  return @

Unit::show = () ->
  # whether or not the unit will be rendered
  @visible = true
  return @

Unit::hide = () ->
  # whether or not the unit will be rendered
  @visible = false
  return @

Unit::addToManagement = (player) ->
  return unless @game
  @game.UnitManager.addUnit(@, player)

Unit::showMovementRange = () ->
  return @ unless @visible and @map
  @selected = true
  #console.log @map.tilegrid.tiles.length
  #console.log @
  range = @data.moveRange
  p = @position
  tilesInRange = @map.tilegrid.filter (Tile, i, tiles) ->
    return true if Tile.distanceFrom(p.x, p.y) <= range

  tilesInRange.forEach (T) ->
    T.highlight = true

  return @


module.exports.Unit = Unit

UnitRangeManager = () ->
  @range = undefined
  return @




UnitManager = (@game) ->
  @currentPlayerIndex = cpi = 0
  players = []

  @addUnit = (UnitObject, playerIndex) ->
    # later this might be replaced with an AJAX
    # and handled by the server
    if playerIndex is undefined or playerIndex is cpi
      players[cpi].units.push UnitObject
      UnitObject.data = players[cpi].data[UnitObject.name]

    else
      players[playerIndex].units.push UnitObject
      UnitObject.data = players[playerIndex].data


    return Unit

  @get = () ->
    return players

  @addPlayer = (PlayerObject) ->
    players.push PlayerObject
    PlayerObject.data = @data

  # initialize for rendering
  @game.Layers.add 
    name: "units",
    layer: 5,
    fn: @render,
    scope: @

  return @

extend UnitManager::, EventEmitter::

  

UnitManager::isTileTaken = () ->
  # todo
  return true  


UnitManager::getUnitById = (id) ->
  # filter it like a fishtank bby
  return

UnitManager::getUnitAtTile = () ->
  # todo

UnitManager::getUnitAt = (position) ->
  players = @get()
  console.log players #, position
  result;

  for playername, index of players
    console.log "getting player:", playername, index
    for unit, unitIndex in players[playername]
      #console.log "getting unit:", unit
      continue unless unit.visible is true
      if unit.position.x is position.x and unit.position.y is position.y
        #console.log "match with", unit
        result = unit
        break;
  return result

UnitManager::reset = () ->
  players = @get()
  player.forEach (el) ->
    player.units = []


UnitManager::render = () ->

  players = @get()
  for player in players
    player.units.forEach (unit) ->

      unit.renderRange().render()

UnitManager::create = (type, position = {x:0, y:0}, player) ->
  return unless @data and @data[type]
  unit = new Unit @game, type, position
  unit.addToManagement(player)

  return unit



module.exports.UnitManager = UnitManager
