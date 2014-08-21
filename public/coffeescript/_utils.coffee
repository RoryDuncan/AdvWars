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
    name = options.name
    fn = options.fn or new Function("console.log('blank fn')")

    list[options.layer] = {name, fn, scope: options.scope}
    return

  @remove = @delete = (layer) ->
    del = list[layer]
    delete list[layer]
    return del

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

module.exports.isInt = (num) ->
  return true if (num / Math.floor(num) is 1 or num / Math.floor(num) is -1)
  return false

module.exports.generateNormalizedGrid = (width, height, iterator, iteratorScope) ->
  evenOffset = module.exports.isInt(width / 2) ? 0 : 1 # even numbers wont have a perfect grid at 0,0; this fixes that
  x0 = ~~(width / 2)   # the boundery x value in the normalized grid
  y0 = ~~(height / 2)   # the first y value in the normalized grid
  centerIndex = null    # may be useful to know where the center is, store for later
  x = -1 * x0           # starting x value before iteration
  y = -1 * y0           # starting y value before iteration

  basicGrid = []

  for i in [0...(width * height)]
    normalData = {x,y,x0,y0}
    if x is 0 and y is 0
      normalData.centerIndex = true
      centerIndex = i

    basicGrid.push normalData
    iterator.call (iteratorScope or null), normalData, i

    if x is (x0 - evenOffset)
      x = (-1 * x0)
      y += 1
    else x++

  return basicGrid