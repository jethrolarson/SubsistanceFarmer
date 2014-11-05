# Simple container for crops
Crop = require './crop'
crops = require '../data/crops'
class Plot extends require('backbone').Model
    initialize: (contents)->
        @child = contents
    hasCrop: ->
        @child instanceof Crop
    plant: (plantType)->
        #replace the plot with the crop, keeps same cid
        @collection.plant new Crop(crops[plantType]), @collection.findWhere cid: @get 'cid'

module.exports = Plot