# TODO
# Försämring av frameRate inträffar om man går från fullscreen till normal på Android

# Istället för sekunder är nu normalformen tertier, 60-dels sekunder

import {globals,createState} from './globals.js'
import {CBits} from './cbits.js'
import {CSettings} from './settings.js'
import {SClock,SBasic,SAdv,S960} from './states.js'

globals.bits = {}
globals.bits.minutes   = new CBits [1,2,4,8,15,30,60]
globals.bits.seconds   = new CBits [1,2,4,8,15,30,60]
globals.bits.handicap  = new CBits [1,2,4,8,15,30]
globals.bits.number960 = new CBits [1,2,4,8,15,30,60,120,240,480]

globals.chess = {}

lastStorageSave = new Date()

rates = []
sumRate = 0

################ p5 ###################

window.preload = ->
	globals.qr = loadImage 'media\\qr.png'
	globals.sound = loadSound 'media\\key.mp3'
	for ltr in "KQRBN"
		globals.chess[ltr] = loadImage "media\\chess\\#{ltr}.png"

window.windowResized = -> resizeCanvas innerWidth, innerHeight

window.setup = ->
	globals.settings = new CSettings globals.bits

	frameRate globals.FRAMERATE
	globals.os = navigator.appVersion
	if globals.os.indexOf('Linux') >= 0 then globals.os = 'Android'
	if globals.os.indexOf('Windows') >= 0 then globals.os = 'Windows'
	if globals.os.indexOf('Mac') >= 0 then globals.os = 'Mac'

	canvas = createCanvas innerWidth,innerHeight
	bodyScrollLock.disableBodyScroll canvas # Förhindrar att man kan scrolla canvas på iOS

	if globals.os == 'Android' then textFont 'Droid Sans'
	if globals.os == 'Mac' then textFont 'Verdana'
	if globals.os == 'Windows' then textFont 'Lucida Sans Unicode'

	globals.TOGGLE = if globals.os == 'Mac' then 1 else 0

	background 'black'
	textAlign CENTER,CENTER
	rectMode CENTER
	angleMode DEGREES

	createState 'SClock', SClock 
	createState 'SAdv',   SAdv
	createState 'SBasic', SBasic
	createState 'S960',   S960
	
	globals.currState = globals.states.SClock

	push()
	textSize 18+9
	globals.tw = textWidth '0'
	pop()

window.mousePressed = -> if globals.os == 'Windows' then globals.currState.mouseClicked()
window.touchStarted = -> if globals.os != 'Windows' then globals.currState.mouseClicked()

window.draw = ->

	if globals.TOGGLE == 0
		scale width/100,height/100 # portrait
	else
		rotate 90
		translate 0,-width
		scale height/100,width/100 # Landscape

	strokeWeight 100/height
	push()
	background 'black'
	globals.settings.tick()
	globals.currState.draw()
	pop()

	globals.settings.save() # SKUM?

	aspect = (w,h,y) ->
		if w < h then [w,h] = [h,w]
		text "#{w} #{(w/h).toFixed(3)} #{h}", 50,y

	#textSize 3
	#fill 'yellow'
	# gb = globals.bits
	# gs = globals.settings
	# gsi = gs.info
	# text "mst #{gb.minutes.nr} #{gb.seconds.nr} #{gb.handicap.nr}",50,60
	# text gs.players,50,65
	# text Math.round(gs.clocks[0]) + ' ' + Math.round(gs.clocks[1]),50,70
	# text gs.bonuses,50,75
	# text gsi.orange,50,80
	# text gsi.white,50,85
	# text gsi.green,50,90

	#for i in range globals.logg.length
	#	text globals.logg[i],50,3*(i+1)

	#text 'J',5,95