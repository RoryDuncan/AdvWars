
playerCount = 0

Player = (@game, @name, @units = [], color) ->

  #console.log "Player \"#{@name}\" created."
  playerCount++
  @color = color or '#0a8'

  return @

module.exports.Player = Player

AI = () ->

  return @


module.exports.AI = AI