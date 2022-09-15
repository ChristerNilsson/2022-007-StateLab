# TODO
# Halvering av frameRate (1000 -> 435) inträffar om man går från fullscreen till normal på Android

HCP = 1
HOUR = 3600
MINUTE = 60

TOGGLE = 1 # 0=porträtt (Android) 1=landskap (Mac)
HEARTBEAT = 1000 # ms updates of localStorage

FRAMERATE = 10

settings = {}
states = {}

qr = null
currState = null
os = ''
sound = null
lastStorageSave = new Date()

rates = []
sumRate = 0

diag = 0 

getLocalCoords = -> # tar 3 microsekunder
	matrix = drawingContext.getTransform()
	pd = pixelDensity()
	matrix.inverse().transformPoint new DOMPoint mouseX * pd,mouseY * pd

toggleFullScreen = ->
	doc = window.document
	docEl = doc.documentElement
	requestFullScreen = docEl.requestFullscreen or docEl.mozRequestFullScreen or docEl.webkitRequestFullScreen or docEl.msRequestFullscreen
	if not doc.fullscreenElement and not doc.mozFullScreenElement and not doc.webkitFullscreenElement and not doc.msFullscreenElement
		requestFullScreen.call docEl

trunc3 = (x) -> Math.trunc(x*1000)/1000
createState = (key,klass) -> states[key] = new klass key

pretty = (tot) ->
	s = tot % 60
	tot = (tot - s) / 60
	m = tot % 60
	tot = (tot - m) / 60
	h = tot % 60
	header = ''
	if trunc3(h)>0 then header += trunc3(h) + 'h'
	if trunc3(m)>0 then header += trunc3(m) + 'm'
	if trunc3(s)>0 then header += trunc3(s) + 's'
	header

prettyPair = (a,b) ->
	separator = if pretty(b) != '' then ' + ' else ''
	pretty(a) + separator + pretty(b)

d2 = (x) ->
	x = Math.trunc x
	if x < 10 then '0'+x else x
#console.log d2(3), '03'

hms = (x) ->
	orig = x
	s = x %% 60
	x = x // 60
	m = x %% 60
	x = x // 60
	h = x
	if orig < 10 then s = Math.trunc(s*10)/10 
	[h,m,s] 
#console.log hms(180), [0,3,0]
#console.log hms(180.5), [0,3,0.5]

class Button
	constructor : (@x,@y,@w,@h,@text='',@bg='white',@fg='black') ->
		@visible = true
		@x = Math.round @x
		@y = Math.round @y
		@w = Math.round @w
		@h = Math.round @h
	draw : ->
		if @visible
			fill @bg
			rect @x,@y,@w,@h
			textSize 4
			fill @fg
			text @text,@x,@y
	inside : (x,y) -> -@w/2 <= x-@x <= @w/2 and -@h/2 <= y-@y <= @h/2

class BPause extends Button
	constructor : (x,y,w=0,h=0,@bg='white',@fg='black') ->
		super x,y,w,h
	draw : ->
		if not settings.paused
			fill @fg
			rect @x-1.75,@y,3,6
			rect @x+1.75,@y,3,6

class BSettings extends Button # Kugghjul
	constructor : (x,y,w=0,h=0,@bg='white',@fg='black') ->
		super x,y,w,h
	draw : ->
		if settings.paused
			push()
			translate @x,@y
			scale [height/width,width/height][TOGGLE],1
			fill @fg
			circle 0,0,6
			fill @bg
			circle 0,0,3
			fill @fg
			for v in range 0,360,45
				push()
				rotate v
				translate 3,0
				stroke @fg
				rect 0,0,1,1
				pop()
			pop()

class BImage extends Button
	constructor : (x,y,w,h,@image) ->
		super x,y,w,h
	draw :  ->
		if @image
			w = @h * [height/width,width/height][TOGGLE]
			image @image,@x-w/2, 0.075+@y-@h/2, w, @h

class BRotate extends Button
	constructor : (x,y,w,h,@degrees,bg,fg,@player) -> 
		super x,y,w,h,'',bg,fg

	draw : ->
		secs = settings.clocks[@player]
		[h,m,s] = hms secs
		if h >= 1 then ss = h + 'h' + d2 m
		else ss = m + ':' + if secs < 10  then s.toFixed 1 else d2 s
		noStroke()
		push()
		translate @x,@y
		rotate @degrees
		fill @bg
		rect 0,0,@w,@h
		fill @fg
		textSize 18+9
		text ss,0,-2
		textSize 5+3

		#text (if h==0 then 'm:ss' else 'h:mm'),0,17
		if settings.bonuses[@player] > 0
			text '+' + trunc3(settings.bonuses[@player])+'s',0,17

		if settings.clocks[@player] <= 0 then @bg = 'red'
		pop()

class BEdit extends Button
	constructor : (x,y,w,h,text,fg='gray') -> 
		super x,y,w,h,text,'black',fg
	draw : ->
		textSize 5
		fill @fg
		text @text,@x,@y

class BDead extends Button
	constructor : (x,y,text,fg='lightgray') -> 
		super x,y,0,0,text,'black',fg
	draw : ->
		textSize 4
		fill @fg
		text @text,@x,@y

class BColor extends Button
	constructor : (x,y,@fg) -> super x,y,0,0
	draw : ->
		push()
		textAlign CENTER,CENTER
		textSize 4
		fill @fg
		text @text,@x,@y
		pop()

# struktur för transitionssträngen:
# =>target0 msg0 msg1 =>target1 msg2 msg3 => msg4
# @transitions[msg0] = target0
# @transitions[msg1] = target0
# @transitions[msg2] = target1
# @transitions[msg3] = target1
# @transitions[msg4] = undefined

class State
	constructor : (@name) -> 
		@buttons = {}
		@transitions = {}
		@makeButtons()

	createTrans : (t) ->
		target = undefined
		arr = t.split ' '
		for word in arr
			if word == '=>' then target = undefined
			else if word.indexOf('=>') == 0 then target = word.slice 2
			else @transitions[word] = target

	message : (key) ->
		console.log "clicked #{@name}.#{key} => #{@transitions[key]}"
		currState = states[@transitions[key]]

	draw : ->
		for tkey of @transitions
			if tkey of @buttons
				@buttons[tkey].draw()
			else
				console.log 'missing',tkey

	mouseClicked : ->
		{x,y} = getLocalCoords()
		for key of @transitions
			if @transitions[key] == undefined then continue
			button = @buttons[key]
			if button.visible and button.inside x, y
				@message key
				break


# class SWelcome extends State
# 	constructor : (name) ->
# 		super name
# 		@createTrans '=>SClock welcome'
# 		console.log @

# 	message : (key) ->
# 		if key == 'welcome'
# 			toggleFullScreen()
# 			#fullscreen true
# 			resizeCanvas innerWidth, innerHeight
# 		super key

# 	makeButtons : ->
# 		@buttons.welcome = new Button 50,50,100,100, 'Click me!'


class SClock extends State

	constructor : (name) ->
		super name
		@createTrans '=>SClock left pause qr right =>SEditor edit'
		settings.paused = true
		settings.player = -1

	makeButtons : ->
		@buttons.left  = new BRotate 50, 22, 100, 44, 180, 'orange', 'white', 0 # eg up
		@buttons.right = new BRotate 50, 78, 100, 44,   0, 'green',  'white', 1 # eg down

		@buttons.pause = new BPause    25, 50, 34, 12, 'white', 'black'
		@buttons.qr    = new BImage    50, 50, 33, 12, qr
		@buttons.edit  = new BSettings 75, 50, 34, 12, 'white', 'black'

	uppdatera : ->
		if settings.paused then return
		clock = settings.clocks[settings.player]
		if clock > 0 then clock -= 1/frameRate()
		if clock <= 0
			clock = 0
			settings.timeout = true
		settings.clocks[settings.player] = clock

	message : (key) ->
		if key == 'left'
			if settings.timeout then return
			else
				#hist.push 'L ' + (new Date() - start)
				#start = new Date()
				if settings.player in [-1,0]
					sound.play()
					settings.clocks[0] += settings.bonuses[0]
				settings.paused = false
				settings.player = 1
				@buttons.left.fg = 'black'
				@buttons.right.fg = 'white'

		if key == 'right'
			if settings.timeout then return
			else
				#hist.push ' R ' + (new Date() - start)
				#start = new Date()
				if settings.player in [-1,1]
					sound.play()
					settings.clocks[1] += settings.bonuses[1]
				settings.paused = false
				settings.player = 0
				@buttons.left.fg = 'white'
				@buttons.right.fg = 'black'

		if key == 'pause'
			settings.paused = true
			@buttons.left.fg = if settings.player == 0 then 'white' else 'black'
			@buttons.right.fg = if settings.player == 0 then 'black' else 'white'

		if key == 'qr'
			toggleFullScreen()
			# fullscreen true
			resizeCanvas innerWidth, innerHeight

		updateLocalStorage()
		super key

	draw : ->
		background 'white'
		super()

# =>SClock ok => orange white green reflection bonus hcp a b c d e f =>SEditor swap a0 a1 a2 a3 a4 a5 b0 b1 b2 b3 b4 b5 c0 c1 c2 c3 c4 c5 d0 d1 d2 d3 d4 d5 e0 e1 e2 e3 e4 e5 f0 f1 f2 f3 f4 f5
class SEditor extends State
	constructor : (name) ->
		super name
		settings.sums = [0,0,0,0,0,0]
		arr = '=> H M S m s t bonus green hcp orange reflection white =>SClock cancel ok =>SEditor swap'.split ' '
		for i in range 6
			for j in range 6
				arr.push 'HMSmst'[i] + [1,2,4,8,15,30][j]
		@createTrans arr.join ' '

	makeButtons : ->

		@buttons.swap       = new Button 25,93, 22,8, 'swap'
		@buttons.cancel     = new Button 50,93, 22,8, 'cancel'
		@buttons.ok         = new Button 75,93, 22,8, 'ok'
		@buttons.orange     = new BColor 50, 3,'orange'
		@buttons.white      = new BColor 50, 9,'white'
		@buttons.green      = new BColor 50,15,'green'
		@buttons.reflection = new BDead  25,21,'reflection'
		@buttons.bonus      = new BDead  66,21,'bonus'
		@buttons.hcp        = new BDead  92,21,'hcp'

		for i in range 6
			letter = 'HMSmst'[i]
			xsize = 100/6
			ysize = 100/10
			xoff = xsize/2
			yoff = 33+2
			@buttons[letter] = new BDead xoff+xsize*i, 26+2, 'HMSmst'[i]
			for j in range 6
				number = [1,2,4,8,15,30][j]
				name = letter + number
				@buttons[name] = new BEdit xoff+xsize*i, yoff+ysize*j, xsize, ysize, number, 'gray'

	message : (key) ->

		if key == 'swap'
			settings.swap = -settings.swap
		else if key == 'cancel'
		else if key == 'ok'
			settings.paused = true
			settings.timeout = false

			states.SClock.buttons.left.fg = 'white'
			states.SClock.buttons.left.bg = 'orange'
			states.SClock.buttons.right.fg = 'white'
			states.SClock.buttons.right.bg = 'green'

			settings.clocks  = [@players[0][0], @players[1][0]]
			settings.bonuses = [@players[0][1], @players[1][1]]

			#start = new Date()
			#hist = []

			updateLocalStorage()

		else
			letter = key[0]
			col = 'HMSmst'.indexOf letter
			number = parseInt key.slice 1
			@buttons[key].fg = if @buttons[key].fg == 'gray' then 'yellow' else 'gray'
			settings.sums[col] += if @buttons[key].fg == 'gray' then -number else number
			@buttons.ok.visible = settings.sums[0] + settings.sums[1] + settings.sums[2] > 0
			@buttons.swap.visible = settings.sums[5] > 0

		@uppdatera()
		super key

	uppdatera : ->

		settings.sums = [0,0,0,0,0,0]
		for i in range 6
			letter = 'HMSmst'[i]
			for j in range 6
				number = [1,2,4,8,15,30][j]
				name = letter + number
				if @buttons[name].fg == 'yellow' then settings.sums[i] += number

		@buttons.white.text = @compact()
		@handicap()
		if @hcp == 0
			@buttons.orange.text = ''
			@buttons.green.text  = ''
		else
			@buttons.orange.text = prettyPair @players[0][0], @players[0][1]
			@buttons.green.text  = prettyPair @players[1][0], @players[1][1]

	compact : ->
		headers = 'hmsms'
		header0 = ''
		header1 = ''
		for i in range 0,3
			if settings.sums[i]>0 then header0 += settings.sums[i] + headers[i]
		for i in range 3,5
			if settings.sums[i]>0 then header1 += settings.sums[i] + headers[i]
		header = header0
		if header1.length > 0 then header += ' + ' + header1
		header

	handicap : ->
		@hcp = settings.swap * settings.sums[5] / (HCP * 60) # 0.0 .. 1.0
		@refl = HOUR * settings.sums[0] + MINUTE * settings.sums[1] + settings.sums[2] # sekunder
		@bonus =                          MINUTE * settings.sums[3] + settings.sums[4] # sekunder
		@players = []
		@players[0] = [@refl + @refl*@hcp, @bonus + @bonus*@hcp]
		@players[1] = [@refl - @refl*@hcp, @bonus - @bonus*@hcp]

###################################

preload = -> 
	qr = loadImage 'qr.png'
	sound = loadSound 'key.mp3'

windowResized = ->
	resizeCanvas innerWidth, innerHeight
	diag = sqrt width*width + height*height

# checkButtons = ->
# 	console.log 'checkButtons started'
# 	for bkey of buttons
# 		button = buttons[bkey]
# 		found = false
# 		for skey of states
# 			state = states[skey]
# 			if bkey of state.transitions then found = true
# 		if not found then console.log '  Button',bkey,'not used by any state'
# 	console.log 'checkButtons done!'

# checkStates = ->
# 	console.log 'checkStates started'
# 	for skey of states
# 		state = states[skey]
# 		found = false
# 		for tkey of state.transitions
# 			transition = state.transitions[tkey]
# 			if transition != undefined and transition not of states then console.log transition,'not found'
# 			if tkey of buttons then found = true else info = tkey
# 		if not found then console.log '  State',skey,'Transition',tkey, 'not defined'
# 	console.log 'checkStates done!'

setup = ->

	frameRate FRAMERATE
	os = navigator.appVersion
	if os.indexOf('Linux') >= 0 then os = 'Android'
	if os.indexOf('Windows') >= 0 then os = 'Windows'
	if os.indexOf('Mac') >= 0 then os = 'Mac'

	# os = 'Android'

	createCanvas innerWidth,innerHeight

	if os == 'Android' then textFont 'Droid Sans'
	if os == 'Mac' then textFont 'Verdana'
	if os == 'Windows' then textFont 'Lucida Sans Unicode'

	TOGGLE = if os == 'Mac' then 1 else 0

	diag = sqrt width*width + height*height

	background 'black'
	textAlign CENTER,CENTER
	rectMode CENTER
	angleMode DEGREES

	#createState 'SWelcome', SWelcome
	createState 'SClock', SClock 
	createState 'SEditor',SEditor

	settings = getSettings()

	states.SEditor.uppdatera()
	for key in settings.bits
		states.SEditor.message key
	#states.SEditor.message 'ok'
	states.SEditor.uppdatera()
	
	#dump()
	#currState = if os == 'Android' then states.SWelcome else states.SClock
	currState = states.SClock

	#checkButtons()
	#checkStates()

dump = -> # log everything
	for skey of states 
		state = states[skey]
		console.log ''
		console.log 'State',state
		for tkey of state.transitions
			transition = state.transitions[tkey]
			button = state.buttons[tkey]
			if transition == undefined then transition = 'nothing'
			console.log ' ',tkey,'=>',transition,button

mouseClicked = -> currState.mouseClicked()

draw = ->

	if TOGGLE == 0
		scale width/100,height/100 # portrait
	else
		rotate 90
		translate 0,-width
		scale height/100,width/100 # Landscape

	strokeWeight 100/height
	push()
	background 'black'
	states.SClock.uppdatera()
	currState.draw()
	pop()
	# debug
	aspect = (w,h,y) ->
		if w<h then [w,h] = [h,w]
		text "#{w} #{(w/h).toFixed(3)} #{h}", 50,y

	updateLocalStorage()

	rates.push frameRate()
	if rates.length > 100 then oldest = rates.shift() else oldest = rates[0]
	sumRate += _.last(rates) - oldest

	# # os = navigator.appVersion
	textSize 2.5
	text 'Click QR => Fullscreen',50,12
	text Math.round(sumRate),95,5

	# text currState.name,50,3
	# # fill 'green'
	# text round3(states.SEditor.bonuses[0]),10,3
	# text round3(states.SEditor.clocks[0]),25,3
	# text round3(states.SEditor.clocks[1]),75,3
	# text round3(states.SEditor.bonuses[1]),90,3

	# text states.SClock.paused,30,2.5
	# text states.SClock.player,70,2.5

	# currState.draw()

makeBits = ->
	bits = []
	for key of states.SEditor.buttons
		if key not in ['ok','cancel','swap']
			button = states.SEditor.buttons[key]
			if button.fg == 'yellow' then bits.push key
	bits

updateLocalStorage = ->
	d = new Date()
	if d - lastStorageSave < HEARTBEAT then return # ms
	lastStorageSave = d
	settings.bits = makeBits()
	localStorage.settings = JSON.stringify settings

getSettings = ->
	if localStorage.settings
		settings = JSON.parse localStorage.settings
		settings.paused = true
		console.log 'fetching stored settings',settings
	else 
		settings = {}
		settings.bits = ['M1','M2','s2']
		settings.clocks = [180,180]
		settings.bonuses= [2,2]
		settings.sums = [0,3,0,0,2,0]
		settings.swap = 1
		settings.player = -1 
		settings.timeout = false
		settings.paused = true
		console.log 'fetching default settings',settings
		localStorage.setItem 'settings', JSON.stringify settings
	settings
