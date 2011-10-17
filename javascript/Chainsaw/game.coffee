class window.Chainsaw
  constructor: (canvas) ->
    console.log 'Chainsaw game initiated'

    # initiate canvas
    #@canvas = canvas
    #@context = @canvas.getContext '2d'
    #@height = canvas.height
    #@width = canvas.width
    @paper = Raphael('canvas', 600, 330)
   
    # some game variables defined here for easy access
    @game =
      playerName: 'Player'
      level: 'practice'
      inProgress: true

    @logs =
      color: '#c09256'
      count: 4
      list: [] # the set of current logs

    # the 'ideal log' that you're trying to cut 
    @referenceLog =
      length: 100
      tolerance: (1/8)*100

    # the fuel meter 
    @fuel =
      initial: 40 # you start with this much
      current: 40
      el: $('#fuel #tank') # the DOM element that holds the fuel tank
    
    @mouse =
      cuttable: false # TODO think of a better structure for this
      down: false
      x: 0
      y: 0

    # define callbacks for mouse events
    $(window).mousemove((e) => @mousemove(e) if e.target is @canvas)

    $('#startButton').click => @generateLogs()
    $('#stopButton').click => @analyzeCuts()
    
    @generateLogs()


  generateLogs: -> # generate a set of logs
    @logs.list = []

    for i in [1..@logs.count]
      # Push a new log to the array, with random x and width values.
      @logs.list.push
        width: 300+Math.floor(Math.random()*200)
        height: 35
        x: 20+Math.floor(Math.random()*31)
        y: 60*i-10
        cuts: []
        active: true

      # Add the width of the log as the first 'cut'
      @logs.list[i-1].cuts.push @logs.list[i-1].width + @logs.list[i-1].x

    @renderLogs()

  renderLogs: ->
    #clear the canvas
    @paper.clear()
    
    renderLogs = @paper.set()
    for log in @logs.list
      # Draw the log itself
      renderLogs.push @paper.rect log.x, log.y, log.width, log.height

      # If it's active, draw the top border
      if log.active
        @paper.rect(log.x, log.y, log.width, 5)
              .mouseover (e) =>
                @tryCut e.layerX, e.layerY if e.which is 1
              .attr fill: '#764d13'
    renderLogs.attr fill: @logs.color

  tryCut: (x,y) ->
    for log in @logs.list
      if x > log.x and x < (log.x + log.width) and y > log.y-5 and y < (log.y+15) and log.active
        @paper.rect(x, log.y+5, 2, 30)
              .attr fill: 'white', "stroke-width": 0
    

  mousemove: (e) ->
    return if e.which isnt 1 # we only care if the mouse is down

    # Store mouse position
    @mouse.x = e.layerX
    @mouse.y = e.layerY
    
    # Check if we're touching any of the logs
    for log in @logs.list
      if @mouse.x > log.x and @mouse.x < (log.x + log.width) and @mouse.y > log.y and @mouse.y < (log.y+5) and log.active # we're cutting within an active 'cut area' 

        # Draw the 'cut' line
        # @context.fillStyle = 'white'
        # @context.fillRect @mouse.x, log.y+5, 1, 30
        log.cuts.push @mouse.x
        console.log 'cut made'

  analyzeCuts: -> # lets see which cuts were valid
    validCuts = 0
    for log in @logs.list
      lastCutPosition = 0
     
      # check the difference betwen each cut and the last one
      for cut in log.cuts
        # @context.font="13pt Helvetica"
        if Math.abs((cut - lastCutPosition) - @referenceLog.length) < @referenceLog.tolerance
          # The cut was valid
          # @context.fillStyle = 'green'
          # @context.fillText(":)", cut-15, log.y+30)
          validCuts++
        else
          # The cut was invalid
          # @context.fillStyle = 'red'
          # @context.fillText("X", cut-15, log.y+30)
        lastCutPosition = cut

    alert "Accepted cuts: "+validCuts
