
class models.Plot extends Backbone.Model

class models.Crop extends Backbone.Model
	MAX_HAPPINESS: 9
	MAX_GROWTH: 9
	GROW_THRESHOLD: 7
	DIE_THRESHOLD: 5
	GROWTH_PER_DAY: 1
	
	defaults:
		maxAge: 22 #how many days crop will live
		yieldAt: 10 #when the crop will start yielding harvestable produce
		maxHarvestSize: 4 #how many units the crop can hold at one time 
		thirst: 2 #water/day
		weather: 5 #preferred weather
		hardiness: 2 #how resistant to weather the plant is

		age: 0
		watered: false
		yield: 0
		harvestSize: 0
		happiness: 0
		growth: 0

	initialize: ->
		@happiness = @MAX_HAPPINESS
		@mods = new Backbone.Collection
		@listenTo time, 'dawn', @onDayStart

	onDayStart:->
		debugger
		@set {happiness: @get('happiness') + (if @get('watered') && Math.abs(@get('weather') - game.weather) < 2 then +1 else -1)}, {silent: true}
		
		@set {happiness: @get('happiness').constrain 0, @MAX_HAPPINESS}, silent: true

		#growing
		if @get('happiness') >= @GROW_THRESHOLD and @get('age') < @get('maxAge')
			@set {growth:  @get('growth') + @GROWTH_PER_DAY}, silent: true
		#dying
		if @get('happiness') <= @DIE_THRESHOLD or @get('age') >= @get('maxAge')
			@set {growth: @get('growth') - @GROWTH_PER_DAY}, silent: true
		###
		TODO When plants are at low health they take damage to one of their core attributes
		###

		#start yield
		@set age: @get('age') + 1
		if @get('age') >= @get 'yieldAt'
			@set {'yield': @get('yield') + Math.round (@get('happiness') - 5) / 2}, silent: true
		@set {watered: false}, silent: true
		@trigger 'change'

	water: ()->
		if not @prop.watered
			@prop.watered = true
			return true
		return false

class views.Plot extends Backbone.View
	tagName: 'div'
	initialize: ->
		@$el = $(@el)
		@model.bind 'remove', =>
			@$el.remove()
		@el.id = @cid
		@$el.on plant: (e,plantType)=>
			for crop,i in @collection.models
				break if crop.cid = @model.cid
			@collection.remove @collection.at i
			@collection.add new models.Crop(CROPS[plantType]), at: i
	render: ->
		@$el.html """<div class="plot" id="#{this.cid}">Plot</div>"""
		@

class views.Crop extends Backbone.View
	tagName: 'div'
	initialize:->
		@$el = $ @el
		_.bindAll @
		@$el.attr(
			id: @cid
			'class': 'crop'
		)
		@listenTo @model,'change', @render
		@render()
	events:
		water: 'water'
	render: ->
		@$el.toggleClass 'unwatered', not @model.get 'watered'
		@$el.html @template @model
		@
	water: ->
		@model.set watered: true
	template: _.template """
		<div><b><%@name%></b></div>
		<%=game.meterTemplate({width:80, height: 5, value: this.get('age') / this.get("maxAge")})%>
		<div>Growth: <%@growth%></div>
		<%=game.meterTemplate({width:80, height: 5, bg: 'yellow', value: this.get('happiness') / this.MAX_HAPPINESS})%>
		<%if(this.get('yield')){%>Yield: <%@yield%><%}%>
		<%if(!this.get('watered')){%><div>thirsty</div><%}%>
	"""

class views.Field extends Backbone.View
	el: $ '#field'
	initialize: ->
		@$el = $(@el)
		_.bindAll @
		@collection.bind 'add', @appendItem
		@length = 0
		@el.id = @cid
		@render()
	events:
		expand: 'expand'
	appendItem: (crop)->
		item_view = new views[crop.constructor.name] model: crop
		item_view.collection = @collection
		@$el.append item_view.render().el
	expand: ->
		@collection.add new models.Plot
			
	render:->
		@$el.html '<div class="expand">Expand Garden</div>'
