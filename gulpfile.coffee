gulp = require 'gulp'
gutil = require 'gulp-util'
coffee = require 'gulp-coffee'
less = require 'gulp-less'
connect = require 'connect'
http = require 'http'
path = require 'path'
prefix = require 'gulp-autoprefixer'
browserify = require 'gulp-browserify'
rename = require 'gulp-rename'

gulp.task 'webserver', ->
    port = 4444
    hostname = null
    directory = path.resolve '.'
    base = path.resolve './public'
    app = connect()
        .use connect.static base
        .use connect.directory directory
    http.createServer(app)
        .listen port, hostname

paths = {
    coffee: 'src/coffee/**/*.coffee'
    html: 'src/**/*.html'
    less: 'src/styles/**/*.less'
}

gulp.task 'coffee', ->
    gulp.src 'src/coffee/index.coffee', { read: false }
        .pipe browserify {
            transform: ['coffee-reactify']
            extensions: ['.cjsx', '.coffee']
            insertGlobals: true
            debug: true
        }
        .pipe(rename('index.js'))
        .pipe gulp.dest 'public/js/'

gulp.task 'html', ->
    gulp.src paths.html
        .pipe gulp.dest 'public/'

gulp.task 'less', ->
    gulp.src paths.less
        .pipe do less
            .on 'error', gutil.log
        .pipe prefix "last 2 versions", "> 5%" #Autoprefix css props
        .pipe gulp.dest 'public/css/'

gulp.task 'watch', ->
    ['coffee', 'html', 'less'].forEach (task) -> gulp.watch paths[task], [task]

gulp.task 'default', ['coffee','html','less', 'watch', 'webserver']
