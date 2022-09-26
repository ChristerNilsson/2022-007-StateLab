// Generated by CoffeeScript 2.5.1
var C960, CAdv, CCogwheel, CColor, CDead, CImage, CNumber, CPause, CRotate, CRounded, CShow, Control,
  boundMethodCheck = function(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new Error('Bound instance method accessed before binding'); } };

Control = class Control {
  constructor(x1, y1, w1, h1, text1 = '', bg1 = 'black', fg1 = 'white') {
    this.x = x1;
    this.y = y1;
    this.w = w1;
    this.h = h1;
    this.text = text1;
    this.bg = bg1;
    this.fg = fg1;
    this.visible = true;
    this.disabled = false;
  }

  
    // @x = Math.round @x
  // @y = Math.round @y
  // @w = Math.round @w
  // @h = Math.round @h
  draw() {
    return console.log('Control.draw must be overriden!');
  }

  inside(x, y) {
    var ref, ref1, w;
    w = this.w * [height / width, width / height][1 - TOGGLE];
    return (-w / 2 <= (ref = x - this.x) && ref <= w / 2) && (-this.h / 2 <= (ref1 = y - this.y) && ref1 <= this.h / 2);
  }

};

C960 = class C960 extends Control {
  constructor(x, y, w, h) {
    super(x, y, w, h);
    this.x = Math.round(this.x);
    this.y = Math.round(this.y);
    this.w = Math.round(this.w);
    this.h = Math.round(this.h);
    this.visible = true;
  }

  draw() {
    var dx, i, j, len, ref, results, w, xoff;
    if (this.visible) {
      dx = 12;
      w = this.h * [height / width, width / height][TOGGLE];
      xoff = this.x + (dx - w) / 2;
      ref = range(8);
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        i = ref[j];
        results.push(image(chess[settings.chess960[i]], xoff + (i - 4) * dx, this.y + 8, w, this.h));
      }
      return results;
    }
  }

};

CAdv = class CAdv extends Control {
  constructor(bits1, index, x, y, diam, text, flipper, read, clk) {
    super(x, y, diam, diam, text, 'black');
    this.bits = bits1;
    this.index = index;
    this.flipper = flipper;
    this.read = read;
    this.clk = clk;
    this.visible = true;
  }

  draw() {
    var s;
    push();
    translate(this.x, this.y);
    if (this.flipper) {
      fill(1 === this.reader() ? 'yellow' : 'gray');
    } else {
      fill('gray');
    }
    s = [height / width, width / height][TOGGLE];
    ellipse(0, 0, this.w * s, this.h);
    fill('black');
    textSize(5);
    text(this.text, 0, 0.2);
    return pop();
  }

  inside(x, y) {
    var h, ref, ref1, s, w;
    s = [height / width, width / height][TOGGLE];
    w = this.w * s;
    h = this.h;
    return (-w / 2 <= (ref = x - this.x) && ref <= w / 2) && (-h / 2 <= (ref1 = y - this.y) && ref1 <= h / 2);
  }

  reader() {
    if (this.flipper) {
      return this.read(this.bits, this.index);
    } else {
      return this.read(this.bits, this.text);
    }
  }

  click() {
    if (this.flipper) {
      return this.clk(this.bits, this.index);
    } else {
      return this.clk(this.bits, this.text);
    }
  }

};

CCogwheel = class CCogwheel extends Control { // Kugghjul
  constructor(x, y, w = 0, h = 0, bg1 = 'black', fg1 = 'white', clicker) {
    super(x, y, w, h);
    this.click = this.click.bind(this);
    this.bg = bg1;
    this.fg = fg1;
    this.clicker = clicker;
  }

  click() {
    boundMethodCheck(this, CCogwheel);
    
    //console.log 'CCogwheel'
    return this.clicker();
  }

  draw() {
    var j, len, ref, v;
    if (settings.paused) {
      push();
      translate(this.x, this.y);
      scale([height / width, width / height][TOGGLE], 1);
      fill(this.fg);
      circle(0, 0, 6);
      fill(this.bg);
      circle(0, 0, 3);
      fill(this.fg);
      ref = range(0, 360, 45);
      for (j = 0, len = ref.length; j < len; j++) {
        v = ref[j];
        push();
        rotate(v);
        translate(3, 0);
        stroke(this.fg);
        rect(0, 0, 1, 1);
        pop();
      }
      return pop();
    }
  }

};

CColor = class CColor extends Control {
  constructor(x, y, fg1) {
    super(x, y, 0, 0);
    this.fg = fg1;
  }

  draw() {
    push();
    textSize(4);
    fill(this.fg);
    text(settings.info[this.fg], this.x, this.y);
    return pop();
  }

};

CDead = class CDead extends Control {
  constructor(x, y, text, fg = 'white') {
    super(x, y, 0, 0, text, 'black', fg);
  }

  draw() {
    push();
    textSize(4);
    fill(this.fg);
    text(this.text, this.x, this.y);
    return pop();
  }

};

CImage = class CImage extends Control {
  constructor(x, y, w, h, image1, clicker) {
    super(x, y, w, h);
    this.click = this.click.bind(this);
    this.image = image1;
    this.clicker = clicker;
  }

  click() {
    boundMethodCheck(this, CImage);
    return this.clicker();
  }

  draw() {
    var w;
    if (this.image) {
      w = this.h * [height / width, width / height][TOGGLE];
      return image(this.image, this.x - w / 2, 0.075 + this.y - this.h / 2, w, this.h);
    }
  }

};

CNumber = class CNumber extends Control {
  constructor(x, y, reader) {
    super(x, y, 0, 0);
    this.reader = reader;
    this.x = Math.round(this.x);
    this.y = Math.round(this.y);
  }

  draw() {
    push();
    textSize(8);
    fill('white');
    text(this.reader(), this.x, this.y);
    return pop();
  }

};

CPause = class CPause extends Control {
  constructor(x, y, w = 0, h = 0, bg1 = 'black', fg1 = 'white', clicker) {
    super(x, y, w, h);
    this.click = this.click.bind(this);
    this.bg = bg1;
    this.fg = fg1;
    this.clicker = clicker;
  }

  click() {
    boundMethodCheck(this, CPause);
    return this.clicker();
  }

  draw() {
    if (!settings.paused) {
      fill(this.fg);
      rect(this.x - 1.75, this.y, 3, 6);
      return rect(this.x + 1.75, this.y, 3, 6);
    }
  }

};

CRotate = class CRotate extends Control {
  constructor(x, y, w, h, degrees, bg, fg, player, clicker) {
    super(x, y, w, h, '', bg, fg);
    this.click = this.click.bind(this);
    this.degrees = degrees;
    this.player = player;
    this.clicker = clicker;
  }

  click() {
    boundMethodCheck(this, CRotate);
    return this.clicker();
  }

  draw() {
    var m, minCol, mw, s, secCol, ss, sw, t, tertier;
    tertier = settings.clocks[this.player];
    [m, s, t] = mst(tertier);
    t = Math.round(t);
    ss = m + ':' + d2(s);
    noStroke();
    push();
    translate(this.x, this.y);
    rotate(this.degrees);
    if (settings.player === this.player) {
      minCol = 'red';
      secCol = settings.timeout ? 'red' : 'white';
    } else {
      minCol = 'lightgrey';
      secCol = 'grey';
    }
    textSize(27);
    mw = tw * m.toString().length;
    sw = tw * 2;
    fill(minCol);
    text(m, -sw / 2, -2);
    fill(secCol);
    text(d2(s), mw / 2, -2);
    textSize(10);
    if (tertier < 10 * 60) {
      text(t, 36, -4);
    }
    if (bits.handicap.nr > 0 && settings.bonuses[this.player] > 0) {
      textSize(8);
      fill('grey');
      text(settings.bonus[this.player], 0, 17);
    }
    return pop();
  }

};

CRounded = class CRounded extends Control {
  constructor(x, y, w, h, text = '', disabled = false, bg = 'white', fg = 'black', clicker = null) {
    super(x, y, w, h, text, bg, fg);
    this.click = this.click.bind(this);
    this.disabled = disabled;
    this.clicker = clicker;
  }

  draw() {
    if (this.visible) {
      push();
      fill(this.disabled ? "black" : this.bg);
      rect(this.x, this.y, this.w, this.h, this.h / 2);
      textSize(4);
      fill(this.disabled ? "white" : this.fg);
      text(this.text, this.x, this.y);
      return pop();
    }
  }

  click() {
    boundMethodCheck(this, CRounded);
    if (this.clicker) {
      return this.clicker();
    }
  }

};

CShow = class CShow extends CDead {
  constructor(x, y, fg = 'white') {
    super(x, y, '', fg);
  }

  draw() {
    push();
    translate(this.x, this.y);
    rotate(-90);
    fill('white');
    textSize(5);
    text(settings.info.white, 0, 0);
    return pop();
  }

};

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiY29udHJvbHMuanMiLCJzb3VyY2VSb290IjoiLi4iLCJzb3VyY2VzIjpbImNvZmZlZVxcY29udHJvbHMuY29mZmVlIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7QUFBQSxJQUFBLElBQUEsRUFBQSxJQUFBLEVBQUEsU0FBQSxFQUFBLE1BQUEsRUFBQSxLQUFBLEVBQUEsTUFBQSxFQUFBLE9BQUEsRUFBQSxNQUFBLEVBQUEsT0FBQSxFQUFBLFFBQUEsRUFBQSxLQUFBLEVBQUEsT0FBQTtFQUFBOztBQUFNLFVBQU4sTUFBQSxRQUFBO0VBQ0MsV0FBYyxHQUFBLElBQUEsSUFBQSxJQUFBLFVBQW1CLEVBQW5CLFFBQTBCLE9BQTFCLFFBQXNDLE9BQXRDLENBQUE7SUFBQyxJQUFDLENBQUE7SUFBRSxJQUFDLENBQUE7SUFBRSxJQUFDLENBQUE7SUFBRSxJQUFDLENBQUE7SUFBRSxJQUFDLENBQUE7SUFBUSxJQUFDLENBQUE7SUFBVyxJQUFDLENBQUE7SUFDaEQsSUFBQyxDQUFBLE9BQUQsR0FBVztJQUNYLElBQUMsQ0FBQSxRQUFELEdBQVk7RUFGQyxDQUFmOzs7Ozs7O0VBT0MsSUFBTyxDQUFBLENBQUE7V0FBRyxPQUFPLENBQUMsR0FBUixDQUFZLGlDQUFaO0VBQUg7O0VBQ1AsTUFBUyxDQUFDLENBQUQsRUFBRyxDQUFILENBQUE7QUFDVixRQUFBLEdBQUEsRUFBQSxJQUFBLEVBQUE7SUFBRSxDQUFBLEdBQUksSUFBQyxDQUFBLENBQUQsR0FBSyxDQUFDLE1BQUEsR0FBTyxLQUFSLEVBQWMsS0FBQSxHQUFNLE1BQXBCLENBQTJCLENBQUMsQ0FBQSxHQUFFLE1BQUg7V0FDcEMsQ0FBQSxDQUFDLENBQUQsR0FBRyxDQUFILFdBQVEsQ0FBQSxHQUFFLElBQUMsQ0FBQSxFQUFYLE9BQUEsSUFBZ0IsQ0FBQSxHQUFFLENBQWxCLENBQUEsSUFBd0IsQ0FBQSxDQUFDLElBQUMsQ0FBQSxDQUFGLEdBQUksQ0FBSixZQUFTLENBQUEsR0FBRSxJQUFDLENBQUEsRUFBWixRQUFB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QUMsS0FBbkIsRUFBMEIsQ0FBMUIsRUFBNEIsQ0FBNUI7V0FDQSxHQUFBLENBQUE7RUFQTTs7QUFGUiIsInNvdXJjZXNDb250ZW50IjpbImNsYXNzIENvbnRyb2xcclxuXHRjb25zdHJ1Y3RvciA6IChAeCxAeSxAdyxAaCxAdGV4dD0nJyxAYmc9J2JsYWNrJyxAZmc9J3doaXRlJykgLT5cclxuXHRcdEB2aXNpYmxlID0gdHJ1ZVxyXG5cdFx0QGRpc2FibGVkID0gZmFsc2UgXHJcblx0XHQjIEB4ID0gTWF0aC5yb3VuZCBAeFxyXG5cdFx0IyBAeSA9IE1hdGgucm91bmQgQHlcclxuXHRcdCMgQHcgPSBNYXRoLnJvdW5kIEB3XHJcblx0XHQjIEBoID0gTWF0aC5yb3VuZCBAaFxyXG5cdGRyYXcgOiAtPiBjb25zb2xlLmxvZyAnQ29udHJvbC5kcmF3IG11c3QgYmUgb3ZlcnJpZGVuISdcclxuXHRpbnNpZGUgOiAoeCx5KSAtPlxyXG5cdFx0dyA9IEB3ICogW2hlaWdodC93aWR0aCx3aWR0aC9oZWlnaHRdWzEtVE9HR0xFXVxyXG5cdFx0LXcvMiA8PSB4LUB4IDw9IHcvMiBhbmQgLUBoLzIgPD0geS1AeSA8PSBAaC8yXHJcblxyXG5jbGFzcyBDOTYwIGV4dGVuZHMgQ29udHJvbFxyXG5cdGNvbnN0cnVjdG9yIDogKHgseSx3LGgpIC0+XHJcblx0XHRzdXBlciB4LHksdyxoXHJcblx0XHRAeCA9IE1hdGgucm91bmQgQHhcclxuXHRcdEB5ID0gTWF0aC5yb3VuZCBAeVxyXG5cdFx0QHcgPSBNYXRoLnJvdW5kIEB3XHJcblx0XHRAaCA9IE1hdGgucm91bmQgQGhcclxuXHRcdEB2aXNpYmxlID0gdHJ1ZVxyXG5cdGRyYXcgOiAtPlxyXG5cdFx0aWYgQHZpc2libGVcclxuXHRcdFx0ZHggPSAxMlxyXG5cdFx0XHR3ID0gQGggKiBbaGVpZ2h0L3dpZHRoLHdpZHRoL2hlaWdodF1bVE9HR0xFXVxyXG5cdFx0XHR4b2ZmID0gQHggKyAoZHgtdykvMlxyXG5cdFx0XHRmb3IgaSBpbiByYW5nZSA4XHJcblx0XHRcdFx0aW1hZ2UgY2hlc3Nbc2V0dGluZ3MuY2hlc3M5NjBbaV1dLCB4b2ZmKyhpLTQpKmR4LCBAeSs4LCB3LEBoXHJcblxyXG5jbGFzcyBDQWR2IGV4dGVuZHMgQ29udHJvbFxyXG5cdGNvbnN0cnVjdG9yIDogKEBiaXRzLEBpbmRleCx4LHksZGlhbSx0ZXh0LEBmbGlwcGVyLEByZWFkLEBjbGspIC0+XHJcblx0XHRzdXBlciB4LHksZGlhbSxkaWFtLHRleHQsJ2JsYWNrJ1xyXG5cdFx0QHZpc2libGUgPSB0cnVlXHJcblxyXG5cdGRyYXcgOiAtPlxyXG5cdFx0cHVzaCgpXHJcblx0XHR0cmFuc2xhdGUgQHgsQHlcclxuXHRcdGlmIEBmbGlwcGVyXHJcblx0XHRcdGZpbGwgaWYgMSA9PSBAcmVhZGVyKCkgdGhlbiAneWVsbG93JyBlbHNlICdncmF5J1xyXG5cdFx0ZWxzZSBcclxuXHRcdFx0ZmlsbCAnZ3JheSdcclxuXHRcdHMgPSBbaGVpZ2h0L3dpZHRoLHdpZHRoL2hlaWdodF1bVE9HR0xFXVxyXG5cdFx0ZWxsaXBzZSAwLDAsQHcqcyxAaFxyXG5cdFx0ZmlsbCAnYmxhY2snXHJcblx0XHR0ZXh0U2l6ZSA1XHJcblx0XHR0ZXh0IEB0ZXh0LDAsMC4yXHJcblx0XHRwb3AoKVxyXG5cclxuXHRpbnNpZGUgOiAoeCx5KSAtPlxyXG5cdFx0cyA9IFtoZWlnaHQvd2lkdGgsd2lkdGgvaGVpZ2h0XVtUT0dHTEVdXHJcblx0XHR3ID0gQHcgKiBzXHJcblx0XHRoID0gQGhcclxuXHRcdC13LzIgPD0geC1AeCA8PSB3LzIgYW5kIC1oLzIgPD0geS1AeSA8PSBoLzJcclxuXHJcblx0cmVhZGVyIDogLT4gaWYgQGZsaXBwZXIgdGhlbiBAcmVhZCBAYml0cyxAaW5kZXggZWxzZSBAcmVhZCBAYml0cyxAdGV4dFxyXG5cdGNsaWNrIDogLT4gaWYgQGZsaXBwZXIgdGhlbiBAY2xrIEBiaXRzLEBpbmRleCBlbHNlIEBjbGsgQGJpdHMsQHRleHRcclxuXHJcbmNsYXNzIENDb2d3aGVlbCBleHRlbmRzIENvbnRyb2wgIyBLdWdnaGp1bFxyXG5cdGNvbnN0cnVjdG9yIDogKHgseSx3PTAsaD0wLEBiZz0nYmxhY2snLEBmZz0nd2hpdGUnLEBjbGlja2VyKSAtPiBzdXBlciB4LHksdyxoXHJcblx0Y2xpY2sgOiA9PiBcclxuXHRcdCNjb25zb2xlLmxvZyAnQ0NvZ3doZWVsJ1xyXG5cdFx0QGNsaWNrZXIoKVxyXG5cdGRyYXcgOiAtPlxyXG5cdFx0aWYgc2V0dGluZ3MucGF1c2VkXHJcblx0XHRcdHB1c2goKVxyXG5cdFx0XHR0cmFuc2xhdGUgQHgsQHlcclxuXHRcdFx0c2NhbGUgW2hlaWdodC93aWR0aCx3aWR0aC9oZWlnaHRdW1RPR0dMRV0sMVxyXG5cdFx0XHRmaWxsIEBmZ1xyXG5cdFx0XHRjaXJjbGUgMCwwLDZcclxuXHRcdFx0ZmlsbCBAYmdcclxuXHRcdFx0Y2lyY2xlIDAsMCwzXHJcblx0XHRcdGZpbGwgQGZnXHJcblx0XHRcdGZvciB2IGluIHJhbmdlIDAsMzYwLDQ1XHJcblx0XHRcdFx0cHVzaCgpXHJcblx0XHRcdFx0cm90YXRlIHZcclxuXHRcdFx0XHR0cmFuc2xhdGUgMywwXHJcblx0XHRcdFx0c3Ryb2tlIEBmZ1xyXG5cdFx0XHRcdHJlY3QgMCwwLDEsMVxyXG5cdFx0XHRcdHBvcCgpXHJcblx0XHRcdHBvcCgpXHJcblxyXG5jbGFzcyBDQ29sb3IgZXh0ZW5kcyBDb250cm9sXHJcblx0Y29uc3RydWN0b3IgOiAoeCx5LEBmZykgLT4gc3VwZXIgeCx5LDAsMFxyXG5cdGRyYXcgOiAtPlxyXG5cdFx0cHVzaCgpXHJcblx0XHR0ZXh0U2l6ZSA0XHJcblx0XHRmaWxsIEBmZ1xyXG5cdFx0dGV4dCBzZXR0aW5ncy5pbmZvW0BmZ10sQHgsQHlcclxuXHRcdHBvcCgpXHJcblxyXG5jbGFzcyBDRGVhZCBleHRlbmRzIENvbnRyb2xcclxuXHRjb25zdHJ1Y3RvciA6ICh4LHksdGV4dCxmZz0nd2hpdGUnKSAtPiBzdXBlciB4LHksMCwwLHRleHQsJ2JsYWNrJyxmZ1xyXG5cdGRyYXcgOiAtPlxyXG5cdFx0cHVzaCgpXHJcblx0XHR0ZXh0U2l6ZSA0XHJcblx0XHRmaWxsIEBmZ1xyXG5cdFx0dGV4dCBAdGV4dCxAeCxAeVxyXG5cdFx0cG9wKClcclxuXHJcbmNsYXNzIENJbWFnZSBleHRlbmRzIENvbnRyb2xcclxuXHRjb25zdHJ1Y3RvciA6ICh4LHksdyxoLEBpbWFnZSxAY2xpY2tlcikgLT5cclxuXHRcdHN1cGVyIHgseSx3LGhcclxuXHRjbGljayA6ID0+IEBjbGlja2VyKClcclxuXHRkcmF3IDogIC0+XHJcblx0XHRpZiBAaW1hZ2VcclxuXHRcdFx0dyA9IEBoICogW2hlaWdodC93aWR0aCx3aWR0aC9oZWlnaHRdW1RPR0dMRV1cclxuXHRcdFx0aW1hZ2UgQGltYWdlLEB4LXcvMiwgMC4wNzUrQHktQGgvMiwgdywgQGhcclxuXHJcbmNsYXNzIENOdW1iZXIgZXh0ZW5kcyBDb250cm9sXHJcblx0Y29uc3RydWN0b3IgOiAoeCx5LEByZWFkZXIpIC0+XHJcblx0XHRzdXBlciB4LHksMCwwXHJcblx0XHRAeCA9IE1hdGgucm91bmQgQHhcclxuXHRcdEB5ID0gTWF0aC5yb3VuZCBAeVxyXG5cdGRyYXcgOiAtPlxyXG5cdFx0cHVzaCgpXHJcblx0XHR0ZXh0U2l6ZSA4XHJcblx0XHRmaWxsICd3aGl0ZSdcclxuXHRcdHRleHQgQHJlYWRlcigpLEB4LEB5XHJcblx0XHRwb3AoKVxyXG5cclxuY2xhc3MgQ1BhdXNlIGV4dGVuZHMgQ29udHJvbFxyXG5cdGNvbnN0cnVjdG9yIDogKHgseSx3PTAsaD0wLEBiZz0nYmxhY2snLEBmZz0nd2hpdGUnLCBAY2xpY2tlcikgLT5cclxuXHRcdHN1cGVyIHgseSx3LGhcclxuXHRjbGljayA6ID0+IEBjbGlja2VyKClcclxuXHRkcmF3IDogLT5cclxuXHRcdGlmIG5vdCBzZXR0aW5ncy5wYXVzZWRcclxuXHRcdFx0ZmlsbCBAZmdcclxuXHRcdFx0cmVjdCBAeC0xLjc1LEB5LDMsNlxyXG5cdFx0XHRyZWN0IEB4KzEuNzUsQHksMyw2XHJcblxyXG5jbGFzcyBDUm90YXRlIGV4dGVuZHMgQ29udHJvbFxyXG5cdGNvbnN0cnVjdG9yIDogKHgseSx3LGgsQGRlZ3JlZXMsYmcsZmcsQHBsYXllcixAY2xpY2tlcikgLT4gc3VwZXIgeCx5LHcsaCwnJyxiZyxmZ1xyXG5cdGNsaWNrIDogPT4gQGNsaWNrZXIoKVxyXG5cclxuXHRkcmF3IDogLT5cclxuXHRcdHRlcnRpZXIgPSBzZXR0aW5ncy5jbG9ja3NbQHBsYXllcl1cclxuXHRcdFttLHMsdF0gPSBtc3QgdGVydGllclxyXG5cdFx0dCA9IE1hdGgucm91bmQgdFxyXG5cdFx0c3MgPSBtICsgJzonICsgZDIgc1xyXG5cclxuXHRcdG5vU3Ryb2tlKClcclxuXHRcdHB1c2goKVxyXG5cdFx0dHJhbnNsYXRlIEB4LEB5XHJcblx0XHRyb3RhdGUgQGRlZ3JlZXNcclxuXHJcblx0XHRpZiBzZXR0aW5ncy5wbGF5ZXIgPT0gQHBsYXllclxyXG5cdFx0XHRtaW5Db2wgPSAncmVkJ1xyXG5cdFx0XHRzZWNDb2wgPSBpZiBzZXR0aW5ncy50aW1lb3V0IHRoZW4gJ3JlZCcgZWxzZSAnd2hpdGUnXHJcblx0XHRlbHNlXHJcblx0XHRcdG1pbkNvbCA9ICdsaWdodGdyZXknXHJcblx0XHRcdHNlY0NvbCA9ICdncmV5J1xyXG5cclxuXHRcdHRleHRTaXplIDI3XHJcblx0XHRtdyA9IHR3ICogbS50b1N0cmluZygpLmxlbmd0aFxyXG5cdFx0c3cgPSB0dyAqIDJcclxuXHRcdFxyXG5cdFx0ZmlsbCBtaW5Db2xcclxuXHRcdHRleHQgbSwgLXN3LzIsIC0yXHJcblxyXG5cdFx0ZmlsbCBzZWNDb2xcclxuXHRcdHRleHQgZDIocyksIG13LzIsIC0yXHJcblxyXG5cdFx0dGV4dFNpemUgMTBcclxuXHRcdGlmIHRlcnRpZXIgPCAxMCo2MCB0aGVuIHRleHQgdCwzNiwtNFxyXG5cclxuXHRcdGlmIGJpdHMuaGFuZGljYXAubnIgPiAwIGFuZCBzZXR0aW5ncy5ib251c2VzW0BwbGF5ZXJdID4gMFxyXG5cdFx0XHR0ZXh0U2l6ZSA4XHJcblx0XHRcdGZpbGwgJ2dyZXknXHJcblx0XHRcdHRleHQgc2V0dGluZ3MuYm9udXNbQHBsYXllcl0sMCwxN1xyXG5cclxuXHRcdHBvcCgpXHJcblxyXG5jbGFzcyBDUm91bmRlZCBleHRlbmRzIENvbnRyb2xcclxuXHRjb25zdHJ1Y3RvciA6ICh4LHksdyxoLHRleHQ9JycsQGRpc2FibGVkPWZhbHNlLGJnPSd3aGl0ZScsZmc9J2JsYWNrJywgQGNsaWNrZXI9bnVsbCkgLT5cclxuXHRcdHN1cGVyIHgseSx3LGgsdGV4dCxiZyxmZ1xyXG5cdGRyYXcgOiAtPlxyXG5cdFx0aWYgQHZpc2libGVcclxuXHRcdFx0cHVzaCgpXHJcblx0XHRcdGZpbGwgaWYgQGRpc2FibGVkIHRoZW4gXCJibGFja1wiIGVsc2UgQGJnXHJcblx0XHRcdHJlY3QgQHgsQHksQHcsQGgsQGgvMlxyXG5cdFx0XHR0ZXh0U2l6ZSA0XHJcblx0XHRcdGZpbGwgaWYgQGRpc2FibGVkIHRoZW4gXCJ3aGl0ZVwiIGVsc2UgQGZnXHJcblx0XHRcdHRleHQgQHRleHQsQHgsQHlcclxuXHRcdFx0cG9wKClcclxuXHRjbGljayA6ID0+IGlmIEBjbGlja2VyIHRoZW4gQGNsaWNrZXIoKVxyXG5cclxuY2xhc3MgQ1Nob3cgZXh0ZW5kcyBDRGVhZFxyXG5cdGNvbnN0cnVjdG9yIDogKHgseSxmZz0nd2hpdGUnKSAtPiBzdXBlciB4LHksJycsZmdcclxuXHRkcmF3IDogLT5cclxuXHRcdHB1c2goKVxyXG5cdFx0dHJhbnNsYXRlIEB4LEB5XHJcblx0XHRyb3RhdGUgLTkwXHJcblx0XHRmaWxsICd3aGl0ZSdcclxuXHRcdHRleHRTaXplIDVcclxuXHRcdHRleHQgc2V0dGluZ3MuaW5mby53aGl0ZSwgMCwwXHJcblx0XHRwb3AoKVxyXG4iXX0=
//# sourceURL=c:\github\2022-007-StateLab\coffee\controls.coffee