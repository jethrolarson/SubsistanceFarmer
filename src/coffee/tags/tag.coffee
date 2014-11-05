# string, obj, string -> string
tag = (tag, attrs, content)->
    if typeof content is 'undefined'
        content = attrs
        attrs = null
    attrsString = _.pairs(attrs).map (p)-> p.join('="') +'"'
    "<#{tag} #{attrsString}>#{content}</#{tag}>"