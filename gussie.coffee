#gussie.coffee by jmvidal@gmail.com
#
#  hi
#   
canvas = 0
context = 0
who = 0
color = {
    black: "#000000",
    white: "#FFFFFF"
    }


class Turtle
    constructor: ->
        @xcor = 100
        @ycor = 100
        @heading = 0
        @who = who++
        @color = color.white
        turtles.add(@)

    draw: ->
        context.save()
        context.fillStyle = @color
        context.translate(Math.round(@xcor),Math.round(@ycor))
        context.rotate(@heading)
        context.beginPath()
        context.moveTo(0,0)
        context.lineTo(-5,-5)
        context.lineTo(10,0)
        context.lineTo(-5,5)
        context.lineTo(0,0)
        context.stroke()
        context.restore()
        return this
        
    update: ->
        @heading += Math.random() * 1 - .5
        @forward(1)
        return @

    setHeading: (@heading) -> 
        return @

    forward: (distance) ->
        dx = Math.cos(this.heading) * distance;
        dy = Math.sin(this.heading) * distance;
        @xcor += dx;
        @ycor += dy;
        return @

class Turtleset
    constructor: (array) ->
        @turtles = array ? []

    add: (turtle) ->
        @turtles.push(turtle)
        return @

    count: ->
        return @turtles.length

    with: (f) ->
        nt = new Turtleset
        result = []
        for turtle in @turtles
            if f.apply(turtle)
                result.push(turtle)
        nt.turtles = result
        return nt

    do: (f) ->
        for turtle in @turtles
            f.apply(turtle)
            
    draw: ->
        turtle.draw() for turtle in @turtles

window.turtles = new Turtleset

#global var where we store a Turtleset of patches
window.patches = 0
patches = window.patches

patches_width = 10
patches_height = 10
max_pxcor = 40
max_pycor = 40 


class Patch extends Turtle
    constructor: (@pxcor, @pycor)->
        @xcor = 0 # the center point of the patch
        @ycor = 0
        @pxcor = 0 # the patch's position (in patch coordinates)
        @pycor = 0
        @pcxcor = 0 #the top-left point (used for drawing)
        @pcycor = 0
        @pcxcor_end = 0 #the bottom-right point (used for drawing)
        @pcycor_end = 0
        @pcolor = color.white
        @neighbors = []  #a turtleset with my neighbors

    draw: ->
        context.fillStyle = @pcolor
        context.fillRect(@pcxcor, @pcycor, @pcxcor_end, @pcycor_end)

    setColor: (@pcolor) ->

    neighbors: () ->
        return @neighbors


# Create all the patches, set window.patches variable 
create_patches = () ->
    w = patches_width * max_pxcor;
    h = patches_height * max_pycor;
    $('#canvas').width(w);
    $('#canvas').height(h);
    #create all the patches
    window.patches = new Turtleset
    for x in [0...max_pxcor]
        for y in [0...max_pycor]
            p = new Patch(x,y)
            p.pxcor = x
            p.pycor = y
            p.pcxcor = x * patches_width
            p.pcxcor_end = p.pcxcor + patches_width
            p.pcycor = y * patches_height
            p.pcycor_end = p.pcycor + patches_height
            p.xcor = p.pcxcor + (patches_width / 2)
            p.ycor = p.pcycor + (patches_height / 2)
            window.patches.add p
    #set each patch's neighbors
    patches = window.patches
    patches.do ->
        myPxcor = @pxcor
        myPycor = @pycor
        myPxcorM1 = myPxcor - 1
        myPxcorM1 =(max_pxcor - 1) if myPxcorM1 < 0 #assumes torus world
        myPxcorP1 = (myPxcor + 1) % max_pxcor
        myPycorM1 = myPycor - 1
        myPycorM1 = (max_pycor - 1) if myPycorM1 < 0
        myPycorP1 = (myPycor + 1) % max_pycor
        @neighbors = patches.with( ->
            (@pxcor == myPxcorM1 and @pycor == myPycor) or
            (@pxcor == myPxcorP1 and @pycor == myPycor) or
            (@pxcor == myPxcor and @pycor == myPycorM1) or
            (@pxcor == myPxcor and @pycor == myPycorP1) or
            (@pxcor == myPxcorM1 and @pycor == myPycorM1) or
            (@pxcor == myPxcorM1 and @pycor == myPycorP1) or
            (@pxcor == myPxcorP1 and @pycor == myPycorM1) or
            (@pxcor == myPxcorP1 and @pycor == myPycorP1))
        
            

#for testing
create_turtles = (num) ->
    for i in [0...num]
        new Turtle

animate = true

#Redraw everything in the canvas.
redraw = () ->
    context.clearRect(0,0,canvas.width(), canvas.height())
    patches.draw()
    turtles.draw()

go = ->
    console.log 'go'
    patches.do ->
        @calculate()
    patches.do ->
        @pcolor = @nextColor
    redraw()
    if $('#goButton').prop('checked')
        setTimeout go,0

goHandler = () ->
    if $('#goButton').prop('checked')
        go()

# User stuff below...or so that is the plan
#

#This is how we add a method to an existing class.
Patch::calculate = ->
    window.n = @neighbors
    numLiveNeighbors = @neighbors.with(->
        @pcolor == color.black
        ).count()
    if @pcolor == color.black
        if (numLiveNeighbors < 2 or numLiveNeighbors > 3)
            @nextColor = color.white #die
    else #dead cell
        if numLiveNeighbors == 3 
            @nextColor = color.black #live!

$(document).ready( () ->
    console.log('ready')
    canvas = $('canvas')
    context = canvas[0].getContext('2d')
    create_patches()
        # t = create_turtles(10)

    $('#setupButton').on('click', ->
        patches.do ->
            @pcolor = if Math.random() < .5  then color.black else color.white
        redraw()
    )
    

    $('#goButton').on('click', goHandler)
)
