Object.getName = (o) ->
    funcNameRegex = /function (.{1,})\(/
    results = funcNameRegex.exec o.constructor.toString()
    return if results && results.length > 1 then results[1] else ""

module.exports =
    storage: require './util/storage'
