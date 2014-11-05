bb = require 'backbone'
class Item extends bb.Model
    defaults:
        name: ''
        label: ''
        description: ''
        maxUses: 0 # ∞
        age: 0
        color: 'blue'
        maxAge: 0 # ∞
    initialize: ->
        init = @get 'initialize'
        @uses = @maxUses if typeof @uses is 'undefined'
        if init
            init.call this
module.exports = Item