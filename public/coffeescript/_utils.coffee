module.exports.EventEmitter = class EventEmitter

  constructor: () -> 
    @__events = {}    

  on: (name, fn, context) ->
    @__events = {} if @__events is undefined
    @__events[name] = {fn, context}
    return @

  off: (name) ->
    delete @__events[name]
    return @

  get: (name) ->
    return if @__events is undefined
    return @__events[name]

  trigger: (name, args = []) ->
    return if @__events is undefined
    f = @get name
    return unless f isnt undefined

    f.fn.apply(f.context, args)

    return @

module.exports.RenderList = (@game) ->

  list = []

  @set = @add = (options) ->
    console.error "That layer (layer #{options.layer}) is allocated already to '#{list[options.layer].name}'." unless list[options.layer] is undefined 
    name = options.name
    fn = options.fn or new Function("")

    list[options.layer] = {name, fn, scope: options.scope}
    return list[options.layer]

  @remove = @delete = (layer) ->
    del = list[layer]
    delete list[layer]
    return del

  @debug = () ->
    console.log list

  @render = (layer) ->

    lyr = list[layer]
    lyr.fn.call(lyr.scope or lyr.fn or null, lyr)

  @renderAll = () ->
    for item, index in list
      continue unless item
      item.fn.call(item.scope or item.fn or null, item)


  return @

module.exports.extend = extend = (extended, objs...) ->
  return extended unless objs
  for obj in objs
    for key of obj
      extended[key] = obj[key]

  return extended

module.exports.ImageLoader = class ImageLoader extends EventEmitter

  constructor: (items, callback, individualFileCallback) ->
    return unless items
    startTime = Date.now()
    count = 0
    total = items.length
    results = []
    filetype = @filetype
    console.groupCollapsed "%cLoading Images.", "color: #0b7"
    console.log "%cProgress: 0%", "color:#ccc"

    load = (path) ->
      i = new window[filetype]()
      i.addEventListener "load", itemDone
      i.src = path
      results.push i

    finished = (e) ->
      @duration = Date.now() - startTime
      console.log "%c#{total} Images Loaded. Time Elapsed: " + @duration + " milliseconds.", "color: #800"

      @results = results
      console.groupEnd "%cLoading Images.", "color: #0b7"
      callback.call(@, results) if callback

    itemDone = (e) ->
      count++
      percentage = 100 / (total / count) + "%"
      console.log "%cProgress: #{percentage}", "color:#ccc"
      individualFileCallback.call(@, e) if individualFileCallback
      finished() if count is total 

    @on "itemDone", itemDone
    @on "done", finished


    items.forEach load
  
  filetype: "Image"

module.exports.getJSON = (url, callbacks) ->
    options = callbacks or {}
    data = undefined
    ajax = $.getJSON url
    ajax.complete ->

      try
        data = $.parseJSON ajax.responseText
      catch e
        options.error.call options.scope or null, e, ajax
        return
      options.success.call(options.scope or null, data, ajax)
      return

module.exports.isArray = Array.isArray or (thing) ->
  # defaults to built in isArray if browser supports it
  Object.prototype.toString.call thing is "[object Array]"

module.exports.isInt = (n) ->
  return true if (n / Math.floor(n) is 1 or n / Math.floor(n) is -1)
  return false
module.exports.isEven = (n) ->
  return if n % 2 is 0 then true else false 
module.exports.has = (obj, key) ->
  return Object.hasOwnProperty.call(obj, key)

UIDgroups = {};
module.exports.generateUID =
module.exports.UID =
UID = (groupName, prependLetter = false) ->
  
  # test directly against undefined because -1 and 0 fire falsy values
  previous = if UIDgroups[groupName] is undefined then 0 else UIDgroups[groupName]

  UIDgroups[groupName] = previous
  UIDgroups[groupName]++
  
  id = UIDgroups[groupName]

  letter = groupName[0] + "_"

  if prependLetter
    return "#{letter}#{id}"

  else return "#{id}"


module.exports.limitToRange = (value, min, max) ->
  return Math.max(min, Math.min(max, value))


module.exports.generateNormalizedGrid = (width, height, iterator = new Function(), scope) ->
  # even numbers wont have a perfect grid at 0,0; this fixes that
  evenOffsetX = module.exports.isInt(width / 2) ? 0 : 1
  evenOffsetY = module.exports.isInt(height / 2) ? 0 : 1
  # the boundery x value in the normalized grid
  x0 = ~~(width / 2) - evenOffsetX

  # the first y value in the normalized grid
  y0 = ~~(height / 2) - evenOffsetY
  xEnd = x0 + evenOffsetX
  yEnd = y0 + evenOffsetY
  centerIndex = false   # may be useful to know where the center is, store for later
  x = -1 * x0           # starting x value before iteration
  y = -1 * y0           # starting y value before iteration

  basicGrid = []

  for i in [0...(width * height)]
    normalData = {x,y,x0,y0, start:{"x":-x0, "y":-y0}, end:{"x":xEnd, "y":yEnd}, "id":i}
    if x is 0 and y is 0
      normalData.centerIndex = true
      centerIndex = i

    else centerIndex = false

    basicGrid.push normalData
    iterator.call (scope or null), normalData, i, centerIndex

    # the checks 
    if x is xEnd
      x = (-1 * x0) #reset to our farmost left value
      y += 1
    else x++

  basicGrid.centerIndex = centerIndex
  console.assert (width * height) is basicGrid.length, "Something went wrong with generation of a Normalized Grid"

  return basicGrid


module.exports.calculatePixelPosition = (size, position, offset, zoom) ->
  #offsets
  xo = ( offset.x * size )
  yo = ( offset.y * size )

  #positions
  xp = ( position.x * size )
  yp = ( position.y * size )

  # widths:
  # (with fillRect / strokeRect it is the x and y coordinates on the canvas)
  xw = (xo + size + xp) * zoom
  yw = (yo + size + yp) * zoom

  x = xp + xo
  y = yp + yo
  endx = xw
  endy = yw

  return {x, y, endx, endy, size, "offset": {"x":xo, "y":yo}}
