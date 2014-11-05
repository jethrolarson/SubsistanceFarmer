View = require('backbone').View
_ = require 'underscore'
$ = require 'jquery'
span = require('../tags/index').span
meter = require '../views/meter'
class Player extends View
    el: $ '#player'
    initialize: ->
        @$el = $ @el
        console.log 'view Player init'
        @listenTo game.time, 'change:hours', @render
        @model.on 'change', @render.bind this
    render: ->
        console.log 'render player'
        vm = @model.toJSON()
        @$el.html @template.bind _.extend {}, vm, {
            caloriesView: meter
                name: "calories: " + vm.calories + "/" + vm.maxCalories
                value: vm.calories / vm.maxCalories
                bg: "hsl(90,70%,40%)"
            helthView: meter
                name: "health: " + vm.health + "/" + vm.maxHealth
                value: vm.health / vm.maxHealth
                bg: "hsl(0,70%,40%)"
            fedView: meter
                name: "Fed: " + vm.fed + "/" + vm.maxFed
                value: vm.fed / vm.maxFed
                bg: "orange"
        }

    template: (vm)-> """
        <div>
            #{game.time.get 'hours'}:00 Day#{game.time.get 'day'}
        </div>
        <div id="status">
            #{_.map(@status.length, span)}
        </div>
        #{@caloriesView()}
        #{@helthView()}
        <div class="eat action" data-action="eat" title="Eat">
            #{@fedView()}
        </div>
    """



module.exports = Player