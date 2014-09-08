
utils = require("./_utils")
extend = utils.extend
pixels = utils.calculatePixelPositions
EventEmitter = utils.EventEmitter



###
    The base to all unit objects
###

Unit = (@game, @name, @position = {x: 0, y: 0}, options) ->
  # The actual constructor is init,
  # that all extended objects should
  # call in their own constructor.
  return @init(options)

extend Unit::, EventEmitter::

Unit::init = (options = {}) ->
  # needs to generate an UID
  @id = utils.UID("units", true)
  @visible = options.visibile or false
  @sprite = @game.Sprites[@name]
  @addToManagement(options.player)
  @map = @game.currentMap.map
  @offset = @map.tilegrid.offset
  @size = options.size or @map.tilegrid.dimensions.tilesize
  @zoom = @map.tilegrid.zoom
  # add to the game's unit manager here

  return extend @, options

Unit::render = () ->
  map = @game.currentMap.map
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

Unit::show = () ->
  # whether or not the unit will be rendered
  @visible = true

Unit::hide = () ->
  # whether or not the unit will be rendered
  @visible = false

Unit::addToManagement = (player) ->
  return unless @game
  @game.UnitManager.addUnit(@, player)

module.exports.Unit = Unit


UnitManager = (@game, @currentPlayer = "player1", otherPlayers = []) ->

  @players = players = {}
  currentPlayerArmy = players[@currentPlayer] = []

  otherPlayers.forEach (name) ->
    players[name] = []

  @addUnit = (Unit, player) ->
    # later this might be replaced with an AJAX
    # and handled by the server
    if player is undefined or player is @currentPlayer
      currentPlayerArmy.push Unit
    else players[player].push Unit

  @get = () ->
    return players

  return @


extend UnitManager::, EventEmitter::


UnitManager::reset = () ->
  console.log "test"


UnitManager::set = () ->
  console.log "todo"

UnitManager::render = () ->

  players = @get()
  for player of players

    army = players[player]
    army.forEach (unit) ->
      unit.render()



module.exports.UnitManager = UnitManager
