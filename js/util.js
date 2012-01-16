(function() {
  var ls, ss;

  Number.prototype.constrain = function(min, max) {
    return Math.max(Math.min(this, max), min);
  };

  Object.getName = function(o) {
    var funcNameRegex, results;
    funcNameRegex = /function (.{1,})\(/;
    results = funcNameRegex.exec(o.constructor.toString());
    if (results && results.length > 1) {
      return results[1];
    } else {
      return "";
    }
  };

  window.$d = $(document);

  ss = 'sessionStorage';

  ls = 'localStorage';

  window.storage = {
    setItem: function(k, v, session) {
      var cache;
      cache = session ? sessionStorage : localStorage;
      if (typeof v === 'object') v = JSON.stringify(v);
      cache.removeItem(k);
      try {
        return cache.setItem(k, v);
      } catch (err) {
        cache.clear();
        return cache.setItem(k, v);
      }
    },
    getItem: function(k, isJSON, where) {
      var cache, v;
      if (typeof isJSON === 'string') {
        where = isJSON;
        isJSON = false;
      }
      cache = where === 'session' || where === 'all' ? sessionStorage : localStorage;
      v = cache.getItem(k);
      if (typeof v === 'undefined' && where === 'all') {
        return this.getItem(k, isJSON, ls);
      }
      if (isJSON) {
        try {
          v = JSON.parse(v);
        } catch (err) {
          v = null;
        }
      }
      return v;
    },
    removeItem: function(k, where) {
      window[where === 'session' ? ss : ls].removeItem(k);
      if (where === 'all') return this.removeItem(k, 'session');
    },
    clear: function(where) {
      window[where === 'session' ? ss : ls].clear();
      if (where === 'all') return this.clear('session');
    }
  };

}).call(this);
