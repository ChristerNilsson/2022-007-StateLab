// Generated by CoffeeScript 2.5.1
// TODO
// Försämring av frameRate inträffar om man går från fullscreen till normal på Android

// Istället för sekunder är nu normalformen tertier, 60-dels sekunder
var createState, lastStorageSave, rates, sumRate;

import {
  globals
} from './globals.js';

import {
  CBits
} from './cbits.js';

import {
  CSettings
} from './settings.js';

import {
  SClock,
  SBasic,
  SAdv,
  S960
} from './states.js';

globals.bits = {};

globals.bits.minutes = new CBits([1, 2, 4, 8, 15, 30, 60]);

globals.bits.seconds = new CBits([1, 2, 4, 8, 15, 30, 60]);

globals.bits.handicap = new CBits([1, 2, 4, 8, 15, 30]);

globals.bits.number960 = new CBits([1, 2, 4, 8, 15, 30, 60, 120, 240, 480]);

globals.chess = {};

lastStorageSave = new Date();

rates = [];

sumRate = 0;

createState = function(key, klass) {
  return globals.states[key] = new klass(key);
};

//############### p5 ###################
window.preload = function() {
  var i, len, ltr, ref, results;
  globals.qr = loadImage('media\\qr.png');
  globals.sound = loadSound('media\\key.mp3');
  ref = "KQRBN";
  results = [];
  for (i = 0, len = ref.length; i < len; i++) {
    ltr = ref[i];
    results.push(globals.chess[ltr] = loadImage(`media\\chess\\${ltr}.png`));
  }
  return results;
};

window.windowResized = function() {
  return resizeCanvas(innerWidth, innerHeight);
};

window.setup = function() {
  var canvas;
  globals.settings = new CSettings(globals.bits);
  frameRate(globals.FRAMERATE);
  globals.os = navigator.appVersion;
  if (globals.os.indexOf('Linux') >= 0) {
    globals.os = 'Android';
  }
  if (globals.os.indexOf('Windows') >= 0) {
    globals.os = 'Windows';
  }
  if (globals.os.indexOf('Mac') >= 0) {
    globals.os = 'Mac';
  }
  canvas = createCanvas(innerWidth, innerHeight);
  bodyScrollLock.disableBodyScroll(canvas); // Förhindrar att man kan scrolla canvas på iOS
  if (globals.os === 'Android') {
    textFont('Droid Sans');
  }
  if (globals.os === 'Mac') {
    textFont('Verdana');
  }
  if (globals.os === 'Windows') {
    textFont('Lucida Sans Unicode');
  }
  globals.TOGGLE = globals.os === 'Mac' ? 1 : 0;
  background('black');
  textAlign(CENTER, CENTER);
  rectMode(CENTER);
  angleMode(DEGREES);
  createState('SClock', SClock);
  createState('SAdv', SAdv);
  createState('SBasic', SBasic);
  createState('S960', S960);
  globals.currState = globals.states.SClock;
  push();
  textSize(18 + 9);
  globals.tw = textWidth('0');
  return pop();
};

window.mousePressed = function() {
  if (globals.os === 'Windows') {
    return globals.currState.mouseClicked();
  }
};

window.touchStarted = function() {
  if (globals.os !== 'Windows') {
    return globals.currState.mouseClicked();
  }
};

window.draw = function() {
  var aspect;
  if (globals.TOGGLE === 0) {
    scale(width / 100, height / 100); // portrait
  } else {
    rotate(90);
    translate(0, -width);
    scale(height / 100, width / 100); // Landscape
  }
  strokeWeight(100 / height);
  push();
  background('black');
  globals.settings.tick();
  globals.currState.draw();
  pop();
  globals.settings.save(); // SKUM?
  return aspect = function(w, h, y) {
    if (w < h) {
      [w, h] = [h, w];
    }
    return text(`${w} ${(w / h).toFixed(3)} ${h}`, 50, y);
  };
};

//textSize 3
//fill 'yellow'
// gb = globals.bits
// gs = globals.settings
// gsi = gs.info
// text "mst #{gb.minutes.nr} #{gb.seconds.nr} #{gb.handicap.nr}",50,60
// text gs.players,50,65
// text Math.round(gs.clocks[0]) + ' ' + Math.round(gs.clocks[1]),50,70
// text gs.bonuses,50,75
// text gsi.orange,50,80
// text gsi.white,50,85
// text gsi.green,50,90

//for i in range globals.logg.length
//	text globals.logg[i],50,3*(i+1)

//text 'J',5,95

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoic2tldGNoLmpzIiwic291cmNlUm9vdCI6Ii4uIiwic291cmNlcyI6WyJjb2ZmZWVcXHNrZXRjaC5jb2ZmZWUiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IjtBQUdvRTs7OztBQUFBLElBQUEsV0FBQSxFQUFBLGVBQUEsRUFBQSxLQUFBLEVBQUE7O0FBRXBFLE9BQUE7RUFBUSxPQUFSO0NBQUEsTUFBQTs7QUFDQSxPQUFBO0VBQVEsS0FBUjtDQUFBLE1BQUE7O0FBQ0EsT0FBQTtFQUFRLFNBQVI7Q0FBQSxNQUFBOztBQUNBLE9BQUE7RUFBUSxNQUFSO0VBQWUsTUFBZjtFQUFzQixJQUF0QjtFQUEyQixJQUEzQjtDQUFBLE1BQUE7O0FBRUEsT0FBTyxDQUFDLElBQVIsR0FBZSxDQUFBOztBQUNmLE9BQU8sQ0FBQyxJQUFJLENBQUMsT0FBYixHQUF5QixJQUFJLEtBQUosQ0FBVSxDQUFDLENBQUQsRUFBRyxDQUFILEVBQUssQ0FBTCxFQUFPLENBQVAsRUFBUyxFQUFULEVBQVksRUFBWixFQUFlLEVBQWYsQ0FBVjs7QUFDekIsT0FBTyxDQUFDLElBQUksQ0FBQyxPQUFiLEdBQXlCLElBQUksS0FBSixDQUFVLENBQUMsQ0FBRCxFQUFHLENBQUgsRUFBSyxDQUFMLEVBQU8sQ0FBUCxFQUFTLEVBQVQsRUFBWSxFQUFaLEVBQWUsRUFBZixDQUFWOztBQUN6QixPQUFPLENBQUMsSUFBSSxDQUFDLFFBQWIsR0FBeUIsSUFBSSxLQUFKLENBQVUsQ0FBQyxDQUFELEVBQUcsQ0FBSCxFQUFLLENBQUwsRUFBTyxDQUFQLEVBQVMsRUFBVCxFQUFZLEVBQVosQ0FBVjs7QUFDekIsT0FBTyxDQUFDLElBQUksQ0FBQyxTQUFiLEdBQXlCLElBQUksS0FBSixDQUFVLENBQUMsQ0FBRCxFQUFHLENBQUgsRUFBSyxDQUFMLEVBQU8sQ0FBUCxFQUFTLEVBQVQsRUFBWSxFQUFaLEVBQWUsRUFBZixFQUFrQixHQUFsQixFQUFzQixHQUF0QixFQUEwQixHQUExQixDQUFWOztBQUV6QixPQUFPLENB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Q0FBQyxDQUFBLEdBQUUsQ0FBSCxDQUFLLENBQUMsT0FBTixDQUFjLENBQWQsQ0FBUixFQUFBLENBQUEsQ0FBNEIsQ0FBNUIsQ0FBQSxDQUFMLEVBQXNDLEVBQXRDLEVBQXlDLENBQXpDO0VBRlE7QUFsQkk7O0FBdEVzRCIsInNvdXJjZXNDb250ZW50IjpbIiMgVE9ET1xyXG4jIEbDtnJzw6RtcmluZyBhdiBmcmFtZVJhdGUgaW50csOkZmZhciBvbSBtYW4gZ8OlciBmcsOlbiBmdWxsc2NyZWVuIHRpbGwgbm9ybWFsIHDDpSBBbmRyb2lkXHJcblxyXG4jIElzdMOkbGxldCBmw7ZyIHNla3VuZGVyIMOkciBudSBub3JtYWxmb3JtZW4gdGVydGllciwgNjAtZGVscyBzZWt1bmRlclxyXG5cclxuaW1wb3J0IHtnbG9iYWxzfSBmcm9tICcuL2dsb2JhbHMuanMnXHJcbmltcG9ydCB7Q0JpdHN9IGZyb20gJy4vY2JpdHMuanMnXHJcbmltcG9ydCB7Q1NldHRpbmdzfSBmcm9tICcuL3NldHRpbmdzLmpzJ1xyXG5pbXBvcnQge1NDbG9jayxTQmFzaWMsU0FkdixTOTYwfSBmcm9tICcuL3N0YXRlcy5qcydcclxuXHJcbmdsb2JhbHMuYml0cyA9IHt9XHJcbmdsb2JhbHMuYml0cy5taW51dGVzICAgPSBuZXcgQ0JpdHMgWzEsMiw0LDgsMTUsMzAsNjBdXHJcbmdsb2JhbHMuYml0cy5zZWNvbmRzICAgPSBuZXcgQ0JpdHMgWzEsMiw0LDgsMTUsMzAsNjBdXHJcbmdsb2JhbHMuYml0cy5oYW5kaWNhcCAgPSBuZXcgQ0JpdHMgWzEsMiw0LDgsMTUsMzBdXHJcbmdsb2JhbHMuYml0cy5udW1iZXI5NjAgPSBuZXcgQ0JpdHMgWzEsMiw0LDgsMTUsMzAsNjAsMTIwLDI0MCw0ODBdXHJcblxyXG5nbG9iYWxzLmNoZXNzID0ge31cclxuXHJcbmxhc3RTdG9yYWdlU2F2ZSA9IG5ldyBEYXRlKClcclxuXHJcbnJhdGVzID0gW11cclxuc3VtUmF0ZSA9IDBcclxuXHJcbmNyZWF0ZVN0YXRlID0gKGtleSxrbGFzcykgLT4gZ2xvYmFscy5zdGF0ZXNba2V5XSA9IG5ldyBrbGFzcyBrZXlcclxuXHJcbiMjIyMjIyMjIyMjIyMjIyMgcDUgIyMjIyMjIyMjIyMjIyMjIyMjI1xyXG5cclxud2luZG93LnByZWxvYWQgPSAtPlxyXG5cdGdsb2JhbHMucXIgPSBsb2FkSW1hZ2UgJ21lZGlhXFxcXHFyLnBuZydcclxuXHRnbG9iYWxzLnNvdW5kID0gbG9hZFNvdW5kICdtZWRpYVxcXFxrZXkubXAzJ1xyXG5cdGZvciBsdHIgaW4gXCJLUVJCTlwiXHJcblx0XHRnbG9iYWxzLmNoZXNzW2x0cl0gPSBsb2FkSW1hZ2UgXCJtZWRpYVxcXFxjaGVzc1xcXFwje2x0cn0ucG5nXCJcclxuXHJcbndpbmRvdy53aW5kb3dSZXNpemVkID0gLT4gcmVzaXplQ2FudmFzIGlubmVyV2lkdGgsIGlubmVySGVpZ2h0XHJcblxyXG53aW5kb3cuc2V0dXAgPSAtPlxyXG5cdGdsb2JhbHMuc2V0dGluZ3MgPSBuZXcgQ1NldHRpbmdzIGdsb2JhbHMuYml0c1xyXG5cclxuXHRmcmFtZVJhdGUgZ2xvYmFscy5GUkFNRVJBVEVcclxuXHRnbG9iYWxzLm9zID0gbmF2aWdhdG9yLmFwcFZlcnNpb25cclxuXHRpZiBnbG9iYWxzLm9zLmluZGV4T2YoJ0xpbnV4JykgPj0gMCB0aGVuIGdsb2JhbHMub3MgPSAnQW5kcm9pZCdcclxuXHRpZiBnbG9iYWxzLm9zLmluZGV4T2YoJ1dpbmRvd3MnKSA+PSAwIHRoZW4gZ2xvYmFscy5vcyA9ICdXaW5kb3dzJ1xyXG5cdGlmIGdsb2JhbHMub3MuaW5kZXhPZignTWFjJykgPj0gMCB0aGVuIGdsb2JhbHMub3MgPSAnTWFjJ1xyXG5cclxuXHRjYW52YXMgPSBjcmVhdGVDYW52YXMgaW5uZXJXaWR0aCxpbm5lckhlaWdodFxyXG5cdGJvZHlTY3JvbGxMb2NrLmRpc2FibGVCb2R5U2Nyb2xsIGNhbnZhcyAjIEbDtnJoaW5kcmFyIGF0dCBtYW4ga2FuIHNjcm9sbGEgY2FudmFzIHDDpSBpT1NcclxuXHJcblx0aWYgZ2xvYmFscy5vcyA9PSAnQW5kcm9pZCcgdGhlbiB0ZXh0Rm9udCAnRHJvaWQgU2FucydcclxuXHRpZiBnbG9iYWxzLm9zID09ICdNYWMnIHRoZW4gdGV4dEZvbnQgJ1ZlcmRhbmEnXHJcblx0aWYgZ2xvYmFscy5vcyA9PSAnV2luZG93cycgdGhlbiB0ZXh0Rm9udCAnTHVjaWRhIFNhbnMgVW5pY29kZSdcclxuXHJcblx0Z2xvYmFscy5UT0dHTEUgPSBpZiBnbG9iYWxzLm9zID09ICdNYWMnIHRoZW4gMSBlbHNlIDBcclxuXHJcblx0YmFja2dyb3VuZCAnYmxhY2snXHJcblx0dGV4dEFsaWduIENFTlRFUixDRU5URVJcclxuXHRyZWN0TW9kZSBDRU5URVJcclxuXHRhbmdsZU1vZGUgREVHUkVFU1xyXG5cclxuXHRjcmVhdGVTdGF0ZSAnU0Nsb2NrJywgU0Nsb2NrIFxyXG5cdGNyZWF0ZVN0YXRlICdTQWR2JywgICBTQWR2XHJcblx0Y3JlYXRlU3RhdGUgJ1NCYXNpYycsIFNCYXNpY1xyXG5cdGNyZWF0ZVN0YXRlICdTOTYwJywgICBTOTYwXHJcblx0XHJcblx0Z2xvYmFscy5jdXJyU3RhdGUgPSBnbG9iYWxzLnN0YXRlcy5TQ2xvY2tcclxuXHJcblx0cHVzaCgpXHJcblx0dGV4dFNpemUgMTgrOVxyXG5cdGdsb2JhbHMudHcgPSB0ZXh0V2lkdGggJzAnXHJcblx0cG9wKClcclxuXHJcbndpbmRvdy5tb3VzZVByZXNzZWQgPSAtPiBpZiBnbG9iYWxzLm9zID09ICdXaW5kb3dzJyB0aGVuIGdsb2JhbHMuY3VyclN0YXRlLm1vdXNlQ2xpY2tlZCgpXHJcbndpbmRvdy50b3VjaFN0YXJ0ZWQgPSAtPiBpZiBnbG9iYWxzLm9zICE9ICdXaW5kb3dzJyB0aGVuIGdsb2JhbHMuY3VyclN0YXRlLm1vdXNlQ2xpY2tlZCgpXHJcblxyXG53aW5kb3cuZHJhdyA9IC0+XHJcblxyXG5cdGlmIGdsb2JhbHMuVE9HR0xFID09IDBcclxuXHRcdHNjYWxlIHdpZHRoLzEwMCxoZWlnaHQvMTAwICMgcG9ydHJhaXRcclxuXHRlbHNlXHJcblx0XHRyb3RhdGUgOTBcclxuXHRcdHRyYW5zbGF0ZSAwLC13aWR0aFxyXG5cdFx0c2NhbGUgaGVpZ2h0LzEwMCx3aWR0aC8xMDAgIyBMYW5kc2NhcGVcclxuXHJcblx0c3Ryb2tlV2VpZ2h0IDEwMC9oZWlnaHRcclxuXHRwdXNoKClcclxuXHRiYWNrZ3JvdW5kICdibGFjaydcclxuXHRnbG9iYWxzLnNldHRpbmdzLnRpY2soKVxyXG5cdGdsb2JhbHMuY3VyclN0YXRlLmRyYXcoKVxyXG5cdHBvcCgpXHJcblxyXG5cdGdsb2JhbHMuc2V0dGluZ3Muc2F2ZSgpICMgU0tVTT9cclxuXHJcblx0YXNwZWN0ID0gKHcsaCx5KSAtPlxyXG5cdFx0aWYgdyA8IGggdGhlbiBbdyxoXSA9IFtoLHddXHJcblx0XHR0ZXh0IFwiI3t3fSAjeyh3L2gpLnRvRml4ZWQoMyl9ICN7aH1cIiwgNTAseVxyXG5cclxuXHQjdGV4dFNpemUgM1xyXG5cdCNmaWxsICd5ZWxsb3cnXHJcblx0IyBnYiA9IGdsb2JhbHMuYml0c1xyXG5cdCMgZ3MgPSBnbG9iYWxzLnNldHRpbmdzXHJcblx0IyBnc2kgPSBncy5pbmZvXHJcblx0IyB0ZXh0IFwibXN0ICN7Z2IubWludXRlcy5ucn0gI3tnYi5zZWNvbmRzLm5yfSAje2diLmhhbmRpY2FwLm5yfVwiLDUwLDYwXHJcblx0IyB0ZXh0IGdzLnBsYXllcnMsNTAsNjVcclxuXHQjIHRleHQgTWF0aC5yb3VuZChncy5jbG9ja3NbMF0pICsgJyAnICsgTWF0aC5yb3VuZChncy5jbG9ja3NbMV0pLDUwLDcwXHJcblx0IyB0ZXh0IGdzLmJvbnVzZXMsNTAsNzVcclxuXHQjIHRleHQgZ3NpLm9yYW5nZSw1MCw4MFxyXG5cdCMgdGV4dCBnc2kud2hpdGUsNTAsODVcclxuXHQjIHRleHQgZ3NpLmdyZWVuLDUwLDkwXHJcblxyXG5cdCNmb3IgaSBpbiByYW5nZSBnbG9iYWxzLmxvZ2cubGVuZ3RoXHJcblx0I1x0dGV4dCBnbG9iYWxzLmxvZ2dbaV0sNTAsMyooaSsxKVxyXG5cclxuXHQjdGV4dCAnSicsNSw5NSJdfQ==
//# sourceURL=c:\github\2022-007-StateLab\coffee\sketch.coffee