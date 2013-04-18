# 
#
#

setup = ->
    clear_all()
    make_patches
        pxmax: 20
        pymax: 20
        size: 20
    patches.do ->
        @pcolor = color.white
    window.t = []
    for i in [0...9]
        window.t[i] = new Turtle
        window.t[i].do ->
            @setpxy(Math.random() * 10, Math.random() * 10)
            @heading = 0 # - Math.PI / 2
            @shape = 'circle'
#    window.t[8].do ->
#        @heading = @towards(window.t[0])
    window.t[8].createLinkWith(window.t[0])
    window.t[1].createLinkWith(window.t[2])
    window.t[2].createLinkWith(window.t[3])
    window.t[2].createLinkWith(window.t[4])
    redraw()


go = ->
    layout_magspring(10)
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
    make_button
        top: 50
        left: 100
        label: 'Step'
        id: 'stepButton'
        click: go        
    make_button
        top: 50
        left: 180
        label: 'Go'
        id: 'goButton'
        click: go
        toggle: true
    console.log('all systems go')

