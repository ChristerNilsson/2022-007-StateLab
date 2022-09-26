// Generated by CoffeeScript 2.5.1
var S960, SAdv, SBasic, SClock, State;

State = class State {
  constructor(name1) {
    this.name = name1;
    this.controls = {};
  }

  draw() {
    var key, results;
    results = [];
    for (key in this.controls) {
      results.push(this.controls[key].draw());
    }
    return results;
  }

  mouseClicked() {
    var control, key, results, x, y;
    console.log('State.mouseClicked');
    ({x, y} = getLocalCoords());
    results = [];
    for (key in this.controls) {
      control = this.controls[key];
      if (control.visible && !control.disabled && control.inside(x, y)) {
        if (control.click) {
          control.click();
        }
        break;
      } else {
        results.push(void 0);
      }
    }
    return results;
  }

};

S960 = class S960 extends State {
  constructor(name) {
    var click960, diam, i, k, key, len, number, random960, reader960, ref, x, xi, y, yi;
    super(name);
    reader960 = (bits, index) => {
      return bits.pattern[index];
    };
    click960 = (bitar, index) => {
      bitar.flipBit(index);
      settings.chess960 = chess960(bits.number960.nr);
      return this.controls.ok.visible = bits.number960.nr < 960;
    };
    random960 = function() {
      var nr;
      nr = _.random(0, 959);
      bits.number960.setNr(nr);
      return settings.chess960 = chess960(nr);
    };
    x = [100 / 4, 200 / 4, 300 / 4];
    y = [-5, 40, 52, 64, 76, 78, 90, 95];
    diam = 10;
    this.controls.C960 = new C960(50, y[0], 100, 10);
    this.controls.CNumber = new CNumber(50, 25, () => {
      return bits.number960.nr;
    });
    ref = range(bits.number960.lst.length);
    for (k = 0, len = ref.length; k < len; k++) {
      i = ref[k];
      number = bits.number960.lst[i];
      key = 'R' + number;
      xi = [0, 0, 0, 0, 1, 1, 1, 2, 2, 2][i];
      yi = [1, 2, 3, 4, 1, 2, 3, 1, 2, 3][i];
      this.controls[key] = new CAdv(bits.number960, i, x[xi], y[yi], diam, number, true, reader960, click960);
    }
    this.controls.random = new CRounded((x[1] + x[2]) / 2, y[4], 18, 6, 'random', false, 'white', 'black', random960);
    this.controls.basic = new CRounded(10, y[7], 18, 6, 'basic', false, 'white', 'black', () => {
      var currState;
      return currState = states.SBasic;
    });
    this.controls.adv = new CRounded(30, y[7], 18, 6, 'adv', false, 'white', 'black', () => {
      var currState;
      return currState = states.SAdv;
    });
    this.controls.b960 = new CRounded(50, y[7], 18, 6, '960', true, 'white', 'black');
    this.controls.cancel = new CRounded(70, y[7], 18, 6, 'cancel', false, 'white', 'black', cancel);
    this.controls.ok = new CRounded(90, y[7], 18, 6, 'ok', false, 'white', 'black', ok);
  }

};

SAdv = class SAdv extends State {
  constructor(name) {
    var y;
    super(name);
    this.controls.orange = new CColor(50, 2.5, 'orange');
    this.controls.white = new CColor(50, 9.5, 'white');
    this.controls.green = new CColor(50, 16.5, 'green');
    this.controls.reflection = new CDead(25, 25, "reflection\nminutes");
    this.controls.bonus = new CDead(50, 25, "bonus\nseconds");
    this.controls.hcp = new CDead(75, 25, "handicap\ntertier");
    y = 95;
    this.controls.basic = new CRounded(1 * 100 / 10, y, 18, 6, 'basic', false, 'white', 'black', () => {
      var currState;
      return currState = states.SBasic;
    });
    this.controls.adv = new CRounded(3 * 100 / 10, y, 18, 6, 'adv', true, 'white', 'black');
    this.controls.b960 = new CRounded(5 * 100 / 10, y, 18, 6, '960', false, 'white', 'black', () => {
      var currState;
      return currState = states.S960;
    });
    this.controls.cancel = new CRounded(7 * 100 / 10, y, 18, 6, 'cancel', false, 'white', 'black', cancel);
    this.controls.ok = new CRounded(9 * 100 / 10, y, 18, 6, 'ok', false, 'white', 'black', ok);
    this.makeEditButtons();
  }

  makeEditButtons() {
    var clicker, diam, i, j, k, len, letter, name, number, reader, ref, results, xoff, xsize, yoff, ysize;
    reader = (bitar, index) => {
      return bitar.pattern[index];
    };
    clicker = (bitar, index) => {
      bitar.flipBit(index);
      settings.info.orange = getOrange();
      settings.info.white = getWhite();
      settings.info.green = getGreen();
      return this.controls.ok.visible = bits.minutes.nr > 0 && bits.handicap.nr < 60;
    };
    ref = range(3);
    results = [];
    for (k = 0, len = ref.length; k < len; k++) {
      i = ref[k];
      letter = 'Mst'[i];
      xsize = 100 / 4;
      ysize = 100 / 12;
      xoff = xsize;
      yoff = 33 + 2;
      diam = 7;
      results.push((function() {
        var l, len1, ref1, results1;
        ref1 = range(7);
        results1 = [];
        for (l = 0, len1 = ref1.length; l < len1; l++) {
          j = ref1[l];
          number = bits.minutes.lst[j];
          name = letter + number;
          if (i !== 2 || j !== 6) {
            results1.push(this.controls[name] = new CAdv([bits.minutes, bits.seconds, bits.handicap][i], j, xoff + xsize * i, yoff + ysize * j, diam, number, true, reader, clicker));
          } else {
            results1.push(void 0);
          }
        }
        return results1;
      }).call(this));
    }
    return results;
  }

};

SBasic = class SBasic extends State {
  constructor(name) {
    var M, clicker, diam, i, k, l, len, len1, reader, ref, ref1, s, x, xi, xm, y, yi;
    super(name);
    reader = (bitar, text) => {
      return bitar.nr;
    };
    clicker = (bitar, text) => {
      bitar.nr = text;
      settings.info.orange = getOrange();
      settings.info.white = getWhite();
      settings.info.green = getGreen();
      return this.controls.ok.visible = bits.minutes.nr > 0 && bits.handicap.nr < 60;
    };
    x = [20, 45, 80];
    y = [32, 41, 50, 59, 68, 77, 86, 95];
    xm = (x[0] + x[1]) / 2;
    diam = 8;
    this.controls.orange = new CColor(50, 2.5, 'orange'); // ,getOrange
    this.controls.white = new CColor(50, 9.5, 'white'); // , getWhite
    this.controls.green = new CColor(50, 16.5, 'green'); // , getGreen
    this.controls.reflection = new CDead(xm, 23, "reflection\nminutes");
    this.controls.bonus = new CDead(x[2], 23, "bonus\nseconds");
    ref = range(11);
    for (k = 0, len = ref.length; k < len; k++) {
      i = ref[k];
      xi = [0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1][i];
      yi = [0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 5][i];
      M = [1, 2, 3, 5, 10, 15, 20, 30, 45, 60, 90][i];
      this.controls['M' + M] = new CAdv(bits.minutes, i, x[xi], y[yi], diam, M, false, reader, clicker);
    }
    ref1 = range(7);
    for (l = 0, len1 = ref1.length; l < len1; l++) {
      i = ref1[l];
      s = [0, 1, 2, 3, 5, 10, 30][i];
      this.controls['s' + s] = new CAdv(bits.seconds, i, x[2], y[i], diam, s, false, reader, clicker);
    }
    this.controls.basic = new CRounded(1 * 100 / 10, y[7], 18, 6, 'basic', true, 'white', 'black');
    this.controls.adv = new CRounded(3 * 100 / 10, y[7], 18, 6, 'adv', false, 'white', 'black', () => {
      var currState;
      return currState = states.SAdv;
    });
    this.controls.b960 = new CRounded(5 * 100 / 10, y[7], 18, 6, '960', false, 'white', 'black', () => {
      var currState;
      return currState = states.S960;
    });
    this.controls.cancel = new CRounded(7 * 100 / 10, y[7], 18, 6, 'cancel', false, 'white', 'black', cancel);
    this.controls.ok = new CRounded(9 * 100 / 10, y[7], 18, 6, 'ok', false, 'white', 'black', ok);
  }

};

SClock = class SClock extends State {
  constructor(name) {
    var handleQR, pause, player0, player1;
    super(name);
    player0 = () => {
      if (settings.timeout) {

      } else {
        return this.handlePlayer(0);
      }
    };
    player1 = () => {
      if (settings.timeout) {

      } else {
        return this.handlePlayer(1);
      }
    };
    pause = () => {
      return settings.paused = true;
    };
    handleQR = () => {
      fullscreen(true);
      return resizeCanvas(innerWidth, innerHeight);
    };
    this.controls.left = new CRotate(50, 22, 100, 44, 180, 'black', 'white', 0, player0); // eg up
    this.controls.right = new CRotate(50, 78, 100, 44, 0, 'black', 'white', 1, player1); // eg down
    this.controls.pause = new CPause(67, 50, 17, 12, 'black', 'white', pause);
    this.controls.qr = new CImage(50, 50, 33, 12, qr, handleQR);
    this.controls.basic = new CCogwheel(83, 50, 17, 12, 'black', 'white', () => {
      var currState;
      console.log('SClock clicker');
      settings.backup();
      currState = states.SBasic;
      return console.log(currState);
    });
    this.controls.show = new CShow(22, 50, 'white');
  }

  handlePlayer(player) {
    if (settings.timeout) {
      return;
    }
    if (settings.paused) {
      sound.play();
    } else if (settings.player === -1) {
      sound.play();
    } else if (settings.player === player) {
      sound.play();
      settings.clocks[player] += settings.bonuses[player];
    }
    settings.paused = false;
    return settings.player = 1 - player;
  }

  indicator() {
    var a, andel, b;
    a = settings.clocks[0];
    b = settings.clocks[1];
    andel = 100 * a / (a + b);
    push();
    strokeWeight(1);
    stroke('white');
    line(1, andel, 10, andel);
    line(90, andel, 99, andel);
    return pop();
  }

  draw() {
    super.draw();
    return this.indicator();
  }

};

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoic3RhdGVzLmpzIiwic291cmNlUm9vdCI6Ii4uIiwic291cmNlcyI6WyJjb2ZmZWVcXHN0YXRlcy5jb2ZmZWUiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IjtBQUFBLElBQUEsSUFBQSxFQUFBLElBQUEsRUFBQSxNQUFBLEVBQUEsTUFBQSxFQUFBOztBQUFNLFFBQU4sTUFBQSxNQUFBO0VBQ0MsV0FBYyxNQUFBLENBQUE7SUFBQyxJQUFDLENBQUE7SUFBUyxJQUFDLENBQUEsUUFBRCxHQUFZLENBQUE7RUFBdkI7O0VBQ2QsSUFBTyxDQUFBLENBQUE7QUFBRSxRQUFBLEdBQUEsRUFBQTtBQUFDO0lBQUEsS0FBQSxvQkFBQTttQkFBQSxJQUFDLENBQUEsUUFBUSxDQUFDLEdBQUQsQ0FBSyxDQUFDLElBQWYsQ0FBQTtJQUFBLENBQUE7O0VBQUg7O0VBRVAsWUFBZSxDQUFBLENBQUE7QUFDaEIsUUFBQSxPQUFBLEVBQUEsR0FBQSxFQUFBLE9BQUEsRUFBQSxDQUFBLEVBQUE7SUFBRSxPQUFPLENBQUMsR0FBUixDQUFZLG9CQUFaO0lBQ0EsQ0FBQSxDQUFDLENBQUQsRUFBRyxDQUFILENBQUEsR0FBUSxjQUFBLENBQUEsQ0FBUjtBQUNBO0lBQUEsS0FBQSxvQkFBQTtNQUNDLE9BQUEsR0FBVSxJQUFDLENBQUEsUUFBUSxDQUFDLEdBQUQ7TUFDbkIsSUFBRyxPQUFPLENBQUMsT0FBUixJQUFvQixDQUFJLE9BQU8sQ0FBQyxRQUFoQyxJQUE2QyxPQUFPLENBQUMsTUFBUixDQUFlLENBQWYsRUFBa0IsQ0FBbEIsQ0FBaEQ7UUFDQyxJQUFHLE9BQU8sQ0FBQyxLQUFYO1VBQXNCLE9BQU8sQ0FBQyxLQUFSLENBQUEsRUFBdEI7O0FBQ0EsY0FGRDtPQUFBLE1BQUE7NkJBQUE7O0lBRkQsQ0FBQTs7RUFIYzs7QUFKaEI7O0FBYU0sT0FBTixNQUFBLEtBQUEsUUFBbUIsTUFBbkI7RUFDQyxXQUFjLENBQUMsSUFBRCxDQUFBO0FBQ2YsUUFBQSxRQUFBLEVBQUEsSUFBQSxFQUFBLENB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QyxNQUFULEdBQWtCLENBQUEsR0FBRTtFQVZOOztFQVlmLFNBQVksQ0FBQSxDQUFBO0FBQ2IsUUFBQSxDQUFBLEVBQUEsS0FBQSxFQUFBO0lBQUUsQ0FBQSxHQUFJLFFBQVEsQ0FBQyxNQUFNLENBQUMsQ0FBRDtJQUNuQixDQUFBLEdBQUksUUFBUSxDQUFDLE1BQU0sQ0FBQyxDQUFEO0lBQ25CLEtBQUEsR0FBUSxHQUFBLEdBQU0sQ0FBTixHQUFRLENBQUMsQ0FBQSxHQUFFLENBQUg7SUFDaEIsSUFBQSxDQUFBO0lBQ0EsWUFBQSxDQUFhLENBQWI7SUFDQSxNQUFBLENBQU8sT0FBUDtJQUNBLElBQUEsQ0FBTSxDQUFOLEVBQVEsS0FBUixFQUFlLEVBQWYsRUFBa0IsS0FBbEI7SUFDQSxJQUFBLENBQUssRUFBTCxFQUFRLEtBQVIsRUFBZSxFQUFmLEVBQWtCLEtBQWxCO1dBQ0EsR0FBQSxDQUFBO0VBVFc7O0VBV1osSUFBTyxDQUFBLENBQUE7U0FBUCxDQUFBLElBQ0MsQ0FBQTtXQUNBLElBQUMsQ0FBQSxTQUFELENBQUE7RUFGTTs7QUEvQ1IiLCJzb3VyY2VzQ29udGVudCI6WyJjbGFzcyBTdGF0ZVxyXG5cdGNvbnN0cnVjdG9yIDogKEBuYW1lKSAtPiBAY29udHJvbHMgPSB7fVxyXG5cdGRyYXcgOiAtPiBAY29udHJvbHNba2V5XS5kcmF3KCkgZm9yIGtleSBvZiBAY29udHJvbHNcclxuXHJcblx0bW91c2VDbGlja2VkIDogLT5cclxuXHRcdGNvbnNvbGUubG9nICdTdGF0ZS5tb3VzZUNsaWNrZWQnXHJcblx0XHR7eCx5fSA9IGdldExvY2FsQ29vcmRzKClcclxuXHRcdGZvciBrZXkgb2YgQGNvbnRyb2xzXHJcblx0XHRcdGNvbnRyb2wgPSBAY29udHJvbHNba2V5XVxyXG5cdFx0XHRpZiBjb250cm9sLnZpc2libGUgYW5kIG5vdCBjb250cm9sLmRpc2FibGVkIGFuZCBjb250cm9sLmluc2lkZSB4LCB5XHJcblx0XHRcdFx0aWYgY29udHJvbC5jbGljayB0aGVuIGNvbnRyb2wuY2xpY2soKVxyXG5cdFx0XHRcdGJyZWFrXHJcblxyXG5jbGFzcyBTOTYwIGV4dGVuZHMgU3RhdGVcclxuXHRjb25zdHJ1Y3RvciA6IChuYW1lKSAtPlxyXG5cdFx0c3VwZXIgbmFtZVxyXG5cdFx0cmVhZGVyOTYwID0gKGJpdHMsaW5kZXgpID0+IGJpdHMucGF0dGVybltpbmRleF1cclxuXHRcdGNsaWNrOTYwID0gKGJpdGFyLGluZGV4KSA9PlxyXG5cdFx0XHRiaXRhci5mbGlwQml0IGluZGV4XHJcblx0XHRcdHNldHRpbmdzLmNoZXNzOTYwID0gY2hlc3M5NjAgYml0cy5udW1iZXI5NjAubnJcclxuXHRcdFx0QGNvbnRyb2xzLm9rLnZpc2libGUgPSBiaXRzLm51bWJlcjk2MC5uciA8IDk2MFxyXG5cclxuXHRcdHJhbmRvbTk2MCA9IC0+XHJcblx0XHRcdG5yID0gXy5yYW5kb20gMCw5NTlcclxuXHRcdFx0Yml0cy5udW1iZXI5NjAuc2V0TnIgbnJcclxuXHRcdFx0c2V0dGluZ3MuY2hlc3M5NjAgPSBjaGVzczk2MCBuclxyXG5cclxuXHRcdHggPSBbMTAwLzQsMjAwLzQsMzAwLzRdXHJcblx0XHR5ID0gWy01LDQwLDUyLDY0LDc2LDc4LDkwLDk1XVxyXG5cdFx0ZGlhbSA9IDEwXHJcblxyXG5cdFx0QGNvbnRyb2xzLkM5NjAgICAgPSBuZXcgQzk2MCAgICA1MCx5WzBdLCAxMDAsIDEwXHJcblx0XHRAY29udHJvbHMuQ051bWJlciA9IG5ldyBDTnVtYmVyIDUwLDI1LCA9PiBiaXRzLm51bWJlcjk2MC5uclxyXG5cclxuXHRcdGZvciBpIGluIHJhbmdlIGJpdHMubnVtYmVyOTYwLmxzdC5sZW5ndGhcclxuXHRcdFx0bnVtYmVyID0gYml0cy5udW1iZXI5NjAubHN0W2ldXHJcblx0XHRcdGtleSAgICA9ICdSJytudW1iZXJcclxuXHRcdFx0eGkgICAgID0gWzAsMCwwLDAsMSwxLDEsMiwyLDJdW2ldXHJcblx0XHRcdHlpICAgICA9IFsxLDIsMyw0LDEsMiwzLDEsMiwzXVtpXVxyXG5cdFx0XHRAY29udHJvbHNba2V5XSA9IG5ldyBDQWR2IGJpdHMubnVtYmVyOTYwLCBpLCB4W3hpXSx5W3lpXSwgZGlhbSwgbnVtYmVyLCB0cnVlLCByZWFkZXI5NjAsIGNsaWNrOTYwXHJcblxyXG5cdFx0QGNvbnRyb2xzLnJhbmRvbSA9IG5ldyBDUm91bmRlZCAoeFsxXSt4WzJdKS8yLHlbNF0sIDE4LDYsICdyYW5kb20nLCBmYWxzZSwgJ3doaXRlJywnYmxhY2snLHJhbmRvbTk2MFxyXG5cdFx0QGNvbnRyb2xzLmJhc2ljICA9IG5ldyBDUm91bmRlZCAxMCx5WzddLCAxOCw2LCAnYmFzaWMnLCBmYWxzZSwnd2hpdGUnLCdibGFjaycsPT4gY3VyclN0YXRlID0gc3RhdGVzLlNCYXNpY1xyXG5cdFx0QGNvbnRyb2xzLmFkdiAgICA9IG5ldyBDUm91bmRlZCAzMCx5WzddLCAxOCw2LCAnYWR2JywgICBmYWxzZSwnd2hpdGUnLCdibGFjaycsPT4gY3VyclN0YXRlID0gc3RhdGVzLlNBZHZcclxuXHRcdEBjb250cm9scy5iOTYwICAgPSBuZXcgQ1JvdW5kZWQgNTAseVs3XSwgMTgsNiwgJzk2MCcsICAgIHRydWUsJ3doaXRlJywnYmxhY2snXHJcblx0XHRAY29udHJvbHMuY2FuY2VsID0gbmV3IENSb3VuZGVkIDcwLHlbN10sIDE4LDYsICdjYW5jZWwnLGZhbHNlLCd3aGl0ZScsJ2JsYWNrJyxjYW5jZWxcclxuXHRcdEBjb250cm9scy5vayAgICAgPSBuZXcgQ1JvdW5kZWQgOTAseVs3XSwgMTgsNiwgJ29rJywgICAgZmFsc2UsJ3doaXRlJywnYmxhY2snLG9rXHJcblxyXG5jbGFzcyBTQWR2IGV4dGVuZHMgU3RhdGVcclxuXHRjb25zdHJ1Y3RvciA6IChuYW1lKSAtPlxyXG5cdFx0c3VwZXIgbmFtZVxyXG5cclxuXHRcdEBjb250cm9scy5vcmFuZ2UgICAgID0gbmV3IENDb2xvciA1MCwgMi41LCdvcmFuZ2UnXHJcblx0XHRAY29udHJvbHMud2hpdGUgICAgICA9IG5ldyBDQ29sb3IgNTAsIDkuNSwnd2hpdGUnXHJcblx0XHRAY29udHJvbHMuZ3JlZW4gICAgICA9IG5ldyBDQ29sb3IgNTAsMTYuNSwnZ3JlZW4nXHJcblxyXG5cdFx0QGNvbnRyb2xzLnJlZmxlY3Rpb24gPSBuZXcgQ0RlYWQgIDI1LDI1LFwicmVmbGVjdGlvblxcbm1pbnV0ZXNcIlxyXG5cdFx0QGNvbnRyb2xzLmJvbnVzICAgICAgPSBuZXcgQ0RlYWQgIDUwLDI1LFwiYm9udXNcXG5zZWNvbmRzXCJcclxuXHRcdEBjb250cm9scy5oY3AgICAgICAgID0gbmV3IENEZWFkICA3NSwyNSxcImhhbmRpY2FwXFxudGVydGllclwiXHJcblxyXG5cdFx0eSA9IDk1XHJcblxyXG5cdFx0QGNvbnRyb2xzLmJhc2ljICA9IG5ldyBDUm91bmRlZCAxKjEwMC8xMCx5LCAxOCw2LCAnYmFzaWMnLCBmYWxzZSwnd2hpdGUnLCdibGFjaycsPT4gY3VyclN0YXRlID0gc3RhdGVzLlNCYXNpY1xyXG5cdFx0QGNvbnRyb2xzLmFkdiAgICA9IG5ldyBDUm91bmRlZCAzKjEwMC8xMCx5LCAxOCw2LCAnYWR2JywgICAgdHJ1ZSwnd2hpdGUnLCdibGFjaydcclxuXHRcdEBjb250cm9scy5iOTYwICAgPSBuZXcgQ1JvdW5kZWQgNSoxMDAvMTAseSwgMTgsNiwgJzk2MCcsICAgZmFsc2UsJ3doaXRlJywnYmxhY2snLD0+IGN1cnJTdGF0ZSA9IHN0YXRlcy5TOTYwXHJcblx0XHRAY29udHJvbHMuY2FuY2VsID0gbmV3IENSb3VuZGVkIDcqMTAwLzEwLHksIDE4LDYsICdjYW5jZWwnLGZhbHNlLCd3aGl0ZScsJ2JsYWNrJyxjYW5jZWxcclxuXHRcdEBjb250cm9scy5vayAgICAgPSBuZXcgQ1JvdW5kZWQgOSoxMDAvMTAseSwgMTgsNiwgJ29rJywgICAgZmFsc2UsJ3doaXRlJywnYmxhY2snLG9rXHJcblxyXG5cdFx0QG1ha2VFZGl0QnV0dG9ucygpXHJcblxyXG5cdG1ha2VFZGl0QnV0dG9ucyA6IC0+XHJcblxyXG5cdFx0cmVhZGVyID0gKGJpdGFyLGluZGV4KSA9PiBiaXRhci5wYXR0ZXJuW2luZGV4XVxyXG5cdFx0Y2xpY2tlciA9IChiaXRhcixpbmRleCkgPT5cclxuXHRcdFx0Yml0YXIuZmxpcEJpdCBpbmRleFxyXG5cdFx0XHRzZXR0aW5ncy5pbmZvLm9yYW5nZSA9IGdldE9yYW5nZSgpXHJcblx0XHRcdHNldHRpbmdzLmluZm8ud2hpdGUgID0gZ2V0V2hpdGUoKVxyXG5cdFx0XHRzZXR0aW5ncy5pbmZvLmdyZWVuICA9IGdldEdyZWVuKClcclxuXHRcdFx0QGNvbnRyb2xzLm9rLnZpc2libGUgPSBiaXRzLm1pbnV0ZXMubnIgPiAwIGFuZCBiaXRzLmhhbmRpY2FwLm5yIDwgNjBcclxuXHJcblx0XHRmb3IgaSBpbiByYW5nZSAzXHJcblx0XHRcdGxldHRlciA9ICdNc3QnW2ldXHJcblx0XHRcdHhzaXplID0gMTAwLzRcclxuXHRcdFx0eXNpemUgPSAxMDAvMTJcclxuXHRcdFx0eG9mZiA9IHhzaXplXHJcblx0XHRcdHlvZmYgPSAzMysyXHJcblx0XHRcdGRpYW0gPSA3XHJcblx0XHRcdGZvciBqIGluIHJhbmdlIDdcclxuXHRcdFx0XHRudW1iZXIgPSBiaXRzLm1pbnV0ZXMubHN0W2pdXHJcblx0XHRcdFx0bmFtZSA9IGxldHRlciArIG51bWJlclxyXG5cdFx0XHRcdGlmIGkhPTIgb3IgaiE9NlxyXG5cdFx0XHRcdFx0QGNvbnRyb2xzW25hbWVdID0gbmV3IENBZHYgW2JpdHMubWludXRlcyxiaXRzLnNlY29uZHMsYml0cy5oYW5kaWNhcF1baV0sIGosIHhvZmYreHNpemUqaSwgeW9mZit5c2l6ZSpqLCBkaWFtLCBudW1iZXIsIHRydWUsIHJlYWRlciwgY2xpY2tlclxyXG5cclxuY2xhc3MgU0Jhc2ljIGV4dGVuZHMgU3RhdGVcclxuXHRjb25zdHJ1Y3RvciA6IChuYW1lKSAtPlxyXG5cdFx0c3VwZXIgbmFtZVxyXG5cclxuXHRcdHJlYWRlciAgPSAoYml0YXIsdGV4dCkgPT4gYml0YXIubnJcclxuXHRcdGNsaWNrZXIgPSAoYml0YXIsdGV4dCkgPT4gXHJcblx0XHRcdGJpdGFyLm5yID0gdGV4dFxyXG5cdFx0XHRzZXR0aW5ncy5pbmZvLm9yYW5nZSA9IGdldE9yYW5nZSgpXHJcblx0XHRcdHNldHRpbmdzLmluZm8ud2hpdGUgID0gZ2V0V2hpdGUoKVxyXG5cdFx0XHRzZXR0aW5ncy5pbmZvLmdyZWVuICA9IGdldEdyZWVuKClcclxuXHRcdFx0QGNvbnRyb2xzLm9rLnZpc2libGUgPSBiaXRzLm1pbnV0ZXMubnIgPiAwIGFuZCBiaXRzLmhhbmRpY2FwLm5yIDwgNjBcclxuXHJcblx0XHR4ID0gWzIwLDQ1LDgwXVxyXG5cdFx0eSA9IFszMiw0MSw1MCw1OSw2OCw3Nyw4Niw5NV1cclxuXHRcdHhtID0gKHhbMF0reFsxXSkvMlxyXG5cdFx0ZGlhbSA9IDhcclxuXHJcblx0XHRAY29udHJvbHMub3JhbmdlID0gbmV3IENDb2xvciA1MCwgMi41LCdvcmFuZ2UnIyAsZ2V0T3JhbmdlXHJcblx0XHRAY29udHJvbHMud2hpdGUgID0gbmV3IENDb2xvciA1MCwgOS41LCd3aGl0ZScjICwgZ2V0V2hpdGVcclxuXHRcdEBjb250cm9scy5ncmVlbiAgPSBuZXcgQ0NvbG9yIDUwLDE2LjUsJ2dyZWVuJyMgLCBnZXRHcmVlblxyXG5cclxuXHRcdEBjb250cm9scy5yZWZsZWN0aW9uID0gbmV3IENEZWFkIHhtLCAgMjMsIFwicmVmbGVjdGlvblxcbm1pbnV0ZXNcIlxyXG5cdFx0QGNvbnRyb2xzLmJvbnVzICAgICAgPSBuZXcgQ0RlYWQgeFsyXSwyMywgXCJib251c1xcbnNlY29uZHNcIlxyXG5cclxuXHRcdGZvciBpIGluIHJhbmdlIDExXHJcblx0XHRcdHhpID0gWzAsMCwwLDAsMCwxLDEsMSwxLDEsMV1baV1cclxuXHRcdFx0eWkgPSBbMCwxLDIsMyw0LDAsMSwyLDMsNCw1XVtpXVxyXG5cdFx0XHRNID0gWzEsMiwzLDUsMTAsMTUsMjAsMzAsNDUsNjAsOTBdW2ldXHJcblx0XHRcdEBjb250cm9sc1snTScrTV0gPSBuZXcgQ0FkdiBiaXRzLm1pbnV0ZXMsaSx4W3hpXSx5W3lpXSwgZGlhbSwgTSwgZmFsc2UsIHJlYWRlcixjbGlja2VyXHJcblxyXG5cdFx0Zm9yIGkgaW4gcmFuZ2UgN1xyXG5cdFx0XHRzID0gWzAsMSwyLDMsNSwxMCwzMF1baV1cclxuXHRcdFx0QGNvbnRyb2xzWydzJytzXSA9IG5ldyBDQWR2IGJpdHMuc2Vjb25kcyxpLHhbMl0seVtpXSwgZGlhbSwgcywgZmFsc2UsIHJlYWRlcixjbGlja2VyXHJcblxyXG5cdFx0QGNvbnRyb2xzLmJhc2ljICA9IG5ldyBDUm91bmRlZCAxKjEwMC8xMCx5WzddLCAxOCw2LCAnYmFzaWMnLCAgdHJ1ZSwnd2hpdGUnLCdibGFjaydcclxuXHRcdEBjb250cm9scy5hZHYgICAgPSBuZXcgQ1JvdW5kZWQgMyoxMDAvMTAseVs3XSwgMTgsNiwgJ2FkdicsICAgZmFsc2UsJ3doaXRlJywnYmxhY2snLD0+IGN1cnJTdGF0ZSA9IHN0YXRlcy5TQWR2XHJcblx0XHRAY29udHJvbHMuYjk2MCAgID0gbmV3IENSb3VuZGVkIDUqMTAwLzEwLHlbN10sIDE4LDYsICc5NjAnLCAgIGZhbHNlLCd3aGl0ZScsJ2JsYWNrJyw9PiBjdXJyU3RhdGUgPSBzdGF0ZXMuUzk2MFxyXG5cdFx0QGNvbnRyb2xzLmNhbmNlbCA9IG5ldyBDUm91bmRlZCA3KjEwMC8xMCx5WzddLCAxOCw2LCAnY2FuY2VsJyxmYWxzZSwnd2hpdGUnLCdibGFjaycsY2FuY2VsXHJcblx0XHRAY29udHJvbHMub2sgICAgID0gbmV3IENSb3VuZGVkIDkqMTAwLzEwLHlbN10sIDE4LDYsICdvaycsICAgIGZhbHNlLCd3aGl0ZScsJ2JsYWNrJyxva1xyXG5cclxuY2xhc3MgU0Nsb2NrIGV4dGVuZHMgU3RhdGVcclxuXHJcblx0Y29uc3RydWN0b3IgOiAobmFtZSkgLT5cclxuXHRcdHN1cGVyIG5hbWVcclxuXHJcblx0XHRwbGF5ZXIwID0gPT4gaWYgc2V0dGluZ3MudGltZW91dCB0aGVuIHJldHVybiBlbHNlIEBoYW5kbGVQbGF5ZXIgMFxyXG5cdFx0cGxheWVyMSA9ID0+IGlmIHNldHRpbmdzLnRpbWVvdXQgdGhlbiByZXR1cm4gZWxzZSBAaGFuZGxlUGxheWVyIDFcclxuXHRcdHBhdXNlICAgPSA9PiBzZXR0aW5ncy5wYXVzZWQgPSB0cnVlXHJcblx0XHRoYW5kbGVRUiA9ID0+XHJcblx0XHRcdGZ1bGxzY3JlZW4gdHJ1ZVxyXG5cdFx0XHRyZXNpemVDYW52YXMgaW5uZXJXaWR0aCwgaW5uZXJIZWlnaHRcclxuXHJcblx0XHRAY29udHJvbHMubGVmdCAgPSBuZXcgQ1JvdGF0ZSA1MCwgMjIsIDEwMCwgNDQsIDE4MCwgJ2JsYWNrJywgJ3doaXRlJywgMCwgcGxheWVyMCAjIGVnIHVwXHJcblx0XHRAY29udHJvbHMucmlnaHQgPSBuZXcgQ1JvdGF0ZSA1MCwgNzgsIDEwMCwgNDQsICAgMCwgJ2JsYWNrJywgJ3doaXRlJywgMSwgcGxheWVyMSAjIGVnIGRvd25cclxuXHRcdEBjb250cm9scy5wYXVzZSA9IG5ldyBDUGF1c2UgIDY3LCA1MCwgIDE3LCAxMiwgJ2JsYWNrJywgJ3doaXRlJywgcGF1c2VcclxuXHRcdEBjb250cm9scy5xciAgICA9IG5ldyBDSW1hZ2UgIDUwLCA1MCwgIDMzLCAxMiwgcXIsIGhhbmRsZVFSXHJcblxyXG5cdFx0QGNvbnRyb2xzLmJhc2ljID0gbmV3IENDb2d3aGVlbCA4MywgNTAsIDE3LCAxMiwgJ2JsYWNrJywgJ3doaXRlJywgPT5cclxuXHRcdFx0Y29uc29sZS5sb2cgJ1NDbG9jayBjbGlja2VyJ1xyXG5cdFx0XHRzZXR0aW5ncy5iYWNrdXAoKVxyXG5cdFx0XHRjdXJyU3RhdGUgPSBzdGF0ZXMuU0Jhc2ljXHJcblx0XHRcdGNvbnNvbGUubG9nIGN1cnJTdGF0ZVxyXG5cdFx0QGNvbnRyb2xzLnNob3cgID0gbmV3IENTaG93ICAgICAyMiwgNTAsICd3aGl0ZSdcclxuXHJcblx0aGFuZGxlUGxheWVyIDogKHBsYXllcikgLT5cclxuXHRcdGlmIHNldHRpbmdzLnRpbWVvdXQgdGhlbiByZXR1cm5cclxuXHRcdGlmIHNldHRpbmdzLnBhdXNlZCBcclxuXHRcdFx0c291bmQucGxheSgpXHJcblx0XHRlbHNlIGlmIHNldHRpbmdzLnBsYXllciA9PSAtMVxyXG5cdFx0XHRzb3VuZC5wbGF5KClcclxuXHRcdGVsc2UgaWYgc2V0dGluZ3MucGxheWVyID09IHBsYXllclxyXG5cdFx0XHRzb3VuZC5wbGF5KClcclxuXHRcdFx0c2V0dGluZ3MuY2xvY2tzW3BsYXllcl0gKz0gc2V0dGluZ3MuYm9udXNlc1twbGF5ZXJdXHJcblx0XHRzZXR0aW5ncy5wYXVzZWQgPSBmYWxzZVxyXG5cdFx0c2V0dGluZ3MucGxheWVyID0gMS1wbGF5ZXJcclxuXHJcblx0aW5kaWNhdG9yIDogLT5cclxuXHRcdGEgPSBzZXR0aW5ncy5jbG9ja3NbMF1cclxuXHRcdGIgPSBzZXR0aW5ncy5jbG9ja3NbMV1cclxuXHRcdGFuZGVsID0gMTAwICogYS8oYStiKVxyXG5cdFx0cHVzaCgpXHJcblx0XHRzdHJva2VXZWlnaHQgMVxyXG5cdFx0c3Ryb2tlICd3aGl0ZSdcclxuXHRcdGxpbmUgIDEsYW5kZWwsIDEwLGFuZGVsXHJcblx0XHRsaW5lIDkwLGFuZGVsLCA5OSxhbmRlbFxyXG5cdFx0cG9wKClcclxuXHJcblx0ZHJhdyA6IC0+XHJcblx0XHRzdXBlcigpXHJcblx0XHRAaW5kaWNhdG9yKClcclxuIl19
//# sourceURL=c:\github\2022-007-StateLab\coffee\states.coffee