_ = require 'underscore'
phases =
    'midnight': 0
    'dawn':     6
    'midday':   12
    'dusk':     18
    'night':    21
phaseTimes = _.invert phases

module.exports =
    phases: phases
    phaseTimes: phaseTimes