#models
bb = Backbone
window.models ||= {}
window.collections ||= {}
window.views ||= {}
itemItter = 0
class models.Item extends bb.Model
	defaults:
		id: 0
		name: ''
		label: ''
		description: ''
		maxUses: 0 # ∞
		age: 0
		color: 'blue'
		maxAge: 0 # ∞
	initialize: ->
		if @get 'events'
			for ev,h of @get 'events'
				$d.on ev, h.bind this

class models.Tool extends models.Item
	defaults:
		active: false
		targets: ''

class collections.Inventory extends bb.Collection
	model: models.Item
	addItem: (name)->
		o = ITEMS[name]
		o.name = name
		@add new models.Item o
	addTool: (name)->
		o = TOOLS[name]
		o.name = name
		@add new models.Tool o
#views
class views.Item extends bb.View
	tagName: 'div'
	initialize: ->
		_.bindAll @
		@model.bind 'change:targetable', =>
			$(@el).toggleClass('targetable',@model.get 'targetable')
		$(@el).attr 
			id: 'item_'+ @model.cid
			'data-itemid': @model.get 'id'
			'class': 'item '+@model.get 'name'
		$d.on 'beforeTurn', @render
		if @model.get 'use'
			$(@el).on click: @model.get 'use'
	render: ->
		$(@el).html @template @model
		@
	template: _.template """
		<div><%@label%></div>
		<%@description%>
		<%if(this.get('maxUses')){%>
			<%=game.meterTemplate({width:60, height: 5, bg: this.get('color'), value: this.get('uses') / this.get('maxUses')})%>
		<%}%>
	"""

class views.Tool extends views.Item
	initialize:->
		super()
		$(@el).addClass 'tool'
		@model.bind 'change:active', @changeActive
		@model.bind 'change:uses', @render
		$(@el).on 
			click: (e)=>
				@model.set(active:true) if not e.isDefaultPrevented()
		@
	changeActive: ->
		if @model.get 'active'
			#deactivate every item except this one
			for model in player.inventory.models
				model.set(active: false) if model.cid isnt @model.cid
			$(@el).addClass 'active'
			for key,val of @model.get 'actions'
				$(key).addClass 'targetable'
				$d.on 'click.' + @cid, key, val.bind @model
		else
			for key of @model.get 'actions'
				$(key).removeClass 'targetable'
			$(@el).removeClass 'active'
			$d.off 'click.'+@cid
		
	render: ->
		$(@el).toggleClass 'active', @model.get 'active'
		super()

class views.Inventory extends bb.View
	tagName: 'div'
	initialize: ->
		_.bindAll @
		@el.id = @cid
		@collection.bind 'add', @appendItem
		@collection.addItem 'bed'
		@collection.addItem 'well'
		@collection.addTool 'wateringCan'
		@collection.addTool 'shovel'
		@collection.addTool 'zucciniSeeds'
	appendItem: (item)->
		item_view = new views[item.constructor.name] model: item
		$(@el).append item_view.render().el
	render: ->
		@


itemItter = 0

class window.Food 
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

