#coffee -o js/ -w -c coffee/
$player =  $ '#player'
$content = $ '#content'
$garden =  $ '#garden'
$toolbar = $ '#toolbar'
DAY_LENGTH = 12
BREAKFAST = DAY_LENGTH * .3
LUNCH = DAY_LENGTH * .5
DINNER = DAY_LENGTH * .8
game = 
	#TODO make this deterministic and store to localStorage
	day: 1
	time: 0
	previousTime: 0
	food: 90
	player:
		health: 10
		maxHealth: 10
		energy: 6
		maxEnergy: 6
		status: {}
		luck: 5
		fed: 2
		maxFed: 5 #4th meal is for quitters
		ate: 0 #0-5
	weather: 5 #0-10
	field: []
	items: []
	inventory:[]
	fieldsize: 0
	ammo: 40

	init: ()->
		@envokeEvent('intro')
		@beforeDay()
	
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

	useEnergy: (energy)->
		msg = if @player.energy > 0
			"This requires #{energy} energy and I only have #{@player.energy}. Should I cowboy up?"
		else 
			msg = "This requires #{energy} energy and I'm exhausted. Should I cowboy up?"
		if @player.energy - energy >= 0 || confirm msg
			@player.energy -= energy
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
	playerTemplate: _.template """
		<div>
			Time: <%=time%>
		</div>
		<div id="status">
			<%for(var i=0,len=player.status.length;i<len;i++){%>
				<span><%=player.status[i]%></span>
			<%}%>
		</div>
		<%=meterTemplate({name: "health: "+player.health+"/"+player.maxHealth, value: player.health / player.maxHealth , bg: "hsl(0,70%,40%)" })%>
		<div class="eat action" data-action="eat" title="Eat">
			<%=meterTemplate({name: "Fed: "+player.fed+"/"+player.maxFed, value: player.fed / player.maxFed, bg: "orange"})%>
		</div>
		
	"""
	renderPlayer: -> $player.html @playerTemplate this
	
	# Phase events
	#==============
	beforeDay: ->
		$d.trigger 'beforeDay'
		that = this

		#Roll for night event
		@time = 0
		if @player.status.exhausted
			@player.energy = Math.floor Math.max @player.maxEnergy + @player.energy, 2
			@message "You're still wiped from yesterday, better take it easy today.", "warning"
			@player.status.exhausted = false
		else
			@player.energy = @player.maxEnergy
		
		@field.forEach (plot)->
			plot.onDayStart(that)
		
		@beforeTurn()

	beforeTurn: ->
		$d.trigger 'beforeTurn'
		if (
			(@previousTime < BREAKFAST and @time >= BREAKFAST) or
			(@previousTime < LUNCH and @time >= LUNCH) or
			(@previousTime < DINNER and @time >= DINNER)
		)
			@fed -= 1
		if @player.fed is 0
			@envokeEvent 'hungry'
		if @player.energy is 0
			@envokeEvent 'tired'

		#roll for turn event

		#render player status
		@renderPlayer()

		#render field
		html = ''
		for i in [0...@field.length]
			html += @field[i].render()
		html += '<div class="expand action" data-action="expand">Expand Garden</div>'
		$garden.html html

		#render items
		html = ''
		for i in [0...@items.length]
			html += @items[i].render()
		$toolbar.html html
		$d.trigger 'gameRendered'
	endTurn: ->
		$d.trigger 'endTurn'
		if @player.energy < 0
			@player.status.exhausted = true
			dmg = Math.abs(@player.energy) ^ 2
			@player.health -= dmg
			@message "Working while exhausted cost you #{dmg} health", 'critical'
		if @player.fed is 0
			@player.energy -= 1

		if @player.health <= 0
			@envokeEvent 'death'
		log 'turn ended'
		@previousTime = @time
		@time += DAY_LENGTH / @player.maxEnergy
		@beforeTurn()
window.game = game
game.init()

# Player event bindings
$d.on('click touchstart','.action', ->
	$this = $ this
	actiondata = $this.data 'actiondata'
	game.performAction $this.data('action'), actiondata
)



