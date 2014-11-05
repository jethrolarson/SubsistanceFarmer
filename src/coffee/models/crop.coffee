Backbone = require 'backbone'
{constrain} = require '../util/number'
class Crop extends Backbone.Model
    MAX_HAPPINESS: 9
    MAX_GROWTH: 9
    GROW_THRESHOLD: 7
    DIE_THRESHOLD: 5
    GROWTH_PER_DAY: 1

    defaults: {
        maxAge: 22 #how many days crop will live
        yieldAt: 10 #when the crop will start yielding harvestable produce
        maxHarvestSize: 4 #how many units the crop can hold at one time
        thirst: 2 #water/day
        weather: 5 #preferred weather
        hardiness: 2 #how resistant to weather the plant is

        age: 0
        watered: false
        yield: 0
        harvestSize: 0
        happiness: 0
        growth: 0
    }

    initialize: ->
        @set happiness: @MAX_HAPPINESS
        @mods = new Backbone.Collection
        @listenTo game.time, 'dawn', @onDayStart
    onDayStart: ->
        @set {happiness: @get('happiness') + (if @get('watered') && Math.abs(@get('weather') - game.weather) < 2 then +1 else -1)}, {silent: true}

        @set {happiness: constrain 0, @MAX_HAPPINESS, @get 'happiness' }, {silent: true}

        #growing
        if @get('happiness') >= @GROW_THRESHOLD and @get('age') < @get('maxAge')
            @set {growth:  @get('growth') + @GROWTH_PER_DAY}, {silent: true}
        #dying
        if @get('happiness') <= @DIE_THRESHOLD or @get('age') >= @get('maxAge')
            @set {growth: @get('growth') - @GROWTH_PER_DAY}, {silent: true}
        ###
        TODO When plants are at low health they take damage to one of their core attributes
        ###

        #start yield
        @set {age: @get('age') + 1}
        if @get('age') >= @get 'yieldAt'
            @set {'yield': @get('yield') + Math.round (@get('happiness') - 5) / 2}, {silent: true}
        @set {watered: false}, {silent: true}
        @trigger 'change'

    water: () ->
        if not @prop.watered
            @prop.watered = true
            return true
        return false
module.exports = Crop