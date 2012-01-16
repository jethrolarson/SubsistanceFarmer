(function() {
  var Entity, EntityCollection, entityItter, modifierTemplate;

  modifierTemplate = {
    name: 'my_modifier',
    _lasts: -1
  };

  entityItter = 0;

  Entity = (function() {

    function Entity(state) {
      if (typeof state === 'string') state = cache.getItem('E_' + state);
      this.state = {};
      this.state.key = state && state.key || entityItter++;
      this.state.props = state && state.props || {};
      this.modifiers = state && state.modifiers || [];
    }

    Entity.prototype.getProp = function(k) {
      var mod, prop, _i, _len, _ref;
      prop = this.state.props[k];
      _ref = this.modifiers;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        mod = _ref[_i];
        if (mod[k] != null) {
          if (typeof mod[k] === 'number') {
            prop += mod[k];
          } else {
            prop = mod[k];
          }
        }
      }
      return prop;
    };

    Entity.prototype.getBaseProp = function(k) {
      return this.state.props[k];
    };

    Entity.prototype.getProps = function() {
      var k, props, v, _ref;
      props = {};
      _ref = this.state.props;
      for (k in _ref) {
        v = _ref[k];
        props[k] = this.get(k);
      }
      return props;
    };

    Entity.prototype.getBaseProps = function() {
      return this.state.props;
    };

    Entity.prototype.addModifier = function(mod) {
      return this.modifiers.push(mod);
    };

    Entity.prototype.removeModifier = function(key) {
      return this.modifiers.getItemByProp('key', key);
    };

    Entity.prototype.save = function() {
      var k, state, v;
      state = this.state;
      for (k in state) {
        v = state[k];
        if (typeof v === 'object' && Object.getName(v) === 'Collection') {
          state[k] = v.getKeyArray();
        }
      }
      return cache.setItem('E_' + this.key, this.state);
    };

    return Entity;

  })();

  EntityCollection = (function() {

    function EntityCollection(ar) {
      this.ar = ar;
    }

    EntityCollection.prototype.push = function(item) {
      return Array.prototype.push.call(this.ar, item);
    };

    EntityCollection.prototype.getLength = function() {
      return this.ar.length;
    };

    EntityCollection.prototype.get = function(k) {
      if (k != null) {
        return this.ar[k];
      } else {
        return this.ar;
      }
    };

    EntityCollection.prototype.getKeyArray = function() {
      var ar, item, _i, _len, _ref;
      ar = [];
      _ref = this.ar;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        ar.push(item.key);
      }
      return ar;
    };

    return EntityCollection;

  })();

  Array.prototype.getItemByProp = function(prop, val) {
    var i, _ref;
    for (i = 0, _ref = this.length; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
      if (this[i][prop] === val) return this[i];
    }
  };

}).call(this);
