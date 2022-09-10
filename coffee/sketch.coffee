HCP = 1
HOUR = 3600
MINUTE = 60

buttons = {}
states = {}

qr = null
timeout = false
currState = null

diag = 0 

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
console.log d2(3), '03'

hms = (x) ->
	orig = x
	s = x %% 60
	x = x // 60
	m = x %% 60
	x = x // 60
	h = x
	if orig < 10 then s = Math.trunc(s*10)/10 
	[h,m,s] 
console.log hms(180), [0,3,0]
console.log hms(180.5), [0,3,0.5]

pimage = (img,x,y,w,h) -> image img, x/100*width, y/100*height, w/100*width, h/100*height
prect = (x,y,w,h) -> rect x/100*width, y/100*height, w/100*width, h/100*height
ptext = (t,x,y) -> text t,x/100*width, y/100*height
ptextSize = (s) -> textSize s/100*diag
ptranslate = (x,y) -> translate x/100*width,y/100*height

class Button
	constructor : (@text,@x,@y,@w,@h,@bg='white',@fg='black') ->
		@visible = true
	draw : (disabled) ->
		if @visible
			fill @bg
			prect @x,@y,@w,@h
			ptextSize 4
			fill @fg
			ptext @text,@x,@y
	inside : -> -@w/2 <= mouseX*100/width-@x <= @w/2 and -@h/2 <= mouseY*100/height-@y <= @h/2

class BImage extends Button
	constructor : (@image,x,y,w,h) -> super '',x,y,w,h
	#draw :  -> if @image then image @image,(width-@w)/2,(height-@h)/2,@w,@h
	draw :  -> if @image then pimage @image,50-@w/2, 50-@h/2, @w, @h

class BRotate extends Button
	constructor : (x,y,w,h,@degrees,bg,fg,@player) -> super '',x,y,w,h,bg,fg

	draw : ->
		secs = states.SEditor.clocks[@player]
		[h,m,s] = hms secs
		if h >= 1 then ss = h + ':' + d2(m)
		else ss = m + ':' + if secs < 10  then s.toFixed(1) else d2(s)

		push()
		ptranslate @x,@y
		rotate @degrees
		fill @bg
		prect 0,0,@w,@h
		fill @fg
		ptextSize 18
		ptext ss,0,1.7
		ptextSize 5
		if states.SEditor.bonuses[@player] > 0
			ptext '+' + trunc3(states.SEditor.bonuses[@player])+'s',0,15
		if states.SEditor.clocks[@player] <= 0 then @bg = 'red'
		pop()

class BEdit extends Button
	constructor : (text,x,y,w,h,fg='gray') -> super text,x,y,w,h,'black',fg
	draw : ->
		ptextSize 5 # 0.05*diag
		fill @fg
		ptext @text,@x,@y

class BDead extends Button
	constructor : (text,x,y,fg='lightgray') -> super text,x,y,0,0,'black',fg
	draw : ->
		ptextSize 4 #0.04*diag
		fill @fg
		ptext @text,@x,@y

class BColor extends Button
	constructor : (@fg,x,y) -> super '',x,y,0,0
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
	constructor : -> @transitions = {}
	createTrans : (t) ->
		console.log t
		target = undefined
		arr = t.split ' '
		for word in arr
			if word == '=>' then target = undefined
			else if word.indexOf('=>') == 0 then target = word.slice 2
			else @transitions[word] = target
		console.log @transitions

	message : (key) ->
		console.log "clicked #{@name}.#{key} => #{@transitions[key]}"
		if key of @transitions
			currState = states[@transitions[key]]
			console.log currState,currState
			currState.patch()
		else console.log 'missing transition:',key
	patch : ->
	draw : ->

# =>SClock qr continue pause left right =>SEditor new
class SClock extends State
	constructor : (@name) ->
		super()
		@createTrans '=>SClock qr continue pause left right =>SEditor new'
		@paused = true
		@player = -1
		buttons.pause.visible = false
		buttons.continue.visible = false

	uppdatera : ->
		#console.log 'uppdatera'
		if @paused then return
		clock = states.SEditor.clocks[@player]
		if clock > 0 then clock -= 1/60
		if clock <= 0 
			clock = 0
			timeout = true
		states.SEditor.clocks[@player] = clock

	message : (key) ->
		if key == 'qr' 
			toggleFullScreen()
			resizeCanvas windowWidth, windowHeight

		if key == 'left'
			if timeout then return
			else
				if @player == 0 then states.SEditor.clocks[0] += states.SEditor.bonuses[0]
				@paused = false
				@player = 1
				buttons.left.fg = 'black'
				buttons.right.fg = 'white'

		if key == 'right'
			if timeout then return
			else
				if @player == 1 then states.SEditor.clocks[1] += states.SEditor.bonuses[1]
				@paused = false
				@player = 0
				buttons.left.fg = 'white'
				buttons.right.fg = 'black'

		if key == 'pause'
			@paused = true
			if @player == 0
				buttons.left.fg = 'gray'
				buttons.right.fg = 'black'
			else
				buttons.left.fg = 'black'
				buttons.right.fg = 'gray'

		if key == 'continue'
			@paused = false
			if @player == 0
				buttons.left.fg = 'white'
				buttons.right.fg = 'black'
			else
				buttons.left.fg = 'black'
				buttons.right.fg = 'white'

		buttons.pause.visible = not @paused
		buttons.continue.visible = @paused
		buttons.new.visible = @paused
		super key

# =>SClock ok => orange white green reflection bonus hcp a b c d e f =>SEditor swap a0 a1 a2 a3 a4 a5 b0 b1 b2 b3 b4 b5 c0 c1 c2 c3 c4 c5 d0 d1 d2 d3 d4 d5 e0 e1 e2 e3 e4 e5 f0 f1 f2 f3 f4 f5
class SEditor extends State
	constructor : (@name) ->
		super()
		@sums = [0,1+2,0,0,2,0]

		@clocks = [3*60,3*60] # seconds
		@bonuses = [2,2] # seconds
		buttons.b0.fg = 'yellow'
		buttons.b1.fg = 'yellow'
		buttons.e1.fg = 'yellow'
		buttons.white.text = '3m + 2s'
		buttons.swap.visible = false

		@hcpSwap = 1

		arr = '=>SClock ok => orange white green reflection bonus hcp a b c d e f =>SEditor swap'.split ' '
		for i in range 6
			letter = 'abcdef'[i]
			for j in range 6
				arr.push letter + j
		@createTrans arr.join ' '
		console.log arr.join ' '

	message : (key) ->

		if key == 'swap'
			@hcpSwap = -@hcpSwap
		else if key == 'ok' 
			timeout = false
			buttons.continue.visible = false
			buttons.pause.visible = true
			buttons.left.fg = 'white'
			buttons.left.bg = 'orange'
			buttons.right.fg = 'white'
			buttons.right.bg = 'green'
		else
			buttons[key].fg = if buttons[key].fg == 'gray' then 'yellow' else 'gray'
			letter = key[0]
			col = 'abcdef'.indexOf letter
			factor = if col==5 then HCP else 1
			j = key[1]
			number = factor * [1,2,4,8,15,30][j]
			@sums[col] = if buttons[key].fg == 'gray' then @sums[col]-number else @sums[col]+number
			buttons.ok.visible = @sums[0] + @sums[1] + @sums[2] > 0
			buttons.swap.visible = @sums[5] > 0

		@uppdatera()
		super key

	uppdatera : ->
		buttons.white.text = @compact()
		@handicap()
		if @hcp == 0
			buttons.orange.text   = ''
			buttons.green.text = ''
		else
			buttons.orange.text   = prettyPair @players[0][0], @players[0][1]
			buttons.green.text = prettyPair @players[1][0], @players[1][1]

	compact : ->
		headers = 'h m s m s'.split ' '
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
		@clocks  = [@players[0][0], @players[1][0]]
		@bonuses = [@players[0][1], @players[1][1]]

makeEditButtons = ->
	for i in range 6
		letter = 'abcdef'[i]
		xsize = 100/6
		ysize = 100/10
		xoff = xsize/2
		yoff = 33
		shown = 'H M S m s t'.split ' '
		buttons[letter] = new BDead shown[i], xoff+xsize*i, 26
		for j in range 6
			number = [1,2,4,8,15,30][j]
			name = letter + j
			factor = if i==5 then HCP else 1
			buttons[name] = new BEdit factor * number, xoff+xsize*i, yoff+ysize*j, xsize, ysize, 'gray'

###################################

preload = -> qr = loadImage 'qr.png'

windowResized = ->
	resizeCanvas windowWidth, windowHeight
	diag = sqrt width*width + height*height

setup = ->
	os = navigator.appVersion
	console.log os
	if os.indexOf('Linux') >= 0 # android/linux
		createCanvas screen.width,screen.height
		#createCanvas displaywidth,displayHeight
	else
		createCanvas window.innerWidth,window.innerHeight # Windows or Mac

	diag = sqrt width*width + height*height

	textFont 'Lucida Sans Unicode'

	background 'black'

	textAlign CENTER,CENTER
	rectMode CENTER
	angleMode DEGREES

	w = width
	h = height

	# Main Page
	hsize = 12
	buttons.left     = new BRotate 50, 22, 100, 44, 180, 'orange', 'white', 0 # eg up
	buttons.right    = new BRotate 50, 78, 100, 44,   0, 'green',  'white', 1 # eg down
	wsize = 12/w*h # make qr quadratic
	w1 = (100-wsize)/2
	buttons.pause    = new Button 'pause',    w1/2,       50, w1, hsize
	buttons.continue = new Button 'continue', w1/2,       50, w1, hsize
	buttons.new      = new Button 'new',      100-w1/2,   50, w1, hsize
	buttons.qr       = new BImage qr, 50, 50, wsize, hsize
	
	# Edit Page
	buttons.swap       = new Button 'swap', 33, 93, 22, 8
	buttons.ok         = new Button 'ok',   67, 93, 22, 8
	buttons.orange     = new BColor 'orange',50, 3
	buttons.white      = new BColor 'white', 50, 9
	buttons.green      = new BColor 'green', 50, 15
	buttons.reflection = new BDead 'reflection', 25,21
	buttons.bonus      = new BDead 'bonus',      66,21
	buttons.hcp        = new BDead 'hcp',        92,21

	makeEditButtons()
	createState 'SClock', SClock
	createState 'SEditor',SEditor
	currState = states.SClock

draw = ->
	background 'black'

	states.SClock.uppdatera()

	for key of currState.transitions
		target = currState.transitions[key]
		if key of buttons then buttons[key].draw target == undefined
		else console.log 'missing button:',key

	# debug

	aspect = (w,h,y) ->
		if w<h then [w,h] = [h,w]
		ptext "#{w} #{(w/h).toFixed(3)} #{h}", 50,y

	# os = navigator.appVersion
	textSize 0.025 * height
	aspect screen.width, screen.height,5
	aspect displayWidth, displayHeight,15
	aspect innerWidth, innerHeight,10
	aspect width, height,20

	# text currState.name,0.5*width,0.03*height
	# fill 'green'
	# text round3(states.SEditor.bonuses[0]),0.1*width,0.03*height
	# text round3(states.SEditor.clocks[0]),0.25*width,0.03*height
	# text round3(states.SEditor.clocks[1]),0.75*width,0.03*height
	# text round3(states.SEditor.bonuses[1]),0.9*width,0.03*height

	# text states.SClock.paused,0.3*width,0.025*height
	# text states.SClock.player,0.7*width,0.025*height

	currState.draw()

mouseClicked = ->
	for key of currState.transitions
		if currState.transitions[key] == undefined then continue
		if buttons[key].visible and buttons[key].inside mouseX, mouseY 
			console.log key
			currState.message key
			break

#################

# HCP = 1
# HOUR = 3600
# MINUTE = 60

# buttons = {}
# states = {}

# qr = null
# timeout = false
# currState = null

# diag = 0 

# toggleFullScreen = ->
# 	doc = window.document
# 	docEl = doc.documentElement
# 	requestFullScreen = docEl.requestFullscreen or docEl.mozRequestFullScreen or docEl.webkitRequestFullScreen or docEl.msRequestFullscreen
# 	if not doc.fullscreenElement and not doc.mozFullScreenElement and not doc.webkitFullscreenElement and not doc.msFullscreenElement
# 		requestFullScreen.call docEl

# trunc3 = (x) -> Math.trunc(x*1000)/1000

# createState = (key,klass) -> states[key] = new klass key

# pretty = (tot) ->
# 	s = tot % 60
# 	tot = (tot - s) / 60
# 	m = tot % 60
# 	tot = (tot - m) / 60
# 	h = tot % 60
# 	header = ''
# 	if trunc3(h)>0 then header += trunc3(h) + 'h'
# 	if trunc3(m)>0 then header += trunc3(m) + 'm'
# 	if trunc3(s)>0 then header += trunc3(s) + 's'
# 	header

# prettyPair = (a,b) ->
# 	separator = if pretty(b) != '' then ' + ' else ''
# 	pretty(a) + separator + pretty(b)

# d2 = (x) ->
# 	x = Math.trunc x
# 	if x < 10 then '0'+x else x
# console.log d2(3), '03'

# hms = (x) ->
# 	orig = x
# 	s = x %% 60
# 	x = x // 60
# 	m = x %% 60
# 	x = x // 60
# 	h = x
# 	if orig < 10 then s = Math.trunc(s*10)/10 
# 	[h,m,s] 
# console.log hms(180), [0,3,0]
# console.log hms(180.5), [0,3,0.5]

# class Button
# 	constructor : (@text,@x,@y,@w,@h,@bg='white',@fg='black') ->
# 		@visible = true
# 	draw : (disabled) ->
# 		if @visible
# 			fill @bg
# 			rect @x,@y,@w,@h
# 			textSize 0.04*diag
# 			fill @fg
# 			text @text,@x,@y
# 	inside : -> -@w/2 <= mouseX-@x <= @w/2 and -@h/2 <= mouseY-@y <= @h/2

# class BImage extends Button
# 	constructor : (@image,x,y,w,h) -> super '',x,y,w,h
# 	draw :  -> if @image then image @image,(width-@w)/2,(height-@h)/2,@w,@h

# class BRotate extends Button
# 	constructor : (x,y,w,h,@degrees,bg,fg,@player) -> super '',x,y,w,h,bg,fg

# 	draw : ->
# 		secs = states.SEditor.clocks[@player]
# 		[h,m,s] = hms secs
# 		if h >= 1 then ss = h + ':' + d2(m)
# 		else ss = m + ':' + if secs < 10  then s.toFixed(1) else d2(s)

# 		fill @bg
# 		rect @x,@y,@w,@h

# 		push()
# 		translate @x,@y
# 		rotate @degrees
# 		textSize 0.18*diag
# 		fill @fg
# 		text ss,0,0.017*height
# 		textSize 0.05*diag
# 		if states.SEditor.bonuses[@player] > 0
# 			text '+' + trunc3(states.SEditor.bonuses[@player])+'s',0,0.15*height
# 		if states.SEditor.clocks[@player] <= 0 then @bg = 'red'
# 		pop()

# class BEdit extends Button
# 	constructor : (text,x,y,w,h,fg='gray') -> super text,x,y,w,h,'black',fg
# 	draw : ->
# 		textSize 0.05*diag
# 		fill @fg
# 		text @text,@x,@y

# class BDead extends Button
# 	constructor : (text,x,y,fg='lightgray') -> super text,x,y,0,0,'black',fg
# 	draw : ->
# 		textSize 0.04*diag
# 		fill @fg
# 		text @text,@x,@y

# class BColor extends Button
# 	constructor : (@fg,x,y) -> super '',x,y,0,0
# 	draw : ->
# 		push()
# 		textAlign CENTER,CENTER
# 		textSize 0.04*diag
# 		fill @fg
# 		text @text,@x,@y
# 		pop()

# # struktur för transitionssträngen:
# # =>target0 msg0 msg1 =>target1 msg2 msg3 => msg4
# # @transitions[msg0] = target0
# # @transitions[msg1] = target0
# # @transitions[msg2] = target1
# # @transitions[msg3] = target1
# # @transitions[msg4] = undefined

# class State
# 	constructor : -> @transitions = {}
# 	createTrans : (t) ->
# 		console.log t
# 		target = undefined
# 		arr = t.split ' '
# 		for word in arr
# 			if word == '=>' then target = undefined
# 			else if word.indexOf('=>') == 0 then target = word.slice 2
# 			else @transitions[word] = target
# 		console.log @transitions

# 	message : (key) ->
# 		console.log "clicked #{@name}.#{key} => #{@transitions[key]}"
# 		if key of @transitions
# 			currState = states[@transitions[key]]
# 			console.log currState,currState
# 			currState.patch()
# 		else console.log 'missing transition:',key
# 	patch : ->
# 	draw : ->

# # =>SClock qr continue pause left right =>SEditor new
# class SClock extends State
# 	constructor : (@name) ->
# 		super()
# 		@createTrans '=>SClock qr continue pause left right =>SEditor new'
# 		@paused = true
# 		@player = -1
# 		buttons.pause.visible = false
# 		buttons.continue.visible = false

# 	uppdatera : ->
# 		#console.log 'uppdatera'
# 		if @paused then return
# 		clock = states.SEditor.clocks[@player]
# 		if clock > 0 then clock -= 1/60
# 		if clock <= 0 
# 			clock = 0
# 			timeout = true
# 		states.SEditor.clocks[@player] = clock

# 	message : (key) ->
# 		if key == 'qr' 
# 			toggleFullScreen()
# 			resizeCanvas windowWidth, windowHeight

# 		if key == 'left'
# 			if timeout then return
# 			else
# 				if @player == 0 then states.SEditor.clocks[0] += states.SEditor.bonuses[0]
# 				@paused = false
# 				@player = 1
# 				buttons.left.fg = 'black'
# 				buttons.right.fg = 'white'

# 		if key == 'right'
# 			if timeout then return
# 			else
# 				if @player == 1 then states.SEditor.clocks[1] += states.SEditor.bonuses[1]
# 				@paused = false
# 				@player = 0
# 				buttons.left.fg = 'white'
# 				buttons.right.fg = 'black'

# 		if key == 'pause'
# 			@paused = true
# 			if @player == 0
# 				buttons.left.fg = 'gray'
# 				buttons.right.fg = 'black'
# 			else
# 				buttons.left.fg = 'black'
# 				buttons.right.fg = 'gray'

# 		if key == 'continue'
# 			@paused = false
# 			if @player == 0
# 				buttons.left.fg = 'white'
# 				buttons.right.fg = 'black'
# 			else
# 				buttons.left.fg = 'black'
# 				buttons.right.fg = 'white'

# 		buttons.pause.visible = not @paused
# 		buttons.continue.visible = @paused
# 		buttons.new.visible = @paused
# 		super key

# # =>SClock ok => orange white green reflection bonus hcp a b c d e f =>SEditor swap a0 a1 a2 a3 a4 a5 b0 b1 b2 b3 b4 b5 c0 c1 c2 c3 c4 c5 d0 d1 d2 d3 d4 d5 e0 e1 e2 e3 e4 e5 f0 f1 f2 f3 f4 f5
# class SEditor extends State
# 	constructor : (@name) ->
# 		super()
# 		@sums = [0,1+2,0,0,2,0]

# 		@clocks = [3*60,3*60] # seconds
# 		@bonuses = [2,2] # seconds
# 		buttons.b0.fg = 'yellow'
# 		buttons.b1.fg = 'yellow'
# 		buttons.e1.fg = 'yellow'
# 		buttons.white.text = '3m + 2s'
# 		buttons.swap.visible = false

# 		@hcpSwap = 1

# 		arr = '=>SClock ok => orange white green reflection bonus hcp a b c d e f =>SEditor swap'.split ' '
# 		for i in range 6
# 			letter = 'abcdef'[i]
# 			for j in range 6
# 				arr.push letter + j
# 		@createTrans arr.join ' '
# 		console.log arr.join ' '

# 	message : (key) ->

# 		if key == 'swap'
# 			@hcpSwap = -@hcpSwap
# 		else if key == 'ok' 
# 			timeout = false
# 			buttons.continue.visible = false
# 			buttons.pause.visible = true
# 			buttons.left.fg = 'white'
# 			buttons.left.bg = 'orange'
# 			buttons.right.fg = 'white'
# 			buttons.right.bg = 'green'
# 		else
# 			buttons[key].fg = if buttons[key].fg == 'gray' then 'yellow' else 'gray'
# 			letter = key[0]
# 			col = 'abcdef'.indexOf letter
# 			factor = if col==5 then HCP else 1
# 			j = key[1]
# 			number = factor * [1,2,4,8,15,30][j]
# 			@sums[col] = if buttons[key].fg == 'gray' then @sums[col]-number else @sums[col]+number
# 			buttons.ok.visible = @sums[0] + @sums[1] + @sums[2] > 0
# 			buttons.swap.visible = @sums[5] > 0

# 		@uppdatera()
# 		super key

# 	uppdatera : ->
# 		buttons.white.text = @compact()
# 		@handicap()
# 		if @hcp == 0
# 			buttons.orange.text   = ''
# 			buttons.green.text = ''
# 		else
# 			buttons.orange.text   = prettyPair @players[0][0], @players[0][1]
# 			buttons.green.text = prettyPair @players[1][0], @players[1][1]

# 	compact : ->
# 		headers = 'h m s m s'.split ' '
# 		header0 = ''
# 		header1 = ''
# 		for i in range 0,3
# 			if @sums[i]>0 then header0 += @sums[i] + headers[i]
# 		for i in range 3,5
# 			if @sums[i]>0 then header1 += @sums[i] + headers[i]
# 		header = header0
# 		if header1.length > 0 then header += ' + ' + header1
# 		header

# 	handicap : ->
# 		@hcp = @hcpSwap * @sums[5] / (HCP * 60) # 0.0 .. 1.0
# 		@refl = HOUR * @sums[0] + MINUTE * @sums[1] + @sums[2] # sekunder
# 		@bonus =                  MINUTE * @sums[3] + @sums[4] # sekunder
# 		@players = []
# 		@players[0] = [@refl + @refl*@hcp, @bonus + @bonus*@hcp]
# 		@players[1] = [@refl - @refl*@hcp, @bonus - @bonus*@hcp]
# 		@clocks  = [@players[0][0], @players[1][0]]
# 		@bonuses = [@players[0][1], @players[1][1]]

# makeEditButtons = ->
# 	for i in range 6
# 		letter = 'abcdef'[i]
# 		xsize = width/6
# 		ysize = height/10
# 		xoff = xsize/2 + (width-6*xsize)/2
# 		yoff = 0.33*height
# 		shown='H M S m s t'.split ' '
# 		buttons[letter] = new BDead shown[i], xoff+xsize*i, 0.26*height 
# 		for j in range 6
# 			number = [1,2,4,8,15,30][j]
# 			name = letter + j
# 			factor = if i==5 then HCP else 1
# 			buttons[name] = new BEdit factor * number, xoff+xsize*i, yoff+ysize*j, xsize, ysize, 'gray'

# ###################################

# preload = -> qr = loadImage 'qr.png'

# #windowResized = -> resizeCanvas windowWidth, windowHeight

# setup = ->
# 	os = navigator.appVersion
# 	console.log os
# 	if os.indexOf('Linux') >= 0 # android/linux
# 		createCanvas screen.width,screen.height
# 		#createCanvas displaywidth,displayHeight
# 	else
# 		createCanvas window.innerWidth,window.innerHeight # Windows or Mac

# 	textFont 'Lucida Sans Unicode'
# 	diag = sqrt width*width + height*height

# 	background 'black'

# 	textAlign CENTER,CENTER
# 	rectMode CENTER
# 	angleMode DEGREES

# 	w = width
# 	h = height

# 	# Main Page
# 	size = 0.12*h # qr
# 	buttons.left     = new BRotate 0.5*w, 0.22*h, w, 0.44*h, 180, 'orange', 'white', 0 # eg up
# 	buttons.right    = new BRotate 0.5*w, 0.78*h, w, 0.44*h,   0, 'green',  'white', 1 # eg down
# 	buttons.pause    = new Button 'pause',    0.25*(w-size), 0.50*h, (w-size)/2, size
# 	buttons.continue = new Button 'continue', 0.25*(w-size), 0.50*h, (w-size)/2, size
# 	buttons.new      = new Button 'new',    w-0.25*(w-size), 0.50*h, (w-size)/2, size
# 	buttons.qr       = new BImage qr,0.5*w, 0.5*h, size, size
	
# 	# Edit Page
# 	buttons.swap       = new Button 'swap', 0.33*w, 0.93*h, 0.22*w, 0.08*h
# 	buttons.ok         = new Button 'ok',   0.67*w, 0.93*h, 0.22*w, 0.08*h
# 	buttons.orange     = new BColor 'orange',w/2, 0.03*h
# 	buttons.white      = new BColor 'white', w/2, 0.09*h
# 	buttons.green      = new BColor 'green', w/2, 0.15*h
# 	buttons.reflection = new BDead 'reflection', 0.25*w, 0.21*h
# 	buttons.bonus      = new BDead 'bonus', 0.66*w, 0.21*h
# 	buttons.hcp        = new BDead 'hcp', 0.92*w, 0.21*h

# 	makeEditButtons()
# 	createState 'SClock', SClock
# 	createState 'SEditor',SEditor
# 	currState = states.SClock

# draw = ->
# 	background 'black'

# 	states.SClock.uppdatera()

# 	for key of currState.transitions
# 		target = currState.transitions[key]
# 		if key of buttons then buttons[key].draw target == undefined
# 		else console.log 'missing button:',key

# 	# debug

# 	# os = navigator.appVersion
# 	# textSize 0.025 * height
# 	# text width,0.5*width,0.05*height
# 	# text height,0.75*width,0.05*height

# 	# text currState.name,0.5*width,0.03*height
# 	# fill 'green'
# 	# text round3(states.SEditor.bonuses[0]),0.1*width,0.03*height
# 	# text round3(states.SEditor.clocks[0]),0.25*width,0.03*height
# 	# text round3(states.SEditor.clocks[1]),0.75*width,0.03*height
# 	# text round3(states.SEditor.bonuses[1]),0.9*width,0.03*height

# 	# text states.SClock.paused,0.3*width,0.025*height
# 	# text states.SClock.player,0.7*width,0.025*height

# 	currState.draw()

# mouseClicked = ->
# 	for key of currState.transitions
# 		if currState.transitions[key] == undefined then continue
# 		if buttons[key].visible and buttons[key].inside mouseX, mouseY 
# 			console.log key
# 			currState.message key
# 			break
