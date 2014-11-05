class window.Food
    status: 'fresh'
    constructor: (name)->
        super FOOD, name
        this

    onDayStart: -> #should spoil on a per step basis based on storage state
        @age += 1
        lastStatus = @status
        if @age >= @maxAge * .7
            @status = 'wilted'
            if lastStatus isnt @status
                @nutrition = @nutrition * .7
        else if @age >= @maxAge * .9
            @status = 'questionable'
            if lastStatus isnt @status
                @nutrition = @nutrition * .5
        else if @age >= @maxAge
            @status = 'spoiled'
            @nutrition = -5
    template: _.template """
        <div class="item food action" data-action="useitem" data-actiondata='{"id":"<%=id%>"}'>
            <h3><%=name%></h3>
            <div class="status"><%=status%></div>
            <div class="nutrition">Nutrition: <%=nutrition%></div>
            <div class="protein">Protein: <%=protein%></div>
            <div class="calories">Calories: <%=calories%></div>
            <div class="description"><%=description%></div>
        </div>
    """
    render: -> @template this


