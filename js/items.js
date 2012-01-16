(function() {
  var bb, itemItter;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  bb = Backbone;

  window.models || (window.models = {});

  window.collections || (window.collections = {});

  window.views || (window.views = {});

  itemItter = 0;

  models.Item = (function() {

    __extends(Item, bb.Model);

    function Item() {
      Item.__super__.constructor.apply(this, arguments);
    }

    Item.prototype.defaults = {
      id: 0,
      name: '',
      label: '',
      description: '',
      maxUses: 0,
      age: 0,
      color: 'blue',
      maxAge: 0
    };

    Item.prototype.initialize = function() {
      var ev, h, _ref, _results;
      if (this.get('events')) {
        _ref = this.get('events');
        _results = [];
        for (ev in _ref) {
          h = _ref[ev];
          _results.push($d.on(ev, h.bind(this)));
        }
        return _results;
      }
    };

    return Item;

  })();

  models.Tool = (function() {

    __extends(Tool, models.Item);

    function Tool() {
      Tool.__super__.constructor.apply(this, arguments);
    }

    Tool.prototype.defaults = {
      active: false,
      targets: ''
    };

    return Tool;

  })();

  collections.Inventory = (function() {

    __extends(Inventory, bb.Collection);

    function Inventory() {
      Inventory.__super__.constructor.apply(this, arguments);
    }

    Inventory.prototype.model = models.Item;

    Inventory.prototype.addItem = function(name) {
      var o;
      o = ITEMS[name];
      o.name = name;
      return this.add(new models.Item(o));
    };

    Inventory.prototype.addTool = function(name) {
      var o;
      o = TOOLS[name];
      o.name = name;
      return this.add(new models.Tool(o));
    };

    return Inventory;

  })();

  views.Item = (function() {

    __extends(Item, bb.View);

    function Item() {
      Item.__super__.constructor.apply(this, arguments);
    }

    Item.prototype.tagName = 'div';

    Item.prototype.initialize = function() {
      var _this = this;
      _.bindAll(this);
      this.model.bind('change:targetable', function() {
        return $(_this.el).toggleClass('targetable', _this.model.get('targetable'));
      });
      $(this.el).attr({
        id: 'item_' + this.model.cid,
        'data-itemid': this.model.get('id'),
        'class': 'item ' + this.model.get('name')
      });
      $d.on('beforeTurn', this.render);
      if (this.model.get('use')) {
        return $(this.el).on({
          click: this.model.get('use')
        });
      }
    };

    Item.prototype.render = function() {
      $(this.el).html(this.template(this.model));
      return this;
    };

    Item.prototype.template = _.template("<div><%@label%></div>\n<%@description%>\n<%if(this.get('maxUses')){%>\n	<%=game.meterTemplate({width:60, height: 5, bg: this.get('color'), value: this.get('uses') / this.get('maxUses')})%>\n<%}%>");

    return Item;

  })();

  views.Tool = (function() {

    __extends(Tool, views.Item);

    function Tool() {
      Tool.__super__.constructor.apply(this, arguments);
    }

    Tool.prototype.initialize = function() {
      var _this = this;
      Tool.__super__.initialize.call(this);
      $(this.el).addClass('tool');
      this.model.bind('change:active', this.changeActive);
      this.model.bind('change:uses', this.render);
      $(this.el).on({
        click: function(e) {
          if (!e.isDefaultPrevented()) {
            return _this.model.set({
              active: true
            });
          }
        }
      });
      return this;
    };

    Tool.prototype.changeActive = function() {
      var key, model, val, _i, _len, _ref, _ref2, _results;
      if (this.model.get('active')) {
        _ref = player.inventory.models;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          model = _ref[_i];
          if (model.cid !== this.model.cid) {
            model.set({
              active: false
            });
          }
        }
        $(this.el).addClass('active');
        _ref2 = this.model.get('actions');
        _results = [];
        for (key in _ref2) {
          val = _ref2[key];
          $(key).addClass('targetable');
          _results.push($d.on('click.' + this.cid, key, val.bind(this.model)));
        }
        return _results;
      } else {
        for (key in this.model.get('actions')) {
          $(key).removeClass('targetable');
        }
        $(this.el).removeClass('active');
        return $d.off('click.' + this.cid);
      }
    };

    Tool.prototype.render = function() {
      $(this.el).toggleClass('active', this.model.get('active'));
      return Tool.__super__.render.call(this);
    };

    return Tool;

  })();

  views.Inventory = (function() {

    __extends(Inventory, bb.View);

    function Inventory() {
      Inventory.__super__.constructor.apply(this, arguments);
    }

    Inventory.prototype.tagName = 'div';

    Inventory.prototype.initialize = function() {
      _.bindAll(this);
      this.el.id = this.cid;
      this.collection.bind('add', this.appendItem);
      this.collection.addItem('bed');
      this.collection.addItem('well');
      this.collection.addTool('wateringCan');
      this.collection.addTool('shovel');
      return this.collection.addTool('zucciniSeeds');
    };

    Inventory.prototype.appendItem = function(item) {
      var item_view;
      item_view = new views[item.constructor.name]({
        model: item
      });
      return $(this.el).append(item_view.render().el);
    };

    Inventory.prototype.render = function() {
      return this;
    };

    return Inventory;

  })();

  itemItter = 0;

  window.Food = (function() {

    Food.prototype.status = 'fresh';

    function Food(name) {
      Food.__super__.constructor.call(this, FOOD, name);
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

}).call(this);
