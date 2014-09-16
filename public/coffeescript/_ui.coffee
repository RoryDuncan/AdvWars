
utils = require "./_utils"
extend = utils.extend
pixels = utils.calculatePixelPosition
EventEmitter = utils.EventEmitter

###
  @NAME Dialogue
  @DESCRIPTION Returns an object for rendering text to the Canvas
  @PAREMS Passed in as options object
    @options,data: object

###

Dialogue = (@game, options) ->

  # defaults
  @data = {
    text: {color: "#fff", size: "14px", family: "Helvetica", value: "" },
    heading: {color: "#fff", size: "20px", family: "Helvetica", value: ""}
  }
  @position = {
    x: 1,
    y: 1,
    absolute: true,
    calc: {
      x: 0,
      y: 0
    }
  }
  @separator = "|"
  @id = utils.UID("dialogue", true)
  @style = {}
  @visible = true
  @has = {}

  return extend @, options


extend Dialogue::, EventEmitter::

Dialogue::verify = () ->
  #todo, if needed
  return

Dialogue::heading = (value, size, color, family) ->
  @has.heading = true
  @data.heading.size = size or @data.heading.size
  @data.heading.color = color or @data.heading.color
  @data.heading.family = family or @data.heading.family
  @data.heading.value = value
  return @

Dialogue::text = (text, size, color, family) ->
  @has.text = true
  @data.text.size = size or @data.text.size
  @data.text.color = color or @data.text.color
  @data.text.family = family or @data.text.family
  @data.text.value = text
  return @

Dialogue::drawBorder = (color) ->
  @has.border = true
  return

Dialogue::drawBackground = (color) ->
  @has.background = true
  return

Dialogue::hide = () ->
  @visible = false
  return @

Dialogue::show = () ->
  @visible = true
  return @

Dialogue::toggle = () ->
  @visible = !@visible
  return @

Dialogue::relativeTo = (obj) ->
  @attachedTo = obj
  @tilegrid = obj.tilegrid or obj.map.tilegrid
  @getRelativePositions()
  @position.absolute = false

Dialogue::getRelativePositions = () ->
  a = @attachedTo
  p = {x: @position.x + a.position.x,y: @position.y + a.position.y}

  dimensions = pixels(@tilegrid.dimensions.tilesize, p, @tilegrid.offset, @tilegrid.zoom)
  #console.log dimensions
  @position.calc.x = dimensions.x
  @position.calc.y = dimensions.y

Dialogue::getFont = (type) ->

  size = parseFloat(@data[type].size)
  family = @data[type].family
  return "#{size}px #{family}"

Dialogue::_renderHeading = () ->
  font = @getFont "heading"
  ctx = @game.context
  ctx.fillStyle = @data.heading.color
  ctx.font = font
  ctx.fillText(@data.heading.value, (@position.calc.x or @position.x), (@position.calc.y or @position.y))
  return parseFloat(@data.heading.size)

Dialogue::_renderLines = () ->
  lines = @data.text.value.split @separator


  margin = 2
  marginTop = 0

  if @has.heading
    # render the heading section
    marginTop = @_renderHeading()


  x = @position.calc.x or @position.x
  y = @position.calc.y or @position.y
  ctx = @game.context
  ctx.fillStyle = @data.text.color
  size = parseFloat(@data.text.size)
  family = @data.text.family
  ctx.font = "#{size}px #{family}"
  for line, i in lines
    ctx.fillText(lines[i], x, marginTop + y + i*(margin + size))


Dialogue::render = () ->
  return if not @visible
  @getRelativePositions() unless @position.absolute
  if (@data.text.value.split(@separator)).length > 1
    #@render = @_renderLines # This doesn't work
    @_renderLines()
    return

  marginTop = 0
  if @has.heading
    marginTop = @_renderHeading()
  ctx = @game.context
  ctx.fillStyle = @data.text.color or "#000"
  ctx.font = @getFont("text")
  ctx.fillText(@data.text.value, (@position.calc.x or @position.x), marginTop + (@position.calc.y or @position.y))



  return

module.exports.Dialogue = Dialogue

###
    Menu 
###

Menu = (@game, options) ->


  return @


extend Menu::, EventEmitter::

Menu::render = () ->
  return

module.exports.Menu = Menu


###
  @name Manager
  The object to manage instances of 'Dialogue' or 'Menu',
  and makes sure they get rendered.

###

Manager = (@game) ->
  @list = []

  # initialize for rendering

  @game.Layers.add 
    name: "UserInterface",
    layer: 7,
    fn: @render,
    scope: @

  return @

extend Manager::, EventEmitter::

Manager::Dialogue = (options) ->
  length = @list.push new Dialogue @game, options
  return @list[length - 1]
  

Manager::Menu = (options) ->
  return new Menu @game, options

Manager::render = () ->

  for item in @list
    item.render.call(item)


module.exports.Manager = Manager

