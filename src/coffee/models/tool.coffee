class Tool extends require './item'
    defaults:
        active: false
        targets: ''
    activate: ->
        game.player.equip this
module.exports = Tool