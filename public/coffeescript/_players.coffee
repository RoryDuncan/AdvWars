
playerCount = 0

Player = (@game, @name, @units = []) ->
  
  #console.log "Player \"#{@name}\" created."
  playerCount++

  return @


module.exports.Player = Player