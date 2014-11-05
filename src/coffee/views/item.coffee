$ = require 'jquery'
bb = require 'backbone'
meter = require './meter'
{str, flag} = require '../util/string'

class Item extends bb.View
    tagName: 'div'
    initialize: ->
        @$el = $ @el
        @model.bind 'change:targetable', =>
            @$el.toggleClass('targetable', @model.get 'targetable')
        @$el.attr
            id: 'item_'+ @model.cid
            'data-itemid': @model.get 'id'
            'class': 'item ' + @model.get 'name'
        @listenTo game.time, 'change:hours', @render
        if @model.get 'use'
            @$el.on click: @model.get('use').bind @model
    render: ->
        @$el.html template.call @model.toJSON()
        @

template = (vm)->
    m = meter
        width:60
        height: 5
        bg: @color
        value: @uses / @maxUses
    """
        <div class="#{flag @active, 'active'}">#{str @label}</div>
        #{str @description}
        #{flag @maxUses, m()}
    """

module.exports = Item