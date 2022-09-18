# TODO
# Försämring av frameRate inträffar om man går från fullscreen till normal på Android
# Ta bort S och m ?

HCP = 1
HOUR = 3600
MINUTE = 60

TOGGLE = 1 # 0=porträtt (Android) 1=landskap (Mac)
HEARTBEAT = 1000 # ms updates of localStorage

FRAMERATE = 30 # 10

settings = {}
backup = null
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

createState = (key,klass) -> states[key] = new klass key

trunc3 = (x) -> Math.trunc(x*1000)/1000
console.assert trunc3(12.345678)==12.345

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
console.assert pretty(3601) == '1h1s'
console.assert pretty(123) == '2m3s'

prettyPair = (a,b) ->
	separator = if pretty(b) != '' then ' + ' else ''
	pretty(a) + separator + pretty(b)
console.assert prettyPair(3601,123) == '1h1s + 2m3s'

d2 = (x) ->
	x = Math.trunc x
	if x < 10 then '0'+x else x
console.assert d2(3) == '03'

hms = (x) ->
	orig = x
	s = x %% 60
	x = x // 60
	m = x %% 60
	x = x // 60
	h = x
	if orig < 10 then s = Math.trunc(s*10)/10 
	[h,m,s] 
chai.assert.deepEqual hms(180), [0,3,0]
chai.assert.deepEqual hms(180.5), [0,3,0.5]

clone = (x) -> JSON.parse JSON.stringify x

class Button
	constructor : (@x,@y,@w,@h,@text='',@bg='white',@fg='black') ->
		@visible = true
		@x = Math.round @x
		@y = Math.round @y
		@w = Math.round @w
		@h = Math.round @h
	draw : ->
		if @visible
			push()
			fill @bg
			rect @x,@y,@w,@h
			textSize 4
			fill @fg
			text @text,@x,@y
			pop()
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
		if h >= 1 then ss = h + ':' + d2 m
		else ss = m + ':' + if secs < 10  then s.toFixed 1 else d2 s
		noStroke()
		push()
		translate @x,@y
		rotate @degrees

		if settings.timeout and settings.player == @player
			@bg = 'red'
			@fg = 'black'

		fill @bg
		rect 0,0,@w,@h
		fill @fg
		textSize 18+9
		text ss,0,-2
		textSize 5+3

		#text (if h==0 then 'm:ss' else 'h:mm'),0,17
		if settings.bonuses[@player] > 0
			text '+' + pretty(settings.bonuses[@player]),0,17

		pop()

class BEdit extends Button
	constructor : (x,y,w,h,text,fg='gray') -> 
		super x,y,w,h,text,'black',fg
	draw : ->
		push()
		textSize 5
		fill @fg
		text @text,@x,@y
		pop()

class BDead extends Button
	constructor : (x,y,text,fg='lightgray') -> 
		super x,y,0,0,text,'black',fg
	draw : ->
		push()
		textSize 4
		fill @fg
		text @text,@x,@y
		pop()
		
class BShow extends BDead
	constructor : (x,y,fg='lightgray') -> 
		super x,y,0,0,'','black',fg
	draw : ->
		@text = settings.show
		super()

class BColor extends Button
	constructor : (x,y,@fg) -> super x,y,0,0
	draw : ->
		push()
		textAlign CENTER,CENTER
		textSize 4
		fill @fg
		text @text,@x,@y
		pop()

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

	mouseClicked : ->
		{x,y} = getLocalCoords()
		for key of @transitions
			if @transitions[key] == undefined then continue
			button = @buttons[key]
			if button.visible and button.inside x, y
				@message key
				break

class SClock extends State

	constructor : (name) ->
		super name
		@createTrans '=>SClock left pause qr right =>SBasic edit => show'
		settings.paused = true
		settings.player = -1

	makeButtons : ->
		@buttons.left  = new BRotate 50, 22, 100, 44, 180, 'orange', 'white', 0 # eg up
		@buttons.right = new BRotate 50, 78, 100, 44,   0, 'green',  'white', 1 # eg down

		@buttons.show  = new BShow     22, 50, 'black'
		@buttons.qr    = new BImage    50, 50, 33, 12, qr
		@buttons.pause = new BPause    67, 50, 17, 12, 'white', 'black'
		@buttons.edit  = new BSettings 83, 50, 17, 12, 'white', 'black'

	uppdatera : ->
		if settings.paused then return
		clock = settings.clocks[settings.player]
		if clock > 0 then clock -= 1/frameRate()
		if clock <= 0
			clock = 0
			settings.timeout = true
			settings.paused = true

		settings.clocks[settings.player] = clock

	message : (key) ->
		if key == 'left'
			if settings.timeout then return
			else
				if settings.player in [-1,0]
					sound.play()
					settings.clocks[0] += settings.bonuses[0]
				settings.paused = false
				settings.player = 1
				@buttons.left.fg = 'black'
				@buttons.right.fg = 'white'

		else if key == 'right'
			if settings.timeout then return
			else
				if settings.player in [-1,1]
					sound.play()
					settings.clocks[1] += settings.bonuses[1]
				settings.paused = false
				settings.player = 0
				@buttons.left.fg = 'white'
				@buttons.right.fg = 'black'

		else if key == 'pause'
			settings.paused = true
			@buttons.left.fg = if settings.player == 0 then 'white' else 'black'
			@buttons.right.fg = if settings.player == 0 then 'black' else 'white'

		else if key == 'qr'
			fullscreen true
			resizeCanvas innerWidth, innerHeight

		else if key == 'edit'
			backup = clone settings # to be used by cancel
			console.log 'backup skapad',backup

		saveSettings()
		super key

	draw : ->
		background 'white'
		super()

class SBasic extends State
	constructor : (name) ->
		super name
		#settings.sums = [0,0,0,0,0,0]
		arr = '=> bonus green hcp orange reflection white =>SClock cancel ok =>SAdvanced advanced =>SBasic M1 M2 M3 M5 M10 M90 s1 s2 s3 s5 s10 s30'.split ' '
		@createTrans arr.join ' '

	makeButtons : ->

		x = [30,70]
		y = [30,40,50,60,70,80,93]
		w = 10

		@buttons.orange     = states.SAdvanced.buttons.orange
		@buttons.white      = states.SAdvanced.buttons.white
		@buttons.green      = states.SAdvanced.buttons.green

		@buttons.reflection = new BDead  x[0],20,'reflection'
		@buttons.bonus      = new BDead  x[1],20,'bonus'

		@buttons.M1   			= new Button x[0],y[0], w,8, '1m'
		@buttons.M2   			= new Button x[0],y[1], w,8, '2m'
		@buttons.M3   			= new Button x[0],y[2], w,8, '3m'
		@buttons.M5   			= new Button x[0],y[3], w,8, '5m'
		@buttons.M10   			= new Button x[0],y[4], w,8, '10m'
		@buttons.M90   			= new Button x[0],y[5], w,8, '90m'

		@buttons.s1   			= new Button x[1],y[0], w,8, '1s'
		@buttons.s2   			= new Button x[1],y[1], w,8, '2s'
		@buttons.s3   			= new Button x[1],y[2], w,8, '3s'
		@buttons.s5   			= new Button x[1],y[3], w,8, '5s'
		@buttons.s10   			= new Button x[1],y[4], w,8, '10s'
		@buttons.s30   			= new Button x[1],y[5], w,8, '30s'

		@buttons.advanced   = new Button 1*100/6,y[6], 30,8, 'advanced'
		@buttons.cancel     = new Button 3*100/6,y[6], 30,8, 'cancel'
		@buttons.ok         = new Button 5*100/6,y[6], 30,8, 'ok'

	message : (key) ->

		if key == 'advanced'
		else if key == 'cancel'
			settings = clone backup # Återställ allt som behövs
			states.SAdvanced.clearMatrix() # Nollställ 6x6-matrisen
			states.SAdvanced.buttons[name].fg = 'yellow' for name in settings.bits # Tänd aktuella siffror
			settings.sums = states.SAdvanced.calcSums()

		else if key == 'ok'
			settings.clocks  = [settings.players[0][0], settings.players[1][0]]
			settings.bonuses = [settings.players[0][1], settings.players[1][1]]
			settings.timeout = false 

		else # 6+6 shortcut buttons
			letter = key[0]
			buttons = states.SAdvanced.buttons
			for i in [1,2,4,8,15,30]
				if letter == 'M'
					buttons['H'+i].fg = 'gray'
					buttons['M'+i].fg = 'gray'
					buttons['S'+i].fg = 'gray'
				else if letter == 's'
					buttons['m'+i].fg = 'gray'
					buttons['s'+i].fg = 'gray'
			states.SAdvanced.message key
			settings.sums = states.SAdvanced.calcSums()
			@buttons.ok.visible = settings.sums[0] + settings.sums[1] + settings.sums[2] > 0 and settings.sums[5] < 60

		super key

class SAdvanced extends State
	constructor : (name) ->
		super name
		#settings.sums = [0,0,0,0,0,0]
		arr = '=> green white orange reflection bonus hcp H M S m s t =>SClock cancel ok =>SBasic basic =>SAdvanced'.split ' '
		for i in range 6
			for j in range 6
				arr.push 'HMSmst'[i] + [1,2,4,8,15,30][j]
		@createTrans arr.join ' '

	makeButtons : ->

		@buttons.orange     = new BColor 50, 3,'orange'
		@buttons.white      = new BColor 50, 9,'white'
		@buttons.green      = new BColor 50,15,'green'

		@buttons.reflection = new BDead  25,21,'reflection'
		@buttons.bonus      = new BDead  66,21,'bonus'
		@buttons.hcp        = new BDead  92,21,'hcp'

		@buttons.basic      = new Button 1*100/6,93, 30,8, 'basic'
		@buttons.cancel     = new Button 3*100/6,93, 30,8, 'cancel'
		@buttons.ok         = new Button 5*100/6,93, 30,8, 'ok'

		@makeEditButtons()

	makeEditButtons : ->
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

		if key == 'basic'
		else if key == 'cancel'
			settings = clone backup # Återställ allt som behövs
			@clearMatrix() # Nollställ 6x6-matrisen
			@buttons[name].fg = 'yellow' for name in settings.bits # Tänd aktuella siffror
			settings.sums = @calcSums()

		else if key == 'ok'
			settings.clocks  = [settings.players[0][0], settings.players[1][0]]
			settings.bonuses = [settings.players[0][1], settings.players[1][1]]
			settings.timeout = false 
		else
			hash = {'M3':'M1 M2','M5':'M1 M4','M10':'M2 M8', 'M90':'H1 M30', 's3':'s1 s2','s5':'s1 s4','s10':'s2 s8'}
			if key of hash
				for msg in hash[key].split ' '
					@message msg
			else # 6 x 6 edit buttons
				#letter = key[0]
				#col = 'HMSmst'.indexOf letter
				#number = parseInt key.slice 1
				@buttons[key].fg = if @buttons[key].fg == 'gray' then 'yellow' else 'gray'
				settings.sums = @calcSums()
				@buttons.ok.visible = settings.sums[0] + settings.sums[1] + settings.sums[2] > 0 and settings.sums[5] < 60

		@uppdatera()
		super key

	clearMatrix : ->
		for i in range 6
			letter = 'HMSmst'[i]
			for j in range 6
				number = [1,2,4,8,15,30][j]
				@buttons[letter + number].fg = 'gray'

	calcSums : ->
		res = [0,0,0,0,0,0]
		for i in range 6
			letter = 'HMSmst'[i]
			for j in range 6
				number = [1,2,4,8,15,30][j]
				name = letter + number
				if @buttons[name].fg == 'yellow' then res[i] += number
		res

	uppdatera : ->

		settings.sums = @calcSums()
		settings.show = @compact()
		@buttons.white.text = settings.show
		
		@handicap()
		if settings.hcp == 0
			@buttons.orange.text = ''
			@buttons.green.text  = ''
		else
			@buttons.orange.text = prettyPair settings.players[0][0], settings.players[0][1]
			@buttons.green.text  = prettyPair settings.players[1][0], settings.players[1][1]

	compact : ->
		headers = 'hmsms'
		header0 = ''
		header1 = ''
		for i in range 0,3
			if settings.sums[i]>0 then header0 += settings.sums[i] + headers[i]
		for i in range 3,5
			if settings.sums[i]>0 then header1 += settings.sums[i] + headers[i]
		header = header0
		if header1.length > 0 then header += '+' + header1
		if settings.sums[5] > 0 then header += '\n' + settings.sums[5]
		header

	handicap : ->
		settings.hcp = settings.sums[5] / (HCP * 60) # 0.0 .. 1.0
		settings.refl = HOUR * settings.sums[0] + MINUTE * settings.sums[1] + settings.sums[2] # sekunder
		settings.bonus =                          MINUTE * settings.sums[3] + settings.sums[4] # sekunder
		settings.players = []
		settings.players[0] = [settings.refl + settings.refl*settings.hcp, settings.bonus + settings.bonus*settings.hcp]
		settings.players[1] = [settings.refl - settings.refl*settings.hcp, settings.bonus - settings.bonus*settings.hcp]

###################################

preload = ->
	qr = loadImage 'qr.png'
	sound = loadSound 'key.mp3'

windowResized = ->
	resizeCanvas innerWidth, innerHeight
	diag = sqrt width*width + height*height

setup = ->

	frameRate FRAMERATE
	os = navigator.appVersion
	if os.indexOf('Linux') >= 0 then os = 'Android'
	if os.indexOf('Windows') >= 0 then os = 'Windows'
	if os.indexOf('Mac') >= 0 then os = 'Mac'

	# os = 'Android'

	canvas = createCanvas innerWidth,innerHeight
	bodyScrollLock.disableBodyScroll canvas # Förhindrar att man kan scrolla canvas på iOS

	if os == 'Android' then textFont 'Droid Sans'
	if os == 'Mac' then textFont 'Verdana'
	if os == 'Windows' then textFont 'Lucida Sans Unicode'

	TOGGLE = if os == 'Mac' then 1 else 0

	diag = sqrt width*width + height*height

	background 'black'
	textAlign CENTER,CENTER
	rectMode CENTER
	angleMode DEGREES

	createState 'SClock', SClock 
	createState 'SAdvanced',SAdvanced
	createState 'SBasic',SBasic

	settings = loadSettings()

	states.SAdvanced.uppdatera()
	for key in settings.bits
		states.SAdvanced.message key
	states.SAdvanced.uppdatera()
	
	#dump()
	currState = states.SClock

	#checkButtons()
	#checkStates()

makeBits = ->
	bits = []
	for key of states.SAdvanced.buttons
		if key not in ['ok','cancel']
			button = states.SAdvanced.buttons[key]
			if button.fg == 'yellow' then bits.push key
	bits

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

	saveSettings()

	# debug
	aspect = (w,h,y) ->
		if w<h then [w,h] = [h,w]
		text "#{w} #{(w/h).toFixed(3)} #{h}", 50,y

	debugFunction()

debugFunction = ->
	rates.push frameRate()
	if rates.length > 100 then oldest = rates.shift() else oldest = rates[0]
	sumRate += _.last(rates) - oldest

	# # os = navigator.appVersion
	textSize 2.5
	#text 'Click QR => Fullscreen',50,12
	text Math.round(sumRate),95,5

	# text currState.name,50,3
	# # fill 'green'
	# text round3(states.SBasic.bonuses[0]),10,3
	# text round3(states.SBasic.clocks[0]),25,3
	# text round3(states.SBasic.clocks[1]),75,3
	# text round3(states.SBasic.bonuses[1]),90,3

	# text states.SClock.paused,30,2.5
	# text states.SClock.player,70,2.5

	# currState.draw()

loadSettings = ->
	if localStorage.settings
		settings = JSON.parse localStorage.settings
		settings.paused = true
		console.log 'fetching stored settings',settings
	else 
		settings = {}
		settings.show = '3m2s'
		settings.bits = ['M1','M2','s2']
		settings.clocks = [180,180]
		settings.bonuses= [2,2]
		settings.sums = [0,3,0,0,2,0]
		settings.player = -1 
		settings.timeout = false
		settings.paused = true
		console.log 'fetching default settings',settings
		localStorage.settings = JSON.stringify settings
	settings

saveSettings = ->
	d = new Date()
	if d - lastStorageSave < HEARTBEAT then return # ms
	lastStorageSave = d
	settings.bits = makeBits()
	localStorage.settings = JSON.stringify settings

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

# arr = []
# for i in range 60
# 	arr.push "#{i} #{Math.round((60+i)/(60-i)*1000)/1000}"
# console.log arr.join "\n"