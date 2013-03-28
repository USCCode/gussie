go = ->
    totalConflicts = 0
    turtles.do ->
        x = @pxcor()
        y = @pycor()
        bestPos = -1
        minConflicts = 10000
        for pos in [0...16]
            @pxcor pos
            conflicts = @other(turtles).with ->
                @pxcor() == pos or @pycor() == y or
                Math.abs (@pxcor() - pos) == Math.abs (@pycor() - y)
            if conflicts.count() < minConflicts
                minConflicts = conflicts.count()
                bestPos = [pos]
            if conflicts.count() == minConflicts
                bestPos.push(pos)
        totalConflicts += minConflicts
        @pxcor(bestPos.one_of())
    console.log totalConflicts + ' conflicts'
    redraw()
    if totalConflicts == 0
        $('#goButton').prop('checked',false)
    if $('#goButton').prop('checked')
        setTimeout go,0

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

