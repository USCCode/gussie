#gussie.coffee by jmvidal@gmail.com
#
#  hi
#   
patchCanvas = 0
patchContext = 0
turtleCanvas = 0
turtleContext = 0

who = 0
color = {
    black: "#555555",
    white: "#EEEEEE",
    red: "#FF0000"
    }

class Turtle
    constructor: ->
        @xcor = 100
        @ycor = 100
        @heading = 0
        @who = who++
        @color = color.red
        turtles.add(@)

    key: ->
        @who

    draw: ->
        turtleContext.save()
        turtleContext.fillStyle = @color
        turtleContext.translate(Math.round(@xcor),Math.round(@ycor))
        turtleContext.rotate(@heading)
        turtleContext.beginPath()
        turtleContext.moveTo(0,0)
        turtleContext.lineTo(-5,-5)
        turtleContext.lineTo(10,0)
        turtleContext.lineTo(-5,5)
        turtleContext.lineTo(0,0)
        turtleContext.fill()
        turtleContext.restore()
        return this
        
    setHeading: (@heading) -> 
        return @

    forward: (distance) ->
        distance = distance * patches_width
        dx = Math.cos(this.heading) * distance
        dy = Math.sin(this.heading) * distance
        @xcor += dx
        @ycor += dy
        [@xcor, @ycor] = wrap(@xcor,@ycor)
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
        for key,turtle of @turtles
            if f.apply(turtle)
                result.add(turtle)
        return result

    withPV: (property, value) ->
        result = new Turtleset
        for key,turtle of @turtles
            if turtle[property] == value
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
        @pcolor = "#AA5555"
        @drawnColor = null
        @neighbors = null  #a turtleset with my neighbors

    draw: ->
        if not (@drawnColor == @pcolor)
            @drawnColor = @pcolor
            patchContext.fillStyle = @pcolor
            patchContext.fillRect(@pcxcor, @pcycor, patches_width, patches_height)
            
    key: ->
        @pxcor + "-" + @pycor
        
    setColor: (@pcolor) ->

    neighbors: () ->
        return @neighbors

w = patches_width * max_pxcor
h = patches_height * max_pycor

wrap = (x,y) ->
    x = x % w
    x =  w + x if x < 0
    y = y % h
    y =  h + y if y < 0
    return [x,y]

# Create all the patches, set window.patches variable 
create_patches = () ->
    $('#world').attr('width',w).width(w) 
    $('#world').attr('height',h).height(h)
    $('#patchCanvas').attr('width',w)
    $('#patchCanvas').attr('height',h)
    $('#turtleCanvas').attr('width',w) #setting it in CSS (.width()) does not work!
    $('#turtleCanvas').attr('height',h)
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
            p.pcycor = y * patches_height
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

    patches.draw()
    turtleContext.clearRect(0,0,turtleCanvas.width(), turtleCanvas.height())
    turtles.draw()
#    displayContext.drawImage(m_canvas,0,0)
#    context = displayContext
    

# User stuff below...or so that is the plan................................................
#
#

window.redraw = redraw


go = ->
    console.log('calculating')
    tm = Date.now()
    patches.do ->
        @calculate()
    turtles.do ->
        @heading += Math.random() * 1 - .5
        @forward 1
    console.log('Took ')
    console.log(Date.now() - tm)        
    console.log('setting new color')        
    patches.do ->
        @setColor @nextColor
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
    numLiveNeighbors = @neighbors.withPV('pcolor', color.black).count()
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


$(document).ready( () ->
    console.log('ready')
    patchCanvas = $('#patchCanvas')
    patchContext = patchCanvas[0].getContext('2d')
    turtleCanvas = $('#turtleCanvas')
    turtleContext = turtleCanvas[0].getContext('2d')
    create_patches()
    redraw()
    
    $('#setupButton').on('click', ->
        patches.do ->
            newColor = color.white
            newColor = if Math.random() < .1  then color.black else color.white 
            @setColor newColor
        create_turtles(1)
        redraw()
    )

    $('#goButton').on('click', goHandler)
    console.log('all systems go')
)
