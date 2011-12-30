
  Number.prototype.constrain = function(min, max) {
    return Math.max(Math.min(this, max), min);
  };

  window.$d = $(document);
