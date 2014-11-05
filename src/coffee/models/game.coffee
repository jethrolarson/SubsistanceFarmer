Player = require "./player"
$ = require "jquery"

{Model, Collection} = require 'backbone'
_ = require 'underscore'
Time = require './time'
phases = require '../data/phases'
events = require '../data/events'
Field = require '../models/field'
FieldView = require '../views/field'
$content = $ '#content'
$toolbar = $ '#toolbar'
Game = ()->
    window.game = this #fixme avoid globals
    @food = 90
    @weather = 5 #0-10
    @time = new Time()
    @player = new Player()
    @field = new Field()
    new FieldView collection: @field
    @envokeEvent 'intro' #note: rather than thinking about firing events we should think about tying transformations to state.

Game::message = (msg, className)->
    className ||= ''
    $content.append """<div class="#{className}">#{msg}</div>"""
    $content.animate({scrollTop: $content[0].scrollHeight}, 500)

Game::envokeEvent = (k, data)->
    data ||= {}
    if not events[k]
        @message "Action #{k} not defined"
    else if events[k].call this, data
        console.log "Event: #{k} evoked"
        return true
    return false

module.exports = Game