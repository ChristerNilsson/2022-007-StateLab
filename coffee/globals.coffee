export globals = {}

globals.HOUR   = 60*60*60 # tertier
globals.MINUTE = 60*60    # tertier
globals.SEC    = 60       # tertier

globals.TOGGLE = 1 # 0=porträtt (Android) 1=landskap (Mac)
globals.HEARTBEAT = 1000 # ms updates of localStorage

globals.FRAMERATE = 60 # 10
globals.states = {}
globals.settings  = {}
globals.bits = {}
globals.backup = null

globals.tw = 0
globals.qr = null
globals.sound = null
globals.currState = null
globals.diag = 0
globals.os = ''
globals.chess = null

export clone = (x) -> JSON.parse JSON.stringify x

export getLocalCoords = ->
	matrix = drawingContext.getTransform()
	pd = pixelDensity()
	matrix.inverse().transformPoint new DOMPoint mouseX * pd,mouseY * pd

export createState = (key,klass) -> globals.states[key] = new klass key

export pretty = (tot) ->
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

export d2 = (x) ->
	x = Math.trunc x
	if x < 10 then '0'+x else x
assert '03', d2 3

export mst = (x) -> # tertier
	t = x %% 60
	x //= 60
	s = x %% 60
	m = x // 60
	[m,s,t] 
assert [3,0,0], mst 3*60*60
assert [3,0,30], mst 180*60+30

export getOrange = ->
	g = globals
	gs = g.settings
	gs.makeHandicap()
	gsp = gs.players
	if g.bits.handicap.nr == 0 then '' else prettyPair gsp[0][0], gsp[0][1]

export getWhite = -> globals.settings.compact()

export getGreen = -> 
	g = globals
	gs = g.settings
	gs.makeHandicap()
	gsp = globals.settings.players
	if g.bits.handicap.nr == 0 then '' else prettyPair gsp[1][0], gsp[1][1]
