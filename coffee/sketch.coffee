# TODO
# Försämring av frameRate inträffar om man går från fullscreen till normal på Android

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
chess = {}

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

class CSettings
	constructor : -> 
		if localStorage.settings
			Object.assign @, JSON.parse localStorage.settings
			console.log "load"
		else
			console.log "default"

		@bits960 ||= ['R480','R30','R8']
		@number ||= 518
		@chess960 ||= 'RNBQKBNR'
		@sums960 ||= {R:518}

		@show ||= '3m2s'
		@bits ||= ['M1','M2','s2']
		@clocks ||= [180,180]
		@bonuses ||= [2,2]
		@sums ||= [H:0,M:3,S:0,m:0,S:2,t:0]
		@player ||= -1 
		@timeout ||= false
		@paused = true

		@handicap()
		@save()

	# random960 : ->
	# 	res = []
	# 	all = [0,1,2,3,4,5,6,7]
	# 	place = (lst,piece) ->
	# 		p = lst[_.random lst.length-1]
	# 		_.remove all, (value) -> value == p
	# 		res[p] = piece
	# 	place [0,2,4,6],'B'
	# 	place [1,3,5,7],'B'
	# 	place all,'Q'
	# 	place all,'N'
	# 	place all,'N'
	# 	[R0,K,R1] = all
	# 	res[R0] = 'R'
	# 	res[K] = 'K'
	# 	res[R1] = 'R'
	# 	res.join ''

	tick : ->
		if @paused then return
		c = @clocks[@player]
		if c > 0 then c -= 1/frameRate()
		if c <= 0
			c = 0
			@timeout = true
			@paused = true
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
		@sums960 = @calcSums960()
		@number = @sums960.R
		@chess960 = chess960 @number

	calcSums : ->
		res = {H:0,M:0,S:0,m:0,s:0,t:0}
		for key in settings.bits
			letter = key[0]
			number = parseInt key.slice 1
			res[letter] += number
		res

	calcSums960 : ->
		res = {R:0}
		for key in settings.bits960
			letter = key[0]
			number = parseInt key.slice 1
			res[letter] += number
		res

	compact : ->
		keys = 'HMSms'
		headers = 'hmsms'
		header0 = ''
		header1 = ''
		for i in [0,1,2]
			key = keys[i]
			if @sums[key]>0 then header0 += @sums[key] + headers[i]
		for i in [3,4]
			key = keys[i]
			if @sums[key]>0 then header1 += @sums[key] + headers[i]
		header = header0
		if header1.length > 0 then header += '+' + header1
		if @sums.t > 0 then header += '\n' + @sums.t
		header

	handicap : ->
		@hcp = @sums.t / (HCP * 60) # 0.0 .. 1.0
		@refl = HOUR * @sums.H + MINUTE * @sums.M + @sums.S # sekunder
		@bonus =                 MINUTE * @sums.m + @sums.s # sekunder
		@players = []
		@players[0] = [@refl + @refl*@hcp, @bonus + @bonus*@hcp]
		@players[1] = [@refl - @refl*@hcp, @bonus - @bonus*@hcp]

	ok : ->
		@sums = @calcSums()
		@handicap()
		@clocks  = [@players[0][0], @players[1][0]]
		@bonuses = [@players[0][1], @players[1][1]]
		@timeout = false
		@paused = true

	cancel : -> 
		Object.assign @, backup
		@paused = true

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

class BNumber extends Button
	constructor : (x,y) ->
		super x,y,0,0
		@x = Math.round @x
		@y = Math.round @y
	draw : ->
		push()
		textSize 4
		fill 'white'
		text settings.sums960.R,@x,@y
		pop()

class B960 extends Button
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

class BRounded extends Button
	constructor : (x,y,w,h,text='',@disabled=false,bg='white',fg='black') ->
		super x,y,w,h,text,bg,fg
	draw : ->
		if @visible
			push()
			fill if @disabled then "gray" else @bg
			rect @x,@y,@w,@h,@h/2
			textSize 4
			fill @fg
			text @text,@x,@y
			pop()

class BPause extends Button
	constructor : (x,y,w=0,h=0,@bg='white',@fg='black') ->
		super x,y,w,h
	draw : ->
		if not settings.paused
			fill @fg
			rect @x-1.75,@y,3,6
			rect @x+1.75,@y,3,6

class BCogwheel extends Button # Kugghjul
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
		text ss,0,2
		textSize 5+3

		#text (if h==0 then 'm:ss' else 'h:mm'),0,17
		if settings.bonuses[@player] > 0
			text '+' + pretty(settings.bonuses[@player]),0,17

		pop()

class BAdv extends Button
	constructor : (@name,x,y,w,h,text) ->
		super x,y,w,h,text,'black'
	draw : ->
		push()
		translate @x,@y
		fill if @name in settings.bits then 'yellow' else 'white'
		scale [height/width,width/height][TOGGLE],1
		circle 0,0,8
		fill 'black'
		textSize 5
		text @text,0,0.2
		pop()
	inside : (x,y) ->
		dx = x-@x
		dy = y-@y
		sqrt(dx*dx + dy*dy) < 5

class BAdv960 extends Button
	constructor : (@name,x,y,w,h,text) ->
		super x,y,w,h,text,'black'
	draw : ->
		push()
		translate @x,@y
		fill if @name in settings.bits960 then 'yellow' else 'white'
		scale [height/width,width/height][TOGGLE],1
		circle 0,0,@w
		fill 'black'
		textSize 5
		text @text,0,0.2
		pop()
	inside : (x,y) ->
		dx = x-@x
		dy = y-@y
		sqrt(dx*dx + dy*dy) < 5

class BBasic extends BAdv
	constructor : (x,y,w,h,text) ->
		super '',x,y,w,h,text
	draw : ->
		push()
		translate @x,@y
		fill 'white'
		scale [height/width,width/height][TOGGLE],1
		circle 0,0,@w
		fill 'black'
		textSize 5
		text @text,0,0.2
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
		#textAlign CENTER,CENTER
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
		@createTrans '=>SClock left pause qr right =>SBasic edit => show chess960'
		settings.paused = true
		settings.player = -1

	makeButtons : ->
		@buttons.left  = new BRotate 50, 22, 100, 44, 180, 'orange', 'white', 0 # eg up
		@buttons.right = new BRotate 50, 78, 100, 44,   0, 'green',  'white', 1 # eg down
		@buttons.show  = new BShow     22, 50, 'black'
		@buttons.qr    = new BImage    50, 50, 33, 12, qr
		@buttons.pause = new BPause    67, 50, 17, 12, 'white', 'black'
		@buttons.edit  = new BCogwheel 83, 50, 17, 12, 'white', 'black'
		#@buttons.chess960 = new B960 50,50,6,6

	handlePlayer : (player) ->
		if settings.player in [-1,player]
			sound.play()
			settings.clocks[player] += settings.bonuses[player]
		settings.paused = false
		settings.player = 1-player
		@buttons.left.fg  = ['black','white'][player]
		@buttons.right.fg = ['white','black'][player]

	message : (key) ->
		if key == 'left'
			if settings.timeout then return else @handlePlayer 0

		else if key == 'right'
			if settings.timeout then return else @handlePlayer 1

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

		settings.save()
		super key

	draw : ->
		background 'white'
		super()

class SBasic extends State
	constructor : (name) ->
		super name
		arr = '=> bonus green hcp orange reflection white M s =>SClock cancel ok =>S960 b960 =>SAdv adv =>SBasic basic M1 M2 M3 M5 M10 M90 s0 s1 s2 s3 s5 s10 s30'.split ' '
		@createTrans arr.join ' '

	makeButtons : ->

		x = [100/3,200/3]
		y = [32,41,50,59,68,77,86,95]
		w = 8
		h = 6

		@buttons.orange     = states.SAdv.buttons.orange
		@buttons.white      = states.SAdv.buttons.white
		@buttons.green      = states.SAdv.buttons.green

		@buttons.reflection = new BDead  x[0],20,'reflection'
		@buttons.bonus      = new BDead  x[1],20,'bonus'

		@buttons.M          = new BDead  x[0], 25, 'M'

		@buttons.M1   			= new BBasic x[0],y[1], w,h, '1'
		@buttons.M2   			= new BBasic x[0],y[2], w,h, '2'
		@buttons.M3   			= new BBasic x[0],y[3], w,h, '3'
		@buttons.M5   			= new BBasic x[0],y[4], w,h, '5'
		@buttons.M10   			= new BBasic x[0],y[5], w,h, '10'
		@buttons.M90   			= new BBasic x[0],y[6], w,h, '90'

		@buttons.s          = new BDead  x[1], 25, 's'

		@buttons.s0   			= new BBasic x[1],y[0], w,h, '0'
		@buttons.s1   			= new BBasic x[1],y[1], w,h, '1'
		@buttons.s2   			= new BBasic x[1],y[2], w,h, '2'
		@buttons.s3   			= new BBasic x[1],y[3], w,h, '3'
		@buttons.s5   			= new BBasic x[1],y[4], w,h, '5'
		@buttons.s10   			= new BBasic x[1],y[5], w,h, '10'
		@buttons.s30   			= new BBasic x[1],y[6], w,h, '30'

		@buttons.basic      = new BRounded 1*100/10,y[7], 18,6, 'basic',true
		@buttons.adv        = new BRounded 3*100/10,y[7], 18,6, 'adv'
		@buttons.b960       = new BRounded 5*100/10,y[7], 18,6, '960'
		@buttons.cancel     = new BRounded 7*100/10,y[7], 18,6, 'cancel'
		@buttons.ok         = new BRounded 9*100/10,y[7], 18,6, 'ok'

		# @buttons.advanced   = new BRounded 1*100/6,y[7], 26,6, 'advanced'
		# @buttons.cancel     = new BRounded 3*100/6,y[7], 26,6, 'cancel'
		# @buttons.ok         = new BRounded 5*100/6,y[7], 26,6, 'ok'

	message : (key) ->

		if key == 'adv'
		else if key == 'basic'
		#else if key == 's960'
		else if key == 'cancel' then settings.cancel()
		else if key == 'ok' then settings.ok()
		else # 6+7 shortcut buttons
			st = settings
			if key[0] == 'M' then st.bits = st.bits.filter (value) -> value[0] not in 'MHS'
			if key[0] == 's' then st.bits = st.bits.filter (value) -> value[0] not in 'ms'
			console.log 'filter',st.bits
			states.SAdv.message key
			@buttons.ok.visible = st.sums.H + st.sums.M + st.sums.S > 0 and st.sums.t < 60

		super key

class SAdv extends State
	constructor : (name) ->
		super name
		arr = '=> green white orange reflection bonus hcp H M S m s t =>SBasic basic =>SAdv adv =>S960 b960 =>SClock cancel ok =>SBasic basic =>SAdv'.split ' '
		for letter in 'HMSmst'
			for number in [1,2,4,8,15,30]
				arr.push letter + number
		@createTrans arr.join ' '
		@uppdatera()

	makeButtons : ->

		@buttons.orange     = new BColor 50, 3,'orange'
		@buttons.white      = new BColor 50, 9,'white'
		@buttons.green      = new BColor 50,15,'green'

		@buttons.reflection = new BDead  25,21,'reflection'
		@buttons.bonus      = new BDead  66,21,'bonus'
		@buttons.hcp        = new BDead  92,21,'hcp'

		y = 95

		@buttons.basic      = new BRounded 1*100/10,y, 18,6, 'basic'
		@buttons.adv        = new BRounded 3*100/10,y, 18,6, 'adv', true
		@buttons.b960       = new BRounded 5*100/10,y, 18,6, '960'
		@buttons.cancel     = new BRounded 7*100/10,y, 18,6, 'cancel'
		@buttons.ok         = new BRounded 9*100/10,y, 18,6, 'ok'

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
				@buttons[name] = new BAdv name, xoff+xsize*i, yoff+ysize*j, xsize, ysize, number

	message : (key) ->
		if key == 'basic'
		else if key == 'advanced'
		else if key == 'cancel' then settings.cancel()
		else if key == 'ok' then settings.ok()
		else
			hash = {'M3':'M1 M2', 'M5':'M1 M4', 'M10':'M2 M8', 'M90':'H1 M30', 's0':'', 's3':'s1 s2', 's5':'s1 s4', 's10':'s2 s8'}
			if key of hash
				for msg in hash[key].split ' '
					if msg != '' then @message msg
			else # 6 x 6 edit buttons
				st = settings
				st.flip key
				@buttons.ok.visible = st.sums.H + st.sums.M + st.sums.S > 0 and st.sums.t < 60

		@uppdatera()
		super key
		
	uppdatera : ->
		@buttons.white.text = settings.show
		
		settings.handicap()
		sp = settings.players
		@buttons.orange.text = if settings.hcp == 0 then '' else prettyPair sp[0][0], sp[0][1]
		@buttons.green.text  = if settings.hcp == 0 then '' else prettyPair sp[1][0], sp[1][1]

class S960 extends State
	constructor : (name) ->
		super name
		arr = '=> B960 BNumber =>SClock cancel ok =>SAdv adv =>SBasic basic =>S960 b960 random R1 R2 R4 R8 R15 R30 R60 R120 R240 R480'.split ' '
		@createTrans arr.join ' '
		@makeButtons()

	makeButtons : ->

		x = [100/4,200/4,300/4]
		y = [-5,30+10,42+10,54+10,66+10,78,90,95]
		w = 11
		h = 10

		@buttons.B960   		= new B960    50,y[0], 100, 10
		@buttons.BNumber    = new BNumber 50,20

		@buttons.R1   			= new BAdv960 'R1', x[0],y[1], w,h, '1'
		@buttons.R2   			= new BAdv960 'R2', x[0],y[2], w,h, '2'
		@buttons.R4   			= new BAdv960 'R4', x[0],y[3], w,h, '4'
		@buttons.R8   			= new BAdv960 'R8', x[0],y[4], w,h, '8'
		
		@buttons.R15   			= new BAdv960 'R15',x[1],y[1], w,h, '15'
		@buttons.R30   			= new BAdv960 'R30',x[1],y[2], w,h, '30'
		@buttons.R60   			= new BAdv960 'R60',x[1],y[3], w,h, '60'

		@buttons.R120  			= new BAdv960 'R120',x[2],y[1], w,h, '120'
		@buttons.R240 			= new BAdv960 'R240',x[2],y[2], w,h, '240'
		@buttons.R480  			= new BAdv960 'R480',x[2],y[3], w,h, '480'

		@buttons.random     = new BRounded (x[1]+x[2])/2,y[4], 18,6, 'random'

		@buttons.basic      = new BRounded 1*100/10,y[7], 18,6, 'basic'
		@buttons.adv        = new BRounded 3*100/10,y[7], 18,6, 'adv'
		@buttons.b960       = new BRounded 5*100/10,y[7], 18,6, '960',true
		@buttons.cancel     = new BRounded 7*100/10,y[7], 18,6, 'cancel'
		@buttons.ok         = new BRounded 9*100/10,y[7], 18,6, 'ok'

	message : (key) ->
		if key == 'adv'
		else if key == 'basic'
		else if key == 'b960'
		else if key == 'cancel' then settings.cancel()
		else if key == 'ok' then settings.ok()
		else if key[0] == 'R'
			settings.flip960 key # 10 buttons
			console.log settings.number
			@buttons.B960.visible = settings.number < 960
		else if key == 'random' 
			nr = _.random 0,959
			settings.number = nr
			settings.bits960 = []
			for value in [480,240,120,60,30,15,8,4,2,1]
				if nr >= value
					nr -= value
					settings.flip960 'R' + value
			@buttons.B960.visible = settings.number < 960
		super key

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
	settings.tick()
	currState.draw()
	pop()

	settings.save()

	# debug
	aspect = (w,h,y) ->
		if w<h then [w,h] = [h,w]
		text "#{w} #{(w/h).toFixed(3)} #{h}", 50,y

	debugFunction()

debugFunction = ->
	# rates.push frameRate()
	# if rates.length > 100 then oldest = rates.shift() else oldest = rates[0]
	# sumRate += _.last(rates) - oldest
	#textSize 3
	# text Math.round(sumRate),50,40
	#text settings.chess960,50,60