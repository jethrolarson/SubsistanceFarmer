module.exports =
    constrain: (min, max, a) ->
        Math.max Math.min(a, max), min