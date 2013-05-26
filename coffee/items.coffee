#models
bb = Backbone
window.models ||= {}
window.collections ||= {}
window.views ||= {}
itemItter = 0
class models.Item extends bb.Model
	defaults:
		name: ''
		label: ''
		description: ''
		maxUses: 0 # ∞
		age: 0
		color: 'blue'
		maxAge: 0 # ∞
	initialize: ->
		init = @get 'initialize'
		if init
			init.call this


class models.Tool extends models.Item
	defaults:
		active: false
		targets: ''


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
		@listenTo time, 'change:hours', @render
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
		@$el = $ @el
		$(@el).addClass 'tool'
		@model.bind 'change:active', @changeActive
		@model.bind 'change:uses', @render
		$(@el).on 
			click: (e)=>
				@model.set(active:true) 
		@
	changeActive: ->
		if @model.get 'active'
			console.log(@model.get('name') + ' activated')
			#deactivate every item except this one
			for model in player.inventory.models
				model.set(active: false) if model.cid isnt @model.cid
			$(@el).addClass 'active'
			for key,val of @model.get 'actions'
				$(key).addClass 'targetable'
				#bind item actions to their targeted elements
				$d.on 'click.' + @cid, key, val.bind @model
		else
			for key of @model.get 'actions'
				$(key).removeClass 'targetable'
			$(@el).removeClass 'active'
			$d.off 'click.'+@cid
		
	render: ->
		$(@el).toggleClass 'active', @model.get 'active'
		super()

class collections.Inventory extends bb.Collection
	model: models.Item
	initialize: ->
		@view = new views.Inventory collection: this
		@bind 'add', @view.appendItem
		@addItem 'bed'
		@addItem 'well'
		@addTool 'wateringCan'
		@addTool 'shovel'
		@addTool 'zucciniSeeds'
		@view.render()
		@
	addItem: (name)->
		o = ITEMS[name]
		o.name = name
		model = new models.Item o
		@add model

	addTool: (name)->
		o = TOOLS[name]
		o.name = name
		@add new models.Tool o

class views.Inventory extends bb.View
	tagName: 'div'
	initialize: ->
		@$el = $ @el
		_.bindAll @
		@el.id = @cid
		@

		
	appendItem: (item)->
		item_view = new views[item.constructor.name] model: item
		@$el.append item_view.render().el

	render: ->
		$('#inventory').empty().append @el
		@el


itemItter = 0

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


