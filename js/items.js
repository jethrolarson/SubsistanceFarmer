(function() {
  var FOODS, ITEMS, Item, TOOLS, itemItter;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  ITEMS = {
    bed: {
      label: 'Bed',
      use: function() {
        game.message("You rest");
        return game.beforeDay();
      },
      events: {
        beforeTurn: function() {
          this.uses = game.player.energy;
          return this.maxUses = game.player.maxEnergy;
        }
      },
      color: 'green'
    }
  };

  itemItter = 0;

  Item = (function() {

    function Item(template) {
      var ev, h, k, v, _ref;
      this.id = itemItter;
      itemItter++;
      for (k in template) {
        v = template[k];
        this[k] = v;
      }
      if (!this.label) this.label = name;
      if (this.events) {
        _ref = this.events;
        for (ev in _ref) {
          h = _ref[ev];
          $d.on(ev, h.bind(this));
        }
      }
    }

    Item.prototype.age = 0;

    Item.prototype.color = 'blue';

    Item.prototype.maxAge = 0;

    Item.prototype.render = function() {
      return this.template(this);
    };

    Item.prototype.template = _.template("<div class=\"item <%#name%>\" data-itemid=\"<%=id%>\">\n	<div><%#label%></div>\n	<%#description%>\n	<%if(this.maxUses){%>\n		<%=game.meterTemplate({width:60, height: 5, bg: color, value: uses / maxUses})%>\n	<%}%>\n</div>");

    return Item;

  })();

  window.Item = function(name) {
    return new Item(ITEMS[name]);
  };

  $d.on('click', '.item', function() {
    return game.items[$(this).data('itemid')].use();
  });

  FOODS = {
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

  window.Food = (function() {

    __extends(Food, Item);

    Food.prototype.status = 'fresh';

    function Food(name) {
      Food.__super__.constructor.call(this, FOOD[name]);
      this;
    }

    Food.prototype.onDayStart = function() {
      var lastStatus;
      this.age += 1;
      lastStatus = this.status;
      if (this.age >= this.maxAge * .7) {
        this.status = 'wilted';
        if (lastStatus !== this.status) {
          return this.nutrition = this.nutrition * .7;
        }
      } else if (this.age >= this.maxAge * .9) {
        this.status = 'questionable';
        if (lastStatus !== this.status) {
          return this.nutrition = this.nutrition * .5;
        }
      } else if (this.age >= this.maxAge) {
        this.status = 'spoiled';
        return this.nutrition = -5;
      }
    };

    Food.prototype.template = _.template("<div class=\"item food action\" data-action=\"useitem\" data-actiondata='{\"id\":\"<%=id%>\"}'>\n	<h3><%=name%></h3>\n	<div class=\"status\"><%=status%></div>\n	<div class=\"nutrition\">Nutrition: <%=nutrition%></div>\n	<div class=\"protein\">Protein: <%=protein%></div>\n	<div class=\"calories\">Calories: <%=calories%></div>\n	<div class=\"description\"><%=description%></div>\n</div>");

    Food.prototype.render = function() {
      return this.template(this);
    };

    return Food;

  })();

  TOOLS = {
    wateringCan: {
      label: "Watering Can",
      actions: {
        '.crop': function(e) {
          var $target, crop;
          $target = $(e.target).closest('.crop');
          crop = game.field[$target.data('plotid')];
          if (this.uses <= 0) {
            game.message("I'm out of water, I'll need to gather some more", "warning");
          } else if (crop.water() && game.useEnergy(1)) {
            this.uses -= 1;
            game.endTurn();
            return true;
          }
          return false;
        },
        '.well': function() {
          if (game.useEnergy(1)) {
            this.uses = this.maxUses;
            return game.endTurn();
          }
        }
      },
      events: {
        activate: function() {
          return this.highlightTargetable();
        },
        gameRendered: function() {
          return this.highlightTargetable();
        }
      },
      highlightTargetable: function() {
        if (this.active) {
          $('.well').toggleClass('targetable', this.uses < this.maxUses);
          $('.crop.unwatered').toggleClass('targetable', this.uses);
          return true;
        }
      },
      uses: 0,
      maxUses: 5
    },
    shovel: {
      actions: {
        '.plot': 'expand'
      }
    }
  };

  window.Tool = (function() {

    __extends(Tool, Item);

    Tool.prototype.active = false;

    function Tool(name) {
      Tool.__super__.constructor.call(this, TOOLS[name]);
    }

    Tool.prototype.activate = function() {
      var k, v, _ref;
      if (this.active) return;
      this.active = true;
      _ref = this.actions;
      for (k in _ref) {
        v = _ref[k];
        $d.on('click.' + this.name, k, v.bind(this));
      }
      return $d.trigger('activate');
    };

    Tool.prototype.deactivate = function() {
      var k, v, _ref;
      if (!this.active) return;
      $(this.targets).removeClass('targetable');
      _ref = this.actions;
      for (k in _ref) {
        v = _ref[k];
        $d.off('click.' + this.name);
      }
      return this.active = false;
    };

    Tool.prototype.template = _.template("<div class=\"tool <%#name%> <%=this.active?'active':''%>\" data-itemid=\"<%=id%>\">\n	<div><%#label%></div>\n	<%#description%>\n	<%if(this.maxUses){%>\n		<%=game.meterTemplate({width:60, height: 5, bg: 'blue', value: uses / maxUses})%>\n	<%}%>\n</div>");

    return Tool;

  })();

  $d.on({
    click: function() {
      var $this;
      $('.tool.active').trigger('deactivate');
      $this = $(this).addClass('active');
      return game.items[$this.data('itemid')].activate();
    },
    deactivate: function() {
      var $this;
      $this = $(this).removeClass('active');
      return game.items[$this.data('itemid')].deactivate();
    }
  }, '.tool');

}).call(this);
