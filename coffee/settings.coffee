import {globals,clone,pretty} from './globals.js'
import {getOrange,getWhite,getGreen} from './globals.js'

export class CSettings 
	constructor : -> 
		console.log if localStorage.settings then "load" else "default"
		if localStorage.settings then Object.assign @, JSON.parse localStorage.settings
		@bits ||= {minutes:3, seconds:2, handicap:0, number960:518}
		@bonus ||= ['',''] # redundant, sparar tid
		@bonuses ||= [2*60,2*60] # tertier, redundant, sparar tid
		@chess960 ||= 'RNBQKBNR' # redundant, sparar tid
		@clocks ||= [180*60,180*60] # tertier
		@info ||= {orange:'', white:'3+2', green:''} # redundant, sparar tid
		@paused = true
		@player ||= -1
		@timeout ||= false

		# Dessa fyra objekt vill man inte spara i localStorage
		@settings2bits()
		@makeHandicap()
		@save(0)

	bits2settings : ->
		gb = globals.bits
		@bits.minutes   = gb.minutes.nr
		@bits.seconds   = gb.seconds.nr
		@bits.handicap  = gb.handicap.nr
		@bits.number960 = gb.number960.nr
	
	settings2bits : ->
		gb = globals.bits
		gb.minutes.setNr   @bits.minutes
		gb.seconds.setNr   @bits.seconds
		gb.handicap.setNr  @bits.handicap
		gb.number960.setNr @bits.number960

	backup : ->
		@bits2settings()
		globals.backup = clone @ # kopierar TILL backup

	restore : ->
		Object.assign @,globals.backup # kopierar FRÅN backup
		@settings2bits()

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
		if d - lastStorageSave < globals.HEARTBEAT then return # ms
		lastStorageSave = d
		@bits2settings()
		localStorage.settings = JSON.stringify @

	compact : ->
		header0 = ''
		header1 = ''
		g = globals
		gb = g.bits
		if gb.minutes.nr > 0 then header0 += gb.minutes.nr
		if gb.seconds.nr > 0 then header1 += gb.seconds.nr
		header = header0
		if header1.length > 0 then header += '+' + header1
		if gb.handicap.nr > 0 then header += "\n(#{gb.handicap.nr})"
		header

	makeHandicap : ->
		g = globals
		gb = g.bits
		hcp = gb.handicap.nr / 60 # 0/60 to 59/60
		refl  = g.MINUTE * gb.minutes.nr # tertier
		bonus =    g.SEC * gb.seconds.nr # tertier
		@players = []
		@players[0] = [refl + refl*hcp, bonus + bonus*hcp]
		@players[1] = [refl - refl*hcp, bonus - bonus*hcp]

	ok : ->
		g = globals
		gs = g.settings
		@makeHandicap()
		@clocks  = [@players[0][0], @players[1][0]]
		@bonuses = [@players[0][1], @players[1][1]]
		@bonus = ['+' + pretty(gs.bonuses[0]), '+' + pretty(gs.bonuses[1])]
		@info.orange = getOrange()
		@info.white = getWhite()
		@info.green = getGreen()
		@timeout = false
		@paused = true
		@player = -1

	cancel : -> 
		@restore()
		@paused = true
