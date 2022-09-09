HCP = 20
HOUR = 3600
MINUTE = 60

buttons = {}
states = {}

qr = null
timeout = false
currState = null

diag = 0 

class Button
	constructor : (@text,@x,@y,@w,@h,@bg='white',@fg='black') ->
		@visible = true
	draw : (disabled) ->
		#if disabled then fill 'lightgray' else fill @bg
		if @visible 
			fill @bg
			rect @x,@y,@w,@h
			textSize 0.04*diag
			fill @fg
			text @text,@x,@y
	inside : -> -@w/2 <= mouseX-@x <= @w/2 and -@h/2 <= mouseY-@y <= @h/2

class ImageButton extends Button
	constructor : (@image,x,y,w,h) -> super '',x,y,w,h
	draw :  -> if @image then image @image,(width-@w)/2,(height-@h)/2,@w,@h

class RotateButton extends Button
	constructor : (x,y,w,h,@degrees,bg,fg,@player) -> super '',x,y,w,h,bg,fg

	draw : ->
		secs = states.Editor.clocks[@player]
		if secs == 0 then fill 'gray'
		[h,m,s] = hms Math.trunc secs
		ss = if h >= 1 then d2(h) + ':' + d2(m) else d2(m) + ':' + d2(s)

		fill @bg
		rect @x,@y,@w,@h

		push()
		translate @x,@y
		rotate @degrees
		textSize 0.18*diag
		fill @fg
		text ss,0,0.017*height
		textSize 0.05*diag
		text '+' + round3(states.Editor.bonuses[@player])+'s',0,0.15*height
		if states.Editor.clocks[@player]<=0 then @bg = 'red' #text 'Out of time',0,-0.15*height
		pop()

class EditButton extends Button
	constructor : (text,x,y,w,h,fg='gray') -> super text,x,y,w,h,'black',fg
	draw : ->
		textSize 0.05*diag
		fill @fg
		text @text,@x,@y

class DeadButton extends Button
	constructor : (text,x,y,fg='lightgray') -> super text,x,y,0,0,'black',fg
	draw : ->
		textSize 0.04*diag
		fill @fg
		text @text,@x,@y

class ColorButton extends Button
	constructor : (@fg,x,y) -> super '',x,y,0,0
	draw : ->
		push()
		textAlign CENTER,CENTER
		textSize 0.04*diag
		fill @fg
		text @text,@x,@y
		pop()

class State
	constructor : -> @transitions = {}
	createTrans : (t) -> 
		arr = t.split ' '
		for pair in arr
			[key,target] = pair.split '=>'
			@transitions[key] = target
	message : (key) ->
		console.log "clicked #{@name}.#{key} => #{@transitions[key]}"
		if key of @transitions
			currState = states[@transitions[key]]
			console.log currState,currState
			currState.patch()
		else console.log 'missing transition:',key
	patch : ->
	draw : ->

class ClockState extends State
	constructor : (@name) ->
		super()
		@createTrans 'qr=>ClockState pause=>ClockState left=>ClockState right=>ClockState new=>Editor' #  play=>ClockState
		@paused = true
		@player = -1
		buttons.pause.visible = false

	uppdatera : ->
		console.log 'uppdatera'
		if  @paused then return
		if states.Editor.clocks[@player] > 0 then states.Editor.clocks[@player] -= 1/60
		if states.Editor.clocks[@player] <= 0 
			states.Editor.clocks[@player] = 0
			timeout = true

	message : (key) ->
		if key == 'qr' 
			toggleFullScreen()
			resizeCanvas windowWidth, windowHeight
		if key == 'left'
			if timeout then return
			if @player == 0 # and not timeout[0]
				states.Editor.clocks[0] += states.Editor.bonuses[0]
			@paused = false
			@player = 1
			buttons.left.fg = 'black'
			buttons.right.fg = 'white'
		if key == 'pause'
			@paused = true
			buttons.left.fg = 'black'
			buttons.right.fg = 'black'
		if key == 'right'
			if timeout then return
			if @player == 1 # and not timeout[1]
				states.Editor.clocks[1] += states.Editor.bonuses[1]
			@paused = false
			@player = 0
			buttons.left.fg = 'white'
			buttons.right.fg = 'black'

		buttons.pause.visible = not @paused
		buttons.new.visible = @paused
		super key

class Editor extends State
	constructor : (@name) ->
		super()
		@sums = [0,1+2,0,0,2,0]

		@clocks = [3*60,3*60] # seconds
		@bonuses = [2,2] # seconds
		buttons.b0.fg = 'yellow'
		buttons.b1.fg = 'yellow'
		buttons.e1.fg = 'yellow'
		buttons.white.text = '3m + 2s'

		@hcpSwap = 1
		arr = 'red white green reflection bonus hcp ok=>ClockState swap=>Editor'.split ' '
		for i in range 6
			letter = 'abcdef'[i]
			arr.push letter
			for j in range 6
				name = letter + j
				arr.push name + '=>Editor'
		@createTrans arr.join ' '
		console.log arr.join ' '

	message : (key) ->
		if key == 'swap'
			@hcpSwap = -@hcpSwap
		if key != 'swap' and key != 'ok'
			buttons[key].fg = if buttons[key].fg == 'gray' then 'yellow' else 'gray'
			letter = key[0]
			i = 'abcdef'.indexOf letter
			factor = if i==5 then 20 else 1
			j = key[1]
			number = factor * [1,2,4,8,15,30][j]
			@sums[i] = if buttons[key].fg == 'gray' then @sums[i]-number else @sums[i]+number
		if key == 'ok' 
			timeout = false
			buttons.left.fg = 'black'
			buttons.right.fg = 'black'
		@uppdatera()
		super key

	uppdatera : ->
		buttons.white.text = @compact()
		@handicap()
		if @hcp == 0
			buttons.red.text   = ''
			buttons.green.text = ''
		else
			buttons.red.text   = pretty(@players[0][0]) + ' + ' + pretty(@players[0][1])
			buttons.green.text = pretty(@players[1][0]) + ' + ' + pretty(@players[1][1])

	compact : ->
		headers = 'h m s m s t'.split ' '
		header0 = ''
		header1 = ''
		for i in range 0,3
			if @sums[i]>0 then header0 += @sums[i] + headers[i]
		for i in range 3,5
			if @sums[i]>0 then header1 += @sums[i] + headers[i]
		header = header0
		if header1.length > 0 then header += ' + ' + header1
		header

	handicap : ->
		@hcp = @hcpSwap * @sums[5] / (HCP * 60) # 0.0 .. 1.0
		@refl = HOUR * @sums[0] + MINUTE * @sums[1] + @sums[2] # sekunder
		@bonus =                  MINUTE * @sums[3] + @sums[4] # sekunder
		@players = []
		@players[0] = [@refl*(1+@hcp), @bonus*(1+@hcp)]
		@players[1] = [@refl*(1-@hcp), @bonus*(1-@hcp)]
		@clocks  = [@players[0][0], @players[1][0]]
		@bonuses = [@players[0][1], @players[1][1]]

makeEditButtons = ->
	for i in range 6
		letter = 'abcdef'[i]
		xsize = width/6
		ysize = height/10
		xoff = xsize/2 + (width-6*xsize)/2
		yoff = 0.33*height
		shown='h m s m s elo'.split ' '
		buttons[letter] = new DeadButton shown[i], xoff+xsize*i, 0.26*height 
		for j in range 6
			number = [1,2,4,8,15,30][j]
			name = letter + j
			factor = if i==5 then HCP else 1
			buttons[name] = new EditButton factor * number, xoff+xsize*i, yoff+ysize*j, xsize, ysize, 'gray'

createState = (key,klass) -> states[key] = new klass key

round3 = (x) -> Math.round(x*1000)/1000

pretty = (tot) ->
	s = tot % 60
	tot = (tot - s) / 60
	m = tot % 60
	tot = (tot - m) / 60
	h = tot % 60
	header = ''
	if h>0 then header += round3(h) + 'h'
	if m>0 then header += round3(m) + 'm'
	if s>0 then header += round3(s) + 's'
	header

d2 = (x) ->
	x = Math.trunc x
	if x < 10 then '0'+x else x
console.log d2(3), '03'

hms = (x) ->
	s = x %% 60
	x = x // 60
	m = x %% 60
	x = x // 60
	h = x
	[h,m,s]
console.log hms(180), [0,3,0]

###################################

preload = -> qr = loadImage 'qr.png'

#windowResized = -> resizeCanvas windowWidth, windowHeight

setup = ->
	os = navigator.appVersion
	console.log os
	if os.indexOf('Linux') >= 0 # android/linux
		createCanvas screen.width,screen.height
		#createCanvas displaywidth,displayHeight
	else
		createCanvas window.innerWidth,window.innerHeight # Windows or Mac

	textFont 'Lucida Sans Unicode'
	diag = sqrt width*width + height*height

	background 'black'

	textAlign CENTER,CENTER
	rectMode CENTER
	angleMode DEGREES

	w = width
	h = height

	# Main Page
	size = 0.12*h # qr
	buttons.left    = new RotateButton    0.5*w, 0.22*h, w,     0.44*h, 180, 'orange', 'black', 0 # eg up
	buttons.right   = new RotateButton    0.5*w, 0.78*h, w,     0.44*h,   0, 'green',  'black', 1 # eg down
	buttons.pause   = new Button 'pause', 0.25*(w-size), 0.50*h, (w-size)/2, size
	buttons.new     = new Button 'new',   w-0.25*(w-size), 0.50*h, (w-size)/2, size
	buttons.qr      = new ImageButton qr,0.5*w, 0.5*h, size, size
	
	# Edit Page
	buttons.swap  = new Button 'swap', 0.33*w, 0.93*h, 0.22*w, 0.08*h
	buttons.ok    = new Button 'ok',   0.67*w, 0.93*h, 0.22*w, 0.08*h
	buttons.red   = new ColorButton 'red',   w/2, 0.03*h
	buttons.white = new ColorButton 'white', w/2, 0.09*h
	buttons.green = new ColorButton 'green', w/2, 0.15*h
	buttons.reflection = new DeadButton 'reflection', 0.25*w, 0.21*h
	buttons.bonus = new DeadButton 'bonus', 0.66*w, 0.21*h
	buttons.hcp   = new DeadButton 'hcp', 0.92*w, 0.21*h

	makeEditButtons()
	createState 'ClockState', ClockState
	createState 'Editor',     Editor
	currState = states.ClockState

draw = ->
	background 'black'

	states.ClockState.uppdatera()

	for key of currState.transitions
		target = currState.transitions[key]
		if key of buttons then buttons[key].draw target == undefined
		else console.log 'missing button:',key

	# debug

	# os = navigator.appVersion
	# textSize 0.025 * height
	# text width,0.5*width,0.05*height
	# text height,0.75*width,0.05*height

	# text currState.name,0.5*width,0.03*height
	# fill 'green'
	# text round3(states.Editor.bonuses[0]),0.1*width,0.03*height
	# text round3(states.Editor.clocks[0]),0.25*width,0.03*height
	# text round3(states.Editor.clocks[1]),0.75*width,0.03*height
	# text round3(states.Editor.bonuses[1]),0.9*width,0.03*height

	# text states.ClockState.paused,0.3*width,0.025*height
	# text states.ClockState.player,0.7*width,0.025*height

	currState.draw()

mouseClicked = ->
	for key of currState.transitions
		if currState.transitions[key] == undefined then continue
		console.log key
		if buttons[key].inside mouseX, mouseY 
			currState.message key
			break

### Grave yard ###
# class LeftOrRight extends State
# 	constructor : (@name) ->
# 		super()
# 		@createTrans 'qr left=>RightTicking right=>LeftTicking pause=>StartState'
# 	draw : ->
# 		buttons.left.fg = 'white'
# 		buttons.right.fg = 'white'

# class LeftTicking extends State
# 	constructor : (@name) ->
# 		super()
# 		@createTrans 'qr right left=>RightTicking pause=>LeftPaused'
# 	draw : ->
# 		if not timeout[0] then states.Editor.clocks[0] -= 1/60
# 		if states.Editor.clocks[0] <= 0 
# 			states.Editor.clocks[0] = 0
# 			timeout[0] = true
# 		buttons.left.fg = 'white'
# 		buttons.right.fg = 'black'
# 		super()
# 	message : (key) ->
# 		if key == 'left'
# 			if not timeout[0]
# 				states.Editor.clocks[0] += states.Editor.bonuses[0]
# 			buttons.left.fg = 'white'
# 			buttons.right.fg = 'black'
# 		super key

# class RightTicking extends State
# 	constructor : (@name) ->
# 		super()
# 		@createTrans 'qr left right=>LeftTicking pause=>RightPaused'
# 	draw : ->
# 		if not timeout[1] then states.Editor.clocks[1] -= 1/60
# 		if states.Editor.clocks[1] <= 0 
# 			states.Editor.clocks[1] = 0
# 			timeout[1] = true
# 		buttons.left.fg = 'black'
# 		buttons.right.fg = 'white'
# 		super()
# 	message : (key) ->
# 		if key == 'right'
# 			if not timeout[1]
# 				states.Editor.clocks[1] += states.Editor.bonuses[1]
# 			buttons.left.fg = 'black'
# 			buttons.right.fg = 'white'
# 		super key

# class LeftPaused extends State
# 	constructor : (@name) ->
# 		super()
# 		@createTrans 'qr left right play=>LeftTicking new=>Editor'

# class RightPaused extends State
# 	constructor : (@name) ->
# 		super()
# 		@createTrans 'qr left right play=>RightTicking new=>Editor'

# class WelcomeState extends State
# 	constructor : (@name) ->
# 		super()
# 		@createTrans 'welcome=>StartState'
# 	message : (key) ->
# 		if key == 'welcome'
# 			os = navigator.appVersion
# 			ok = os.indexOf('Linux') >= 0 
# 			console.log ok
# 			#if ok then toggleFullScreen()
# 		super key

