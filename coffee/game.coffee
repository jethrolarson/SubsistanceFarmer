#coffee --map -o js/ -w -c coffee/
window.models = {}
window.collections = {}
window.views = {}
$player =  $ '#player'
$content = $ '#content'
$garden =  $ '#garden'
$toolbar = $ '#toolbar'
DAY_LENGTH = 24
BREAKFAST = DAY_LENGTH * .3
LUNCH = DAY_LENGTH * .5
DINNER = DAY_LENGTH * .8

class models.Player extends Backbone.Model
	defaults:
		health: 10
		maxHealth: 10
		calories: 6
		maxCalories: 6
		status: {}
		luck: 5
		fed: 80
		maxFed: 100 #4th meal is for quitters
		ate: 0 #0-5
	initialize: ->
		console.log 'model Player init'
		@inventory = new collections.Inventory()
		@listenTo time, 'change:hours', @onStep
		@listenTo time, 'dawn', @onDay
		@on 'change:fed', @onFedChange

		#render player status
		@view = new views.Player model: this
		@view.render()
	onStep: ->
		@set fed: @get('fed') - 1

	onFedChange: ->
		if @get('fed') is 0
			game.envokeEvent 'hungry'
	
	onDay: ->
		status = @get('status')
		if status.exhausted
			@set
				calories: Math.floor Math.max @get('maxCalories') + @get('calories'), 2
			game.message "You're still wiped from yesterday, better take it easy today.", "warning"
			status.exhausted = false
		else
			@set calories: @get 'maxCalories'
			game.message "I feel a lot better today"
			
	burnCalories: (calories)->
		msg = if @get('calories') > 0
			"This requires #{calories} calories and I only have #{@get('calories')}. Should I cowboy up?"
		else 
			msg = "This requires #{calories} calories and I'm exhausted. Should I cowboy up?"
		if @get('calories') - calories >= 0 || confirm msg
			newCals = @get('calories') - calories
			@set calories: newCals
			if newCals is 0
				game.envokeEvent 'tired'
			return true
		return false

	work: (hours=1)->
		time.addTime(hours)

		if @get('calories') < 0
			@get('status').exhausted = true
			dmg = Math.abs(@get('calories')) ^ 2
			@set health: @get('health') - dmg
			game.message "Working while exhausted cost you #{dmg} health", 'critical'
		
		#working while hungry makes you even more tired
		if @fed is 0
			@set calories: @get('calories') - 1

		if @get('health') <= 0
			game.envokeEvent 'death'

class views.Player extends Backbone.View
	el: $ '#player'
	initialize: ->
		console.log 'view Player init'
		@listenTo time, 'change:hours', @render
		@model.on 'change', @render.bind this
	render: ->
		console.log 'render player'
		$(@el).html @template @model
	template: _.template """
		<div>
			<%=time.get('hours')%>:00 Day<%=time.get('day')%>
		</div>
		<div id="status">
			<%for(var i=0,len=this.get('status').length;i<len;i++){%>
				<span><%=this.get('status')[i]%></span>
			<%}%>
		</div>
		<%=game.meterTemplate({name: "calories: "+this.get('calories')+"/"+this.get('maxCalories'), value: this.get('calories') / this.get('maxCalories') , bg: "hsl(90,70%,40%)" })%>
		<%=game.meterTemplate({name: "health: "+this.get('health')+"/"+this.get('maxHealth'), value: this.get('health') / this.get('maxHealth') , bg: "hsl(0,70%,40%)" })%>
		<div class="eat action" data-action="eat" title="Eat">
			<%=game.meterTemplate({name: "Fed: "+this.get('fed')+"/"+this.get('maxFed'), value: this.get('fed') / this.get('maxFed'), bg: "orange"})%>
		</div>
		
	"""
#FIXME incomplete
phases =
	'midnight': 0
	'dawn':     6
	'midday':   12
	'dusk':     18
	'night':    21
phaseTimes = _.invert phases

class models.Time extends Backbone.Model
	
	defaults:
		hours: 6
		previousTime: 0
		day: 1
		
	sleep: ->
		while @get('hours') != phases.dawn
			@step()
	addTime: (h)->
		while h
			@step()
			h -= 1
		
	step: ->
		hours = @get('hours') + 1
		
		if hours is DAY_LENGTH
			@set day: @get('day') + 1
			hours = 0
		@set hours: hours
		if phaseTimes[hours]
			@trigger phaseTimes[hours]


		




class models.Game extends Backbone.Model
	defaults:
		#TODO make this deterministic and store to localStorage
		food: 90
		weather: 5 #0-10
		
	start: ->
		console.log 'model Game init'
		window.time = new models.Time
		@player = new models.Player
		window.player = @player
		@field = new Backbone.Collection
		new views.Game model: this
		@listenTo time, phases.dawn, @beforeDay
		@envokeEvent('intro')
	# Phase events
	#==============

	message: (msg, className)->
		className ||= ''
		$content.append """<div class="#{className}">#{msg}</div>"""
		$content.animate({scrollTop: $content[0].scrollHeight},500)

	envokeEvent: (k,data)->
		data ||= {}
		if not window.events[k] 
			@message "Action #{k} not defined"
		else if window.events[k].call this, data
			log "Event: #{k} evoked"
			return true
		return false

	burnCalories: (calories)->
		msg = if @player.calories > 0
			"This requires #{calories} calories and I only have #{@player.calories}. Should I cowboy up?"
		else 
			msg = "This requires #{calories} calories and I'm exhausted. Should I cowboy up?"
		if @player.calories - calories >= 0 || confirm msg
			@player.calories -= calories
			return true
		return false

	meterTemplate: _.template """
		<% var meterWidth = this.width || 150, meterHeight = this.height || 25;%>
		<div class="meter" style="width: <%=meterWidth%>px; height: <%=meterHeight%>px">
			<em style="line-height: <%=meterHeight%>px; width: <%=meterWidth%>"><%=name%></em>
			<span style="height: <%=meterHeight%>px; <%if(this.bg){%>background-color: <%=bg%>;<%}%>width: <%=value*meterWidth%>px"></span>
		</div>
	"""

class views.Game extends Backbone.View
	initialize: ->
		console.log 'view Game init'
		@fieldView = new views.Field collection: @model.field
		
	render: -> @




$ ->
	window.game = new models.Game
	game.start()

