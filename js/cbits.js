// Generated by CoffeeScript 2.5.1
var M;

export var CBits = class CBits {
  constructor(lst, nr1 = 0) {
    this.lst = lst;
    this.nr = nr1;
    this.pattern = _.map(this.lst, function() {
      return 0;
    });
    this.setNr(this.nr);
  }

  setBit(index) {
    if (this.pattern[index] === 0) {
      this.nr += this.lst[index];
    }
    return this.pattern[index] = 1;
  }

  clrBit(index) {
    if (this.pattern[index] === 1) {
      this.nr -= this.lst[index];
    }
    return this.pattern[index] = 0;
  }

  flipBit(index) {
    if (this.pattern[index] === 1) {
      return this.clrBit(index);
    } else {
      return this.setBit(index);
    }
  }

  setNr(nr) {
    var i, results;
    this.nr = nr;
    i = this.lst.length;
    results = [];
    while (i > 0) {
      i--;
      if (nr >= this.lst[i]) {
        nr -= this.lst[i];
        results.push(this.pattern[i] = 1);
      } else {
        results.push(this.pattern[i] = 0);
      }
    }
    return results;
  }

};

M = new CBits([1, 2, 4, 8, 15, 30], 20);

assert([1, 0, 1, 0, 1, 0], M.pattern);

M.clrBit(2);

assert([1, 0, 0, 0, 1, 0], M.pattern);

assert(16, M.nr);

M.setBit(3);

assert([1, 0, 0, 1, 1, 0], M.pattern);

assert(24, M.nr);

M.setBit(5);

assert([1, 0, 0, 1, 1, 1], M.pattern);

assert(54, M.nr);

M.flipBit(5);

assert([1, 0, 0, 1, 1, 0], M.pattern);

assert(24, M.nr);

M.flipBit(5);

assert([1, 0, 0, 1, 1, 1], M.pattern);

assert(54, M.nr);

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiY2JpdHMuanMiLCJzb3VyY2VSb290IjoiLi4iLCJzb3VyY2VzIjpbImNvZmZlZVxcY2JpdHMuY29mZmVlIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7QUFBQSxJQUFBOztBQUFBLE9BQUEsSUFBYSxRQUFOLE1BQUEsTUFBQTtFQUNOLFdBQWMsSUFBQSxRQUFVLENBQVYsQ0FBQTtJQUFDLElBQUMsQ0FBQTtJQUFJLElBQUMsQ0FBQTtJQUNwQixJQUFDLENBQUEsT0FBRCxHQUFXLENBQUMsQ0FBQyxHQUFGLENBQU0sSUFBQyxDQUFBLEdBQVAsRUFBWSxRQUFBLENBQUEsQ0FBQTthQUFHO0lBQUgsQ0FBWjtJQUNYLElBQUMsQ0FBQSxLQUFELENBQU8sSUFBQyxDQUFBLEVBQVI7RUFGYTs7RUFJZCxNQUFTLENBQUMsS0FBRCxDQUFBO0lBQ1IsSUFBRyxJQUFDLENBQUEsT0FBTyxDQUFDLEtBQUQsQ0FBUixLQUFtQixDQUF0QjtNQUE2QixJQUFDLENBQUEsRUFBRCxJQUFPLElBQUMsQ0FBQSxHQUFHLENBQUMsS0FBRCxFQUF4Qzs7V0FDQSxJQUFDLENBQUEsT0FBTyxDQUFDLEtBQUQsQ0FBUixHQUFrQjtFQUZWOztFQUlULE1BQVMsQ0FBQyxLQUFELENBQUE7SUFDUixJQUFHLElBQUMsQ0FBQSxPQUFPLENBQUMsS0FBRCxDQUFSLEtBQW1CLENBQXRCO01BQTZCLElBQUMsQ0FBQSxFQUFELElBQU8sSUFBQyxDQUFBLEdBQUcsQ0FBQyxLQUFELEVBQXhDOztXQUNBLElBQUMsQ0FBQSxPQUFPLENBQUMsS0FBRCxDQUFSLEdBQWtCO0VBRlY7O0VBSVQsT0FBVSxDQUFDLEtBQUQsQ0FBQTtJQUNULElBQUcsSUFBQyxDQUFBLE9BQU8sQ0FBQyxLQUFELENBQVIsS0FBbUIsQ0FBdEI7YUFBNkIsSUFBQyxDQUFBLE1BQUQsQ0FBUSxLQUFSLEVBQTdCO0tBQUEsTUFBQTthQUFnRCxJQUFDLENBQUEsTUFBRCxDQUFRLEtBQVIsRUFBaEQ7O0VBRFM7O0VBR1YsS0FBUSxDQUFDLEVBQUQsQ0FBQTtBQUNULFFBQUEsQ0FBQSxFQUFBO0lBQUUsSUFBQyxDQUFBLEVBQUQsR0FBTTtJQUNOLENBQUEsR0FBSSxJQUFDLENBQUEsR0FBRyxDQUFDO0FBQ1Q7V0FBTSxDQUFBLEdBQUksQ0FBVjtNQUNDLENBQUE7TUFDQSxJQUFHLEVBQUEsSUFBTSxJQUFDLENBQUEsR0FBRyxDQUFDLENBQUQsQ0FBYjtRQUNDLEVBQUEsSUFBTSxJQUFDLENBQUEsR0FBRyxDQUFDLENBQUQ7cUJBQ1YsSUFBQyxDQUFBLE9BQU8sQ0FBQyxDQUFELENBQVIsR0FBYyxHQUZmO09BQUEsTUFBQTtxQkFHSyxJQUFDLENBQUEsT0FBTyxDQUFDLENBQUQsQ0FBUixHQUFjLEdBSG5COztJQUZELENBQUE7O0VBSE87O0FBaEJGOztBQTJCUCxDQUFBLEdBQUksSUFBSSxLQUFKLENBQVUsQ0FBQyxDQUFELEVBQUcsQ0FBSCxFQUFLLENBQUwsRUFBTyxDQUFQLEVBQVMsRUFBVCxFQUFZLEVBQVosQ0FBVixFQUEwQixFQUExQjs7QUFDSixNQUFBLENBQU8sQ0FBQyxDQUFELEVBQUcsQ0FBSCxFQUFLLENBQUwsRUFBTyxDQUFQLEVBQVMsQ0FBVCxFQUFXLENBQVgsQ0FBUCxFQUFzQixDQUFDLENBQUMsT0FBeEI7O0FBRUEsQ0FBQyxDQUFDLE1BQUYsQ0FBUyxDQUFUOztBQUNBLE1BQUEsQ0FBTyxDQUFDLENBQUQsRUFBRyxDQUFILEVBQUssQ0FBTCxFQUFPLENBQVAsRUFBUyxDQUFULEVBQVcsQ0FBWCxDQUFQLEVBQXNCLENBQUMsQ0FBQyxPQUF4Qjs7QUFDQSxNQUFBLENBQU8sRUFBUCxFQUFXLENBQUMsQ0FBQyxFQUFiOztBQUVBLENBQUMsQ0FBQyxNQUFGLENBQVMsQ0FBVDs7QUFDQSxNQUFBLENBQU8sQ0FBQyxDQUFELEVBQUcsQ0FBSCxFQUFLLENBQUwsRUFBTyxDQUFQLEVBQVMsQ0FBVCxFQUFXLENBQVgsQ0FBUCxFQUFzQixDQUFDLENBQUMsT0FBeEI7O0FBQ0EsTUFBQSxDQUFPLEVBQVAsRUFBVyxDQUFDLENBQUMsRUFBYjs7QUFFQSxDQUFDLENBQUMsTUFBRixDQUFTLENBQVQ7O0FBQ0EsTUFBQSxDQUFPLENBQUMsQ0FBRCxFQUFHLENBQUgsRUFBSyxDQUFMLEVBQU8sQ0FBUCxFQUFTLENBQVQsRUFBVyxDQUFYLENBQVAsRUFBc0IsQ0FBQyxDQUFDLE9BQXhCOztBQUNBLE1BQUEsQ0FBTyxFQUFQLEVBQVcsQ0FBQyxDQUFDLEVBQWI7O0FBRUEsQ0FBQyxDQUFDLE9BQUYsQ0FBVSxDQUFWOztBQUNBLE1BQUEsQ0FBTyxDQUFDLENBQUQsRUFBRyxDQUFILEVBQUssQ0FBTCxFQUFPLENBQVAsRUFBUyxDQUFULEVBQVcsQ0FBWCxDQUFQLEVBQXNCLENBQUMsQ0FBQyxPQUF4Qjs7QUFDQSxNQUFBLENBQU8sRUFBUCxFQUFXLENBQUMsQ0FBQyxFQUFiOztBQUVBLENBQUMsQ0FBQyxPQUFGLENBQVUsQ0FBVjs7QUFDQSxNQUFBLENBQU8sQ0FBQyxDQUFELEVBQUcsQ0FBSCxFQUFLLENBQUwsRUFBTyxDQUFQLEVBQVMsQ0FBVCxFQUFXLENBQVgsQ0FBUCxFQUFzQixDQUFDLENBQUMsT0FBeEI7O0FBQ0EsTUFBQSxDQUFPLEVBQVAsRUFBVyxDQUFDLENBQUMsRUFBYiIsInNvdXJjZXNDb250ZW50IjpbImV4cG9ydCBjbGFzcyBDQml0c1xyXG5cdGNvbnN0cnVjdG9yIDogKEBsc3QsQG5yPTApIC0+IFxyXG5cdFx0QHBhdHRlcm4gPSBfLm1hcCBAbHN0LCAtPiAwXHJcblx0XHRAc2V0TnIgQG5yXHJcblx0XHJcblx0c2V0Qml0IDogKGluZGV4KSAtPlxyXG5cdFx0aWYgQHBhdHRlcm5baW5kZXhdID09IDAgdGhlbiBAbnIgKz0gQGxzdFtpbmRleF1cclxuXHRcdEBwYXR0ZXJuW2luZGV4XSA9IDFcclxuXHRcclxuXHRjbHJCaXQgOiAoaW5kZXgpIC0+XHJcblx0XHRpZiBAcGF0dGVybltpbmRleF0gPT0gMSB0aGVuIEBuciAtPSBAbHN0W2luZGV4XVxyXG5cdFx0QHBhdHRlcm5baW5kZXhdID0gMFxyXG5cclxuXHRmbGlwQml0IDogKGluZGV4KSAtPlxyXG5cdFx0aWYgQHBhdHRlcm5baW5kZXhdID09IDEgdGhlbiBAY2xyQml0IGluZGV4IGVsc2UgQHNldEJpdCBpbmRleFxyXG5cdFxyXG5cdHNldE5yIDogKG5yKSAtPlxyXG5cdFx0QG5yID0gbnJcclxuXHRcdGkgPSBAbHN0Lmxlbmd0aFxyXG5cdFx0d2hpbGUgaSA+IDBcclxuXHRcdFx0aS0tXHJcblx0XHRcdGlmIG5yID49IEBsc3RbaV1cclxuXHRcdFx0XHRuciAtPSBAbHN0W2ldXHJcblx0XHRcdFx0QHBhdHRlcm5baV0gPSAxIFxyXG5cdFx0XHRlbHNlIEBwYXR0ZXJuW2ldID0gMFxyXG5cclxuXHJcbk0gPSBuZXcgQ0JpdHMgWzEsMiw0LDgsMTUsMzBdLDIwXHJcbmFzc2VydCBbMSwwLDEsMCwxLDBdLCBNLnBhdHRlcm5cclxuXHJcbk0uY2xyQml0IDJcclxuYXNzZXJ0IFsxLDAsMCwwLDEsMF0sIE0ucGF0dGVyblxyXG5hc3NlcnQgMTYsIE0ubnJcclxuXHJcbk0uc2V0Qml0IDNcclxuYXNzZXJ0IFsxLDAsMCwxLDEsMF0sIE0ucGF0dGVyblxyXG5hc3NlcnQgMjQsIE0ubnJcclxuXHJcbk0uc2V0Qml0IDVcclxuYXNzZXJ0IFsxLDAsMCwxLDEsMV0sIE0ucGF0dGVyblxyXG5hc3NlcnQgNTQsIE0ubnJcclxuXHJcbk0uZmxpcEJpdCA1XHJcbmFzc2VydCBbMSwwLDAsMSwxLDBdLCBNLnBhdHRlcm5cclxuYXNzZXJ0IDI0LCBNLm5yXHJcblxyXG5NLmZsaXBCaXQgNVxyXG5hc3NlcnQgWzEsMCwwLDEsMSwxXSwgTS5wYXR0ZXJuXHJcbmFzc2VydCA1NCwgTS5uclxyXG4iXX0=
//# sourceURL=c:\github\2022-007-StateLab\coffee\cbits.coffee