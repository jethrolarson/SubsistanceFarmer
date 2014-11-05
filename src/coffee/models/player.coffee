Model = require('backbone').Model
PlayerView = require '../views/player'
Inventory = require './inventory'
class Player extends Model
    defaults:
        health: 10
        maxHealth: 10
        calories: 6
        maxCalories: 6
        status: {}
        luck: 5
        fed: 80
        maxFed: 100 #4th meal is for quitters
        ate: 0 #0-5
        activeItem: null

    equip: (item)->
        @set activeItem: item
    initialize: ->
        time = game.time
        @inventory = new Inventory({time: time})
        @listenTo time, 'change:hours', @onStep
        @listenTo time, 'dawn', @onDay
        @on 'change:fed', @onFedChange

        #render player status
        @view = new PlayerView model: this
        @view.render()
        window.player = this #fixme avoid globals

    isAlive: ->
        @get('health') > 0

    onStep: ->
        @set fed: @get('fed') - 1

    onFedChange: ->
        if @get('fed') is 0
            game.envokeEvent 'hungry'

    onDay: ->
        status = @get('status')
        if status.exhausted
            @set {calories: Math.floor Math.max @get('maxCalories') + @get('calories'), 2}
            game.message "You're still wiped from yesterday, better take it easy today.", "warning"
            status.exhausted = false
        else
            @set {calories: @get 'maxCalories'}
            game.message "I feel a lot better today"

    burnCalories: (calories) ->
        msg = if @get('calories') > 0
            "This requires #{calories} calories and I only have #{@get('calories')}. Should I cowboy up?"
        else
            msg = "This requires #{calories} calories and I'm exhausted. Should I cowboy up?"
        if @get('calories') - calories >= 0 || confirm msg
            newCals = @get('calories') - calories
            @set {calories: newCals}
            if newCals is 0
                game.envokeEvent 'tired'
            return true
        return false

    work: (hours = 1) ->
        game.time.addTime(hours)

        if @get('calories') < 0
            @get('status').exhausted = true
            dmg = Math.abs(@get('calories')) ^ 2
            @set {health: @get('health') - dmg}
            game.message "Working while exhausted cost you #{dmg} health", 'critical'

        #working while hungry makes you even more tired
        if @fed is 0
            @set {calories: @get('calories') - 1}

        if @get('health') <= 0
            game.envokeEvent 'death'

module.exports = Player