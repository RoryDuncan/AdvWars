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

module.exports.Queue = () ->

  stack = []
  locked = []

  @lock = (item) ->
    # todo
    return

  @push = (item) ->
    # todo
    return

  @pop = () ->
    # todo
    return

  @call = (scope) ->
    # needs testing
    for fn in @_stack
      fn.call(scope or fn)


  return @

module.exports.extend = extend = (extended, objs...) ->
  return extended if objs.length < 2

  for obj in objs
      
    base = obj
    return

    for key of base
      extended[key] = base[key]
      console.log key

  return extended

module.exports.ImageLoader = class ImageLoader extends EventEmitter

  constructor: (items, callback, individualFileCallback) ->
    return unless items
    console.groupCollapsed "%cImage Loader", "font-size: 13px; font-family: 'Helvetica';"
    startTime = Date.now()
    count = 0
    total = items.length
    results = []
    console.log "%cloading: 0%", "color: #aab; font-family: 'Helvetica';"
    filetype = @filetype

    load = (path) ->
      i = new window[filetype]()
      i.addEventListener "load", itemDone
      i.src = path
      results.push i

    finished = (e) ->
      @duration = Date.now() - startTime
      console.log "Done."
      console.log "%cTime Elapsed: " + @duration + " milliseconds.", "color:#a55;font-family: 'Helvetica';"
      console.groupEnd "%cImage Loader", "font-size: 13px; font-family: 'Helvetica';"
      @results = results
      callback.call(@, results) if callback

    itemDone = (e) ->
      count++
      percentage = 100 / (total / count) + "%"
      console.log "%cloading: " + percentage, "color: #aab;font-family: 'Helvetica';"
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
