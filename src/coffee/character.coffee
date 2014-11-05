

class Resource extends Backbone.Model
    defaults: {
        max: 100
        current: 100
        min: 0
    }
    initialize: () -> null

class ResourceView extends Backbone.View
    defaults: {
        meterWidth: 150
        meterHeight: 25
        bg: 'red'
    }
    initialize: ->
        @model.bind 'change:current', -> @el.render()

    render: () ->
        vm = _.extend {}, @attributes, @model.attributes
        @el.css {width: @attributes.meterWidth}
        @el.css {height: @attributes.meterHeight}
        @el.html @template vm
        @
    template: _.template """
            <em style="line-height: <%=meterHeight%>px; width: <%=meterWidth%>"><%=name%></em>
            <span style="height: <%=meterHeight%>px; background-color: <%=bg%>;<%}%>width: <%=value*meterWidth%>px"></span>
    """

class model.Character extends Backbone.Model
    initialize: () ->
        @set {
            health: new Resource {name: "Health"}
            fed: new Resource {name: "Fed"}
            energy: new Resource {name: 'Energy'}
            status: {}
            job: null
        }
