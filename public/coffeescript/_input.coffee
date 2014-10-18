
$ = require "jquery"
utils = require "./_utils"
consoleColor = "color:#8b8"


InputHandler = (el) ->
  return unless $
  @profiles = {}
  $el = $(el)
  # the relevent e.which keys, hashed

  key =

    #   mouse clicks

    "leftClick": 1,
    "scrollwheel": 2,
    "rightClick": 3,

    #   keys

    'backspace': 8,
    'tab': 9,
    'enter': 13,
    'shift': 16,
    'ctrl': 17,
    'alt': 18,
    'pause': 19,
    'capslock': 20,
    'esc': 27,
    'pageup': 33,
    'pagedown': 34,
    'end': 35,
    'home': 36,
    'left': 37,
    'up': 38,
    'right': 39,
    'down': 40,
    'insert': 45,
    'delete': 46,
    '0': 48,
    '1': 49,
    '2': 50,
    '3': 51,
    '4': 52,
    '5': 53,
    '6': 54,
    '7': 55,
    '8': 56,
    '9': 57,
    'a': 65,
    'b': 66,
    'c': 67,
    'd': 68,
    'e': 69,
    'f': 70,
    'g': 71,
    'h': 72,
    'i': 73,
    'j': 74,
    'k': 75,
    'l': 76,
    'm': 77,
    'n': 78,
    'o': 79,
    'p': 80,
    'q': 81,
    'r': 82,
    's': 83,
    't': 84,
    'u': 85,
    'v': 86,
    'w': 87,
    'x': 88,
    'y': 89,
    'z': 90,
    'numpad0': 96,
    'numpad1': 97,
    'numpad2': 98,
    'numpad3': 99,
    'numpad4': 100,
    'numpad5': 101,
    'numpad6': 102,
    'numpad7': 103,
    'numpad8': 104,
    'numpad9': 105,
    'multiply': 106,
    'plus': 107,
    'minut': 109,
    'dot': 110,
    'slash1': 111,
    'F1': 112,
    'F2': 113,
    'F3': 114,
    'F4': 115,
    'F5': 116,
    'F6': 117,
    'F7': 118,
    'F8': 119,
    'F9': 120,
    'F10': 121,
    'F11': 122,
    'F12': 123,
    'equal': 187,
    'coma': 188,
    'slash': 191,
    'backslash': 220


  bound = {}


  handler = (e) ->
    
    #e.position = utils.getMousePosition(e)
    b = bound[e.type]
    #console.log "event options:", b
    #console.log "key pressed:", e.which
    return unless b
    for keyname of b
      if key[keyname] is e.which
        e.preventDefault()
        #console.log "calling #{keyname}"
        b[keyname].callback.call( b[keyname], e, b[keyname] )
        return

  # mouse movement is a special case
  mousemoveHandler = (e) ->

    e.preventDefault()
    e.position = utils.getMousePosition(e)

    b = bound["mousemove"]
    data = b.data or {}
    b.callback.call stage, e, data
    return

  @bind =
  @on = (events, keyname, callback, data) ->
    return unless arguments.length >= 2
    _events = events.split(" ")

    if _events[0] is "mousemove"
      # There is no keyname for mousemove,
      # so 'keyname' is actually callback, and 'callback' is data
      bound["mousemove"] = { "callback": keyname, "data": callback }
      $el.on "mousemove", mousemoveHandler

    for eventType in _events
      # TODO:
      # needs to not trigger on() everytime an event is added,
      # it should check to see if bound[eventType] exists, if it does, assume an on()
      # has been set for that event
      if bound[eventType] isnt undefined
        bound[eventType][keyname] = {callback, data, scope: (data or {}).scope}
        #console.log "%cAdding key('#{keyname}') to #{eventType}. Event Listener exists prior.", consoleColor
      else
        bound[eventType] = {}
        bound[eventType][keyname] = { callback, data, scope: (data or {}).scope}
        $el.on eventType, handler
        #console.log "%cAssigning new key('#{keyname}') to #{eventType} and adding an Event Listener.", consoleColor
      

    return @

  @unbind =
  @off = (events, keyname) ->

    _events = events.split(" ")
    #console.log "bound", bound
    #console.log "OFFING BITCHES ->"#, events
    for eventType in _events

      delete bound[eventType][keyname]
      keys = utils.count( bound[eventType] )
      if keys is 0
        $el.off(eventType, handler)
      
    return @

  @trigger = (event) ->
    $el.trigger event
    return bound[event]

  return @

InputHandler::getProfile = (name) ->
  return @profiles[name]


module.exports.InputHandler = InputHandler


###
@InputProfiles are used to 
keep track of certain keybinding configurations
###

InputProfile = (@name, @inputHandler, @actions, @scope) -> 
  @_state = "off"
  @_combined = []
  @combinedWith = []
  @inputHandler.profiles = @inputHandler.profiles or {}
  @inputHandler.profiles[@name] = @
  return @

InputProfile::multipleInputActions = (inputMethod) ->

  console.log "%cProfile #{@name} is #{inputMethod}.", consoleColor

  @_state = inputMethod 

  # Deal with internal event actions

  for key, value of @actions

    #split into the event and the key, ie:
    # eventdetails[0] = "keypress"
    # eventdetails[1] = "numpad4"

    eventdetails = key.split " "
    eventdetails = key if eventdetails.length is 1
    @inputHandler[inputMethod].call @inputHandler, eventdetails[0], eventdetails[1], value

  # then deal with any combined actions via recursion
  for inputProf in @_combined
    inputProf.multipleInputActions.call inputProf, inputMethod

  return @actions

InputProfile::toggle = () ->
  if @_state is "on"
    @disable()
  else if @_state is "off"
    @enable()

InputProfile::enable = () ->
  #console.log @
  @multipleInputActions "on"

InputProfile::disable = () ->
  console.log @
  @multipleInputActions "off"

InputProfile::add = (inputProf) ->
  @_combined.push inputProf
  @combinedWith.push inputProf.name

InputProfile::remove = (inputProfname) ->
  index = @_combinedWith.indexOf(inputProfname)
  delete @combinedWith[index]
  item = @_combined[index]
  item.multipleInputActions "off"
  delete @_combined[index]
  return item

InputProfile::switchTo = (profileNameOrObject) ->
  @disable()
  console.log "wow", profileNameOrObject.name, "switching from", @name, "unwow"

  if typeof profileNameOrObject is "string"

    p = @inputHandler.profiles[profileNameOrObject]
    console.log "p", p
    p.enable.call(p)
    return p

  else if typeof profileNameOrObject is "object"

    profileNameOrObject.enable.call(profileNameOrObject)
    return profileNameOrObject

  else return null

module.exports.InputProfile = InputProfile