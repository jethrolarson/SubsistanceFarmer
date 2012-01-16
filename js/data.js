
  window.CROPS = {
    zuccini: {
      maxAge: 22,
      yieldAt: 10,
      maxHarvestSize: 4,
      thirst: 2,
      weather: 5,
      hardiness: 2
    }
  };

  window.ITEMS = {
    bed: {
      label: 'Bed',
      use: function() {
        game.message("You rest");
        return newGame.beforeDay();
      },
      events: {
        beforeTurn: function() {
          this.set({
            uses: player.get('calories')
          });
          this.set({
            maxUses: player.get('maxCalories')
          });
          return true;
        },
        rendered: function() {
          if (player.get('calories') < 3) {
            this.set({
              targetable: true
            });
          }
          return true;
        }
      },
      color: 'green'
    },
    well: {
      label: "Well",
      use: function() {
        return null;
      }
    }
  };

  window.FOODS = {
    zuccini: {
      maxAge: 14,
      calories: 25,
      protien: 1.5,
      nutrition: 5,
      description: "I can tell I'm going to get sick of these, but they're healthy."
    },
    cabbage: {
      maxAge: 28,
      calories: 8,
      protein: .5,
      nutrition: 5,
      description: "Surprisingly healthy for something that tastes like rubber."
    },
    tomato: {
      maxAge: 14,
      calories: 33,
      protein: 2,
      nutrition: 4.9,
      description: "Tasty, versitile, and good for you too."
    },
    potato: {
      maxAge: 40,
      calories: 160,
      protein: 4,
      nutrition: 4.0,
      description: "A great food for hard times."
    },
    apple: {
      maxAge: 36,
      calories: 95,
      protein: 0,
      nutrition: 2.7
    },
    venison: {
      maxAge: 7,
      calories: 130,
      protein: 24,
      nutrition: 2.6
    },
    chicken: {
      maxAge: 7,
      calories: 240,
      protein: 24,
      nutrition: 2.0
    }
  };

  window.TOOLS = {
    wateringCan: {
      label: "Watering Can",
      actions: {
        '.crop': function(e) {
          if (this.get('uses') <= 0) {
            game.message("I'm out of water, I'll need to gather some more", "warning");
          } else if (player.burnCalories(1)) {
            $(e.target).trigger('water');
            this.set({
              uses: this.get('uses') - 1
            });
            newGame.endTurn();
            return true;
          }
          return false;
        },
        '.well': function() {
          if (this.get('uses') < this.get('maxUses') && player.burnCalories(1)) {
            this.set({
              uses: this.get('maxUses')
            });
            return newGame.endTurn();
          }
        }
      },
      events: {
        activate: function() {
          return this.get('highlightTargetable')();
        },
        rendered: function() {
          return this.get('highlightTargetable')();
        }
      },
      highlightTargetable: function() {
        if (this.active) {
          $('.well').toggleClass('targetable', this.uses === 0);
          $('.crop.unwatered').toggleClass('targetable', this.uses);
          return true;
        }
      },
      uses: 0,
      maxUses: 5,
      color: 'blue'
    },
    shovel: {
      label: 'Shovel',
      actions: {
        '.expand': function(e) {
          if (player.burnCalories(3)) {
            $(e.target).trigger('expand');
            return newGame.endTurn();
          }
        }
      }
    },
    zucciniSeeds: {
      label: 'Zuccini Seeds',
      uses: 0,
      maxUses: 1,
      actions: {
        '.plot': function(e) {
          if (player.burnCalories(2)) {
            this.set({
              maxUses: 0
            });
            $(e.target).trigger('plant', 'zuccini');
            return newGame.endTurn();
          }
        }
      }
    }
  };
