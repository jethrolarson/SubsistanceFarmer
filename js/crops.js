(function() {
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  window.models || (window.models = {});

  window.views || (window.views = {});

  models.Plot = (function() {

    __extends(Plot, Backbone.Model);

    function Plot() {
      Plot.__super__.constructor.apply(this, arguments);
    }

    return Plot;

  })();

  models.Crop = (function() {

    __extends(Crop, Backbone.Model);

    function Crop() {
      Crop.__super__.constructor.apply(this, arguments);
    }

    Crop.prototype.MAX_HAPPINESS = 9;

    Crop.prototype.MAX_GROWTH = 9;

    Crop.prototype.GROW_THRESHOLD = 7;

    Crop.prototype.DIE_THRESHOLD = 5;

    Crop.prototype.GROWTH_PER_DAY = 1;

    Crop.prototype.defaults = {
      maxAge: 22,
      yieldAt: 10,
      maxHarvestSize: 4,
      thirst: 2,
      weather: 5,
      hardiness: 2,
      age: 0,
      watered: false,
      yield: 0,
      harvestSize: 0,
      happiness: 0,
      growth: 0
    };

    Crop.prototype.initialize = function() {
      this.happiness = this.MAX_HAPPINESS;
      this.mods = new Backbone.Collection;
      return $d.on({
        onDayStart: this.onDayStart
      });
    };

    Crop.prototype.onDayStart = function() {
      this.set({
        happiness: this.get('happiness') + (this.get('watered') && Math.abs(this.get('weather') - newGame.weather) < 2 ? +1 : -1)
      }, {
        silent: true
      });
      this.set({
        happiness: this.get('happiness').constrain(0, this.MAX_HAPPINESS)
      }, {
        silent: true
      });
      if (this.get('happiness') >= this.GROW_THRESHOLD && this.get('age') < this.get('maxAge')) {
        this.set({
          growth: this.get('growth') + this.GROWTH_PER_DAY
        }, {
          silent: true
        });
      }
      if (this.get('happiness') <= this.DIE_THRESHOLD || this.get('age') >= this.get('maxAge')) {
        this.set({
          growth: this.get('growth') - this.GROWTH_PER_DAY
        }, {
          silent: true
        });
      }
      /*
      		TODO When plants are at low health they take damage to one of their core attributes
      */
      this.set({
        age: this.get('age') + 1
      });
      if (this.get('age') >= this.get('yieldAt')) {
        this.set({
          'yield': this.get('yield') + Math.round((this.get('happiness') - 5) / 2)
        }, {
          silent: true
        });
      }
      this.set({
        watered: false
      }, {
        silent: true
      });
      return this.change();
    };

    Crop.prototype.water = function() {
      if (!this.prop.watered) {
        this.prop.watered = true;
        return true;
      }
      return false;
    };

    return Crop;

  })();

  views.Plot = (function() {

    __extends(Plot, Backbone.View);

    function Plot() {
      Plot.__super__.constructor.apply(this, arguments);
    }

    Plot.prototype.tagName = 'div';

    Plot.prototype.initialize = function() {
      var _this = this;
      this.model.bind('remove', function() {
        return $(_this.el).remove();
      });
      this.el.id = this.cid;
      return $(this.el).on({
        plant: function(e, plantType) {
          var crop, i, _len, _ref;
          _ref = _this.collection.models;
          for (i = 0, _len = _ref.length; i < _len; i++) {
            crop = _ref[i];
            if (crop.cid = _this.model.cid) break;
          }
          _this.collection.remove(_this.collection.at(i));
          return _this.collection.add(new models.Crop(CROPS[plantType]), {
            at: i
          });
        }
      });
    };

    Plot.prototype.render = function() {
      $(this.el).html("<div class=\"plot\" id=\"" + this.cid + "\">Plot</div>");
      return this;
    };

    return Plot;

  })();

  views.Crop = (function() {

    __extends(Crop, Backbone.View);

    function Crop() {
      Crop.__super__.constructor.apply(this, arguments);
    }

    Crop.prototype.tagName = 'div';

    Crop.prototype.initialize = function() {
      _.bindAll(this);
      $(this.el).attr({
        id: this.cid,
        'class': 'crop'
      }).on({
        water: this.water
      });
      $d.on({
        onDayStart: this.render
      });
      return this.render();
    };

    Crop.prototype.render = function() {
      $(this.el).toggleClass('unwatered', !this.model.get('watered'));
      $(this.el).html(this.template(this.model));
      return this;
    };

    Crop.prototype.water = function() {
      this.model.set({
        watered: true
      });
      return this.render();
    };

    Crop.prototype.template = _.template("<div><b><%@name%></b></div>\n<%=game.meterTemplate({width:80, height: 5, value: this.get('age') / this.get(\"maxAge\")})%>\n<div>Growth: <%@growth%></div>\n<%=game.meterTemplate({width:80, height: 5, bg: 'yellow', value: this.get('happiness') / this.MAX_HAPPINESS})%>\n<%if(this.get('yield')){%>Yield: <%@yield%><%}%>\n<%if(!this.get('watered')){%><div>thirsty</div><%}%>");

    return Crop;

  })();

  views.Field = (function() {

    __extends(Field, Backbone.View);

    function Field() {
      Field.__super__.constructor.apply(this, arguments);
    }

    Field.prototype.el = $('#field');

    Field.prototype.initialize = function() {
      _.bindAll(this);
      this.collection.bind('add', this.appendItem);
      this.length = 0;
      this.render();
      return $(this.el).attr({
        id: this.cid
      }).on({
        click: this.expand
      }, '.expand');
    };

    Field.prototype.appendItem = function(crop) {
      var item_view;
      item_view = new views[crop.constructor.name]({
        model: crop
      });
      item_view.collection = this.collection;
      return $(this.el).append(item_view.render().el);
    };

    Field.prototype.expand = function() {
      if (player.burnCalories(3)) {
        this.collection.add(new models.Plot);
        return newGame.endTurn();
      }
    };

    Field.prototype.render = function() {
      return $(this.el).html('<div class="expand">Expand Garden</div>');
    };

    return Field;

  })();

}).call(this);
