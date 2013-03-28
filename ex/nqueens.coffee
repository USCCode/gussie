go = ->
    turtles.do ->
        x = @pxcor()
        y = @pycor()
        conflicts = @other(turtles).with ->
            @pxcor() == x or @pycor() == y or
            Math.abs (@pxcor() - x) == Math.abs (@pycor() - y)
        if conflicts.count() > 0
            @pxcor((@pxcor() + 1) % 16)
    redraw()
#    if $('#goButton').prop('checked')
#        setTimeout go,0

window.go = go

setup = ->
    clear_all()
    patches.do ->
        if (@pxcor + @pycor) % 2 == 0 
            @setColor color.white
        else
            @setColor color.black
    window.t = []
    for i in [0...16]
        window.t[i] = new Turtle
        window.t[i].setpxy i,i
        window.t[i].heading = - Math.PI / 2
    redraw()
    
$ ->
    initialize(16,16,20)
    $('#setupButton').on('click', setup)
    $('#goButton').on 'click', go
    console.log('all systems go')

