// Generated by CoffeeScript 2.5.1
var assert,
  modulo = function(a, b) { return (+a % (b = +b) + b) % b; };

assert = function(a, b) {
  a = JSON.stringify(a);
  b = JSON.stringify(b);
  return console.log(a === b ? "ok" : `${a} != ${b}`);
};

export var globals = {};

globals.HOUR = 60 * 60 * 60; // tertier

globals.MINUTE = 60 * 60; // tertier

globals.SEC = 60; // tertier

globals.TOGGLE = 1; // 0=porträtt (Android) 1=landskap (Mac)

globals.HEARTBEAT = 1000; // ms updates of localStorage

globals.FRAMERATE = 60; // 10

globals.states = {};

globals.settings = {};

globals.bits = {};

globals.backup = null;

export var clone = function(x) {
  return JSON.parse(JSON.stringify(x));
};

export var getLocalCoords = function() {
  var matrix, pd;
  matrix = drawingContext.getTransform();
  pd = pixelDensity();
  return matrix.inverse().transformPoint(new DOMPoint(mouseX * pd, mouseY * pd));
};

export var createState = function(key, klass) {
  return globals.states[key] = new klass(key);
};

export var pretty = function(tot) {
  var header, m, s, t;
  tot = Math.round(tot);
  t = modulo(tot, 60);
  tot = Math.floor(tot / 60);
  s = modulo(tot, 60);
  m = Math.floor(tot / 60);
  header = '';
  if (m > 0) {
    header += m + 'm';
  }
  if (s > 0) {
    header += s + 's';
  }
  if (t > 0) {
    header += t + 't';
  }
  return header;
};

assert('1m1t', pretty(3601));

assert('2s3t', pretty(123));

assert('60m30s', pretty(60 * 60 * 60 + 30 * 60));

export var prettyPair = function(a, b) {
  var separator;
  separator = pretty(b) !== '' ? ' + ' : '';
  return pretty(a) + separator + pretty(b);
};

assert('1m1t + 2s3t', prettyPair(3601, 123));

export var d2 = function(x) {
  x = Math.trunc(x);
  if (x < 10) {
    return '0' + x;
  } else {
    return x;
  }
};

assert('03', d2(3));

export var mst = function(x) { // tertier
  var m, s, t;
  t = modulo(x, 60);
  x = Math.floor(x / 60);
  s = modulo(x, 60);
  m = Math.floor(x / 60);
  return [m, s, t];
};

assert([3, 0, 0], mst(3 * 60 * 60));

assert([3, 0, 30], mst(180 * 60 + 30));

export var getOrange = function() {
  var g, gs, gsp;
  g = globals;
  gs = g.settings;
  gs.makeHandicap();
  gsp = gs.players;
  if (g.bits.handicap.nr === 0) {
    return '';
  } else {
    return prettyPair(gsp[0][0], gsp[0][1]);
  }
};

export var getWhite = function() {
  return globals.settings.compact();
};

export var getGreen = function() {
  var g, gs, gsp;
  g = globals;
  gs = g.settings;
  gs.makeHandicap();
  gsp = globals.settings.players;
  if (g.bits.handicap.nr === 0) {
    return '';
  } else {
    return prettyPair(gsp[1][0], gsp[1][1]);
  }
};

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiZ2xvYmFscy5qcyIsInNvdXJjZVJvb3QiOiIuLiIsInNvdXJjZXMiOlsiY29mZmVlXFxnbG9iYWxzLmNvZmZlZSJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiO0FBQUEsSUFBQSxNQUFBO0VBQUE7O0FBQUEsTUFBQSxHQUFTLFFBQUEsQ0FBQyxDQUFELEVBQUcsQ0FBSCxDQUFBO0VBQ1IsQ0FBQSxHQUFJLElBQUksQ0FBQyxTQUFMLENBQWUsQ0FBZjtFQUNKLENBQUEsR0FBSSxJQUFJLENBQUMsU0FBTCxDQUFlLENBQWY7U0FDSixPQUFPLENBQUMsR0FBUixDQUFlLENBQUEsS0FBRyxDQUFOLEdBQWEsSUFBYixHQUF1QixDQUFBLENBQUEsQ0FBRyxDQUFILENBQUEsSUFBQSxDQUFBLENBQVcsQ0FBWCxDQUFBLENBQW5DO0FBSFE7O0FBS1QsT0FBQSxJQUFPLE9BQUEsR0FBVSxDQUFBOztBQUVqQixPQUFPLENBQUMsSUFBUixHQUFpQixFQUFBLEdBQUcsRUFBSCxHQUFNLEdBUHZCOztBQVFBLE9BQU8sQ0FBQyxNQUFSLEdBQWlCLEVBQUEsR0FBRyxHQVJwQjs7QUFTQSxPQUFPLENBQUMsR0FBUixHQUFpQixHQVRqQjs7QUFXQSxPQUFPLENBQUMsTUFBUixHQUFpQixFQVhqQjs7QUFZQSxPQUFPLENBQUMsU0FBUixHQUFvQixLQVpwQjs7QUFjQSxPQUFPLENBQUMsU0FBUixHQUFvQixHQWRwQjs7QUFlQSxPQUFPLENBQUMsTUFBUixHQUFpQixDQUFBOztBQUNqQixPQUFPLENBQUMsUUFBUixHQUFvQixDQUFBOztBQUNwQixPQUFPLENBQUMsSUFBUixHQUFlLENBQUE7O0FBQ2YsT0FBTyxDQUFDLE1BQVIsR0FBaUI7O0FBRWpCLE9BQUEsSUFBTyxLQUFBLEdBQVEsUUFBQSxDQUFDLENBQUQsQ0FBQTtTQUFPLElBQUksQ0FBQyxLQUFMLENBQVcsSUFBSSxDQUFDLFNBQUwsQ0FBZSxDQUFmLENBQVg7QUFBUDs7QUFFZixPQUFBLElBQU8sY0FBQSxHQUFpQixRQUFBLENB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O0FBQ25CLE1BQUEsQ0FBQSxFQUFBLEVBQUEsRUFBQTtFQUFDLENBQUEsR0FBSTtFQUNKLEVBQUEsR0FBSyxDQUFDLENBQUM7RUFDUCxFQUFFLENBQUMsWUFBSCxDQUFBO0VBQ0EsR0FBQSxHQUFNLEVBQUUsQ0FBQztFQUNULElBQUcsQ0FBQyxDQUFDLElBQUksQ0FBQyxRQUFRLENBQUMsRUFBaEIsS0FBc0IsQ0FBekI7V0FBZ0MsR0FBaEM7R0FBQSxNQUFBO1dBQXdDLFVBQUEsQ0FBVyxHQUFHLENBQUMsQ0FBRCxDQUFHLENBQUMsQ0FBRCxDQUFqQixFQUFzQixHQUFHLENBQUMsQ0FBRCxDQUFHLENBQUMsQ0FBRCxDQUE1QixFQUF4Qzs7QUFMa0I7O0FBT25CLE9BQUEsSUFBTyxRQUFBLEdBQVcsUUFBQSxDQUFBLENBQUE7U0FBRyxPQUFPLENBQUMsUUFBUSxDQUFDLE9BQWpCLENBQUE7QUFBSDs7QUFFbEIsT0FBQSxJQUFPLFFBQUEsR0FBVyxRQUFBLENBQUEsQ0FBQTtBQUNsQixNQUFBLENBQUEsRUFBQSxFQUFBLEVBQUE7RUFBQyxDQUFBLEdBQUk7RUFDSixFQUFBLEdBQUssQ0FBQyxDQUFDO0VBQ1AsRUFBRSxDQUFDLFlBQUgsQ0FBQTtFQUNBLEdBQUEsR0FBTSxPQUFPLENBQUMsUUFBUSxDQUFDO0VBQ3ZCLElBQUcsQ0FBQyxDQUFDLElBQUksQ0FBQyxRQUFRLENBQUMsRUFBaEIsS0FBc0IsQ0FBekI7V0FBZ0MsR0FBaEM7R0FBQSxNQUFBO1dBQXdDLFVBQUEsQ0FBVyxHQUFHLENBQUMsQ0FBRCxDQUFHLENBQUMsQ0FBRCxDQUFqQixFQUFzQixHQUFHLENBQUMsQ0FBRCxDQUFHLENBQUMsQ0FBRCxDQUE1QixFQUF4Qzs7QUFMaUIiLCJzb3VyY2VzQ29udGVudCI6WyJhc3NlcnQgPSAoYSxiKSAtPlxyXG5cdGEgPSBKU09OLnN0cmluZ2lmeSBhIFxyXG5cdGIgPSBKU09OLnN0cmluZ2lmeSBiXHJcblx0Y29uc29sZS5sb2cgaWYgYT09YiB0aGVuIFwib2tcIiBlbHNlIFwiI3thfSAhPSAje2J9XCJcclxuXHJcbmV4cG9ydCBnbG9iYWxzID0ge31cclxuXHJcbmdsb2JhbHMuSE9VUiAgID0gNjAqNjAqNjAgIyB0ZXJ0aWVyXHJcbmdsb2JhbHMuTUlOVVRFID0gNjAqNjAgICAgIyB0ZXJ0aWVyXHJcbmdsb2JhbHMuU0VDICAgID0gNjAgICAgICAgIyB0ZXJ0aWVyXHJcblxyXG5nbG9iYWxzLlRPR0dMRSA9IDEgIyAwPXBvcnRyw6R0dCAoQW5kcm9pZCkgMT1sYW5kc2thcCAoTWFjKVxyXG5nbG9iYWxzLkhFQVJUQkVBVCA9IDEwMDAgIyBtcyB1cGRhdGVzIG9mIGxvY2FsU3RvcmFnZVxyXG5cclxuZ2xvYmFscy5GUkFNRVJBVEUgPSA2MCAjIDEwXHJcbmdsb2JhbHMuc3RhdGVzID0ge31cclxuZ2xvYmFscy5zZXR0aW5ncyAgPSB7fVxyXG5nbG9iYWxzLmJpdHMgPSB7fVxyXG5nbG9iYWxzLmJhY2t1cCA9IG51bGxcclxuXHJcbmV4cG9ydCBjbG9uZSA9ICh4KSAtPiBKU09OLnBhcnNlIEpTT04uc3RyaW5naWZ5IHhcclxuXHJcbmV4cG9ydCBnZXRMb2NhbENvb3JkcyA9IC0+XHJcblx0bWF0cml4ID0gZHJhd2luZ0NvbnRleHQuZ2V0VHJhbnNmb3JtKClcclxuXHRwZCA9IHBpeGVsRGVuc2l0eSgpXHJcblx0bWF0cml4LmludmVyc2UoKS50cmFuc2Zvcm1Qb2ludCBuZXcgRE9NUG9pbnQgbW91c2VYICogcGQsbW91c2VZICogcGRcclxuXHJcbmV4cG9ydCBjcmVhdGVTdGF0ZSA9IChrZXksa2xhc3MpIC0+IGdsb2JhbHMuc3RhdGVzW2tleV0gPSBuZXcga2xhc3Mga2V5XHJcblxyXG5leHBvcnQgcHJldHR5ID0gKHRvdCkgLT5cclxuXHR0b3QgPSBNYXRoLnJvdW5kIHRvdFxyXG5cdHQgPSB0b3QgJSUgNjBcclxuXHR0b3QgLy89IDYwXHJcblx0cyA9IHRvdCAlJSA2MFxyXG5cdG0gPSB0b3QgLy8gNjBcclxuXHRoZWFkZXIgPSAnJ1xyXG5cdGlmIG0gPiAwIHRoZW4gaGVhZGVyICs9IG0gKyAnbSdcclxuXHRpZiBzID4gMCB0aGVuIGhlYWRlciArPSBzICsgJ3MnXHJcblx0aWYgdCA+IDAgdGhlbiBoZWFkZXIgKz0gdCArICd0J1xyXG5cdGhlYWRlclxyXG5hc3NlcnQgJzFtMXQnLCBwcmV0dHkgMzYwMVxyXG5hc3NlcnQgJzJzM3QnLCBwcmV0dHkgMTIzXHJcbmFzc2VydCAnNjBtMzBzJywgcHJldHR5IDYwKjYwKjYwKzMwKjYwXHJcblxyXG5leHBvcnQgcHJldHR5UGFpciA9IChhLGIpIC0+IFxyXG5cdHNlcGFyYXRvciA9IGlmIHByZXR0eShiKSAhPSAnJyB0aGVuICcgKyAnIGVsc2UgJydcclxuXHRwcmV0dHkoYSkgKyBzZXBhcmF0b3IgKyBwcmV0dHkoYilcclxuYXNzZXJ0ICcxbTF0ICsgMnMzdCcsIHByZXR0eVBhaXIgMzYwMSwxMjNcclxuXHJcbmV4cG9ydCBkMiA9ICh4KSAtPlxyXG5cdHggPSBNYXRoLnRydW5jIHhcclxuXHRpZiB4IDwgMTAgdGhlbiAnMCcreCBlbHNlIHhcclxuYXNzZXJ0ICcwMycsIGQyIDNcclxuXHJcbmV4cG9ydCBtc3QgPSAoeCkgLT4gIyB0ZXJ0aWVyXHJcblx0dCA9IHggJSUgNjBcclxuXHR4IC8vPSA2MFxyXG5cdHMgPSB4ICUlIDYwXHJcblx0bSA9IHggLy8gNjBcclxuXHRbbSxzLHRdIFxyXG5hc3NlcnQgWzMsMCwwXSwgbXN0IDMqNjAqNjBcclxuYXNzZXJ0IFszLDAsMzBdLCBtc3QgMTgwKjYwKzMwXHJcblxyXG5leHBvcnQgZ2V0T3JhbmdlID0gLT5cclxuXHRnID0gZ2xvYmFsc1xyXG5cdGdzID0gZy5zZXR0aW5nc1xyXG5cdGdzLm1ha2VIYW5kaWNhcCgpXHJcblx0Z3NwID0gZ3MucGxheWVyc1xyXG5cdGlmIGcuYml0cy5oYW5kaWNhcC5uciA9PSAwIHRoZW4gJycgZWxzZSBwcmV0dHlQYWlyIGdzcFswXVswXSwgZ3NwWzBdWzFdXHJcblxyXG5leHBvcnQgZ2V0V2hpdGUgPSAtPiBnbG9iYWxzLnNldHRpbmdzLmNvbXBhY3QoKVxyXG5cclxuZXhwb3J0IGdldEdyZWVuID0gLT4gXHJcblx0ZyA9IGdsb2JhbHNcclxuXHRncyA9IGcuc2V0dGluZ3NcclxuXHRncy5tYWtlSGFuZGljYXAoKVxyXG5cdGdzcCA9IGdsb2JhbHMuc2V0dGluZ3MucGxheWVyc1xyXG5cdGlmIGcuYml0cy5oYW5kaWNhcC5uciA9PSAwIHRoZW4gJycgZWxzZSBwcmV0dHlQYWlyIGdzcFsxXVswXSwgZ3NwWzFdWzFdXHJcbiJdfQ==
//# sourceURL=c:\github\2022-007-StateLab\coffee\globals.coffee