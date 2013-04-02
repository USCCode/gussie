# n-queens problem and solution
#
#
go = ->
    totalConflicts = 0
    turtles.do ->
        y = @pycor()
        bestPos = -1
        minConflicts = 10000
        for x in [0...size]
            conflicts = @other(turtles).with ->
                @pxcor() == x or @pycor() == y or
                Math.abs(@pxcor() - x) == Math.abs(@pycor() - y)
            if conflicts.count() < minConflicts
                minConflicts = conflicts.count()
                bestPos = [x]
            if conflicts.count() == minConflicts
                bestPos.push(x)
        totalConflicts += minConflicts
        @pxcor(bestPos.one_of())
    console.log totalConflicts + ' conflicts'
    redraw()
    if totalConflicts == 0
        $('#goButton').prop('checked',false)
        $('#goButton').button('refresh')

window.go = go
size = 16

setup = ->
    size = $('#sizeSlider').slider('value')
    width = 400 / size
    initialize(size,size,width)
    clear_all()
    patches.do ->
        if (@pxcor + @pycor) % 2 == 0 
            @setColor color.white
        else
            @setColor color.black
    window.t = []
    for i in [0...size]
        window.t[i] = new Turtle
        window.t[i].setpxy i,i
        window.t[i].heading = - Math.PI / 2
    redraw()
    
$ ->
    make_world
        top: 30
        left: 300
    make_button
        top: 50
        left: 10
        label: 'Setup'
        id: 'setupButton'
        click: setup
    make_button
        top: 50
        left: 100
        label: 'Go'
        id: 'goButton'
        toggle: true
        click: go
    $('#sizeSlider').slider
        min: 8
        max: 32
        value: size
        slide: (event,ui) ->
            $('#boardSize').html(ui.value)
        create: (event,ui) ->
            $('#boardSize').html(size)
    $('#sizeSlider').width('200px')
    initialize(size,size,20)
    console.log('all systems go')

