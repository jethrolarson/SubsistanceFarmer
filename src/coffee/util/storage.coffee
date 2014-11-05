ss = 'sessionStorage'
ls = 'localStorage'
module.exports = {
    setItem: (k,v, session) ->
        cache = if session then sessionStorage else localStorage
        if typeof v == 'object'
            v = JSON.stringify v

        cache.removeItem k
        try
            cache.setItem k, v
        catch err
            cache.clear()
            cache.setItem k, v

    #@isJSON bool If true will parse the value as JSON. Default false. omitable. null if undefined.
    #@where string 'localStorage' or 'sessionStorage' or 'all' which caches to look in. Default is 'localStorage'.
    getItem: (k, isJSON, where) ->
        # allow getItem(key,where) signature
        if typeof isJSON is 'string'
            where = isJSON
            isJSON = false
        cache = if (where is 'session' or where is 'all') then sessionStorage else localStorage
        v = cache.getItem k
        if typeof v is 'undefined' && where is 'all'
            return this.getItem k, isJSON, ls
        if isJSON
            try
                v = JSON.parse v
            catch err
                v = null
        return v

    removeItem: (k, where) ->
        window[if where is 'session' then ss else ls].removeItem k
        if where is 'all'
            this.removeItem k,'session'
    clear: (where) ->
        window[if where is 'session' then ss else ls].clear()
        if where is 'all'
            this.clear 'session'
}