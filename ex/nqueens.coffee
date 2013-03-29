go = ->
    totalConflicts = 0
    turtles.do ->
        y = @pycor()
        bestPos = -1
        minConflicts = 10000
        for x in [0...16]
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
    if $('#goButton').prop('checked')
        setTimeout go,0

window.go = go

window.show_conflicts = ->
    turtles.do ->
        console.log @who + " " + @pxcor() + "," + @pycor()
    turtles.do ->
        x = @pxcor()
        y = @pycor()
        conflicts = @other(turtles).with ->
            console.log 'diff with who=' + @who
            console.log @pxcor() - x
            console.log @pycor() - y
            value = @pxcor() == x or @pycor() == y or
                Math.abs(@pxcor() - x) == Math.abs(@pycor() - y)
            console.log 'value=' + value
            return value
        console.log @who + " conflicts=" + conflicts.count()

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

