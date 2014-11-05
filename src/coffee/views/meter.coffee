{px} = require '../util/unit'
meter = (model)->
    render.bind model

render = ->
    meterWidth = @width || 150
    meterHeight = @height || 25
    """
    <div class="meter" style="width: #{px meterWidth}; height: #{px meterHeight}">
        <em style="line-height: #{px meterHeight}; width: #{px meterWidth}">#{@name}</em>
        <span style="height: #{px meterHeight}; #{if @bg then "background-color: #{@bg};"}width: #{px @value * meterWidth}"></span>
    </div>
"""

module.exports = meter