# TODO
# Försämring av frameRate inträffar om man går från fullscreen till normal på Android

# Istället för sekunder är nu normalformen tertier, 60-dels sekunder

HOUR   = 60*60*60 # tertier
MINUTE = 60*60    # tertier
SEC    = 60       # tertier

TOGGLE = 1 # 0=porträtt (Android) 1=landskap (Mac)
HEARTBEAT = 1000 # ms updates of localStorage

FRAMERATE = 60 # 10

settings  = {}
minutes   = new CBits [1,2,4,8,15,30,60]
seconds   = new CBits [1,2,4,8,15,30,60]
handicap  = new CBits [1,2,4,8,15,30]
number960 = new CBits [1,2,4,8,15,30,60,120,240,480]

backup = null
states = {}

qr = null
chess = {}

currState = null
os = ''
sound = null
lastStorageSave = new Date()

rates = []
sumRate = 0

diag = 0 

getLocalCoords = ->
	matrix = drawingContext.getTransform()
	pd = pixelDensity()
	matrix.inverse().transformPoint new DOMPoint mouseX * pd,mouseY * pd

createState = (key,klass) -> states[key] = new klass key

pretty = (tot) ->
	tot = Math.round tot
	t = tot %% 60
	tot //= 60
	s = tot %% 60
	m = tot // 60
	header = ''
	if m > 0 then header += m + 'm'
	if s > 0 then header += s + 's'
	if t > 0 then header += t + 't'
	header
assert '1m1t', pretty 3601
assert '2s3t', pretty 123
assert '60m30s', pretty 60*60*60+30*60

prettyPair = (a,b) ->
	separator = if pretty(b) != '' then ' + ' else ''
	pretty(a) + separator + pretty(b)
assert '1m1t + 2s3t', prettyPair 3601,123

d2 = (x) ->
	x = Math.trunc x
	if x < 10 then '0'+x else x
assert '03', d2 3

mst = (x) -> # tertier
	orig = x
	t = x %% 60
	x //= 60
	s = x %% 60
	m = x // 60
	[m,s,t] 
assert [3,0,0], mst 3*60*60
assert [3,0,30], mst 180*60+30

clone = (x) -> JSON.parse JSON.stringify x

cancel = =>
	settings.cancel()
	currState = states.SClock

ok     = =>
	settings.ok()
	currState = states.SClock

class CSettings
	constructor : -> 
		console.log if localStorage.settings then "load" else "default"
		if localStorage.settings then Object.assign @, JSON.parse localStorage.settings

		@minutes  ||= 3
		@seconds  ||= 2
		@handicap ||= 0
		@number960 ||= 518
		@chess960 ||= 'RNBQKBNR'
		@show ||= '3 + 2'
		@clocks ||= [180*60,180*60] # tertier
		@bonuses ||= [2*60,2*60]    # tertier
		@player ||= -1
		@timeout ||= false
		@paused = true

		minutes.setNr @minutes
		seconds.setNr @seconds
		handicap.setNr @handicap
		number960.setNr @number960

		console.log minutes,seconds,handicap,number960
		@makeHandicap()
		@save()

	tick : ->
		if @paused then return
		c = @clocks[@player]
		if c > 0 then c -= 60/frameRate()
		if c <= 0
			c = 0
			@timeout = true
			@paused = true
		@clocks[@player] = c

	save : ->
		d = new Date()
		if d - lastStorageSave < HEARTBEAT then return # ms
		lastStorageSave = d
		@minutes = minutes.nr
		@seconds = seconds.nr
		@handicap = handicap.nr 
		@number960 = number960.nr
		localStorage.settings = JSON.stringify @

	compact : ->
		header0 = ''
		header1 = ''
		if minutes.nr > 0 then header0 += minutes.nr
		if seconds.nr > 0 then header1 += seconds.nr
		header = header0
		if header1.length > 0 then header += '+' + header1
		if handicap.nr > 0 then header += "\n(#{handicap.nr})"
		header

	makeHandicap : ->
		hcp = handicap.nr / 60 # 0/60 to 59/60
		refl  = MINUTE * minutes.nr # tertier
		bonus =    SEC * seconds.nr # tertier
		@players = []
		@players[0] = [refl + refl*hcp, bonus + bonus*hcp]
		@players[1] = [refl - refl*hcp, bonus - bonus*hcp]

	ok : ->
		console.log 'settings.ok'
		@makeHandicap()
		@clocks  = [@players[0][0], @players[1][0]]
		@bonuses = [@players[0][1], @players[1][1]]
		@timeout = false
		@paused = true
		@player = -1

	cancel : -> 
		Object.assign @, backup
		@paused = true

class Control
	constructor : (@x,@y,@w,@h,@text='',@bg='black',@fg='white') ->
		@visible = true
		# @x = Math.round @x
		# @y = Math.round @y
		# @w = Math.round @w
		# @h = Math.round @h
	draw : -> console.log 'Control.draw must be overriden!'
	inside : (x,y) ->
		w = @w * [height/width,width/height][1-TOGGLE]
		-w/2 <= x-@x <= w/2 and -@h/2 <= y-@y <= @h/2

class CNumber extends Control
	constructor : (x,y,@reader) ->
		super x,y,0,0
		@x = Math.round @x
		@y = Math.round @y
	draw : ->
		push()
		textSize 8
		fill 'white'
		text @reader(),@x,@y
		pop()

class C960 extends Control
	constructor : (x,y,w,h) ->
		super x,y,w,h
		@x = Math.round @x
		@y = Math.round @y
		@w = Math.round @w
		@h = Math.round @h
		@visible = true
	draw : ->
		if @visible
			dx = 12
			w = @h * [height/width,width/height][TOGGLE]
			xoff = @x + (dx-w)/2
			for i in range 8
				image chess[settings.chess960[i]], xoff+(i-4)*dx, @y+8, w,@h

class CRounded extends Control
	constructor : (x,y,w,h,text='',@disabled=false,bg='white',fg='black', @clicker=null) ->
		super x,y,w,h,text,bg,fg
	draw : ->
		if @visible
			push()
			fill if @disabled then "black" else @bg
			rect @x,@y,@w,@h,@h/2
			textSize 4
			fill if @disabled then "white" else @fg
			text @text,@x,@y
			pop()
	click : => if @clicker then @clicker()

class CPause extends Control
	constructor : (x,y,w=0,h=0,@bg='black',@fg='white', @clicker) ->
		super x,y,w,h
	click : => @clicker()
	draw : ->
		if not settings.paused
			fill @fg
			rect @x-1.75,@y,3,6
			rect @x+1.75,@y,3,6

class CCogwheel extends Control # Kugghjul
	constructor : (x,y,w=0,h=0,@bg='black',@fg='white',@clicker) -> super x,y,w,h
	click : => @clicker()
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

class CImage extends Control
	constructor : (x,y,w,h,@image,@clicker) ->
		super x,y,w,h
	click : => @clicker()
	draw :  ->
		if @image
			w = @h * [height/width,width/height][TOGGLE]
			image @image,@x-w/2, 0.075+@y-@h/2, w, @h

class CRotate extends Control
	constructor : (x,y,w,h,@degrees,bg,fg,@player,@clicker) ->
		super x,y,w,h,'',bg,fg

	click : => @clicker()

	draw : ->
		tertier = settings.clocks[@player]
		[m,s,t] = mst tertier
		t = Math.round t
		ss = m + ':' + d2 s

		noStroke()
		push()
		translate @x,@y
		rotate @degrees

		if settings.player == @player
			minCol = 'red'
			secCol = if settings.timeout then 'red' else 'white'
		else
			minCol = 'lightgrey'
			secCol = 'grey'

		textSize 18+9
		mw = textWidth m
		sw = textWidth d2 2

		fill minCol
		text m, -sw/2, -2

		fill secCol
		text d2(s), mw/2, -2

		textSize 10
		if tertier < 10*60 then text t,36,-4

		if handicap.nr > 0 and settings.bonuses[@player] > 0
			textSize 8
			fill 'grey'
			text '+' + pretty(settings.bonuses[@player]),0,17

		pop()

class CAdv extends Control
	constructor : (@bits,@index,x,y,diam,text,@flipper,@read,@clk) ->
		super x,y,diam,diam,text,'black'
		@visible = true

	draw : ->
		push()
		translate @x,@y
		if @flipper
			fill if 1 == @reader() then 'yellow' else 'gray'
		else 
			fill 'gray'
		s = [height/width,width/height][TOGGLE]
		ellipse 0,0,@w*s,@h
		fill 'black'
		textSize 5
		text @text,0,0.2
		pop()

	inside : (x,y) ->
		s = [height/width,width/height][TOGGLE]
		w = @w * s
		h = @h
		-w/2 <= x-@x <= w/2 and -h/2 <= y-@y <= h/2

	reader : -> if @flipper then @read @bits,@index else @read @bits,@text
	click : -> if @flipper then @clk @bits,@index else @clk @bits,@text

class CDead extends Control
	constructor : (x,y,text,fg='white') ->
		super x,y,0,0,text,'black',fg
	draw : ->
		push()
		textSize 4
		fill @fg
		text @text,@x,@y
		pop()

class CShow extends CDead
	constructor : (x,y,fg='white') ->
		super x,y,'',fg
	draw : ->
		push()
		translate @x,@y
		rotate -90
		@text = settings.show
		fill 'white'
		textSize 5
		text settings.show, 0,0
		#super()
		pop()

class CColor extends Control
	constructor : (x,y,@fg,@reader) -> super x,y,0,0
	draw : ->
		push()
		textSize 4
		fill @fg
		text @reader(),@x,@y
		pop()

class State
	constructor : (@name) -> @controls = {}	
	draw : (key) => @controls[key].draw key for key of @controls

	mouseClicked : ->
		{x,y} = getLocalCoords()
		for key of @controls
			control = @controls[key]
			if control.visible and not control.disabled and control.inside x, y
				if control.click then control.click()
				break

handlePlayer = (player) ->
	if settings.timeout then return
	if settings.paused 
		sound.play()
	else if settings.player == -1
		sound.play()
	else if settings.player == player
		sound.play()
		settings.clocks[player] += settings.bonuses[player]
	settings.paused = false
	settings.player = 1-player

class SClock extends State

	constructor : (name) ->
		super name

		player0 = => if settings.timeout then return else handlePlayer 0
		player1 = => if settings.timeout then return else handlePlayer 1
		pause   = => settings.paused = true
		handleQR = =>
			fullscreen true
			resizeCanvas innerWidth, innerHeight

		@controls.left  = new CRotate 50, 22, 100, 44, 180, 'black', 'white', 0, player0 # eg up
		@controls.right = new CRotate 50, 78, 100, 44,   0, 'black', 'white', 1, player1 # eg down
		@controls.pause = new CPause  67, 50,  17, 12, 'black', 'white', pause
		@controls.qr    = new CImage  50, 50,  33, 12, qr, handleQR

		@controls.basic = new CCogwheel 83, 50, 17, 12, 'black', 'white', => currState = states.SBasic
		@controls.show  = new CShow     22, 50, 'white'

	indicator : ->
		a = settings.clocks[0]
		b = settings.clocks[1]
		andel = 100 * a/(a+b)
		push()
		strokeWeight 1
		stroke 'white'
		line  1,andel, 10,andel
		line 90,andel, 99,andel
		pop()

	draw : =>
		super()
		@indicator()


class SBasic extends State
	constructor : (name) ->
		super name

		reader  = (bits,text) => bits.nr
		clicker = (bits,text) => bits.nr = text

		x = [100/3,200/3]
		y = [32,41,50,59,68,77,86,95]
		diam = 8

		@controls.orange     = states.SAdv.controls.orange
		@controls.white      = states.SAdv.controls.white
		@controls.green      = states.SAdv.controls.green

		@controls.reflection = new CDead  x[0],20,'reflection'
		@controls.bonus      = new CDead  x[1],20,'bonus'

		@controls.M          = new CDead  x[0], 25, 'minutes'
		@controls.s          = new CDead  x[1], 25, 'seconds'

		for i in range 5
			M = [1,2,3,5,10][i]
			@controls['M'+M] = new CAdv minutes,i,x[0]-10,y[i], diam, M, false, reader,clicker

		for i in range 6
			M = [15,20,30,45,60,90][i]
			@controls['M'+M] = new CAdv minutes,i,x[0]+10,y[i], diam, M, false, reader,clicker

		for i in range 7
			s = [0,1,2,3,5,10,30][i]
			@controls['s'+s] = new CAdv seconds,i,x[1],y[i], diam, s, false, reader,clicker

		@controls.basic      = new CRounded 1*100/10,y[7], 18,6, 'basic',  true,'white','black'
		@controls.adv        = new CRounded 3*100/10,y[7], 18,6, 'adv',   false,'white','black',=> currState = states.SAdv
		@controls.b960       = new CRounded 5*100/10,y[7], 18,6, '960',   false,'white','black',=> currState = states.S960
		@controls.cancel     = new CRounded 7*100/10,y[7], 18,6, 'cancel',false,'white','black',cancel
		@controls.ok         = new CRounded 9*100/10,y[7], 18,6, 'ok',    false,'white','black',ok


class SAdv extends State
	constructor : (name) ->
		super name

		getOrange = -> 
			settings.makeHandicap()
			sp = settings.players
			if handicap.nr == 0 then '' else prettyPair sp[0][0], sp[0][1]

		getWhite = -> settings.compact()

		getGreen = -> 
			settings.makeHandicap()
			sp = settings.players
			if handicap.nr == 0 then '' else prettyPair sp[1][0], sp[1][1]

		@controls.orange     = new CColor 50, 2.5,'orange', getOrange
		@controls.white      = new CColor 50, 9.5,'white', getWhite
		@controls.green      = new CColor 50,16.5,'green', getGreen

		@controls.reflection = new CDead  25,21,'reflection'
		@controls.bonus      = new CDead  50,21,'bonus'
		@controls.hcp        = new CDead  75,21,'handicap'

		y = 95

		@controls.basic      = new CRounded 1*100/10,y, 18,6, 'basic', false,'white','black',=> currState = states.SBasic
		@controls.adv        = new CRounded 3*100/10,y, 18,6, 'adv',    true,'white','black'
		@controls.b960       = new CRounded 5*100/10,y, 18,6, '960',   false,'white','black',=> currState = states.S960
		@controls.cancel     = new CRounded 7*100/10,y, 18,6, 'cancel',false,'white','black',cancel
		@controls.ok         = new CRounded 9*100/10,y, 18,6, 'ok',    false,'white','black',ok

		@makeEditButtons()

	makeEditButtons : ->

		reader = (bits,index) => bits.pattern[index]
		clicker = (bits,index) =>
			bits.flipBit index
			@controls.ok.visible = minutes.nr > 0 and handicap.nr < 60

		for i in range 3
			letter = 'Mst'[i]
			xsize = 100/4
			ysize = 100/12
			xoff = xsize
			yoff = 33+2
			diam = 7
			@controls[letter] = new CDead xoff+xsize*i, 26+1, 'minutes seconds tertier'.split(' ')[i]
			for j in range 7
				number = [1,2,4,8,15,30,60][j]
				name = letter + number
				if i!=2 or j!=6
					@controls[name] = new CAdv [minutes,seconds,handicap][i], j, xoff+xsize*i, yoff+ysize*j, diam, number, true, reader, clicker


class S960 extends State
	constructor : (name) ->
		super name
		reader960 = (bits,index) => bits.pattern[index]
		click960 = (bits,index) =>
			bits.flipBit index
			settings.chess960 = chess960 number960.nr

		random960 = ->
			nr = _.random 0,959
			number960.setNr nr
			settings.chess960 = chess960 nr

		x = [100/4,200/4,300/4]
		y = [-5,40,52,64,76,78,90,95]
		diam = 10

		@controls.C960    = new C960    50,y[0], 100, 10
		@controls.CNumber = new CNumber 50,25, () -> number960.nr

		for i in range number960.lst.length
			number = number960.lst[i]
			key    = 'R'+number
			xi     = [0,0,0,0,1,1,1,2,2,2][i]
			yi     = [1,2,3,4,1,2,3,1,2,3][i]
			@controls[key] = new CAdv number960, i, x[xi],y[yi], diam, number, true, reader960, click960

		@controls.random = new CRounded (x[1]+x[2])/2,y[4], 18,6, 'random', false, 'white','black',random960
		@controls.basic  = new CRounded 10,y[7], 18,6, 'basic', false,'white','black',=> currState = states.SBasic
		@controls.adv    = new CRounded 30,y[7], 18,6, 'adv',   false,'white','black',=> currState = states.SAdv
		@controls.b960   = new CRounded 50,y[7], 18,6, '960',    true,'white','black'
		@controls.cancel = new CRounded 70,y[7], 18,6, 'cancel',false,'white','black',cancel
		@controls.ok     = new CRounded 90,y[7], 18,6, 'ok',    false,'white','black',ok

###################################

preload = ->
	qr = loadImage 'qr.png'
	sound = loadSound 'key.mp3'
	for ltr in "KQRBN"
		chess[ltr] = loadImage "chess\\#{ltr}.png"

windowResized = ->
	resizeCanvas innerWidth, innerHeight
	diag = sqrt width*width + height*height

setup = ->
	settings = new CSettings

	frameRate FRAMERATE
	os = navigator.appVersion
	if os.indexOf('Linux') >= 0 then os = 'Android'
	if os.indexOf('Windows') >= 0 then os = 'Windows'
	if os.indexOf('Mac') >= 0 then os = 'Mac'

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
	createState 'SAdv',SAdv
	createState 'SBasic',SBasic
	createState 'S960',S960
	
	currState = states.SClock

mousePressed = -> if os == 'Windows' then currState.mouseClicked()
touchStarted = -> if os != 'Windows' then currState.mouseClicked()

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
	settings.tick()
	currState.draw()
	pop()

	settings.save()

	aspect = (w,h,y) ->
		if w < h then [w,h] = [h,w]
		text "#{w} #{(w/h).toFixed(3)} #{h}", 50,y
