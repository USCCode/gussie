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

    key: ->
        @who

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


#Turtleset stores the turtles in @turtles as an object
# with turtle.key as the key
#It is a set (no duplicates) based on the key.

class Turtleset
    constructor: (array) -> #TODO: check that array is an Array
        @turtles = {}
        @size = 0
        if array
            for turtle in array
                @add turtle

    add: (turtle) ->
        if not @turtles.hasOwnProperty turtle.key
            @size++
        @turtles[turtle.key()] = turtle
        return @

    get: (key) ->
        @turtles[key]

    count: ->
        return @size

    with: (f) ->
        result = new Turtleset
        for own key,turtle of @turtles
            if f.apply(turtle)
                result.add(turtle)
        return result

    do: (f) ->
        for own key,turtle of @turtles
            f.apply(turtle)
            
    draw: ->
        turtle.draw() for own key,turtle of @turtles

window.turtles = new Turtleset
turtles = window.turtles

turtle = (w) ->
    turtles.get(w)
        

#global var where we store a Turtleset of patches
window.patches = 0
patches = window.patches

patch = (x,y) ->
    patches.get(x + "-" + y)

patches_width = 1
patches_height = 1
max_pxcor = 400
max_pycor = 400


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

    key: ->
        @pxcor + "-" + @pycor
        
    setColor: (@pcolor) ->

    neighbors: () ->
        return @neighbors

w = patches_width * max_pxcor
h = patches_height * max_pycor

# Create all the patches, set window.patches variable 
create_patches = () ->
    $('#canvas').attr('width',w) #setting it in CSS (.width()) does not work!
    $('#canvas').attr('height',h)
    #create all the patches
    window.patches = new Turtleset
    patches = window.patches
    console.log('making patches')
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
            patches.add p
    #set each patch's neighbors
    console.log('setting neighbors')
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
        @neighbors = new Turtleset([
            patch(myPxcorM1,myPycor),
            patch(myPxcorP1,myPycor),
            patch(myPxcor,myPycorM1),
            patch(myPxcor,myPycorP1),
            patch(myPxcorM1,myPycorM1),
            patch(myPxcorM1,myPycorP1),
            patch(myPxcorP1,myPycorM1),
            patch(myPxcorP1,myPycorP1) ] )

#for testing
create_turtles = (num) ->
    for i in [0...num]
        new Turtle

animate = true

#Redraw everything in the canvas.
redraw = () ->
#    displayContext = context
#    m_canvas = document.createElement('canvas')
#    m_canvas.width = w;
#    m_canvas.height = h;
#    context = m_canvas.getContext('2d');
    context.clearRect(0,0,canvas.width(), canvas.height())    
    patches.draw()
    turtles.draw()
#    displayContext.drawImage(m_canvas,0,0)
#    context = displayContext
    

# User stuff below...or so that is the plan................................................
#
#

go = ->
    console.log('calculating')
    patches.do ->
        @calculate()
    console.log('setting')
    patches.do ->
        @setColor(@nextColor)
    console.log('drawing')
    tm = Date.now()
    redraw()
    console.log('Took ')
    console.log(Date.now() - tm)
    if $('#goButton').prop('checked')
        setTimeout go,0

goHandler = () ->
    if $('#goButton').prop('checked')
        go()

#This is how we add a method to an existing class.
Patch::calculate = ->
    @nextColor = @pcolor
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
    redraw()
    
    $('#setupButton').on('click', ->
        patches.do ->
            newColor = if Math.random() < .5  then color.black else color.white 
            @setColor newColor
        redraw()
    )

    $('#goButton').on('click', goHandler)
    console.log('all systems go')
)
