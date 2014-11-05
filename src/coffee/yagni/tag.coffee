wit = (context, callback) ->
    callback.call context

addChildren = (el, children) ->
    if children
        #allow the passing of elements not in an array
        if children instanceof Element
            children = [children]

        if _.isArray children
            children.forEach (child) ->
                el.appendChild if typeof child is 'string' then document.createTextNode(child) else child
        else if typeof children is 'string'
            el.textContent = children
    el

# Creates tag function
tag = (tag) ->
    (attrs, callback) ->
        # make attrs optional
        if typeof attrs is 'function'
            context = callback
            callback = attrs
            attrs = null
        el = document.createElement tag
        for k,v of attrs
            if k is 'class' #obsorb ignorance
                el.className = v
            else if k is 'id' or k is 'className'
                el[k] = v
            else if k is 'text' or k is 'content' or k is 'textContent'
                el.textContent = v
            else
                el.setAttribute k, v
        
        if callback
            el = addChildren el, callback el
        el

#create tag functions
for tagname in 'div a span p button section header footer h1 h2 h3 h4 h5 h6 i b strong em'.split ' '
    window[tagname] = tag tagname




