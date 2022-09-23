# TODO
# Försämring av frameRate inträffar om man går från fullscreen till normal på Android

# Istället för sekunder är nu normalformen tertier, 60-dels sekunder

HOUR   = 60*60*60 # tertier
MINUTE = 60*60    # tertier
SEC    = 60       # tertier

TOGGLE = 1 # 0=porträtt (Android) 1=landskap (Mac)
HEARTBEAT = 1000 # ms updates of localStorage

FRAMERATE = 60 # 10

settings = {}
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

class CSettings
	constructor : -> 
		console.log if localStorage.settings then "load" else "default"
		if localStorage.settings then Object.assign @, JSON.parse localStorage.settings

		@bits960 ||= ['R480','R30','R8']
		@number ||= 518 # normal chess
		@chess960 ||= 'RNBQKBNR'

		@show ||= '3 + 2'
		@bits ||= ['M1','M2','s2']
		@clocks ||= [180*60,180*60] # tertier
		@bonuses ||= [2*60,2*60]    # tertier
		@sums ||= {M:3,s:2,t:0}
		@player ||= -1 
		@timeout ||= false
		@paused = true

		@handicap()
		@save()

	tick : ->
		if @paused then return
		c = @clocks[@player]
		if c > 0 then c -= 60/frameRate()
		if c <= 0
			c = 0
			@timeout = true
			@paused = true
			if @player == 0 
				currState.controls.left.bg = 'red'
			else
				currState.controls.right.bg = 'red'
		@clocks[@player] = c

	save : ->
		d = new Date()
		if d - lastStorageSave < HEARTBEAT then return # ms
		lastStorageSave = d
		localStorage.settings = JSON.stringify @
		console.log 'save' #,JSON.stringify @

	flip : (key) ->
		if key in @bits then _.remove @bits, (n) -> n == key else @bits.push key
		@sums = @calcSums()
		@show = @compact()

	flip960 : (key) ->
		if key in @bits960 then _.remove @bits960, (n) -> n == key else @bits960.push key
		@number = @calcSum960()
		@chess960 = chess960 @number

	calcSums : ->
		res = {M:0,s:0,t:0}
		for key in settings.bits
			letter = key[0]
			number = parseInt key.slice 1
			res[letter] += number
		res

	calcSum960 : ->
		res = 0
		for key in settings.bits960
			res += parseInt key.slice 1
		res

	compact : ->
		header0 = ''
		header1 = ''
		if @sums.M > 0 then header0 += @sums.M
		if @sums.s > 0 then header1 += @sums.s
		header = header0
		if header1.length > 0 then header += '+' + header1
		if @sums.t > 0 then header += "\n(#{@sums.t})"
		header

	handicap : ->
		hcp = @sums.t / 60 # 0.0 .. 1.0
		refl  = MINUTE * @sums.M # tertier
		bonus =    SEC * @sums.s # tertier
		@players = []
		@players[0] = [refl + refl*hcp, bonus + bonus*hcp]
		@players[1] = [refl - refl*hcp, bonus - bonus*hcp]

	ok : ->
		@sums = @calcSums()
		@handicap()
		@clocks  = [@players[0][0], @players[1][0]]
		@bonuses = [@players[0][1], @players[1][1]]
		@timeout = false
		@paused = true
		@player = -1
		states.SClock.controls.left.bg = 'black'
		states.SClock.controls.right.bg = 'black'

	cancel : -> 
		Object.assign @, backup
		@paused = true

class Control
	constructor : (@x,@y,@w,@h,@text='',@bg='white',@fg='black') ->
		@visible = true
		# @x = Math.round @x
		# @y = Math.round @y
		# @w = Math.round @w
		# @h = Math.round @h
	draw : ->
		if @visible
			push()
			fill @bg
			rect @x,@y,@w,@h
			textSize 4
			fill @fg
			text @text,@x,@y
			pop()
	inside : (x,y) ->
		w = @w * [height/width,width/height][1-TOGGLE]
		-w/2 <= x-@x <= w/2 and -@h/2 <= y-@y <= @h/2
class CNumber extends Control
	constructor : (x,y) ->
		super x,y,0,0
		@x = Math.round @x
		@y = Math.round @y
	draw : ->
		push()
		textSize 8
		fill 'white'
		text settings.number,@x,@y
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
	constructor : (x,y,w,h,text='',@disabled=false,bg='white',fg='black') ->
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
class CPause extends Control
	constructor : (x,y,w=0,h=0,@bg='white',@fg='black') ->
		super x,y,w,h
	draw : ->
		if not settings.paused
			fill @fg
			rect @x-1.75,@y,3,6
			rect @x+1.75,@y,3,6
class CCogwheel extends Control # Kugghjul
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
class CImage extends Control
	constructor : (x,y,w,h,@image) ->
		super x,y,w,h
	draw :  ->
		if @image
			w = @h * [height/width,width/height][TOGGLE]
			image @image,@x-w/2, 0.075+@y-@h/2, w, @h
class CRotate extends Control
	constructor : (x,y,w,h,@degrees,bg,fg,@player) ->
		super x,y,w,h,'',bg,fg

	draw : ->
		tertier = settings.clocks[@player]
		[m,s,t] = mst tertier
		t = Math.round t
		ss = m + ':' + d2 s

		noStroke()
		push()
		translate @x,@y
		rotate @degrees

		minCol = if settings.player == @player then 'red' else 'grey'
		secCol = if settings.player == @player then 'white' else 'lightgrey'

		textSize 18+9
		mw = textWidth m
		sw = textWidth d2 2
		@bg = if settings.timeout and settings.player = @player then 'red' else 'black'

		fill @bg
		rect 0,0,@w,@h

		fill minCol
		text m, -sw/2, -2

		fill secCol
		text d2(s), mw/2, -2

		textSize 10
		if tertier < 10*60 then text t,36,-4

		if settings.sums.t > 0 and settings.bonuses[@player] > 0
			textSize 8
			text '+' + pretty(settings.bonuses[@player]),0,17

		pop()
class CAdv extends Control
	constructor : (@key,@name,x,y,diam,text) ->
		super x,y,diam,diam,text,'black'
		@visible = true

	draw : ->
		push()
		translate @x,@y
		if @name!=''
			fill if @name in settings[@key] then 'yellow' else 'gray'
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
	constructor : (x,y,@fg) -> super x,y,0,0
	draw : ->
		push()
		#textAlign CENTER,CENTER
		textSize 4
		fill @fg
		text @text,@x,@y
		pop()

class State
	constructor : (@name) ->
		@controls = {}
		@transitions = {}
		@makeControls()

	createTrans : (t) ->
		arr = t.split ' '
		target = ''
		for word in arr
			if ':' == _.last word then target = word.slice 0,word.length-1
			else @transitions[word] = target

	message : (key) -> console.log "Message #{@name}.#{key} not handled!"
	draw : -> @controls[key].draw() for key of @controls

	mouseClicked : ->
		{x,y} = getLocalCoords()
		for key of @controls
			control = @controls[key]
			if control.visible and not control.disabled and control.inside x, y
				console.log 'mouseClicked',key,@transitions[key]
				currState = states[@transitions[key]]
				currState.message key
				break

class SClock extends State

	constructor : (name) ->
		super name
		@createTrans 'SClock: left right pause qr SBasic: edit'
		settings.paused = true
		settings.player = -1

	makeControls : ->
		@controls.left  = new CRotate 50, 22, 100, 44, 180, 'black', 'white', 0 # eg up
		@controls.right = new CRotate 50, 78, 100, 44,   0, 'black',  'white', 1 # eg down
		@controls.pause = new CPause    67, 50, 17, 12, 'black', 'white'
		@controls.qr    = new CImage    50, 50, 33, 12, qr
		@controls.edit  = new CCogwheel 83, 50, 17, 12, 'black', 'white'
		@controls.show  = new CShow     22, 50, 'white'

	handlePlayer : (player) ->
		if settings.paused 
			sound.play()
		else if settings.player == -1
			sound.play()
		else if settings.player == player
			sound.play()
			settings.clocks[player] += settings.bonuses[player]
		settings.paused = false
		settings.player = 1-player

	message : (key) ->

		if key == 'left'
			if settings.timeout then return else @handlePlayer 0
		else if key == 'right'
			if settings.timeout then return else @handlePlayer 1
		else if key == 'pause'
			settings.paused = true
		else if key == 'qr'
			fullscreen true
			resizeCanvas innerWidth, innerHeight
		else if key == 'cancel' then settings.cancel()
		else if key == 'ok' then settings.ok()
		else super key
		settings.save()

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

	draw : ->
		background 'black'
		super()
		@indicator()

class SBasic extends State
	constructor : (name) ->
		super name
		@createTrans 'SBasic: M1 M2 M3 M5 M10 M15 M90 s0 s1 s2 s3 s5 s10 s30 SAdv: adv S960: b960 SClock: cancel ok'

	makeControls : ->

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

		for i in range 7
			M = [1,2,3,5,10,15,90][i]
			@controls['M'+M] = new CAdv 'bits', '',x[0],y[i], diam, M
			s = [0,1,2,3,5,10,30][i]
			@controls['s'+s] = new CAdv 'bits', '',x[1],y[i], diam, s

		@controls.basic      = new CRounded 1*100/10,y[7], 18,6, 'basic',true
		@controls.adv        = new CRounded 3*100/10,y[7], 18,6, 'adv'
		@controls.b960       = new CRounded 5*100/10,y[7], 18,6, '960'
		@controls.cancel     = new CRounded 7*100/10,y[7], 18,6, 'cancel'
		@controls.ok         = new CRounded 9*100/10,y[7], 18,6, 'ok'

	message : (key) ->
		st = settings
		if key in ['edit','basic']
			backup = clone settings # to be used by cancel
			console.log 'backup skapad',backup
		else if key[0]=='M'
			st.bits = st.bits.filter (value) -> value[0] != 'M'
			states.SAdv.message key
			@controls.ok.visible = st.sums.M > 0 and st.sums.t < 60
		else if key[0]=='s'
			st.bits = st.bits.filter (value) -> value[0] != 's'
			states.SAdv.message key
		else super key

class SAdv extends State
	constructor : (name) ->
		super name
		@createTrans 'SAdv: M1 M2 M4 M8 M15 M30 M60 s1 s2 s4 s8 s15 s30 s60 t1 t2 t4 t8 t15 t30 t60 SBasic: basic S960: b960 SClock: cancel ok'
		@uppdatera()

	makeControls : ->

		@controls.orange     = new CColor 50, 2.5,'orange'
		@controls.white      = new CColor 50, 9.5,'white'
		@controls.green      = new CColor 50,16.5,'green'

		@controls.reflection = new CDead  25,21,'reflection'
		@controls.bonus      = new CDead  50,21,'bonus'
		@controls.hcp        = new CDead  75,21,'handicap'

		y = 95

		@controls.basic      = new CRounded 1*100/10,y, 18,6, 'basic'
		@controls.adv        = new CRounded 3*100/10,y, 18,6, 'adv', true
		@controls.b960       = new CRounded 5*100/10,y, 18,6, '960'
		@controls.cancel     = new CRounded 7*100/10,y, 18,6, 'cancel'
		@controls.ok         = new CRounded 9*100/10,y, 18,6, 'ok'

		@makeEditButtons()

	makeEditButtons : ->
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
					@controls[name] = new CAdv 'bits', name, xoff+xsize*i, yoff+ysize*j, diam, number

	message : (key) ->
		hash = {'M3':'M1 M2', 'M5':'M1 M4', 'M10':'M2 M8', 'M90':'M30 M60', 's3':'s1 s2', 's5':'s1 s4', 's10':'s2 s8'}
		if key == 'adv'
		else if key of hash
			for msg in hash[key].split ' '
				if msg != '' then @message msg
		else if key[0] in 'Mst'
			st = settings
			st.flip key
			@controls.ok.visible = st.sums.M > 0 and st.sums.t < 60
		else super key

		@uppdatera()
		
	uppdatera : ->
		@controls.white.text = settings.show
		
		settings.handicap()
		sp = settings.players
		@controls.orange.text = if settings.sums.t == 0 then '' else prettyPair sp[0][0], sp[0][1]
		@controls.green.text  = if settings.sums.t == 0 then '' else prettyPair sp[1][0], sp[1][1]

class S960 extends State
	constructor : (name) ->
		super name
		@createTrans 'S960: random R1 R2 R4 R8 R15 R30 R60 R120 R240 R480 SBasic: basic SAdv: adv SClock: cancel ok'
		@makeControls()

	makeControls : ->

		x = [100/4,200/4,300/4]
		y = [-5,40,52,64,76,78,90,95]
		diam = 10

		@controls.C960    = new C960    50,y[0], 100, 10
		@controls.CNumber = new CNumber 50,25

		for i in range 10
			number = [1,2,4,8,15,30,60,120,240,480][i]
			key    = 'R'+number
			xi     = [0,0,0,0,1,1,1,2,2,2][i]
			yi     = [1,2,3,4,1,2,3,1,2,3][i]
			@controls[key] = new CAdv 'bits960',key, x[xi],y[yi], diam, number

		@controls.random     = new CRounded (x[1]+x[2])/2,y[4], 18,6, 'random'

		@controls.basic      = new CRounded 1*100/10,y[7], 18,6, 'basic'
		@controls.adv        = new CRounded 3*100/10,y[7], 18,6, 'adv'
		@controls.b960       = new CRounded 5*100/10,y[7], 18,6, '960',true
		@controls.cancel     = new CRounded 7*100/10,y[7], 18,6, 'cancel'
		@controls.ok         = new CRounded 9*100/10,y[7], 18,6, 'ok'

	message : (key) ->
		if key == 'b960'
		else if key[0] == 'R'
			settings.flip960 key # 10 controls
			@controls.C960.visible = settings.number < 960
		else if key == 'random' 
			nr = _.random 0,959
			settings.number = nr
			settings.bits960 = []
			for value in [480,240,120,60,30,15,8,4,2,1]
				if nr >= value
					nr -= value
					settings.flip960 'R' + value
			@controls.C960.visible = settings.number < 960
		else super key

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
	
	#dump()
	currState = states.SClock

dump = -> # log everything
	for skey of states 
		state = states[skey]
		console.log ''
		console.log 'State',state
		for tkey of state.transitions
			transition = state.transitions[tkey]
			control = state.controls[tkey]
			if transition == undefined then transition = 'nothing'
			console.log ' ',tkey,'=>',transition,control

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

	# debug
	aspect = (w,h,y) ->
		if w < h then [w,h] = [h,w]
		text "#{w} #{(w/h).toFixed(3)} #{h}", 50,y

debugFunction = ->
	# rates.push frameRate()
	# if rates.length > 100 then oldest = rates.shift() else oldest = rates[0]
	# sumRate += _.last(rates) - oldest
	#textSize 3
	# text Math.round(sumRate),50,40
	#text settings.chess960,50,60