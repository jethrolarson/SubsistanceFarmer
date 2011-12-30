(function() {
  var CROPS, Crop, Plot, plotItter;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  CROPS = {
    zuccini: {
      attr: {
        maxAge: 22,
        yieldAt: 10,
        maxHarvestSize: 4,
        thirst: 2,
        weather: 5,
        hardiness: 2
      }
    }
  };

  plotItter = 0;

  Plot = (function() {

    function Plot() {
      this.id = plotItter;
      plotItter += 1;
    }

    Plot.prototype.onDayStart = function() {
      return true;
    };

    Plot.prototype.render = function() {
      return "<div class=\"plot action\" data-action=\"plant\" data-actiondata='{\"id\":\"" + this.id + "\"}'>Plant</div>";
    };

    return Plot;

  })();

  Crop = (function() {

    __extends(Crop, Plot);

    function Crop(name, plot) {
      var crop, k, v;
      this.id = plot.id;
      crop = CROPS[name];
      for (k in crop) {
        v = crop[k];
        this[k] = v;
      }
      this.name = name;
      this.prop = {
        age: 0,
        watered: false,
        yield: 0,
        harvestSize: 0,
        happiness: this.MAX_HAPPINESS,
        growth: 0
      };
      this;
    }

    Crop.prototype.attr = {
      maxAge: 20,
      weather: 4,
      yieldAt: 15,
      maxYield: 18,
      name: "Unnamed crop"
    };

    Crop.prototype.MAX_HAPPINESS = 9;

    Crop.prototype.MAX_GROWTH = 9;

    Crop.prototype.GROW_THRESHOLD = 7;

    Crop.prototype.DIE_THRESHOLD = 5;

    Crop.prototype.GROWTH_PER_DAY = 1;

    Crop.prototype.mods = [];

    Crop.prototype.onDayStart = function(game) {
      if (this.prop.watered && Math.abs(this.attr.weather - game.weather) < 2) {
        this.prop.happiness += 1;
      } else {
        this.prop.happiness -= 1;
      }
      this.prop.happiness = this.prop.happiness.constrain(0, this.MAX_HAPPINESS);
      if (this.prop.happiness >= this.GROW_THRESHOLD && this.prop.age < this.attr.maxAge) {
        this.prop.growth += this.GROWTH_PER_DAY;
      }
      if (this.prop.happiness <= this.DIE_THRESHOLD || this.prop.age >= this.attr.maxAge) {
        this.prop.growth -= this.GROWTH_PER_DAY;
      }
      /*
      		When plants are at low health they take damage to one of their core attributes
      */
      this.prop.age += 1;
      if (this.prop.age >= this.attr.yieldAt) {
        this.yield += Math.round((this.prop.happiness - 5) / 2);
        this.yield = this.yield.constrain(0, this.attr.maxYield);
      }
      return this.prop.watered = false;
    };

    Crop.prototype.water = function() {
      if (!this.prop.watered) {
        this.prop.watered = true;
        return true;
      }
      return false;
    };

    Crop.prototype.render = function() {
      return this.template(this);
    };

    Crop.prototype.getAttr = function(k) {
      return this.attr[k];
    };

    Crop.prototype.template = _.template("<div id=\"crop_<%=id%>\" class=\"crop happiness_<%=prop.happiness%> <%if(!prop.watered){%>unwatered<%}%>\" data-plotid=\"<%=id%>\">\n	<div><b><%=name%></b></div>\n	<%=game.meterTemplate({width:80, height: 5, value: prop.age / getAttr(\"maxAge\")})%>\n\n	<div>Growth: <%=prop.growth%></div>\n	<%=game.meterTemplate({width:80, height: 5, bg: 'yellow', value: prop.happiness / MAX_HAPPINESS})%>\n	<%if(prop.yield){%><%=yield%><%}%>\n	<%if(!prop.watered){%><div>thirsty</div><%}%>\n</div>");

    return Crop;

  })();

  window.Plot = Plot;

  window.Crop = Crop;

}).call(this);
