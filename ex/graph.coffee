# 
#
#

setup = ->
    make_patches
        pxmax: 10
        pymax: 10
        size: 40
    clear_all()
    patches.do ->
        @pcolor = color.white
    window.t = []
    for i in [0...10]
        window.t[i] = new Turtle
        window.t[i].do ->
            @setpxy i,i
            @heading = - Math.PI / 2
            @shape = 'circle'
    redraw()
    
$ ->
    make_world
        top: 30
        left: 300
        width: 400
        height: 400
    make_button
        top: 50
        left: 10
        label: 'Setup'
        id: 'setupButton'
        click: setup
    console.log('all systems go')

