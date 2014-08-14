
lastTime = 0
vendors = ['ms', 'moz', 'webkit', 'o']

for x in vendors and not window.requestAnimationFrame
    window.requestAnimationFrame = window[vendors[x]+'RequestAnimationFrame']
    window.cancelAnimationFrame = window[vendors[x]+'CancelAnimationFrame'] or
    window[vendors[x]+'CancelRequestAnimationFrame']
    
unless window.requestAnimationFrame
    window.requestAnimationFrame =  (callback, element) ->
        currTime = new Date().getTime()
        timeToCall = Math.max( 0, 16 - ( currTime - lastTime ) )

        id = window.setTimeout ->
            callback(currTime + timeToCall)
        , timeToCall

        lastTime = currTime + timeToCall

        return id
