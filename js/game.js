(function() {
  var $content, $garden, $player, $toolbar, BREAKFAST, DAY_LENGTH, DINNER, LUNCH, game, gameView;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  models || (models = {});

  views || (views = {});

  collections || (collections = {});

  $player = $('#player');

  $content = $('#content');

  $garden = $('#garden');

  $toolbar = $('#toolbar');

  DAY_LENGTH = 12;

  BREAKFAST = DAY_LENGTH * .3;

  LUNCH = DAY_LENGTH * .5;

  DINNER = DAY_LENGTH * .8;

  models.Player = (function() {

    __extends(Player, Backbone.Model);

    function Player() {
      Player.__super__.constructor.apply(this, arguments);
    }

    Player.prototype.defaults = {
      health: 10,
      maxHealth: 10,
      calories: 6,
      maxCalories: 6,
      status: {},
      luck: 5,
      fed: 2,
      maxFed: 5,
      ate: 0
    };

    Player.prototype.initialize = function() {
      console.log('model Player init');
      return this.inventory = new collections.Inventory();
    };

    Player.prototype.burnCalories = function(calories) {
      var msg;
      msg = this.get('calories') > 0 ? "This requires " + calories + " calories and I only have " + (this.get('calories')) + ". Should I cowboy up?" : msg = "This requires " + calories + " calories and I'm exhausted. Should I cowboy up?";
      if (this.get('calories') - calories >= 0 || confirm(msg)) {
        this.set({
          calories: this.get('calories') - calories
        });
        return true;
      }
      return false;
    };

    return Player;

  })();

  views.Player = (function() {

    __extends(Player, Backbone.View);

    function Player() {
      Player.__super__.constructor.apply(this, arguments);
    }

    Player.prototype.el = $('#player');

    Player.prototype.initialize = function() {
      console.log('view Player init');
      this.inventoryView = new views.Inventory({
        collection: this.model.inventory
      });
      return $('#inventory').html(this.inventoryView.render().el);
    };

    Player.prototype.render = function() {
      console.log('render player');
      return $(this.el).html(this.template(this.model));
    };

    Player.prototype.template = _.template("<div>\n	Time: <%=window.newGame.get('time')%>\n</div>\n<div id=\"status\">\n	<%for(var i=0,len=this.get('status').length;i<len;i++){%>\n		<span><%=this.get('status')[i]%></span>\n	<%}%>\n</div>\n<%=game.meterTemplate({name: \"health: \"+this.get('health')+\"/\"+this.get('maxHealth'), value: this.get('health') / this.get('maxHealth') , bg: \"hsl(0,70%,40%)\" })%>\n<div class=\"eat action\" data-action=\"eat\" title=\"Eat\">\n	<%=game.meterTemplate({name: \"Fed: \"+this.get('fed')+\"/\"+this.get('maxFed'), value: this.get('fed') / this.get('maxFed'), bg: \"orange\"})%>\n</div>\n");

    return Player;

  })();

  models.Game = (function() {

    __extends(Game, Backbone.Model);

    function Game() {
      Game.__super__.constructor.apply(this, arguments);
    }

    Game.prototype.defaults = {
      day: 1,
      time: 0,
      previousTime: 0,
      food: 90,
      weather: 5
    };

    Game.prototype.initialize = function() {
      console.log('model Game init');
      this.player = new models.Player;
      window.player = this.player;
      this.playerView = new views.Player({
        model: this.player
      });
      return this.field = new Backbone.Collection;
    };

    Game.prototype.beforeDay = function() {
      var status, that;
      $d.trigger('beforeDay');
      that = this;
      this.time = 0;
      status = this.player.get('status');
      if (status.exhausted) {
        this.player.set({
          calories: Math.floor(Math.max(this.player.get('maxCalories') + this.player.get('calories'), 2))
        });
        this.message("You're still wiped from yesterday, better take it easy today.", "warning");
        status.exhausted = false;
      } else {
        this.player.set({
          calories: this.player.get('maxCalories')
        });
      }
      $d.trigger('dayStart');
      return this.beforeTurn();
    };

    Game.prototype.beforeTurn = function() {
      $d.trigger('beforeTurn');
      console.log('before turn');
      if ((this.get('previousTime') < BREAKFAST && this.get('time') >= BREAKFAST) || (this.get('previousTime') < LUNCH && this.get('time') >= LUNCH) || (this.get('previousTime') < DINNER && this.get('time') >= DINNER)) {
        this.fed -= 1;
      }
      if (this.player.get('fed') === 0) game.envokeEvent('hungry');
      if (this.player.get('calories') === 0) game.envokeEvent('tired');
      this.playerView.render();
      return $d.trigger('rendered');
    };

    Game.prototype.endTurn = function() {
      var dmg;
      $d.trigger('endTurn');
      console.log('end turn');
      if (this.player.get('calories') < 0) {
        this.player.get('status').exhausted = true;
        dmg = Math.abs(this.player.get('calories')) ^ 2;
        this.player.set({
          health: this.player.get('health') - dmg
        });
        this.message("Working while exhausted cost you " + dmg + " health", 'critical');
      }
      if (this.player.fed === 0) {
        this.player.set({
          calories: this.player.get('calories') - 1
        });
      }
      if (this.player.get('health') <= 0) game.envokeEvent('death');
      log('turn ended');
      this.set({
        previousTime: this.get('time')
      });
      this.set({
        time: this.get('time') + DAY_LENGTH / this.player.get('maxCalories')
      });
      return this.beforeTurn();
    };

    return Game;

  })();

  views.Game = (function() {

    __extends(Game, Backbone.View);

    function Game() {
      Game.__super__.constructor.apply(this, arguments);
    }

    Game.prototype.initialize = function() {
      console.log('view Game init');
      this.fieldView = new views.Field({
        collection: this.model.field
      });
      this.model.beforeDay();
      return game.envokeEvent('intro');
    };

    Game.prototype.render = function() {
      return this;
    };

    return Game;

  })();

  game = {
    message: function(msg, className) {
      className || (className = '');
      $content.append("<div class=\"" + className + "\">" + msg + "</div>");
      return $content.animate({
        scrollTop: $content[0].scrollHeight
      }, 500);
    },
    envokeEvent: function(k, data) {
      data || (data = {});
      if (!window.events[k]) {
        this.message("Action " + k + " not defined");
      } else if (window.events[k].call(this, data)) {
        log("Event: " + k + " evoked");
        return true;
      }
      return false;
    },
    burnCalories: function(calories) {
      var msg;
      msg = this.player.calories > 0 ? "This requires " + calories + " calories and I only have " + this.player.calories + ". Should I cowboy up?" : msg = "This requires " + calories + " calories and I'm exhausted. Should I cowboy up?";
      if (this.player.calories - calories >= 0 || confirm(msg)) {
        this.player.calories -= calories;
        return true;
      }
      return false;
    },
    performAction: function(k, data) {
      data || (data = {});
      if (window.actions[k]) {
        if (window.actions[k].call(this, data)) {
          log("Action: " + k + " performed");
          this.endTurn();
          return true;
        } else {
          return false;
        }
      } else {
        this.message("Action " + k + " not defined", 'warning');
        return false;
      }
    },
    meterTemplate: _.template("<% var meterWidth = this.width || 150, meterHeight = this.height || 25;%>\n<div class=\"meter\" style=\"width: <%=meterWidth%>px; height: <%=meterHeight%>px\">\n	<em style=\"line-height: <%=meterHeight%>px; width: <%=meterWidth%>\"><%=name%></em>\n	<span style=\"height: <%=meterHeight%>px; <%if(this.bg){%>background-color: <%=bg%>;<%}%>width: <%=value*meterWidth%>px\"></span>\n</div>")
  };

  window.game = game;

  $d.on('click touchstart', '.action', function() {
    var $this, actiondata;
    $this = $(this);
    actiondata = $this.data('actiondata');
    return game.performAction($this.data('action'), actiondata);
  });

  window.newGame = new models.Game;

  gameView = new views.Game({
    model: newGame
  });

}).call(this);
