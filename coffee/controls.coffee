import {globals,mst,d2} from './globals.js'

export class Control
	constructor : (@x,@y,@w,@h,@text='',@bg='black',@fg='white') ->
		@visible = true
		# @x = Math.round @x
		# @y = Math.round @y
		# @w = Math.round @w
		# @h = Math.round @h
	draw : -> console.log 'Control.draw must be overriden!'
	inside : (x,y) ->
		w = @w * [height/width,width/height][1-globals.TOGGLE]
		-w/2 <= x-@x <= w/2 and -@h/2 <= y-@y <= @h/2

export class CNumber extends Control
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

export class C960 extends Control
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
			w = @h * [height/width,width/height][globals.TOGGLE]
			xoff = @x + (dx-w)/2
			for i in range 8
				image globals.chess[globals.settings.chess960[i]], xoff+(i-4)*dx, @y+8, w,@h

export class CRounded extends Control
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

export class CPause extends Control
	constructor : (x,y,w=0,h=0,@bg='black',@fg='white', @clicker) ->
		super x,y,w,h
	click : => @clicker()
	draw : ->
		if not globals.settings.paused
			fill @fg
			rect @x-1.75,@y,3,6
			rect @x+1.75,@y,3,6

export class CCogwheel extends Control # Kugghjul
	constructor : (x,y,w=0,h=0,@bg='black',@fg='white',@clicker) -> super x,y,w,h
	click : => @clicker()
	draw : ->
		if globals.settings.paused
			push()
			translate @x,@y
			scale [height/width,width/height][globals.TOGGLE],1
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

export class CImage extends Control
	constructor : (x,y,w,h,@image,@clicker) ->
		super x,y,w,h
	click : => @clicker()
	draw :  ->
		if @image
			w = @h * [height/width,width/height][globals.TOGGLE]
			image @image,@x-w/2, 0.075+@y-@h/2, w, @h

export class CRotate extends Control
	constructor : (x,y,w,h,@degrees,bg,fg,@player,@clicker) ->
		super x,y,w,h,'',bg,fg

	click : => @clicker()

	draw : ->
		tertier = globals.settings.clocks[@player]
		[m,s,t] = mst tertier
		t = Math.round t
		ss = m + ':' + d2 s

		noStroke()
		push()
		translate @x,@y
		rotate @degrees

		if globals.settings.player == @player
			minCol = 'red'
			secCol = if globals.settings.timeout then 'red' else 'white'
		else
			minCol = 'lightgrey'
			secCol = 'grey'

		textSize 18+9
		mw = globals.tw * m.toString().length
		sw = globals.tw * 2
		
		fill minCol
		text m, -sw/2, -2

		fill secCol
		text d2(s), mw/2, -2

		textSize 10
		if tertier < 10*60 then text t,36,-4

		if globals.bits.handicap.nr > 0 and globals.settings.bonuses[@player] > 0
			textSize 8
			fill 'grey'
			text globals.settings.bonus[@player],0,17

		pop()

export class CAdv extends Control
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
		s = [height/width,width/height][globals.TOGGLE]
		ellipse 0,0,@w*s,@h
		fill 'black'
		textSize 5
		text @text,0,0.2
		pop()

	reader : -> if @flipper then @read @bits,@index else @read @bits,@text
	click : -> if @flipper then @clk @bits,@index else @clk @bits,@text

export class CDead extends Control
	constructor : (x,y,text,fg='white') ->
		super x,y,0,0,text,'black',fg
	draw : ->
		push()
		textSize 4
		fill @fg
		text @text,@x,@y
		pop()

export class CShow extends CDead
	constructor : (x,y,fg='white') -> super x,y,'',fg
	draw : ->
		push()
		translate @x,@y
		rotate -90
		fill 'white'
		textSize 5
		text globals.settings.info.white, 0,0
		pop()

export class CColor extends Control
	constructor : (x,y,@fg) -> super x,y,0,0
	draw : ->
		push()
		textSize 4
		fill @fg
		text globals.settings.info[@fg],@x,@y
		pop()
