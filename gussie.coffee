#gussie.coffee by jmvidal@gmail.com
# no bugs here, just lots of newts
#
#Coordinates:
# Turtle.xcor and ycor are real-valued and map directly into the underlying canvas.
# Turtle.who is an int, starting at 0
# Patch.pxcor and pycor are ints and count the patches, starting at 0,0 in the top-left
#  and incrementing by 1. The 
#   
patchCanvas = 0
patchContext = 0
turtleCanvas = 0
turtleContext = 0

#The size of the patches, in canvas pixels. Patches must be square
patches_size = 10 
patches_radius = patches_size / 2

#How many patches there will be in each direction.
max_pxcor = 40
max_pycor = 40

#The canvas width and height
canvas_width = patches_size * max_pxcor
canvas_height = patches_size * max_pycor

#Global counter for the next who number
who = 0
color = 
    black: "#555555"
    white: "#FEFEFE"
    red: "#FF0000"
    green: "#00FF00"
    blue: "#0000FF"
    yellow: "#FFFF00"
    magenta: "#FF00FF"
    cyan: "#00FFFF"

window.color = color

#Add methods to the built-in array
Array::min = ->
    Math.min.apply null,this

Array::max = ->
    Math.max.apply null,this


if (typeof Object.create != 'function')
    Object.create =  (o) ->
        F = -> 
        F.prototype = o
        return new F()


#The Turtle
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
        turtleContext.lineTo(-patches_radius,-patches_radius)
        turtleContext.lineTo(patches_radius,0)
        turtleContext.lineTo(-patches_radius,patches_radius)
        turtleContext.lineTo(0,0)
        turtleContext.fill()
        turtleContext.restore()
        return @
        
    setHeading: (@heading) -> 
        return @

    forward: (distance) ->
        distance = distance * patches_size
        dx = Math.cos(this.heading) * distance
        dy = Math.sin(this.heading) * distance
        @xcor += dx
        @ycor += dy
        [@xcor, @ycor] = wrap(@xcor,@ycor)
        return @

    # Return the angle that would make this turtle point to otherx,othery
    # We look for the min
    towardsxy: (otherx,othery) ->
        dx = otherx - @xcor
        dy = othery - @ycor

        #Wraparound fix
        if 2 * Math.abs(dx) > canvas_width #it is closer to go around
            if dx > 0 #he is to my right
                otherx = @xcor - canvas_width + dx
            if dx < 0 #he is to my left
                otherx = @xcor + canvas_width + dx
            dx = otherx - @xcor
        if 2 * Math.abs(dy) > canvas_height #it is closer to go around
            if dy > 0 
                othery = @ycor - canvas_height + dy
            if dy < 0 
                othery = @ycor + canvas_height + dy
            dy = othery - @ycor

        angle = Math.atan (dy / dx)
        angle = angle + Math.PI if dx < 0
        return angle

    towards: (other) ->
        return @towardsxy(other.xcor, other.ycor)

    distancexy: (otherx,othery) ->
        dx = Math.abs (otherx - @xcor)
        dy = Math.abs (othery - @ycor)
        return Math.sqrt(Math.pow(Math.min(dx, canvas_width - dx), 2)
            + Math.pow(Math.min(dy, canvas_height - dy),2) )

    distance: (other) ->
        @distancexy other.xcor,other.ycor

    face: (other) ->
        @heading = @towards other
        return @

    #A turtle dies by removing itself from the 'turtles' global variable.
    die: ->
        turtles.delete @who

window.Turtle = Turtle

#Turtleset stores the turtles in @turtles as an object
# with turtle.key as the key
#It is a set (no duplicates) based on the key.
#NOTE: It can be that @turtles[x] == undefined, for some x,
# this is how we remove a turtle from the set so that it is not inherited from its parent.
# 
class Turtleset
    constructor: (array) -> #TODO: check that array is an Array
        @turtles = {}
        @size = 0
        if array
            for turtle in array
                @add turtle

    add: (turtle) ->
        if not @turtles.hasOwnProperty turtle.key or not @turtles[turtle.key()]
            @size++
        @turtles[turtle.key()] = turtle
        return @

    #Return a new turtleset with all the same turtles except 'turtle'
    #The returned turtleset inherits from this one, but with turtle delete (set to undefined)
    minus: (turtle) ->
        nt = Object.create @
        nt.turtles = Object.create @turtles
        nt.turtles[turtle.key()] = undefined
        nt.size--
        return nt
#        return new Turtleset (t for key,t of @turtles when t.who != turtle.who)

    get: (key) ->
        @turtles[key]

    #Returns an array with the values of the given property for all, like 'of'
    values: (property) ->
        if property instanceof Function
            return (property.apply(turtle) for key,turtle of @turtles when turtle)
        return (turtle[property] for key,turtle of @turtles when turtle)

    count: ->
        return @size

    one_of : ->
        keys = (key for key,turtle of @turtles when turtle) #TODO: @keys optimization
        chosenKey = keys[Math.floor(Math.random() * keys.length)]
        return @turtles[chosenKey]

    #Returns a turtleset containing all the turtles that have a minimal value for prop
    min_of : (prop) ->
        vals = @values prop
        minVal = vals.min()
        return @withPV(prop,minVal)

    #Same as min_of
    with_min: (prop) ->
        return @min_of prop

    min_n_of: (prop, n) ->

    #Returns one of the turtles with a min value for prop.
    min_one_of: (prop) ->
        return @min_of(prop).one_of()

    max_of: (prop) ->
        vals = @values prop
        maxVal = vals.max()
        return @withPV(prop,maxVal)

    with_max: (prop) ->
        return @max_of prop
                
    max_one_of: (prop) ->
        return @max_of(prop).one_of()
        
    with: (f) ->
        result = Object.create @
        result.turtles = Object.create @turtles
        for key,turtle of result.turtles when turtle
            if not f.apply(turtle)
                result.turtles[key] = undefined
                result.size--
        return result

    withPV: (property, value) ->
        result = Object.create @
        result.turtles = Object.create @turtles
        for key,turtle of result.turtles when turtle
            if property instanceof Function
                if property.apply(turtle) != value
                    result.turtles[key] = undefined
                    result.size--
            else if turtle[property] != value
                result.turtles[key] = undefined
                result.size--
        return result        

    do: (f) ->
        for key,turtle of @turtles when turtle
            f.apply(turtle)

    delete: (who) ->
        @size--
        @turtles[who] = undefined

    draw: ->
        turtle.draw() for key,turtle of @turtles when turtle

window.Turtleset = Turtleset

window.turtles = new Turtleset
turtles = window.turtles

turtle = (w) ->
    turtles.get(w)
        

#global var where we store a Turtleset of patches
window.patches = 0
patches = window.patches

patch = (x,y) ->
    patches.get(x + "-" + y)

class Patch extends Turtle
    constructor: (@pxcor, @pycor)->
        @xcor = 0 # the center point of the patch
        @ycor = 0
        @pxcor = 0 # the patch's position (in patch coordinates)
        @pycor = 0
        @pcxcor = 0 #the top-left point of the patch, in pixels, used for drawing
        @pcycor = 0
        @pcolor = "#AA5555"
        @drawnColor = null
        @neighbors = null  #a turtleset with my neighbors
        @who = @key()

    draw: ->
        if not (@drawnColor == @pcolor)
            @drawnColor = @pcolor
            patchContext.fillStyle = @pcolor
            patchContext.fillRect(@pcxcor, @pcycor, patches_size, patches_size)
            
    key: ->
        @pxcor + "-" + @pycor
        
    setColor: (@pcolor) ->

    neighbors: () ->
        return @neighbors

wrap = (x,y) ->
    x = x % canvas_width
    x =  canvas_width + x if x < 0
    y = y % canvas_height
    y =  canvas_height + y if y < 0
    return [x,y]

# Create all the patches, set window.patches variable 
create_patches = () ->
    $('#world').attr('width',canvas_width).width(canvas_width) 
    $('#world').attr('height',canvas_height).height(canvas_height)
    $('#patchCanvas').attr('width',canvas_width)
    $('#patchCanvas').attr('height',canvas_height)
    $('#turtleCanvas').attr('width',canvas_width) #setting it in CSS (.width()) does not work!
    $('#turtleCanvas').attr('height',canvas_height)
    #create all the patches
    window.patches = new Turtleset
    patches = window.patches
    console.log('making patches')
    for x in [0...max_pxcor]
        for y in [0...max_pycor]
            p = new Patch(x,y)
            p.pxcor = x
            p.pycor = y
            p.pcxcor = x * patches_size
            p.pcycor = y * patches_size
            p.xcor = p.pcxcor + (patches_size / 2)
            p.ycor = p.pcycor + (patches_size / 2)
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

window.Patch = Patch

create_turtles = (num) ->
    for i in [0...num]
        new Turtle

clear_all = ->
    turtles.do( -> @die())
    patches = {}
    who = 0
    create_patches()
    redraw()

window.clear_all = clear_all
    
    
animate = true

#Redraw everything in the canvas.
redraw =  ->
    patches.draw()
    turtleContext.clearRect(0,0,turtleCanvas.width(), turtleCanvas.height())
    turtles.draw()

window.redraw = redraw

#Create the patches, setup the world
$ ->
    console.log('ready')
    patchCanvas = $('#patchCanvas')
    patchContext = patchCanvas[0].getContext('2d')
    turtleCanvas = $('#turtleCanvas')
    turtleContext = turtleCanvas[0].getContext('2d')
    create_patches()
    redraw()
  

#TODO: Sample programs
# n-queens problem
# grah coloring: link and layout primitives
# combinatorial auction

