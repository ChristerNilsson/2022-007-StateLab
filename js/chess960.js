// Generated by CoffeeScript 2.5.1
// Givet ID räknar chess960 ut konfigurationen.
// <= 0 ID < 960
// 518 motsvarar normalt schack, dvs RNBQKBNR

// https://chess-tigers.de/download/chess960_regeln.pdf?PHPSESSID=d71dfe17e7e8aae16adce6f8fb284410

// assert = (a,b) ->
// 	a = JSON.stringify a 
// 	b = JSON.stringify b
// 	console.log if a==b then "ok" else "#{a} != #{b}"
export var chess960 = function(index) { // 16 microsecs
  var B, B0, B1, N, N0, N1, Q, X, b0, b1, fillIn, five, getEmpty, n0, n1, q, six;
  [Q, N, B, X] = 'QNB_';
  N0 = [0, 0, 0, 0, 1, 1, 1, 2, 2, 3];
  N1 = [1, 2, 3, 4, 2, 3, 4, 3, 4, 4];
  B0 = [0, 2, 4, 6];
  B1 = [1, 3, 5, 7];
  getEmpty = function(arr) {
    arr = _.map(arr, function(value, index) {
      if (value === X) {
        return index;
      } else {
        return X;
      }
    });
    return _.filter(arr, function(value) {
      return value !== X;
    });
  };
  assert([0, 1, 3], getEmpty([X, X, N, X, N]));
  fillIn = function(piece, places, pieces) {
    var empty, i, j, k, len, len1, place, ref, res;
    res = new Array(places.length + pieces.length);
    _.fill(res, X);
    for (j = 0, len = places.length; j < len; j++) {
      place = places[j];
      res[place] = piece;
    }
    empty = getEmpty(res);
    ref = _.range(pieces.length);
    for (k = 0, len1 = ref.length; k < len1; k++) {
      i = ref[k];
      res[empty[i]] = pieces[i];
    }
    return res.join('');
  };
  assert('RNKNR', fillIn(N, [1, 3], 'RKR'));
  assert('RNQKNR', fillIn(Q, [2], 'RNKNR'));
  assert('RNBQKBNR', fillIn(B, [2, 5], 'RNQKNR'));
  q = Math.floor(index / 16) % 6;
  n0 = N0[Math.floor(index / 96) % 10];
  n1 = N1[Math.floor(index / 96) % 10];
  b0 = B0[Math.floor(index / 4) % 4];
  b1 = B1[index % 4];
  five = fillIn(N, [n0, n1], 'RKR');
  six = fillIn(Q, [q], five);
  return fillIn(B, [b0, b1], six);
};

assert("RNBQKBNR", chess960(518));

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiY2hlc3M5NjAuanMiLCJzb3VyY2VSb290IjoiLi4iLCJzb3VyY2VzIjpbImNvZmZlZVxcY2hlc3M5NjAuY29mZmVlIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7QUFTb0Q7Ozs7Ozs7Ozs7QUFFcEQsT0FBQSxJQUFPLFFBQUEsR0FBVyxRQUFBLENBQUMsS0FBRCxDQUFBLEVBQUE7QUFDbEIsTUFBQSxDQUFBLEVBQUEsRUFBQSxFQUFBLEVBQUEsRUFBQSxDQUFBLEVBQUEsRUFBQSxFQUFBLEVBQUEsRUFBQSxDQUFBLEVBQUEsQ0FBQSxFQUFBLEVBQUEsRUFBQSxFQUFBLEVBQUEsTUFBQSxFQUFBLElBQUEsRUFBQSxRQUFBLEVBQUEsRUFBQSxFQUFBLEVBQUEsRUFBQSxDQUFBLEVBQUE7RUFBQyxDQUFDLENBQUQsRUFBRyxDQUFILEVBQUssQ0FBTCxFQUFPLENBQVAsQ0FBQSxHQUFZO0VBRVosRUFBQSxHQUFLLENBQUMsQ0FBRCxFQUFHLENBQUgsRUFBSyxDQUFMLEVBQU8sQ0FBUCxFQUFTLENBQVQsRUFBVyxDQUFYLEVBQWEsQ0FBYixFQUFlLENBQWYsRUFBaUIsQ0FBakIsRUFBbUIsQ0FBbkI7RUFDTCxFQUFBLEdBQUssQ0FBQyxDQUFELEVBQUcsQ0FBSCxFQUFLLENBQUwsRUFBTyxDQUFQLEVBQVMsQ0FBVCxFQUFXLENBQVgsRUFBYSxDQUFiLEVBQWUsQ0FBZixFQUFpQixDQUFqQixFQUFtQixDQUFuQjtFQUNMLEVBQUEsR0FBSyxDQUFDLENBQUQsRUFBRyxDQUFILEVBQUssQ0FBTCxFQUFPLENBQVA7RUFDTCxFQUFBLEdBQUssQ0FBQyxDQUFELEVBQUcsQ0FBSCxFQUFLLENBQUwsRUFBTyxDQUFQO0VBRUwsUUFBQSxHQUFXLFFBQUEsQ0FBQyxHQUFELENBQUE7SUFDVixHQUFBLEdBQU0sQ0FBQyxDQUFDLEdBQUYsQ0FBTSxHQUFOLEVBQVcsUUFBQSxDQUFDLEtBQUQsRUFBTyxLQUFQLENBQUE7TUFBaUIsSUFBRyxLQUFBLEtBQU8sQ0FBVjtlQUFpQixNQUFqQjtPQUFBLE1BQUE7ZUFBNEIsRUFBNUI7O0lBQWpCLENBQVg7V0FDTixDQUFDLENBQUMsTUFBRixDQUFTLEdBQVQsRUFBYyxRQUFBLENBQUMsS0FBRCxDQUFBO2FBQVcsS0FBQSxLQUFTO0lBQXBCLENBQWQ7RUFGVTtFQUdYLE1BQUEsQ0FBTyxDQUFDLENBQUQsRUFBRyxDQUFILEVBQUssQ0FBTCxDQUFQLEVBQWdCLFFBQUEsQ0FBUyxDQUFDLENBQUQsRUFBRyxDQUFILEVBQUssQ0FBTCxFQUFPLENBQVAsRUFBUyxDQUFULENBQVQsQ0FBaEI7RUFFQSxNQUFBLEdBQVMsUUFBQSxDQUFDLEtBQUQsRUFBTyxNQUFQLEVBQWMsTUFBZCxDQUFBO0FBQ1YsUUFBQSxLQUFBLEVBQUEsQ0FBQSxFQUFBLENBQUEsRUFBQSxDQUFBLEVBQUEsR0FBQSxFQUFBLElBQUEsRUFBQSxLQUFBLEVBQUEsR0FBQSxFQUFBO0lBQUUsR0FBQSxHQUFNLElBQUksS0FBSixDQUFVLE1BQU0sQ0FBQyxNQUFQLEdBQWdCLE1BQU0sQ0FBQyxNQUFqQztJQUNOLENBQUMsQ0FBQyxJQUFGLENBQU8sR0FBUCxFQUFXLENBQVg7SUFDQSxLQUFBLHdDQUFBOztNQUFBLEdBQUcsQ0FBQyxLQUFELENBQUgsR0FBYTtJQUFiO0lBQ0EsS0FBQSxHQUFRLFFBQUEsQ0FBUyxHQUFUO0FBQ1I7SUFBQSxLQUFBLHVDQUFBOztNQUFBLEdBQUcsQ0FBQyxLQUFLLENBQUMsQ0FBRCxDQUFOLENBQUgsR0FBZ0IsTUFBTSxDQUFDLENBQUQ7SUFBdEI7V0FDQSxHQUFHLENBQUMsSUFBSixDQUFTLEVBQVQ7RUFOUTtFQU9ULE1BQUEsQ0FBVSxPQUFWLEVBQW1CLE1BQUEsQ0FBTyxDQUFQLEVBQVUsQ0FBQyxDQUFELEVBQUcsQ0FBSCxDQUFWLEVBQWlCLEtBQWpCLENBQW5CO0VBQ0EsTUFBQSxDQUFTLFFBQVQsRUFBbUIsTUFBQSxDQUFPLENBQVAsRUFBVSxDQUFDLENBQUQsQ0FBVixFQUFpQixPQUFqQixDQUFuQjtFQUNBLE1BQUEsQ0FBTyxVQUFQLEVBQW1CLE1BQUEsQ0FBTyxDQUFQLEVBQVUsQ0FBQyxDQUFELEVBQUcsQ0FBSCxDQUFWLEVBQWlCLFFBQWpCLENBQW5CO0VBRUEsQ0FBQSxjQUFLLFFBQVMsR0FBVCxHQUFjO0VBQ25CLEVBQUEsR0FBSyxFQUFFLFlBQUMsUUFBUyxHQUFULEdBQWMsRUFBZjtFQUNQLEVBQUEsR0FBSyxFQUFFLFlBQUMsUUFBUyxHQUFULEdBQWMsRUFBZjtFQUNQLEVBQUEsR0FBSyxFQUFFLFlBQUMsUUFBUyxFQUFULEdBQWEsQ0FBZDtFQUNQLEVBQUEsR0FBSyxFQUFFLENBQUMsS0FBQSxHQUFRLENBQVQ7RUFFUCxJQUFBLEdBQU8sTUFBQSxDQUFPLENBQVAsRUFBUyxDQUFDLEVBQUQsRUFBSSxFQUFKLENBQVQsRUFBaUIsS0FBakI7RUFDUCxHQUFBLEdBQU8sTUFBQSxDQUFPLENBQVAsRUFBUyxDQUFDLENBQUQsQ0FBVCxFQUFhLElBQWI7U0FDUCxNQUFBLENBQU8sQ0FBUCxFQUFTLENBQUMsRUFBRCxFQUFJLEVBQUosQ0FBVCxFQUFpQixHQUFqQjtBQWhDaUI7O0FBaUNsQixNQUFBLENBQU8sVUFBUCxFQUFtQixRQUFBLENBQVMsR0FBVCxDQUFuQiIsInNvdXJjZXNDb250ZW50IjpbIiMgR2l2ZXQgSUQgcsOka25hciBjaGVzczk2MCB1dCBrb25maWd1cmF0aW9uZW4uXHJcbiMgPD0gMCBJRCA8IDk2MFxyXG4jIDUxOCBtb3RzdmFyYXIgbm9ybWFsdCBzY2hhY2ssIGR2cyBSTkJRS0JOUlxyXG5cclxuIyBodHRwczovL2NoZXNzLXRpZ2Vycy5kZS9kb3dubG9hZC9jaGVzczk2MF9yZWdlbG4ucGRmP1BIUFNFU1NJRD1kNzFkZmUxN2U3ZThhYWUxNmFkY2U2ZjhmYjI4NDQxMFxyXG5cclxuIyBhc3NlcnQgPSAoYSxiKSAtPlxyXG4jIFx0YSA9IEpTT04uc3RyaW5naWZ5IGEgXHJcbiMgXHRiID0gSlNPTi5zdHJpbmdpZnkgYlxyXG4jIFx0Y29uc29sZS5sb2cgaWYgYT09YiB0aGVuIFwib2tcIiBlbHNlIFwiI3thfSAhPSAje2J9XCJcclxuXHJcbmV4cG9ydCBjaGVzczk2MCA9IChpbmRleCkgLT4gIyAxNiBtaWNyb3NlY3NcclxuXHRbUSxOLEIsWF0gPSAnUU5CXydcclxuXHJcblx0TjAgPSBbMCwwLDAsMCwxLDEsMSwyLDIsM11cclxuXHROMSA9IFsxLDIsMyw0LDIsMyw0LDMsNCw0XVxyXG5cdEIwID0gWzAsMiw0LDZdXHJcblx0QjEgPSBbMSwzLDUsN11cclxuXHJcblx0Z2V0RW1wdHkgPSAoYXJyKSAtPlxyXG5cdFx0YXJyID0gXy5tYXAgYXJyLCAodmFsdWUsaW5kZXgpIC0+IGlmIHZhbHVlPT1YIHRoZW4gaW5kZXggZWxzZSBYXHJcblx0XHRfLmZpbHRlciBhcnIsICh2YWx1ZSkgLT4gdmFsdWUgIT0gWFxyXG5cdGFzc2VydCBbMCwxLDNdLCBnZXRFbXB0eSBbWCxYLE4sWCxOXVxyXG5cclxuXHRmaWxsSW4gPSAocGllY2UscGxhY2VzLHBpZWNlcykgLT5cclxuXHRcdHJlcyA9IG5ldyBBcnJheSBwbGFjZXMubGVuZ3RoICsgcGllY2VzLmxlbmd0aFxyXG5cdFx0Xy5maWxsIHJlcyxYXHJcblx0XHRyZXNbcGxhY2VdID0gcGllY2UgZm9yIHBsYWNlIGluIHBsYWNlc1xyXG5cdFx0ZW1wdHkgPSBnZXRFbXB0eSByZXNcclxuXHRcdHJlc1tlbXB0eVtpXV0gPSBwaWVjZXNbaV0gZm9yIGkgaW4gXy5yYW5nZSBwaWVjZXMubGVuZ3RoXHJcblx0XHRyZXMuam9pbiAnJ1xyXG5cdGFzc2VydCAgICAnUk5LTlInLCBmaWxsSW4gTiwgWzEsM10sICdSS1InXHJcblx0YXNzZXJ0ICAgJ1JOUUtOUicsIGZpbGxJbiBRLCBbMl0sICAgJ1JOS05SJ1xyXG5cdGFzc2VydCAnUk5CUUtCTlInLCBmaWxsSW4gQiwgWzIsNV0sICdSTlFLTlInXHJcblxyXG5cdHEgID0gaW5kZXggLy8gMTYgJSA2XHJcblx0bjAgPSBOMFtpbmRleCAvLyA5NiAlIDEwXVxyXG5cdG4xID0gTjFbaW5kZXggLy8gOTYgJSAxMF1cclxuXHRiMCA9IEIwW2luZGV4IC8vIDQgJSA0XVxyXG5cdGIxID0gQjFbaW5kZXggJSA0XVxyXG5cclxuXHRmaXZlID0gZmlsbEluIE4sW24wLG4xXSwnUktSJ1xyXG5cdHNpeCAgPSBmaWxsSW4gUSxbcV0sZml2ZVxyXG5cdGZpbGxJbiBCLFtiMCxiMV0sc2l4XHJcbmFzc2VydCBcIlJOQlFLQk5SXCIsIGNoZXNzOTYwIDUxOFxyXG4iXX0=
//# sourceURL=c:\github\2022-007-StateLab\coffee\chess960.coffee