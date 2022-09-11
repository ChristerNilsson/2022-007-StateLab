HCP = 1
HOUR = 3600
MINUTE = 60

FRAMERATE = 10

states = {}

rates = []
sumRate = 0

qr = null
timeout = false
currState = null
os = ''
sound = null

diag = 0 

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

# procentuella versioner:
pw = (x) -> x/100 * width
ph = (y) -> y/100 * height
pd = (s) -> s/100 * sqrt width*width + height*height
pimage = (img,x,y,w,h) -> image img, pw(x), ph(y), pw(w), ph(h)
prect = (x,y,w,h) -> rect pw(x), ph(y), pw(w), ph(h)
ptext = (t,x,y) -> text t, pw(x), ph(y)
ptextSize = (s) -> textSize pd(s)
ptranslate = (x,y) -> translate pw(x), ph(y)

class Button
	constructor : (@text,@x,@y,@w=0,@h=0,@bg='white',@fg='black') ->
		@visible = true
		@x = Math.round @x
		@y = Math.round @y
		@w = Math.round @w
		@h = Math.round @h
	draw : ->
		if @visible
			fill @bg
			prect @x,@y,@w,@h
			ptextSize 4
			fill @fg
			ptext @text,@x,@y
	inside : -> -@w/2 <= mouseX*100/width-@x <= @w/2 and -@h/2 <= mouseY*100/height-@y <= @h/2

class BImage extends Button
	constructor : (@image,x,y,w,h) ->
		super '',x,y,w,h
		@visible = false
	draw :  ->
		if @image
			w = @h * height/width # quadratic qr
			pimage @image,@x-w/2, @y-@h/2, w, @h

class BRotate extends Button
	constructor : (x,y,w,h,@degrees,bg,fg,@player) -> super '',x,y,w,h,bg,fg

	draw : ->
		secs = states.SEditor.clocks[@player]
		[h,m,s] = hms secs
		if h >= 1 then ss = h + ':' + d2 m
		else ss = m + ':' + if secs < 10  then s.toFixed 1 else d2 s

		push()
		ptranslate @x,@y
		rotate @degrees
		fill @bg
		prect 0,0,@w,@h
		fill @fg
		ptextSize 18
		ptext ss,0,-2
		ptextSize 5
		if states.SEditor.bonuses[@player] > 0
			ptext '+' + trunc3(states.SEditor.bonuses[@player])+'s',0,17
		if states.SEditor.clocks[@player] <= 0 then @bg = 'red'
		pop()

class BEdit extends Button
	constructor : (text,x,y,w,h,fg='gray') -> super text,x,y,w,h,'black',fg
	draw : ->
		ptextSize 5
		fill @fg
		ptext @text,@x,@y

class BDead extends Button
	constructor : (text,x,y,fg='lightgray') -> super text,x,y,0,0,'black',fg
	draw : ->
		ptextSize 4
		fill @fg
		ptext @text,@x,@y

class BColor extends Button
	constructor : (@fg,x,y) -> super '',x,y
	draw : ->
		push()
		textAlign CENTER,CENTER
		ptextSize 4
		fill @fg
		ptext @text,@x,@y
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

class SWelcome extends State
	constructor : (name) ->
		super name
		@createTrans '=>SClock welcome'
		console.log @

	message : (key) ->
		if key == 'welcome'
			fullscreen true
			resizeCanvas innerWidth, innerHeight
		super key

	makeButtons : ->
		@buttons.welcome  = new Button 'Click me!', 50,50,100,100


# =>SClock continue pause left right =>SEditor new
class SClock extends State

	constructor : (name) ->
		super name
		@createTrans '=>SClock continue left pause qr right =>SEditor new'
		@paused = true
		@player = -1
		@buttons.pause.visible = false
		@buttons.continue.visible = false

	makeButtons : ->
		@buttons.left     = new BRotate 50, 22, 100, 44, 180, 'orange', 'white', 0 # eg up
		@buttons.right    = new BRotate 50, 78, 100, 44,   0, 'green',  'white', 1 # eg down
		@buttons.pause    = new Button 'pause',    25, 50, 50, 12
		@buttons.continue = new Button 'continue', 25, 50, 50, 12
		@buttons.new      = new Button 'new',      75, 50, 50, 12
		@buttons.qr       = new BImage qr,         75, 50, 12, 12

	uppdatera : ->
		#console.log 'uppdatera'
		if @paused then return
		clock = states.SEditor.clocks[@player]
		if clock > 0 then clock -= 1/FRAMERATE
		if clock <= 0 
			clock = 0
			timeout = true
		states.SEditor.clocks[@player] = clock

	message : (key) ->
		if key == 'left'
			if timeout then return
			else
				if @player in [-1,0]
					sound.play()
					states.SEditor.clocks[0] += states.SEditor.bonuses[0]
				@paused = false
				@player = 1
				@buttons.left.fg = 'black'
				@buttons.right.fg = 'white'

		if key == 'right'
			if timeout then return
			else
				if @player in [-1,1]
					sound.play()
					states.SEditor.clocks[1] += states.SEditor.bonuses[1]
				@paused = false
				@player = 0
				@buttons.left.fg = 'white'
				@buttons.right.fg = 'black'

		if key == 'pause'
			@paused = true
			if @player == 0
				@buttons.left.fg = 'gray'
				@buttons.right.fg = 'black'
			else
				@buttons.left.fg = 'black'
				@buttons.right.fg = 'gray'

		if key == 'continue'
			@paused = false
			if @player == 0
				@buttons.left.fg = 'white'
				@buttons.right.fg = 'black'
			else
				@buttons.left.fg = 'black'
				@buttons.right.fg = 'white'

		@buttons.pause.visible = not @paused
		@buttons.qr.visible = not @paused
		@buttons.continue.visible = @paused
		@buttons.new.visible = @paused
		super key

# =>SClock ok => orange white green reflection bonus hcp a b c d e f =>SEditor swap a0 a1 a2 a3 a4 a5 b0 b1 b2 b3 b4 b5 c0 c1 c2 c3 c4 c5 d0 d1 d2 d3 d4 d5 e0 e1 e2 e3 e4 e5 f0 f1 f2 f3 f4 f5
class SEditor extends State
	constructor : (name) ->
		super name

		@sums = [0,0,0,0,0,0]
		@hcpSwap = 1

		arr = '=> H M S m s t bonus green hcp orange reflection white =>SClock cancel ok =>SEditor swap'.split ' '
		for i in range 6
			for j in range 6
				arr.push 'HMSmst'[i] + [1,2,4,8,15,30][j]
		@createTrans arr.join ' '

		# initialisera M3+s2
		@message 'M1'
		@message 'M2'
		@message 's2'
		@message 'ok'

	makeButtons : ->

		@buttons.swap       = new Button 'swap',      25,93, 22,8
		@buttons.cancel     = new Button 'cancel',    50,93, 22,8
		@buttons.ok         = new Button 'ok',        75,93, 22,8
		@buttons.orange     = new BColor 'orange',    50,3
		@buttons.white      = new BColor 'white',     50,9
		@buttons.green      = new BColor 'green',     50,15
		@buttons.reflection = new BDead 'reflection', 25,21
		@buttons.bonus      = new BDead 'bonus',      66,21
		@buttons.hcp        = new BDead 'hcp',        92,21

		for i in range 6
			letter = 'HMSmst'[i]
			xsize = 100/6
			ysize = 100/10
			xoff = xsize/2
			yoff = 33+2
			@buttons[letter] = new BDead 'HMSmst'[i], xoff+xsize*i, 26+2
			for j in range 6
				number = [1,2,4,8,15,30][j]
				name = letter + number
				@buttons[name] = new BEdit number, xoff+xsize*i, yoff+ysize*j, xsize, ysize, 'gray'

	message : (key) ->

		if key == 'swap'
			@hcpSwap = -@hcpSwap
		else if key == 'cancel'
		else if key == 'ok'
			timeout = false
			states.SClock.buttons.continue.visible = false
			states.SClock.buttons.pause.visible = true
			states.SClock.buttons.new.visible = false
			states.SClock.buttons.qr.visible = true

			states.SClock.buttons.left.fg = 'white'
			states.SClock.buttons.left.bg = 'orange'
			states.SClock.buttons.right.fg = 'white'
			states.SClock.buttons.right.bg = 'green'

			@clocks  = [@players[0][0], @players[1][0]]
			@bonuses = [@players[0][1], @players[1][1]]

		else
			@buttons[key].fg = if @buttons[key].fg == 'gray' then 'yellow' else 'gray'
			letter = key[0]
			col = 'HMSmst'.indexOf letter
			number = parseInt key.slice 1
			@sums[col] = if @buttons[key].fg == 'gray' then @sums[col]-number else @sums[col]+number
			@buttons.ok.visible = @sums[0] + @sums[1] + @sums[2] > 0
			@buttons.swap.visible = @sums[5] > 0

		@uppdatera()
		super key

	uppdatera : ->
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
		@players[0] = [@refl + @refl*@hcp, @bonus + @bonus*@hcp]
		@players[1] = [@refl - @refl*@hcp, @bonus - @bonus*@hcp]


###################################

preload = -> 
	qr = loadImage 'qr.png'
	sound = loadSound 'key.mp3'

windowResized = ->
	resizeCanvas innerWidth, innerHeight
	diag = sqrt width*width + height*height

checkButtons = ->
	console.log 'checkButtons started'
	for bkey of buttons
		button = buttons[bkey]
		found = false
		for skey of states
			state = states[skey]
			if bkey of state.transitions then found = true
		if not found then console.log '  Button',bkey,'not used by any state'
	console.log 'checkButtons done!'

checkStates = ->
	console.log 'checkStates started'
	for skey of states
		state = states[skey]
		found = false
		for tkey of state.transitions
			transition = state.transitions[tkey]
			if transition != undefined and transition not of states then console.log transition,'not found'
			if tkey of buttons then found = true else info = tkey
		if not found then console.log '  State',skey,'Transition',tkey, 'not defined'
	console.log 'checkStates done!'

setup = ->
	frameRate FRAMERATE
	os = navigator.appVersion
	if os.indexOf('Linux') >= 0 then os = 'Android'
	if os.indexOf('Windows') >= 0 then os = 'Windows'
	if os.indexOf('Mac') >= 0 then os = 'Mac'

	createCanvas innerWidth,innerHeight

	if os == 'Mac' then textFont 'Verdana'
	if os == 'Windows' then textFont 'Lucida Sans Unicode'

	diag = sqrt width*width + height*height

	background 'black'
	textAlign CENTER,CENTER
	rectMode CENTER
	angleMode DEGREES

	createState 'SWelcome', SWelcome
	createState 'SClock', SClock
	createState 'SEditor',SEditor

	# log everything
	for skey of states 
		state = states[skey]
		console.log ''
		console.log 'State',state
		for tkey of state.transitions
			transition = state.transitions[tkey]
			button = state.buttons[tkey]
			if transition == undefined then transition = 'nothing'
			console.log ' ',tkey,'=>',transition,button

	currState = if os == 'Android' then states.SWelcome else states.SClock

	#checkButtons()
	#checkStates()

draw = ->
	background 'black'
	states.SClock.uppdatera()
	for tkey of currState.transitions
		if tkey of currState.buttons 
			currState.buttons[tkey].draw()
		else
			console.log 'missing',tkey

	# debug
	aspect = (w,h,y) ->
		if w<h then [w,h] = [h,w]
		ptext "#{w} #{(w/h).toFixed(3)} #{h}", 50,y

	rates.push frameRate()
	if rates.length > 100 then oldest = rates.shift() else oldest = rates[0]
	sumRate += _.last(rates) - oldest

	# # os = navigator.appVersion
	ptextSize 2.5
	ptext 'A',5,5
	ptext Math.round(sumRate),95,5

	# ptext currState.name,50,3
	# # fill 'green'
	# ptext round3(states.SEditor.bonuses[0]),10,3
	# ptext round3(states.SEditor.clocks[0]),25,3
	# ptext round3(states.SEditor.clocks[1]),75,3
	# ptext round3(states.SEditor.bonuses[1]),90,3

	# ptext states.SClock.paused,30,2.5
	# ptext states.SClock.player,70,2.5

	currState.draw()

mouseClicked = ->
	for key of currState.transitions
		if currState.transitions[key] == undefined then continue
		button = currState.buttons[key]
		if button.visible and button.inside mouseX, mouseY 
			currState.message key
			break
