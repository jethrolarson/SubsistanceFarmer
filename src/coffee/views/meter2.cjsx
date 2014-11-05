rx = require 'react'
{px} = require '../util/unit'
module.exports = rx.createClass
    render: ->
        meterWidth = @props.width || 150
        meterHeight = @props.height || 25
        divStyle =
            width: px meterWidth
            height: px meterHeight

        expanderStyle =
            height: px meterHeight
            backgroundColor: @props.bg
            width: px @props.value * meterWidth

        labelStyle =
            lineHeight: px meterHeight
            width: px meterWidth

        <div class="meter" style={divStyle}>
            <em style={labelStyle}>
                {@props.name}
            </em>
            <span style={expanderStyle}></span>
        </div>