modifierTemplate = 
	name: 'my_modifier'
	_lasts: -1 #lasts forever. Time units which is days currently
	#maxHealth: -1

entityItter = 0
class Entity
	constructor: (state)->
		if typeof state is 'string'
			state = cache.getItem 'E_' + state
		@state = {}
		@state.key = state and state.key or entityItter++
		@state.props = state and state.props or {}
		@modifiers = state and state.modifiers or [] 
	getProp: (k)->
		prop = @state.props[k]
		for mod in @modifiers
			if mod[k]?
				if typeof mod[k] is 'number'
					prop += mod[k]
				else
					prop = mod[k]
		return prop
	getBaseProp: (k)-> @state.props[k]
	getProps: -> 
		props = {}
		for k,v of @state.props
			props[k] = @get k
		return props
	getBaseProps: -> @state.props
	addModifier: (mod)-> @modifiers.push mod
	removeModifier: (key)-> @modifiers.getItemByProp 'key', key
	save: ->
		state = @state
		for k,v of state
			if typeof v is 'object' and Object.getName(v) is 'Collection'
				state[k] = v.getKeyArray()
		cache.setItem 'E_' + (@key), @state

class EntityCollection
	constructor: (ar)->
		@ar = ar
	push: (item)-> Array::push.call @ar, item
	getLength: -> @ar.length
	get: (k)-> if k? then @ar[k] else @ar
	getKeyArray: ->
		ar = []
		ar.push(item.key) for item in @ar
		ar

# For arrays of objects
Array::getItemByProp = (prop, val)->
	for i in [0...@length]
		return @[i] if @[i][prop] is val