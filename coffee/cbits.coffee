export class CBits
	constructor : (@lst,@nr=0) -> 
		@pattern = _.map @lst, -> 0
		@setNr @nr
	
	setBit : (index) ->
		if @pattern[index] == 0 then @nr += @lst[index]
		@pattern[index] = 1
	
	clrBit : (index) ->
		if @pattern[index] == 1 then @nr -= @lst[index]
		@pattern[index] = 0

	flipBit : (index) ->
		if @pattern[index] == 1 then @clrBit index else @setBit index
	
	setNr : (nr) ->
		@nr = nr
		i = @lst.length
		while i > 0
			i--
			if nr >= @lst[i]
				nr -= @lst[i]
				@pattern[i] = 1 
			else @pattern[i] = 0


M = new CBits [1,2,4,8,15,30],20
assert [1,0,1,0,1,0], M.pattern

M.clrBit 2
assert [1,0,0,0,1,0], M.pattern
assert 16, M.nr

M.setBit 3
assert [1,0,0,1,1,0], M.pattern
assert 24, M.nr

M.setBit 5
assert [1,0,0,1,1,1], M.pattern
assert 54, M.nr

M.flipBit 5
assert [1,0,0,1,1,0], M.pattern
assert 24, M.nr

M.flipBit 5
assert [1,0,0,1,1,1], M.pattern
assert 54, M.nr
