bb = require 'backbone'
InventoryView = require '../views/inventory'
Item = require '../models/item'
Tool = require '../models/tool'
tools = require '../data/tools'
items = require '../data/items'

class Inventory extends bb.Collection
    model: Item
    initialize: (settings)->
        @time = settings.time
        @view = new InventoryView collection: this
        @bind 'add', @view.appendItem.bind @view
        @addItem 'bed'
        @addItem 'well'
        @addTool 'wateringCan'
        @addTool 'shovel'
        @addTool 'zucciniSeeds'
        @view.render()
        @
    addItem: (name) ->
        o = items[name]
        o.name = name
        o.time = @time
        @add new Item o

    addTool: (name) ->
        o = tools[name]
        o.name = name
        o.time = @time
        @add new Tool o
module.exports = Inventory