(function (window) {
	//General file for non-specific utilities that can be used on any page or template
	window.storage = {
		getItem: function(k){
			return JSON.parse(localStorage.getItem(k));
		},
		setItem: function(k,v){
			localStorage.setItem(k,JSON.stringify(v));
		},
		removeItem: function(k){
			localStorage.removeItem(k);
		}
	};

	//OVERWRITING Underscore.js's templates
	// By default, Underscore uses ERB-style template delimiters, change the
	// following template settings to use alternative delimiters.
	_.templateSettings = $.extend(_.templateSettings,{
		modelProp   : /<%@([\s\S]+?)%>/g,
		value       : /<%#([\s\S]+?)%>/g // inserts value of a variable on the object or "" if undefined
	});

	// JavaScript micro-templating, similar to John Resig's implementation.
	// Underscore templating handles arbitrary delimiters, preserves whitespace,
	// and correctly escapes quotes within interpolated code.
	// Jethro adds context binding to data and `value` template delimeter
	var tIndex = 0;
	_.template = function(str, data) {
		var c  = _.templateSettings;
		var tmpl = 'var __p=[],print=function(){__p.push.apply(__p,arguments);};' +
			'(function(){with(obj||{}){__p.push(\'' +
			str.replace(/\\/g, '\\\\')
				.replace(/'/g, "\\'")
				.replace(c.escape, function(match, code) {
					return "',_.escape(" + code.replace(/\\'/g, "'") + "),'";
				})
				.replace(c.modelProp, function(match, code) {
					return "',this.get('" + code.replace(/\\'/g, "'") + "'),'";
				})
				.replace(c.value, function(match, code) {
					return "',this." + code.replace(/\\'/g, "'") + "||'','";
				})
				.replace(c.interpolate, function(match, code) {
					return "'," + code.replace(/\\'/g, "'") + ",'";
				})
				.replace(c.evaluate || null, function(match, code) {
					return "');" + code.replace(/\\'/g, "'")
															.replace(/[\r\n\t]/g, ' ') + ";__p.push('";
				})
				.replace(/\r/g, '\\r')
				.replace(/\n/g, '\\n')
				.replace(/\t/g, '\\t')
				+ "');}}).call(obj);return __p.join('');//@ sourceURL=template"+(tIndex++)+".js";
		var func = new Function('obj', '_', tmpl);
		return data ? func(data, _) : function(data) { return func(data, _) };
	};

	// usage: log('inside coolFunc', this, arguments);
	// paulirish.com/2009/log-a-lightweight-wrapper-for-consolelog/
	window.log = function(){
		log.history = log.history || [];   // store logs to an array for reference
		log.history.push(arguments);
		if(this.console) {
			arguments.callee = arguments.callee.caller;
			var newarr = [].slice.call(arguments);
			(typeof console.log === 'object' ? log.apply.call(console.log, console, newarr) : console.log.apply(console, newarr));
		}
	};

	// make it safe to use console.log always
	(function(b){function c(){}for(var d="assert,clear,count,debug,dir,dirxml,error,exception,firebug,group,groupCollapsed,groupEnd,info,log,memoryProfile,memoryProfileEnd,profile,profileEnd,table,time,timeEnd,timeStamp,trace,warn".split(","),a;a=d.pop();){b[a]=b[a]||c}})((function(){try
	{console.log();return window.console;}catch(err){return window.console={};}})());


	// place any jQuery/helper plugins in here, instead of separate, slower script files.

})(window);
