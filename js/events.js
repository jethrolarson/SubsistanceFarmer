
  window.events = {
    intro: function() {
      this.message("Society has collapsed and millions have died. I have fled to the hills and am trying to scrape out an existance as a subsistance farmer. Maybe through hard work and a little luck I'll survive the winter...");
      this.items.push(new Tool('wateringCan'));
      this.items.push(new Item('bed'));
      this.items.push(new Item('well'));
      return true;
    },
    tired: function() {
      this.message("I'm exhausted. If I press on I'll be hurting tomorrow.", 'warning');
      $('.rest').addClass('hilight');
      return true;
    },
    hungry: function() {
      this.message("I am hungry. I should eat something.", "warning");
      $('.eat').addClass('hilight');
      return true;
    },
    death: function() {
      return this.message("I died. That sucked...", 'critical');
    }
  };
