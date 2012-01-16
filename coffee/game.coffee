#coffee -o js/ -w -c coffee/
models ||= {}
views ||= {}
collections ||= {}
$player =  $ '#player'
$content = $ '#content'
$garden =  $ '#garden'
$toolbar = $ '#toolbar'
DAY_LENGTH = 12
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
		fed: 2
		maxFed: 5 #4th meal is for quitters
		ate: 0 #0-5
	initialize: ->
		console.log 'model Player init'
		@inventory = new collections.Inventory() 
	burnCalories: (calories)->
		msg = if @get('calories') > 0
			"This requires #{calories} calories and I only have #{@get('calories')}. Should I cowboy up?"
		else 
			msg = "This requires #{calories} calories and I'm exhausted. Should I cowboy up?"
		if @get('calories') - calories >= 0 || confirm msg
			@set calories: @get('calories') -  calories
			return true
		return false

class views.Player extends Backbone.View
	el: $ '#player'
	initialize: ->
		console.log 'view Player init'
		@inventoryView = new views.Inventory collection: @model.inventory
		$('#inventory').html @inventoryView.render().el
	render: ->
		console.log 'render player'
		$(@el).html @template @model
	template: _.template """
		<div>
			Time: <%=window.newGame.get('time')%>
		</div>
		<div id="status">
			<%for(var i=0,len=this.get('status').length;i<len;i++){%>
				<span><%=this.get('status')[i]%></span>
			<%}%>
		</div>
		<%=game.meterTemplate({name: "health: "+this.get('health')+"/"+this.get('maxHealth'), value: this.get('health') / this.get('maxHealth') , bg: "hsl(0,70%,40%)" })%>
		<div class="eat action" data-action="eat" title="Eat">
			<%=game.meterTemplate({name: "Fed: "+this.get('fed')+"/"+this.get('maxFed'), value: this.get('fed') / this.get('maxFed'), bg: "orange"})%>
		</div>
		
	"""

class models.Game extends Backbone.Model
	defaults:
		#TODO make this deterministic and store to localStorage
		day: 1
		time: 0
		previousTime: 0
		food: 90
		weather: 5 #0-10
	initialize:->
		console.log 'model Game init'
		@player = new models.Player
		window.player = @player
		@playerView = new views.Player model: @player
		@field = new Backbone.Collection
	
	# Phase events
	#==============
	beforeDay: ->
		$d.trigger 'beforeDay'
		that = this

		#Roll for night event
		@time = 0
		status = @player.get('status')
		if status.exhausted
			@player.set
				calories: Math.floor Math.max @player.get('maxCalories') + @player.get('calories'), 2
			@message "You're still wiped from yesterday, better take it easy today.", "warning"
			status.exhausted = false
		else
			@player.set calories: @player.get 'maxCalories'
		
		@field.forEach (plot)->
			plot.onDayStart(that)
		
		@beforeTurn()

	beforeTurn: ->
		$d.trigger 'beforeTurn'
		console.log 'before turn'
		if (
			(@get('previousTime') < BREAKFAST and @get('time') >= BREAKFAST) or
			(@get('previousTime') < LUNCH and @get('time') >= LUNCH) or
			(@get('previousTime') < DINNER and @get('time') >= DINNER)
		)
			@fed -= 1
		if @player.get('fed') is 0
			game.envokeEvent 'hungry'
		if @player.get('calories') is 0
			game.envokeEvent 'tired'

		#roll for turn event

		#render player status
		@playerView.render()
		$d.trigger 'rendered'

	endTurn: ->
		$d.trigger 'endTurn'
		console.log 'end turn'
		if @player.get('calories') < 0
			@player.get('status').exhausted = true
			dmg = Math.abs(@player.get('calories')) ^ 2
			@player.set health: @player.get('health') - dmg
			@message "Working while exhausted cost you #{dmg} health", 'critical'
		if @player.fed is 0
			@player.set calories: @player.get('calories') - 1

		if @player.get('health') <= 0
			game.envokeEvent 'death'
		log 'turn ended'
		@set previousTime: @get 'time'
		@set time: @get('time') + DAY_LENGTH / @player.get('maxCalories')
		@beforeTurn()
class views.Game extends Backbone.View
	initialize: ->
		console.log 'view Game init'
		@fieldView = new views.Field collection: @model.field
		@model.beforeDay()
		game.envokeEvent('intro')
	render: -> @
		


game = 

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
	performAction: (k,data)->
		data ||= {}
		if window.actions[k] 
			if window.actions[k].call this, data
				log "Action: #{k} performed"
				@endTurn()
				true
			else false
		else
			@message "Action #{k} not defined", 'warning'
			false

	meterTemplate: _.template """
		<% var meterWidth = this.width || 150, meterHeight = this.height || 25;%>
		<div class="meter" style="width: <%=meterWidth%>px; height: <%=meterHeight%>px">
			<em style="line-height: <%=meterHeight%>px; width: <%=meterWidth%>"><%=name%></em>
			<span style="height: <%=meterHeight%>px; <%if(this.bg){%>background-color: <%=bg%>;<%}%>width: <%=value*meterWidth%>px"></span>
		</div>
	"""
	
window.game = game

# Player event bindings
$d.on('click touchstart','.action', ->
	$this = $ this
	actiondata = $this.data 'actiondata'
	game.performAction $this.data('action'), actiondata
)



window.newGame = new models.Game
gameView = new views.Game model: newGame
