$ = require 'jquery'
module.exports =
    wateringCan:
        label: "Watering Can"
        actions:
            '.crop': (e)->
                if @get('uses') <= 0
                    game.message "I'm out of water, I'll need to gather some more", "warning"
                else if player.burnCalories 1
                    $(e.target).trigger 'water'
                    @set uses: @get('uses') - 1
                    player.work()
                    return true
                return false

            '.well':->
                if @get('uses') < @get('maxUses') and player.burnCalories(1)
                    @set uses: @get 'maxUses'
                    player.work()
        initialize:->
            @listenTo @get("time"),'change:hours', -> null
            if @active
                $('.well').toggleClass 'targetable', @uses is 0
                $('.crop.unwatered').toggleClass 'targetable', @uses
                true
        uses: 0
        maxUses: 5
        color: 'blue'
    shovel:
        label: 'Shovel'
        actions:
            '.expand': (e)->
                if player.burnCalories(3)
                    $(e.target).trigger 'expand'
                    player.work()
    zucciniSeeds:
        label: 'Zuccini Seeds'
        uses: 0
        maxUses: 1
        actions:
            '.plot': (e)->
                if player.burnCalories(2)
                    @set maxUses: 0
                    $(e.target).trigger('plant','zuccini')
                    player.work()