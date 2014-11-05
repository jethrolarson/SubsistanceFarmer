
identifier = '[A-Za-z\-_]+'
reClassName = new RegExp "\.(#{identifier})"
reID = new RegExp "\#(#{identifier})"
reAttrs = new RegExp "(\[[^\]]+\])+"
#always returns a string, absorbs failure
String.prototype.matchOne = (re) ->
    m = this.match re
    if m and m[1]
        m[1]
    else
        ''

#always returns an array, absorbs failure
String.prototype.matchAll = (re) ->
    m = this.match re
    if m and m.length
        m
    else
        []
#parses tag props from string
parseSelector = (selector) ->
    out = {}
    out.name = selector.matchOne(/([A-Za-z\-_]+)/) or 'div'
    
    attrs = {}
    selector.matchAll(reAttrs).forEach (item) ->
        tmp = item.substring 1, item.length - 2
        tmp = tmp.split '='
        if tmp and tmp.length is 2
            attrs[tmp[0]] = tmp[1]
    
    attrs.classname = selector.matchOne reClassName
    attrs.id = selector.matchOne reID

    out.attrs = attrs

    out

# attrs is optional
tag = (selector, callback) ->
    if _.isArray selector
        children = selector
        selector = ''
    props = parseSelector selector
    _tag props.name, props.attrs, callback