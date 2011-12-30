CROPS =
	zuccini:
		attr:
			maxAge: 22 #how many days crop will live
			yieldAt: 10 #when the crop will start yielding harvestable produce
			maxHarvestSize: 4 #how many units the crop can hold at one time 
			thirst: 2 #water/day
			weather: 5 #preferred weather
			hardiness: 2 #how resistant to weather the plant is

plotItter = 0
class Plot
	constructor: ->
		@id = plotItter
		plotItter += 1
	onDayStart: -> true
	render: -> """<div class="plot action" data-action="plant" data-actiondata='{"id":"#{@id}"}'>Plant</div>"""
class Crop extends Plot
	constructor: (name, plot)->
		@id = plot.id
		crop = CROPS[name]
		for k,v of crop
			this[k] = v
		@name = name
		@prop = 
			age: 0
			watered: false
			yield: 0
			harvestSize: 0
			happiness: @MAX_HAPPINESS
			growth: 0
		@
	attr: #base attributes
		maxAge: 20
		weather: 4
		yieldAt: 15
		name: "Unnamed crop"
	MAX_HAPPINESS: 9
	MAX_GROWTH: 9
	GROW_THRESHOLD: 7
	DIE_THRESHOLD: 5
	GROWTH_PER_DAY: 1
	mods:[]#examples: cold weather sheeting, root insulation, fertilizers
	onDayStart: (game)->
		if @prop.watered && Math.abs(@attr.weather - game.weather) < 2
			@prop.happiness+=1
		else
			@prop.happiness -= 1
		@prop.happiness = @prop.happiness.constrain 0, @MAX_HAPPINESS

		if @prop.happiness >= @GROW_THRESHOLD and @prop.age < @attr.maxAge
			@prop.growth += @GROWTH_PER_DAY
		if @prop.happiness <= @DIE_THRESHOLD or @prop.age >= @attr.maxAge
			@prop.growth -= @GROWTH_PER_DAY
		###
		When plants are at low health they take damage to one of their core attributes
		###

		#progress
		@prop.age +=1
		if @prop.age >= @attr.yieldAt
			@prop.yield += Math.round (@prop.happiness - 5) / 2
		@prop.watered = false

	water: ()->
		if not @prop.watered
			@prop.watered = true
			return true
		return false

	render: ->
		@template this

	getAttr: (k)->
		#TODO merge crop attrs with modifiers and return current value
		this.attr[k]
	template: _.template """
		<div id="crop_<%=id%>" class="crop happiness_<%=prop.happiness%> <%if(!prop.watered){%>unwatered<%}%>" data-plotid="<%=id%>">
			<div><b><%=name%></b></div>
			<%=game.meterTemplate({width:80, height: 5, value: prop.age / getAttr("maxAge")})%>
			<div>Growth: <%=prop.growth%></div>
			<%=game.meterTemplate({width:80, height: 5, bg: 'yellow', value: prop.happiness / MAX_HAPPINESS})%>
			<%if(prop.yield){%>Yield: <%=prop.yield%><%}%>
			<%if(!prop.watered){%><div>thirsty</div><%}%>
		</div>
	"""

window.Plot = Plot
window.Crop = Crop