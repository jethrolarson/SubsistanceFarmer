window.CROPS =
	zuccini:
		maxAge: 22 #how many days crop will live
		yieldAt: 10 #when the crop will start yielding harvestable produce
		maxHarvestSize: 4 #how many units the crop can hold at one time 
		thirst: 2 #water/day
		weather: 5 #preferred weather
		hardiness: 2 #how resistant to weather the plant is

window.ITEMS =
	bed:
		label: 'Bed'
		use: ->
			game.message "You rest"
			newGame.beforeDay()
		events:
			beforeTurn: ->#non-standard use of @uses
				@set uses: player.get 'calories'
				@set maxUses: player.get 'maxCalories'
				true
			rendered: ->
				if player.get('calories') < 3
					@set targetable: true
				true
		color: 'green'
	well:
		label: "Well"
		use: -> null

window.FOODS =
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

window.TOOLS =
	wateringCan:
		label: "Watering Can"
		actions: 
			'.crop': (e)->
				if @get('uses') <= 0
					game.message "I'm out of water, I'll need to gather some more", "warning"
				else if player.burnCalories 1
					$(e.target).trigger 'water'
					@set uses: @get('uses') - 1
					newGame.endTurn()
					return true
				return false
					
			'.well':->
				if @get('uses') < @get('maxUses') and player.burnCalories(1)
					@set uses: @get 'maxUses'
					newGame.endTurn()
		events: 
			activate: -> @get('highlightTargetable')()
			rendered: -> @get('highlightTargetable')()
		highlightTargetable: ->
			if @active
				$('.well').toggleClass 'targetable', @uses is 0
				$('.crop.unwatered').toggleClass 'targetable', @uses
				true
		uses: 0
		maxUses: 5
		color: 'blue'
	shovel:
		label: 'Shovel'
		actions:
			'.expand': (e)->
				if player.burnCalories(3)
					$(e.target).trigger 'expand'
					newGame.endTurn()
	zucciniSeeds:
		label: 'Zuccini Seeds'
		uses: 0
		maxUses: 1
		actions: 
			'.plot': (e)->
				if player.burnCalories(2)
					@set maxUses: 0
					$(e.target).trigger('plant','zuccini')
					newGame.endTurn()
