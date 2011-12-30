ITEMS =
	bed:
		label: 'Bed'
		use: ->
			game.message "You rest"
			game.beforeDay()
		events:
			beforeTurn: ->#non-standard use of @uses
				@uses = game.player.energy
				@maxUses = game.player.maxEnergy
				true
			rendered: ->
				if game.player.energy < 3
					@get$().addClass 'targetable'
				true
		color: 'green'
	well:
		label: "Well"
		use: -> null
itemItter = 0
class window.Item
	constructor: (group, name)->
		@id = itemItter
		itemItter++
		if not name
			name = group
			group = ITEMS
		template = group[name]
		for k,v of template
			this[k] = v
		@label = name if not @label
		@name = name
		if @events
			for ev,h of @events
				$d.on ev, h.bind this
	age: 0
	color: 'blue'
	maxAge: 0 #0=∞
	render: -> @template @
	template: _.template """
		<div id="item_<%=id%>" class="item <%#name%>" data-itemid="<%=id%>">
			<div><%#label%></div>
			<%#description%>
			<%if(this.maxUses){%>
				<%=game.meterTemplate({width:60, height: 5, bg: color, value: uses / maxUses})%>
			<%}%>
		</div>
	"""
	get$: -> $ '#item_' + @id
 
$d.on 'click', '.item', ->
	game.items[$(this).data 'itemid'].use()

FOODS =
	#vegetables
	zuccini: #4oz
		maxAge: 14
		calories: 25
		protien: 1.5
		nutrition: 5
		description: "I can tell I'm going to get sick of these, but they're healthy."
	cabbage: #1 cup shreaded
		maxAge: 28
		calories: 8
		protein: .5
		nutrition: 5
		description: "Surprisingly healthy for something that tastes like rubber."
	tomato:
		maxAge: 14
		calories: 33
		protein: 2
		nutrition: 4.9
		description: "Tasty, versitile, and good for you too."
	potato: #1 medium
		maxAge: 40
		calories: 160
		protein: 4
		nutrition: 4.0
		description: "A great food for hard times."
	#fruit
	apple:
		maxAge: 36
		calories: 95
		protein: 0
		nutrition: 2.7
	#meats
	venison: #4oz
		maxAge: 7
		calories: 130
		protein: 24
		nutrition: 2.6
	chicken:#4oz
		maxAge: 7
		calories: 240
		protein: 24
		nutrition: 2.0

class window.Food extends Item
	status: 'fresh'
	constructor: (name)->
		super FOOD, name
		this

	onDayStart: ->
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

TOOLS =
	wateringCan:
		label: "Watering Can"
		actions: 
			'.crop': (e)->
				$target = $(e.target).closest '.crop'
				crop = game.field[$target.data 'plotid']
				if @uses <= 0
					game.message "I'm out of water, I'll need to gather some more", "warning"
				else if crop.water() and game.useEnergy 1
					@uses -= 1
					game.endTurn()
					return true
				return false
					
			'.well':->
				if game.useEnergy(1)
					@uses = @maxUses
					game.endTurn()
		events: 
			activate: -> @highlightTargetable()
			rendered: -> @highlightTargetable()
		highlightTargetable: ->
			if @active
				$('.well').toggleClass 'targetable', @uses is 0
				$('.crop.unwatered').toggleClass 'targetable', @uses
				true
		uses: 0
		maxUses: 5
	shovel:
		actions:
			'.plot': 'expand'
		
class window.Tool extends Item
	active: false
	constructor: (name)->
		super TOOLS,name
	activate: ->
		return if @active
		@active = true
		#bind actions
		for k,v of @actions
			$d.on 'click.' + @name, k, v.bind this
		$d.trigger 'activate'
	deactivate: ->
		return if not @active
		$(@targets).removeClass 'targetable'
		for k,v of @actions
			$d.off 'click.'+@name
		@active = false
	template: _.template """
		<div class="tool <%#name%> <%=this.active?'active':''%>" data-itemid="<%=id%>">
			<div><%#label%></div>
			<%#description%>
			<%if(this.maxUses){%>
				<%=game.meterTemplate({width:60, height: 5, bg: 'blue', value: uses / maxUses})%>
			<%}%>
		</div>
	"""
$d.on 
	click: ->
		$('.tool.active').trigger 'deactivate'
		$this = $(this).addClass 'active'
		game.items[$this.data 'itemid'].activate()
	deactivate: ->
		$this = $(this).removeClass 'active'
		game.items[$this.data 'itemid'].deactivate()
,'.tool'
