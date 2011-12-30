window.actions =
	plant: (data)->
		if @useEnergy 1
			name = 'zuccini'
			@field[data.id] = new Crop name, @field[data.id]
			return true
		else false
	expand: ->
		if @useEnergy 3
			@field.push new Plot()
			return true
		else false
		
	getWater: ->
		@water = @maxWater if @useEnergy 1