(function() {
  var $content, $garden, $player, $toolbar, BREAKFAST, DAY_LENGTH, DINNER, LUNCH, game;

  $player = $('#player');

  $content = $('#content');

  $garden = $('#garden');

  $toolbar = $('#toolbar');

  DAY_LENGTH = 12;

  BREAKFAST = DAY_LENGTH * .3;

  LUNCH = DAY_LENGTH * .5;

  DINNER = DAY_LENGTH * .8;

  game = {
    day: 1,
    time: 0,
    previousTime: 0,
    food: 90,
    player: {
      health: 10,
      maxHealth: 10,
      energy: 6,
      maxEnergy: 6,
      status: {},
      luck: 5,
      fed: 2,
      maxFed: 5,
      ate: 0
    },
    weather: 5,
    field: [],
    items: [],
    inventory: [],
    fieldsize: 0,
    ammo: 40,
    init: function() {
      this.envokeEvent('intro');
      return this.beforeDay();
    },
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
    useEnergy: function(energy) {
      var msg;
      msg = this.player.energy > 0 ? "This requires " + energy + " energy and I only have " + this.player.energy + ". Should I cowboy up?" : msg = "This requires " + energy + " energy and I'm exhausted. Should I cowboy up?";
      if (this.player.energy - energy >= 0 || confirm(msg)) {
        this.player.energy -= energy;
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
    meterTemplate: _.template("<% var meterWidth = this.width || 150, meterHeight = this.height || 25;%>\n<div class=\"meter\" style=\"width: <%=meterWidth%>px; height: <%=meterHeight%>px\">\n	<em style=\"line-height: <%=meterHeight%>px; width: <%=meterWidth%>\"><%=name%></em>\n	<span style=\"height: <%=meterHeight%>px; <%if(this.bg){%>background-color: <%=bg%>;<%}%>width: <%=value*meterWidth%>px\"></span>\n</div>"),
    playerTemplate: _.template("<div>\n	Time: <%=time%>\n</div>\n<div id=\"status\">\n	<%for(var i=0,len=player.status.length;i<len;i++){%>\n		<span><%=player.status[i]%></span>\n	<%}%>\n</div>\n<%=meterTemplate({name: \"health: \"+player.health+\"/\"+player.maxHealth, value: player.health / player.maxHealth , bg: \"hsl(0,70%,40%)\" })%>\n<div class=\"eat action\" data-action=\"eat\" title=\"Eat\">\n	<%=meterTemplate({name: \"Fed: \"+player.fed+\"/\"+player.maxFed, value: player.fed / player.maxFed, bg: \"orange\"})%>\n</div>\n"),
    renderPlayer: function() {
      return $player.html(this.playerTemplate(this));
    },
    beforeDay: function() {
      var that;
      $d.trigger('beforeDay');
      that = this;
      this.time = 0;
      if (this.player.status.exhausted) {
        this.player.energy = Math.floor(Math.max(this.player.maxEnergy + this.player.energy, 2));
        this.message("You're still wiped from yesterday, better take it easy today.", "warning");
        this.player.status.exhausted = false;
      } else {
        this.player.energy = this.player.maxEnergy;
      }
      this.field.forEach(function(plot) {
        return plot.onDayStart(that);
      });
      return this.beforeTurn();
    },
    beforeTurn: function() {
      var html, i, _ref, _ref2;
      $d.trigger('beforeTurn');
      if ((this.previousTime < BREAKFAST && this.time >= BREAKFAST) || (this.previousTime < LUNCH && this.time >= LUNCH) || (this.previousTime < DINNER && this.time >= DINNER)) {
        this.fed -= 1;
      }
      if (this.player.fed === 0) this.envokeEvent('hungry');
      if (this.player.energy === 0) this.envokeEvent('tired');
      this.renderPlayer();
      html = '';
      for (i = 0, _ref = this.field.length; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
        html += this.field[i].render();
      }
      html += '<div class="expand action" data-action="expand">Expand Garden</div>';
      $garden.html(html);
      html = '';
      for (i = 0, _ref2 = this.items.length; 0 <= _ref2 ? i < _ref2 : i > _ref2; 0 <= _ref2 ? i++ : i--) {
        html += this.items[i].render();
      }
      $toolbar.html(html);
      return $d.trigger('rendered');
    },
    endTurn: function() {
      var dmg;
      $d.trigger('endTurn');
      if (this.player.energy < 0) {
        this.player.status.exhausted = true;
        dmg = Math.abs(this.player.energy) ^ 2;
        this.player.health -= dmg;
        this.message("Working while exhausted cost you " + dmg + " health", 'critical');
      }
      if (this.player.fed === 0) this.player.energy -= 1;
      if (this.player.health <= 0) this.envokeEvent('death');
      log('turn ended');
      this.previousTime = this.time;
      this.time += DAY_LENGTH / this.player.maxEnergy;
      return this.beforeTurn();
    }
  };

  window.game = game;

  game.init();

  $d.on('click touchstart', '.action', function() {
    var $this, actiondata;
    $this = $(this);
    actiondata = $this.data('actiondata');
    return game.performAction($this.data('action'), actiondata);
  });

}).call(this);
