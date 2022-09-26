# Givet ID räknar chess960 ut konfigurationen.
# <= 0 ID < 960
# 518 motsvarar normalt schack, dvs RNBQKBNR

# https://chess-tigers.de/download/chess960_regeln.pdf?PHPSESSID=d71dfe17e7e8aae16adce6f8fb284410

# assert = (a,b) ->
# 	a = JSON.stringify a 
# 	b = JSON.stringify b
# 	console.log if a==b then "ok" else "#{a} != #{b}"

export chess960 = (index) -> # 16 microsecs
	[Q,N,B,X] = 'QNB_'

	N0 = [0,0,0,0,1,1,1,2,2,3]
	N1 = [1,2,3,4,2,3,4,3,4,4]
	B0 = [0,2,4,6]
	B1 = [1,3,5,7]

	getEmpty = (arr) ->
		arr = _.map arr, (value,index) -> if value==X then index else X
		_.filter arr, (value) -> value != X
	assert [0,1,3], getEmpty [X,X,N,X,N]

	fillIn = (piece,places,pieces) ->
		res = new Array places.length + pieces.length
		_.fill res,X
		res[place] = piece for place in places
		empty = getEmpty res
		res[empty[i]] = pieces[i] for i in _.range pieces.length
		res.join ''
	assert    'RNKNR', fillIn N, [1,3], 'RKR'
	assert   'RNQKNR', fillIn Q, [2],   'RNKNR'
	assert 'RNBQKBNR', fillIn B, [2,5], 'RNQKNR'

	q  = index // 16 % 6
	n0 = N0[index // 96 % 10]
	n1 = N1[index // 96 % 10]
	b0 = B0[index // 4 % 4]
	b1 = B1[index % 4]

	five = fillIn N,[n0,n1],'RKR'
	six  = fillIn Q,[q],five
	fillIn B,[b0,b1],six
assert "RNBQKBNR", chess960 518
