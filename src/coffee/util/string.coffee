flag = (bool, a)-> str bool and a
str = (v)-> if typeof v isnt 'string' then  '' else v
module.exports =
    flag: flag
    str: str