tag = require './tag'
span = (attrs, content)-> tag 'span', attrs, content
module.exports =
    tag: tag
    span: (attrs, content)-> tag 'span', attrs, content