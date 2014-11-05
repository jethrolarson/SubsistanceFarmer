bb = require 'backbone'
bb.$ = $ = require 'jquery'
_ = require 'underscore'
itemViews =
    Item: require './item'
    Tool: require './tool'

class Inventory extends bb.View
    tagName: 'div'
    initialize: ->
        @$el = $ @el
        @el.id = @cid
        @

    appendItem: (item)->
        item_view = new itemViews[item.constructor.name] model: item
        @$el.append item_view.render().el

    render: ->
        $('#inventory').empty().append @el
        @el

module.exports = Inventory