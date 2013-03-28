go = ->
#    console.log('calculating')
#    tm = Date.now()
#    patches.do -> 
#        @calculate()
    turtles.with( -> @who > 0).do ->
        @heading = @heading + Math.random() - .5
        @forward 1
    turtles.withPV('who', 0).do ->
        myself = @
        closest = turtles.minus(@).min_one_of(-> @distance myself)
        @heading = @towards closest
        @forward 1
#    console.log('Took ')
#    console.log(Date.now() - tm)        
#    console.log('setting new color')        
#    patches.do ->
#        @setColor @nextColor
#    console.log('drawing')        
#    tm = Date.now()
    redraw()
#    console.log('Took ')
#    console.log(Date.now() - tm)
    if $('#goButton').prop('checked')
        setTimeout go,0

setup = ->
    clear_all()
    patches.do ->
        newColor = color.white
#            newColor = if Math.random() < .5  then color.black else color.white 
        @setColor newColor
    window.t0 = new Turtle
    window.t1 = new Turtle
    window.t1.xcor = 200
    window.t2 = new Turtle
    window.t2.xcor = 300
    redraw()
    
#This is how we add a method to an existing class.
Patch::calculate = ->
    numLiveNeighbors = @neighbors.withPV('pcolor', color.black).count()
    #Another way to do it, a bit slower
    # numLiveNeighbors = @neighbors.with(->
    #     @pcolor == color.black
    #     ).count()        
    @nextColor = @pcolor
    if @pcolor == color.black
        if (numLiveNeighbors < 2 or numLiveNeighbors > 3)
            @nextColor = color.white #die
    else #dead cell
        if numLiveNeighbors == 3
            @nextColor = color.black #live!


$ ->
    $('#setupButton').on('click', setup)
    $('#goButton').on 'click', go
    console.log('all systems go')

