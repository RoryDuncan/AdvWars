
console.log "%cAdvanced Wars Clone", "color: #c88"

require             "./_rafPolyfill"
utils = require     "./_utils"
EventEmitter =      utils.EventEmitter
Sprite = require    "./_sprites"
mapUtils = require  "./_map"
input = require    "./_input"
Clock = require     "./_clock"
$ = require         "jquery"

Game = (@canvas, @width, @height) ->
  
  gameloop = Clock.Loop
  @__events = {} # for event emitter
  @width = @width or window.innerWidth
  @height = @height or window.innerHeight

  @context = @canvas.getContext("2d")
  @canvas.width = @width
  @canvas.height = @height
  @context.fillStyle = "#48c"
  @context.fillRect(0, 0, @width, @height)

  @Layers = new utils.RenderList(@)
  @Sprites = {}
  @maps = {}
  @inputHandler = new input.InputHandler( document )
  @inputHandler.profiles = {}
  @clock = new Clock()

  # internal render loop
  render = () ->

    # iterates through any 'layers'
    #and calls them in order (0,1,2,etc)
    @Layers.renderAll.call(@Layers)
    


  @__loop = @clock.loop "render", render, [], @
  @__loop.for({interval:17})

  return @


# extend EventEmitter
Game:: = EventEmitter::

Game::start = (mode) ->
  console.log "Starting..."
  @clock.start()
  # if mode is "game" / "mapeditor" etc
  that = @

  #introduce the map panning profile
  mapPanning = 
    "keydown up": (that.currentMap.map.up).bind(that.currentMap.map)
    "keydown down": (that.currentMap.map.down).bind(that.currentMap.map)
    "keydown left": (that.currentMap.map.left).bind(that.currentMap.map)
    "keydown right": (that.currentMap.map.right).bind(that.currentMap.map)

  mapPanProfile = new input.InputProfile("map-panning", @inputHandler, mapPanning)
  @inputHandler.profiles["map-panning"] = mapPanProfile
  mapPanProfile.enable()


Game::pause = () ->
  @clock.pause()

Game::getMapJSON = (url) ->
  console.log "Getting Map Data..."
  that = @
  promise = $.getJSON url

  return promise

Game::getMapFromUrl = (url) ->
  that = @
  promise = @getMapJSON url
  promise.then (e) ->
    that._createMap.call that, e

Game::loadMap = (name) ->

  if @maps[name] is undefined
    console.log "Map '#{name}' wasn't found."
    return

  @currentMap = {name, map: @maps[name]}
  map = @maps[name]

  @Layers.add 
    name: "backdrop",
    layer: 0,
    fn: map.drawBackground,
    scope: map

  @Layers.add 
    name: "map render",
    layer: 3,
    fn: map.render,
    scope: map

  console.log "Loading Map '#{name}'... Done."
  @trigger "ready"

Game::getSpriteListJSON = (url, callback) ->
  console.log "Getting SpriteList..."
  that = @
  promise = $.getJSON url

  promise.then (responseText) ->

    that.Sprites._list = responseText
    that._createSpriteList.call that, responseText

  return promise

Game::_createSpriteList = (spritelist, callback) ->

  start = Date.now();
  list = @Sprites
  context = @

  computeSprite = (o, name, i) ->
    return if o.x is undefined # how an empty object is determined

    key = name + (i or "")
    s = @Sprites.spritesheet

    list[key] = new Sprite s, {x:o.x, y:o.y, w:o.w, h:o.h}
    list[key].name = key
    list[key].render({x:100, y: 100})
    console.log "Adding Sprite for '#{key}'"

  console.groupCollapsed "%cCreating Sprites From JSON data", "color: #0b7"

  for key, item of spritelist
    
    for name, val  of item

      if utils.isArray val

        val.forEach (el, index) ->
          computeSprite.call context, el, name, index

      else
        computeSprite.call context, val, name

  elapsed = (Date.now() - start)
  console.log "%cDone. Elapsed Time: #{elapsed}ms", "color: #800"
  console.groupEnd "%cCreating Sprites From JSON data", "color: #0b7"
  callback.call context if callback

Game::_createMap = (mapData) ->

  name = mapData.name
  tilegrid = new mapUtils.TileGrid(@, mapData.tiles, mapData.dimensions)
  @maps[name] = new mapUtils.Map(name, tilegrid, @)



# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ #
###                      @TESTING                           ###
# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ #






canvas = document.getElementById("game")
game = new Game(canvas);
Sprite::game = game
Sprite::ctx = game.context

console.log game
game.on "ready", game.start, game

finishedLoadingImages = (loadedImages) ->
  game.Sprites.spritesheet = loadedImages[0]
  spritelistPromise = game.getSpriteListJSON "/JSON/spritelist.json"
  mapPromise = null
  spritelistPromise.then (e) ->

    mapPromise = game.getMapFromUrl "/JSON/testmap.json"
    mapPromise.then () ->
      game.loadMap "testmap"
  return

# need to promise the tits out of this
loader = new utils.ImageLoader ["sprites/spritesheet.png"], finishedLoadingImages


###

  movementAmount = 1
  



###

