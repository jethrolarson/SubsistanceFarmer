(function() {
  var FOODS, Food, ITEMS, Item, TOOLS, Tool, itemItter;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  ITEMS = {};

  itemItter = 0;

  Item = (function() {

    function Item(template) {
      var k, v;
      this.id = itemItter;
      itemItter++;
      for (k in template) {
        v = template[k];
        this[k] = v;
      }
      if (!this.label) this.label = name;
    }

    Item.prototype.status = 'new';

    Item.prototype.age = 0;

    Item.prototype.maxAge = 0;

    return Item;

  })();

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

  Food = (function() {

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
      action: function() {}
    },
    shovel: {
      actions: {
        '.plot': 'expand'
      }
    }
  };

  Tool = (function() {

    __extends(Tool, Item);

    function Tool(name) {
      Tool.__super__.constructor.call(this, TOOLS[name]);
    }

    Tool.prototype.template = _.template("<div class=\"tool <%#name%>\">\n	<div><%#label%></div>\n	<%#description%>\n</div>");

    return Tool;

  })();

}).call(this);
