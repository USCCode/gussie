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
    turtles.do ->
        @createLinkWith(turtles.one_of())
    redraw()


mouseIsDown = false
chosen = null

go = ->
    layout_magspring(1)
    if chosen?
        chosen.setxy(chosen.mousex, chosen.mousey)
    redraw()

handleClick = (e) ->
    console.log e.offsetX + ',' + e.offsetY
    mouseIseDown = true
    chosen = turtles.min_one_of ->
        @distancexy(e.offsetX,e.offsetY)
    chosen.setxy(e.offsetX,e.offsetY)
    chosen.mousex = e.offsetX
    chosen.mousey = e.offsetY

handleMove = (e) ->
    if chosen?
        chosen.mousex = e.offsetX
        chosen.mousey = e.offsetY

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
    $('#world').on('mousedown', handleClick)
    $('#world').on('mousemove', handleMove)
    $('#world').on('mouseup', ->
        mouseIsDown = false
        chosen = null
        )
    console.log('all systems go')
