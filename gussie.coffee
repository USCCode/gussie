##....working on changing turtleset to make a copy on .with()
#  all turtlesets should be copies, and turtles point back to their
#   turtlesets so they can delete themselves when they die.
# 
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
# 
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

Array::one_of = ->
    @[Math.floor(Math.random() * @length)]

# Array Remove - By John Resig (MIT Licensed)
# from,to are indeces
Array::remove = (from, to) ->
  rest = @slice((to || from) + 1 || @length)
  @length =  if (from < 0) then (@length + from) else from
  @push.apply(@, rest)

# Remove element if it exists.
Array::eliminate = (element) ->
    i = @indexOf(element)
    if i >= 0
        @remove(i)
    return @


if (typeof Object.create != 'function')
    Object.create =  (o) ->
        F = -> 
        F.prototype = o
        return new F()

# a Turtle keeps track of all the sets it is in with @_sets
# when it dies it removes itself from all those sets.

#The Turtle
class Turtle
    constructor: ->
        @_xcor = 100 # @_ means private instance variable: OBEY
        @_ycor = 100 
        @heading = 0
        @who = who++
        @color = color.red
        @myLinks = new Turtleset
        @size = 1
        @_sets = [] #array of all the Turtlesets that I belong to
        @shape = 'default'
        turtles.add(@) #all turtles are in the turtles set

    # Add me Turtleset tset
    addTo: (tset) ->
        @_sets.push(tset)

    removeFrom: (tset) ->
        @_sets.eliminate(tset)

    xcor: (x) ->
        @_xcor = x if x?
        return @_xcor

    ycor: (y) ->
        @_ycor = y if y?
        return @_ycor

    key: ->
        @who
        
    pxcor: (px) ->
        if px?
            @xcor(px * patches_size + patches_radius)
        return Math.floor (@xcor() / patches_size)

    pycor: (py) ->
        if py?
            @ycor(py * patches_size + patches_radius)
        return Math.floor (@ycor() / patches_size)

    setxy: (x,y) ->
        @xcor(x)
        @ycor(y)

    setpxy: (x,y) ->
        @pxcor(x)
        @pycor(y)

    myLinks: -> @_myLinks

    createLinkWith: (other) ->
        link = new Link(@,other)
        @myLinks.add(link)
        other.myLinks.add(link)

    linkNeighbors: ->
        myself = @
        new Turtleset @myLinks.values ->
            if @a == myself then @b else @a

    do: (f) ->
        f.apply(@)

    draw: ->
        @drawShape()

        # Calculate wraparound coordinates: NOTE: this only works for
        # shapes that wrap around ONCE, and no more. It does not handle bigger shapes.
        radius = @size * patches_radius
        ox = @_xcor
        oy = @_ycor
        nx = @_xcor
        nx = @_xcor - canvas_width if @_xcor + radius > canvas_width
        nx = canvas_width + @_xcor if @_xcor - radius < 0
        ny = @_ycor
        ny = @_ycor - canvas_width if @_ycor + radius > canvas_height
        ny = canvas_height + @_ycor if @_ycor - radius < 0
        if nx != ox
            @xcor(nx)
            @drawShape()
            @xcor(ox)
        if ny != oy
            @ycor(ny)
            @drawShape()
            @ycor(oy)
        if nx != ox and ny != oy
            @xcor(nx)
            @ycor(ny)
            @drawShape()
            @xcor(ox)
            @ycor(oy)
        return @

    drawShape: ->
        turtleContext.save()
        turtleContext.fillStyle = @color
        turtleContext.translate(Math.round(@xcor()),Math.round(@ycor()))
        turtleContext.scale(@size,@size)
        turtleContext.rotate(@heading)
        if @shape == 'circle'
            turtleContext.beginPath()            
            turtleContext.arc(0,0,patches_radius,0,2*Math.PI)
            turtleContext.fill()
        else
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

    dx: ->
        return Math.cos @heading

    dy: ->
        return Math.sin @heading

    forward: (distance) ->
        distance = distance * patches_size
        dx = Math.cos(this.heading) * distance
        dy = Math.sin(this.heading) * distance
        @xcor(@xcor() + dx)
        @ycor(@ycor() + dy)
        [x, y] = wrap(@xcor(),@ycor())
        @xcor(x)
        @ycor(y)
        return @

    # Return the angle that would make this turtle point to otherx,othery
    # We look for the min
    towardsxy: (otherx,othery) ->
        dx = otherx - @xcor()
        dy = othery - @ycor()

        #Wraparound fix
        if 2 * Math.abs(dx) > canvas_width #it is closer to go around
            if dx > 0 #he is to my right
                otherx = @xcor() - canvas_width + dx
            if dx < 0 #he is to my left
                otherx = @xcor() + canvas_width + dx
            dx = otherx - @xcor()
        if 2 * Math.abs(dy) > canvas_height #it is closer to go around
            if dy > 0 
                othery = @ycor() - canvas_height + dy
            if dy < 0 
                othery = @ycor() + canvas_height + dy
            dy = othery - @ycor()

        angle = Math.atan (dy / dx)
        angle = angle + Math.PI if dx < 0
        return angle

    towards: (other) ->
        return @towardsxy(other.xcor(), other.ycor())

    distancexy: (otherx,othery) ->
        dx = Math.abs (otherx - @xcor())
        dy = Math.abs (othery - @ycor())
        return Math.sqrt(Math.pow(Math.min(dx, canvas_width - dx), 2) + Math.pow(Math.min(dy, canvas_height - dy),2) ) / (2 * patches_radius)


    distance: (other) ->
        @distancexy other.xcor(),other.ycor()

    face: (other) ->
        @heading = @towards other
        return @

    #A turtle dies by removing itself from all its @_sets (which includes 'turtles')
    die: ->
        for tset in @_sets
            tset.remove(@)

    #remove this turtle from tset turtleset and return that
    other: (tset) ->
        return tset.minus(@)

window.Turtle = Turtle

class Link extends Turtle

    #a,b are start and end Turtle
    constructor: (@a,@b)->
        @heading = 0
        @who = who++
        @color = color.black        
        @directed = false
        @size = 1
        @_sets = [] #array of all the Turtlesets that I belong to
        links.add(@)

    fixCoords: ->
        @_xcor = @a.xcor()
        @_ycor = @a.ycor()
        @face(@b) #set my direction
        length = @distance @b
        @size = length 
        @forward(@size / 2)
        return @
        
    drawShape: ->
        turtleContext.save()
        turtleContext.fillStyle = @color
        turtleContext.strokeStyle = @color
        turtleContext.lineWidth = 2 #if this is 1 then horizontal line disappears.
        turtleContext.translate(Math.round(@xcor()),Math.round(@ycor()))
        turtleContext.rotate(@heading)
        turtleContext.beginPath()        
        startx = -patches_radius * @size #+ patches_radius #hit the end of the circle around b
        endx = patches_radius * @size #- patches_radius
        turtleContext.moveTo(startx,0)
        turtleContext.lineTo(endx,0)
        if @directed
            tip = patches_radius / 2
            turtleContext.lineTo(endx - tip, -tip)
            turtleContext.moveTo(endx,0)
            turtleContext.lineTo(endx - tip, tip)
        turtleContext.stroke()
        turtleContext.restore()
        return @



#Turtleset stores the turtles in @_turtles as an object
# with turtle.key as the key
#It is a set (no duplicates) based on the key.
#
# @with and other commands return a COPY of this turtleset, but the @_turtles themselves
#   are not copied (that would not make sense, we only want one copy of each turtle).
# 
class Turtleset
    constructor: (array) -> #TODO: check that array is an Array
        @_turtles = {}
        @size = 0
        if array
            for turtle in array
                @add turtle

    add: (turtle) ->
        if not @_turtles.hasOwnProperty turtle.key or not @_turtles[turtle.key()]
            @size++
            turtle.addTo(@)
        @_turtles[turtle.key()] = turtle
        return @

    #Return a new turtleset with all the same turtles except 'turtle'
    #The returned turtleset inherits from this one, but with turtle delete (set to undefined)
    minus: (turtle) ->
        c = new Turtleset
        for key,t of @_turtles when t != turtle
            c.add t
        return c

    # Return a new Turtleset which is a copy of this one
    copy: ->
        c = new Turtleset
        for key,turtle of @_turtles
            c.add turtle
        return c

    get: (key) ->
        @_turtles[key]

    #Returns an array with the values of the given property for all, like 'of'
    values: (property) ->
        if property instanceof Function
            return (property.apply(turtle) for key,turtle of @_turtles)
        return (turtle[property] for key,turtle of @_turtles)

    count: ->
        return @size

    one_of : ->
        keys = (key for key,turtle of @_turtles) #TODO: @keys optimization
        chosenKey = keys[Math.floor(Math.random() * keys.length)]
        return @_turtles[chosenKey]

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
        result = new Turtleset
        for key,turtle of @_turtles when turtle?
            if f.apply(turtle)
                result.add turtle
        return result

    withPV: (property, value) ->
        result = new Turtleset
        for key,turtle of result.turtles
            if property instanceof Function
                if property.apply(turtle) == value
                    result.add turtle
            else if turtle[property] == value
                result.add turtle
        return result        

    do: (f) ->
        for key,turtle of @_turtles
            f.apply(turtle)

    doOwn: (f) ->
        for key,turtle of @_turtles
            turtle[f]()

    # Remove turtle from this turtleset, nothing more.
    remove: (turtle) ->
        @size--
        delete @_turtles[turtle.key()]

    draw: ->
        turtle.draw() for key,turtle of @_turtles

window.Turtleset = Turtleset

window.turtles = new Turtleset
turtles = window.turtles

turtle = (w) ->
    turtles.get(w)

window.links = new Turtleset
links = window.links

#global var where we store a Turtleset of patches
window.patches = 0
patches = window.patches

patch = (x,y) ->
    patches.get(x + "-" + y)

class Patch extends Turtle
    constructor: (@pxcor, @pycor)->
        @xcor(0) # the center point of the patch
        @ycor(0)
        @pxcor = 0 # OVERRIDE Turtle.pxcor
        @pycor = 0 # the patch's position (in patch coordinates)
        @pcxcor = 0 #the top-left point of the patch, in pixels, used for drawing
        @pcycor = 0
        @pcolor = "#AA5555"
        @drawnColor = null
        @neighbors = null  #a turtleset with my neighbors
        @who = @key()
        @_sets = [patches] #array of all the Turtlesets that I belong to


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

# Returns coordinates that are within the canvas, by wrapping around
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


class Vector
    constructor: (@dx,@dy) ->

    add: (v) ->
        new Vector(@dx+v.dx, @dy+v.dy)

    scale: (c) ->
        new Vector(@dx*c, @dy*c)

#Layout all the turtles given all the links.
# turtles repel each other 1/d^2
# linked turtles are attracted/repelled to the link's springLength
layout_magspring = (springLength )->
    remainingTurtles = turtles.copy()
    turtles.do ->
        @forces = []
    turtles.do ->
        from = @
        remainingTurtles = remainingTurtles.minus(@)
        remainingTurtles.do ->
            #apply repulsive force between 'from' and '@'
            oldHeading = @heading
            @face(from)
            hisForce = new Vector(@dx(), @dy())
            d = @distance(from)
            hisForce = hisForce.scale(1 / (d * d))
            from.forces.push(hisForce)
            myForce = hisForce.scale(-1)
            @forces.push(myForce)
            @heading = oldHeading
    links.do ->
        a = @a
        b = @b
        @a.do ->
            oldHeading = @heading
            @face(b)
            if @distance(b) > springLength
                bForce = new Vector(@dx(),@dy())
                b.forces.push(bForce)
                aForce = bForce.scale(-1)
                @forces.push(aForce)
            else 
                aForce = new Vector(@dx(),@dy())
                @forces.push(aForce)                
                bForce = aForce.scale(-1)                
                b.forces.push(bForce)
            @heading = oldHeading
    turtles.do ->
        @totalForce = @forces.reduce (a,b) ->
            a.add(b)
        @xcor(@xcor() + @totalForce.dx)
        @ycor(@ycor() + @totalForce.dy)
                    

window.layout_magspring = layout_magspring                
    
create_turtles = (num) ->
    for i in [0...num]
        new Turtle

clear_all = ->
    turtles.do( -> @die())
    links.do( -> @die())
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
    links.doOwn('fixCoords')
    links.draw()

window.redraw = redraw

#Setup the canvas global variables
$ ->
    console.log('ready')

#Create the patches, according to the user's need
# pxmax,pymax are the number of patches in each dimension.
# size: is the size of the patches in pixels. Patches are square.
window.make_patches = (p) ->
    max_pxcor = p.pxmax
    max_pycor = p.pymax    
    patches_size = p.size
    patches_radius = patches_size / 2
    canvas_width = patches_size * max_pxcor
    canvas_height = patches_size * max_pycor
    create_patches()
    redraw()
    
window.make_world = (p) ->
    $world = $('<div class="widget" id="world"><canvas id="patchCanvas"></canvas><canvas id="turtleCanvas"></canvas></div>')
    $world.css('top', p.top) if p.top?
    $world.css('left', p.left) if p.left?
    $world.width p.width if p.width?
    $world.height p.height if p.height?
    $('#frame').append $world
    patchCanvas = $('#patchCanvas')
    patchContext = patchCanvas[0].getContext('2d')
    turtleCanvas = $('#turtleCanvas')
    turtleContext = turtleCanvas[0].getContext('2d')


_forever_call = (f, id) ->
    fun = ->
        if $('#' + id).prop('checked')
            f()
            setTimeout fun,0
    return fun
    
window.make_button = (p) ->
    id = p.id
    if p.toggle?
        $button = $("<input class=\"widget\" type=\"checkbox\" id=\"#{id}\"/>
            <label class=\"widget\" for=\"#{p.id}\">#{p.label}</label>")
    else
        $button = $("<button class=\"widget\" id=\"#{p.id}\">#{p.label}</button>)")
    $('#frame').append $button
    if p.toggle?
        $button.on('change',_forever_call(p.click,p.id))
    else
        $button.on('click',p.click)
    $button.css('top', p.top) if p.top?
    $button.css('left', p.left) if p.left?
    $('#'+ p.id).button()

window.make_slider = (p) ->
    displayID = p.id + 'Display'
    $slider =  $("<div class=\"ui-widget widget sliderContainer\"><div id=\"#{p.id}\"></div><p>#{p.label}<span id=\"#{displayID}\"></span></p></div>")
    $slider.css('top', p.top) if p.top?
    $slider.css('left', p.left) if p.left?
    $('#frame').append $slider
    $slider.width p.width if p.width?
    $slider.height p.height if p.height?
    $('#' + p.id).slider
        min: p.min
        max: p.max
        value: p.value
        slide: (event,ui) ->
            $('#' + displayID).html(ui.value)
        create: (event,ui) ->
            $('#' + displayID).html(16)


#TODO: Sample programs
# grah coloring: link and layout primitives
# active edges:
#   graph-oriented programming: Following Sussman's paper where a node
#   holds variables and edges represnt evidence for the vars' values.
# combinatorial auction

