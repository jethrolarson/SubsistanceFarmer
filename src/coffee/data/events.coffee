$ = require 'jquery'
module.exports =
    intro: ->
        @message "Society has collapsed and millions have died. I have fled to the hills and am trying to scrape out an existance as a subsistance farmer. Maybe through hard work and a little luck I'll survive the winter..."
        true
    tired: ->
        @message "I'm exhausted. If I press on I'll be hurting tomorrow.", 'warning'
        $('.rest').addClass('hilight')
        true
    hungry: ->
        @message "I am hungry. I should eat something.", "warning"
        $('.eat').addClass('hilight')
        true
    death: ->
        @message "I died. That sucked...", 'critical'
        #TODO actually end the game
