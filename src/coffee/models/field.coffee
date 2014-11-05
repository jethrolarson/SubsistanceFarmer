Backbone = require 'backbone'
Plot = require './plot'
class Field extends Backbone.Collection
    plant: (model, index)->
        @remove @at index
        @add model,  at: index

    expand: ->
        @add new Plot()

module.exports = Field