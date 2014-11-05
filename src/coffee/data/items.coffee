module.exports =
    bed:
        label: 'Bed'
        use: ->
            game.message "You rest"
            game.time.sleep()
        initialize:->
            @listenTo game.time,'change:hours', ->
                if player.get('calories') < 3
                    @set targetable: true
                true
        color: 'green'
    well:
        label: "Well"