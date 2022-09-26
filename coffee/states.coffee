class State
	constructor : (@name) -> @controls = {}
	draw : -> @controls[key].draw() for key of @controls

	mouseClicked : ->
		console.log 'State.mouseClicked'
		{x,y} = getLocalCoords()
		for key of @controls
			control = @controls[key]
			if control.visible and not control.disabled and control.inside x, y
				if control.click then control.click()
				break

class S960 extends State
	constructor : (name) ->
		super name
		reader960 = (bits,index) => bits.pattern[index]
		click960 = (bitar,index) =>
			bitar.flipBit index
			settings.chess960 = chess960 bits.number960.nr
			@controls.ok.visible = bits.number960.nr < 960

		random960 = ->
			nr = _.random 0,959
			bits.number960.setNr nr
			settings.chess960 = chess960 nr

		x = [100/4,200/4,300/4]
		y = [-5,40,52,64,76,78,90,95]
		diam = 10

		@controls.C960    = new C960    50,y[0], 100, 10
		@controls.CNumber = new CNumber 50,25, => bits.number960.nr

		for i in range bits.number960.lst.length
			number = bits.number960.lst[i]
			key    = 'R'+number
			xi     = [0,0,0,0,1,1,1,2,2,2][i]
			yi     = [1,2,3,4,1,2,3,1,2,3][i]
			@controls[key] = new CAdv bits.number960, i, x[xi],y[yi], diam, number, true, reader960, click960

		@controls.random = new CRounded (x[1]+x[2])/2,y[4], 18,6, 'random', false, 'white','black',random960
		@controls.basic  = new CRounded 10,y[7], 18,6, 'basic', false,'white','black',=> currState = states.SBasic
		@controls.adv    = new CRounded 30,y[7], 18,6, 'adv',   false,'white','black',=> currState = states.SAdv
		@controls.b960   = new CRounded 50,y[7], 18,6, '960',    true,'white','black'
		@controls.cancel = new CRounded 70,y[7], 18,6, 'cancel',false,'white','black',cancel
		@controls.ok     = new CRounded 90,y[7], 18,6, 'ok',    false,'white','black',ok

class SAdv extends State
	constructor : (name) ->
		super name

		@controls.orange     = new CColor 50, 2.5,'orange'
		@controls.white      = new CColor 50, 9.5,'white'
		@controls.green      = new CColor 50,16.5,'green'

		@controls.reflection = new CDead  25,25,"reflection\nminutes"
		@controls.bonus      = new CDead  50,25,"bonus\nseconds"
		@controls.hcp        = new CDead  75,25,"handicap\ntertier"

		y = 95

		@controls.basic  = new CRounded 1*100/10,y, 18,6, 'basic', false,'white','black',=> currState = states.SBasic
		@controls.adv    = new CRounded 3*100/10,y, 18,6, 'adv',    true,'white','black'
		@controls.b960   = new CRounded 5*100/10,y, 18,6, '960',   false,'white','black',=> currState = states.S960
		@controls.cancel = new CRounded 7*100/10,y, 18,6, 'cancel',false,'white','black',cancel
		@controls.ok     = new CRounded 9*100/10,y, 18,6, 'ok',    false,'white','black',ok

		@makeEditButtons()

	makeEditButtons : ->

		reader = (bitar,index) => bitar.pattern[index]
		clicker = (bitar,index) =>
			bitar.flipBit index
			settings.info.orange = getOrange()
			settings.info.white  = getWhite()
			settings.info.green  = getGreen()
			@controls.ok.visible = bits.minutes.nr > 0 and bits.handicap.nr < 60

		for i in range 3
			letter = 'Mst'[i]
			xsize = 100/4
			ysize = 100/12
			xoff = xsize
			yoff = 33+2
			diam = 7
			for j in range 7
				number = bits.minutes.lst[j]
				name = letter + number
				if i!=2 or j!=6
					@controls[name] = new CAdv [bits.minutes,bits.seconds,bits.handicap][i], j, xoff+xsize*i, yoff+ysize*j, diam, number, true, reader, clicker

class SBasic extends State
	constructor : (name) ->
		super name

		reader  = (bitar,text) => bitar.nr
		clicker = (bitar,text) => 
			bitar.nr = text
			settings.info.orange = getOrange()
			settings.info.white  = getWhite()
			settings.info.green  = getGreen()
			@controls.ok.visible = bits.minutes.nr > 0 and bits.handicap.nr < 60

		x = [20,45,80]
		y = [32,41,50,59,68,77,86,95]
		xm = (x[0]+x[1])/2
		diam = 8

		@controls.orange = new CColor 50, 2.5,'orange'# ,getOrange
		@controls.white  = new CColor 50, 9.5,'white'# , getWhite
		@controls.green  = new CColor 50,16.5,'green'# , getGreen

		@controls.reflection = new CDead xm,  23, "reflection\nminutes"
		@controls.bonus      = new CDead x[2],23, "bonus\nseconds"

		for i in range 11
			xi = [0,0,0,0,0,1,1,1,1,1,1][i]
			yi = [0,1,2,3,4,0,1,2,3,4,5][i]
			M = [1,2,3,5,10,15,20,30,45,60,90][i]
			@controls['M'+M] = new CAdv bits.minutes,i,x[xi],y[yi], diam, M, false, reader,clicker

		for i in range 7
			s = [0,1,2,3,5,10,30][i]
			@controls['s'+s] = new CAdv bits.seconds,i,x[2],y[i], diam, s, false, reader,clicker

		@controls.basic  = new CRounded 1*100/10,y[7], 18,6, 'basic',  true,'white','black'
		@controls.adv    = new CRounded 3*100/10,y[7], 18,6, 'adv',   false,'white','black',=> currState = states.SAdv
		@controls.b960   = new CRounded 5*100/10,y[7], 18,6, '960',   false,'white','black',=> currState = states.S960
		@controls.cancel = new CRounded 7*100/10,y[7], 18,6, 'cancel',false,'white','black',cancel
		@controls.ok     = new CRounded 9*100/10,y[7], 18,6, 'ok',    false,'white','black',ok

class SClock extends State

	constructor : (name) ->
		super name

		player0 = => if settings.timeout then return else @handlePlayer 0
		player1 = => if settings.timeout then return else @handlePlayer 1
		pause   = => settings.paused = true
		handleQR = =>
			fullscreen true
			resizeCanvas innerWidth, innerHeight

		@controls.left  = new CRotate 50, 22, 100, 44, 180, 'black', 'white', 0, player0 # eg up
		@controls.right = new CRotate 50, 78, 100, 44,   0, 'black', 'white', 1, player1 # eg down
		@controls.pause = new CPause  67, 50,  17, 12, 'black', 'white', pause
		@controls.qr    = new CImage  50, 50,  33, 12, qr, handleQR

		@controls.basic = new CCogwheel 83, 50, 17, 12, 'black', 'white', =>
			console.log 'SClock clicker'
			settings.backup()
			currState = states.SBasic
			console.log currState
		@controls.show  = new CShow     22, 50, 'white'

	handlePlayer : (player) ->
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
		super()
		@indicator()
