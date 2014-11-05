Model = require('backbone').Model
{phases, phaseTimes} = require '../data/phases'
DAY_LENGTH = 24
BREAKFAST = DAY_LENGTH * .3
LUNCH = DAY_LENGTH * .5
DINNER = DAY_LENGTH * .8

#FIXME remove references to phase state
class Time extends Model
    defaults:
        hours: 6
        previousTime: 0
        day: 1

    sleep: ->
        while @get('hours') != phases.dawn
            @step()
    addTime: (h) ->
        while h
            @step()
            h -= 1

    step: ->
        hours = @get('hours') + 1
        if hours is DAY_LENGTH
            @set day: @get('day') + 1
            hours = 0
        @set {hours: hours}
        if phaseTimes[hours]
            @trigger phaseTimes[hours]

module.exports = Time