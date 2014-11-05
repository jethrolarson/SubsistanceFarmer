$ = require 'jquery'
Item = require './item'
$d = require '../util/document'
class Tool extends Item
    initialize:->
        super()
        @$el = $ @el
        @$el.addClass 'tool'
        @model.bind 'change:active', @changeActive.bind @
        @model.bind 'change:uses', @render.bind @
        @$el.on
            click: (e)=>
                @model.set active: true
        @
    changeActive: ->
        if @model.get 'active'
            #deactivate every item except this one
            for model in player.inventory.models
                model.set(active: false) if model.cid isnt @model.cid
            @$el.addClass 'active'
            for key, val of @model.get 'actions'
                $(key).addClass 'targetable'
                #bind item actions to their targeted elements
                $d.on 'click.' + @cid, key, val.bind @model
        else
            for key of @model.get 'actions'
                $(key).removeClass 'targetable'
            @$el.removeClass 'active'
            $d.off 'click.' + @cid

    render: ->
        super()


    appendItem: (item)->
        item_view = new views[item.constructor.name] model: item
        @$el.append item_view.render().el

module.exports = Tool