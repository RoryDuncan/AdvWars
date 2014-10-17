utils =        require "./_utils"
input =        require "./_input"
extend =       utils.extend
pixels =       utils.calculatePixelPosition
EventEmitter = utils.EventEmitter
$ =            require "jquery"

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
    x: -1,
    y: -1,
    absolute: true,
    calc: {
      x: 0,
      y: 0
    }
  }
  @separator = "|"
  @id = utils.UID("dialogue", true)
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


Menu = (@game, @id, options = {}) ->
  # @noop used instead of declaring a 
  # new anonymous function for each instance
  @noop = new Function()
  @deferred = @noop
  @callbackContext = null
  @classname = options.classname or "list"
  @position = {x:0, y:0}
  @active = 0
  @$el = $("##{@id}")
  @map 

  # init actions
  @compile options.data if options.data
  @applyCSS options.css if options.css
  return @

extend Menu::, EventEmitter::

Menu::css = (obj) ->
  if $("##{@id}").length is 0
    console.warn "Delegated applying css. Compile to apply.", obj
    @deferred = () ->
      $("##{@id}").css( obj )
  else $("##{@id}").css( obj )
  return @

Menu::animate = (obj) ->
  # quick use
  return $("##{@id}").animate obj
  
Menu::getPosition = () ->
  top    = $("##{@id}").css "top"
  left   = $("##{@id}").css "left"
  right  = $("##{@id}").css "right"
  bottom = $("##{@id}").css "bottom"
  if top    isnt "auto" then y = parseFloat top, 10
  if left   isnt "auto" then x = parseFloat left, 10
  if right  isnt "auto" then x = -1 * parseFloat right, 10
  if bottom isnt "auto" then y = -1 * parseFloat bottom, 10
  
  x = x or 0 # in case of NaN
  x = x or 0 # in case of NaN
  console.log {top, right, bottom, left}
  return {x, y}

Menu::compile = (obj) ->
  console.log obj
  @data = obj or @data or {}
  @names = []
  @active = @active or 0
  count = 0
  header = "<div id='#{@id}' class='#{@classname}'><ul>"
  listItems = ""
  footer = "</ul></div>"
  
  # helper for generating list items
  li = (text, id) ->
    if text.slice(0,2) is "__"
      return ""
    isActive = (if count is @active then " class='active' " else "")
    count++
    return "<li> <a href='#' #{isActive} data-name='#{text}'> #{text} </a></li>"

  for key, value of @data
    continue if key is "length"  
    listItems += li.call @, key, @id
    if typeof value isnt "function"
      @data[key] = @noop
    @names.push key
  @length = count
  @compiledString = header + listItems + footer
  @compiledListItems = listItems
  return @

# ! WARNING: trickery ahead
# This is all stuff to 'extend' some of jquery's
# DOM functionality to the Menu's prototype.

methodizer = ($method, isSubject = true) ->
  if isSubject
    return (selector) ->
      @exists = true
      $(@compiledString)[$method] selector  
  else
    return (selector) ->
      @exists = true
      $(selector)[$method] @compiledString

$meth = # CASHMONEYMETH
  "append":   false,
  "before":   false,
  "html":     false,
  "after":    false,
  "appendTo": true

for method, isSubject of $meth
  return console.warn "Menu.p.#{method} is not undefined." if Menu::[method] isnt undefined
  Menu::[method] = methodizer method, isSubject

# END OF TRICKERY

Menu::update = () ->
  @compile @data
  $("##{@id} ul").html(@compiledListItems)
  return @

Menu::render = (@selector) ->
  return @update() if @exists
  @html @selector
  @deferred.call(@)
  @deferred = @noop
  return @
  
Menu::add = (name, callback) ->
  @data[name] = callback or @noop
  @update()
  return @

Menu::remove = (name) ->
  @data[name] = undefined
  delete @data[name]
  @update()
  return @

Menu::hide = (name) ->
  # if no parems, hide the entire thing
  if name is undefined
    $("##{@id}").hide()
    return @
  # any item with "__" in front of it is excluded
  callback = @data[name]
  return @ unless callback
  delete @data[name]
  @add "__#{name}", callback
  return @
  
Menu::show = (name) ->
  # if no parems, show the entire thing
  if name is undefined
    $("##{@id}").show()
    return @
  callback = @data["__#{name}"]
  return @ unless callback
  delete @data["__#{name}"]
  @add name, callback
  return @

Menu::destroy = () ->
  console.log "Destruction Imminent"
  $("##{@id}").remove() # removes events too

  return

Menu::next = () ->
  if @active is @length - 1
    @active = 0
  else @active += 1
  # no need to update the entire template
  $("##{@id} li a").removeClass("active")
  current = $("##{@id} li a")[@active]
  $(current).addClass "active"

Menu::prev = () ->
  if @active is 0
    @active = @length - 1
  else @active -= 1
  # no need to update the entire template
  $("##{@id} li a").removeClass("active")
  current = $("##{@id} li a")[@active]
  $(current).addClass "active"

Menu::select = (e) ->
  name = @names[@active]
  @data[name].call(@callbackContext or @, name, @, e)
  
Menu::selectedElement = () ->
  # return the current selected 
  return $("##{@id} li a.active")

Menu::getActionBindings = () ->
  that = @
  return {
    "keydown up":    that.prev.bind(that),
    "keydown down":  that.next.bind(that),
    "keydown enter":    that.select.bind(that)
  }

Menu::open = () ->
  @trigger "open"
  @render(@selector or ".menu").show()
  console.log @
  @profile_ = menuProfile_ = @profile_ or new input.InputProfile("menu-navigation", @game.inputHandler, @getActionBindings())
  @profile_.enable()
  
  return @

Menu::close = () ->
  return unless @profile_
  console.log "closing"
  @profile_.disable()
  @trigger "close"
  @hide()
module.exports.Menu = Menu


###
  @name Manager
  The object to manage instances of 'Dialogue' or 'Menu',
  and makes sure they get rendered.
###

Manager = (@game) ->
  @list = []
  @menus = []
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
  
Manager::Menu = (name, options) ->
  menu = new Menu @game, name, options
  #@list.push menu
  @menus.push menu
  return menu

Manager::render = () ->

  for item in @list
    item.render.call(item)


module.exports.Manager = Manager

