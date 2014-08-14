
console.log "%cAdvanced Wars Clone", "color: #c88"

require "./_rafPolyfill"
utils = require "./_utils"
Sprite = require "./_sprites"
map = require "./_map"
Input = require "./_input"
Clock = require "./_clock"

Game = (@canvas, @width, @height) ->

  @width = @width or window.innerWidth
  @height = @height or @width or window.innerHeight

  @context = @canvas.getContext("2d")
  @context.fillStyle = "#4a8"

  @canvas.width = @width
  @canvas.height = @height
  @context.fillRect(0, 0, @width, @height)
  @Layer = new utils.Queue()
  return @


###   TESTING  ###


canvas = document.getElementById("game")
game = new Game(canvas, 500);
Sprite::game = game
Sprite::ctx = game.context

console.log game

clock = new Clock()

spritesheet = "NOT LOADED"
tg = "NOT LOADED"

render = () ->
  console.log()

base = "sprites/"
loader = new utils.ImageLoader [base + "AWspritesheet.png"],
(e) -> 

  spritesheet = e[0]
  #console.log( new Sprite(spritesheet) )

  #game.context.drawImage(spritesheet, 0, 0, 50, 40, 10, 0, 50, 40)

  tg = new map.TileGrid(game, [1..64], {width: 15, height: 15})
  tg.render()

  movementAmount = 1
  input = new Input( document )

  input.on "keydown", "up", (e) ->
    tg.move(0, (-1)*movementAmount)

  input.on "keydown", "down", (e) ->
    tg.move(0, movementAmount)

  input.on "keydown", "left", (e) ->
    tg.move((-1)*movementAmount, 0)

  input.on "keydown", "right", (e) ->
    tg.move(movementAmount, 0)

  render = () ->
    console.log "super wow"
    tg.render();

  clock.on "tick", render

  clock.start()
