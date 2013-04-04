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
        $('#goButton').prop('checked',false) #add $.fn.checked() ???
        $('#goButton').button('refresh')

window.go = go
size = 16 #I need this global in go()
worldSize = 400 #in pixels

setup = ->
    size = $('#sizeSlider').slider('value')
    width = worldSize / size
    make_patches
        pxmax: size
        pymax: size
        size: width
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
        width: worldSize
        height: worldSize
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
    make_button
        top: 50
        left: 165
        label: 'Step'
        id: 'stepButton'
        click: go        
    make_slider
        top: 100
        left: 10
        width: 200
        min: 8
        max: 32
        value: size
        id: 'sizeSlider'
        label: 'Board Size:'
    console.log('all systems go')

