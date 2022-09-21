[Q,N,B,X] = 'QNB_'

N0 = [0,0,0,0,1,1,1,2,2,3]
N1 = [1,2,3,4,2,3,4,3,4,4]
B0 = [0,2,4,6]
B1 = [1,3,5,7]

getEmpty = (arr) ->
	arr = _.map arr, (value,index) -> if value==X then index else X
	_.filter arr, (value) -> value != X

fillIn = (piece,places,pieces) ->
	res = new Array places.length + pieces.length
	_.fill res,X
	for place in places
		res[place] = piece
	empty = getEmpty res
	for i in _.range pieces.length
		res[empty[i]] = pieces[i]
	res

chess960 = (i) -> # 16 microsecs

	q  = i // 16 % 6
	n0 = N0[i // 96 % 10]
	n1 = N1[i // 96 % 10]
	b0 = B0[i // 4 % 4]
	b1 = B1[i % 4]

	five  = fillIn N,[n0,n1],'RKR'
	six   = fillIn Q,[q],five
	eight = fillIn B,[b0,b1],six
	eight.join ''

console.assert "RNBQKBNR" == chess960 518