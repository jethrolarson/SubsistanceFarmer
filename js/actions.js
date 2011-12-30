
  window.actions = {
    plant: function(data) {
      var name;
      if (this.useEnergy(1)) {
        name = 'zuccini';
        this.field[data.id] = new Crop(name, this.field[data.id]);
        return true;
      } else {
        return false;
      }
    },
    expand: function() {
      if (this.useEnergy(3)) {
        this.field.push(new Plot());
        return true;
      } else {
        return false;
      }
    },
    getWater: function() {
      if (this.useEnergy(1)) return this.water = this.maxWater;
    }
  };
