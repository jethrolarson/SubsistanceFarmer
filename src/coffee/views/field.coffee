Backbone = require 'backbone'
$ = require "jquery"
_ = require "underscore"
meter = require '../views/meter'
views = {}
class Field extends Backbone.View
    el: $ '#field'
    initialize: ->
        @$el = $(@el)
        @collection.bind 'add', @appendItem.bind @
        @length = 0
        @el.id = @cid
        @render()
    events:{
        expand: 'expand'
    }
    appendItem: (crop) ->
        item_view = new views[crop.constructor.name](model: crop)
        item_view.collection = @collection
        @$el.append item_view.render().el
    expand: ->
        @collection.expand()

    render: ->
        @$el.html '<div class="expand">Expand Garden</div>'



class views.Plot extends Backbone.View
    tagName: 'div'
    initialize: ->
        @$el = $(@el)
        @model.bind 'remove', =>
            @$el.remove()
        @el.id = @cid
        @$el.on
            plant: (e, plantType)=>
                @model.plant plantType
    render: ->
        @$el.html """<div class="plot" id="#{this.cid}">Plot</div>"""
        @

class views.Crop extends Backbone.View
    tagName: 'div'
    initialize: ->
        @$el = $ @el
        @$el.attr {
            id: @cid
            'class': 'crop'
        }
        @listenTo @model,'change', @render.bind @
        @render()
    events: {
        water: 'water'
    }

    render: ->
        @$el.toggleClass 'unwatered', not @model.get 'watered'
        vm = @model.toJSON()
        @$el.html template.call _.extend {}, vm, {
            happinessView: meter
                width:80,
                height: 5,
                bg: 'yellow',
                value: vm.happiness / vm.MAX_HAPPINESS
            ageView: meter
                width:80,
                height: 5,
                value: vm.age / vm.maxAge
        }
        @

    water: ->
        @model.set watered: true

template = (vm)-> """
    <div><b>#{@name}</b></div>
    #{@ageView()}
    <div>Growth: #{@growth}</div>
    #{@happinessView()}
    #{if @yield then 'Yield:' + @yield else ''}
    #{if !@watered then '<div>thirsty</div>' else ''}
"""


module.exports = Field