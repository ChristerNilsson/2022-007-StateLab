// Generated by CoffeeScript 2.5.1
import {
  globals,
  clone,
  getLocalCoords,
  createState,
  pretty,
  prettyPair,
  d2,
  mst
} from '/js/globals.js';

import {
  getOrange,
  getWhite,
  getGreen
} from '/js/globals.js';

export var CSettings = class CSettings {
  constructor() {
    console.log(localStorage.settings ? "load" : "default");
    if (localStorage.settings) {
      Object.assign(this, JSON.parse(localStorage.settings));
    }
    this.bits || (this.bits = {
      minutes: 3,
      seconds: 2,
      handicap: 0,
      number960: 518
    });
    this.bonus || (this.bonus = [
      '',
      '' // redundant, sparar tid
    ]);
    this.bonuses || (this.bonuses = [
      2 * 60,
      2 * 60 // tertier, redundant, sparar tid
    ]);
    this.chess960 || (this.chess960 = 'RNBQKBNR'); // redundant, sparar tid
    this.clocks || (this.clocks = [
      180 * 60,
      180 * 60 // tertier
    ]);
    this.info || (this.info = {
      orange: '',
      white: '3+2',
      green: '' // redundant, sparar tid
    });
    this.paused = true;
    this.player || (this.player = -1);
    this.timeout || (this.timeout = false);
    // Dessa fyra objekt vill man inte spara i localStorage
    this.settings2bits();
    this.makeHandicap();
    this.save(0);
  }

  bits2settings() {
    var gb;
    gb = globals.bits;
    this.bits.minutes = gb.minutes.nr;
    this.bits.seconds = gb.seconds.nr;
    this.bits.handicap = gb.handicap.nr;
    return this.bits.number960 = gb.number960.nr;
  }

  settings2bits() {
    var gb;
    gb = globals.bits;
    gb.minutes.setNr(this.bits.minutes);
    gb.seconds.setNr(this.bits.seconds);
    gb.handicap.setNr(this.bits.handicap);
    return gb.number960.setNr(this.bits.number960);
  }

  backup() {
    this.bits2settings();
    return globals.backup = clone(this); // kopierar TILL backup
  }

  restore() {
    Object.assign(this, globals.backup); // kopierar FRÅN backup
    return this.settings2bits();
  }

  tick() {
    var c;
    if (this.paused) {
      return;
    }
    c = this.clocks[this.player];
    if (c > 0) {
      c -= 60 / frameRate();
    }
    if (c <= 0) {
      c = 0;
      this.timeout = true;
      this.paused = true;
    }
    return this.clocks[this.player] = c;
  }

  save() {
    var d, lastStorageSave;
    d = new Date();
    if (d - lastStorageSave < globals.HEARTBEAT) { // ms
      return;
    }
    lastStorageSave = d;
    this.bits2settings();
    return localStorage.settings = JSON.stringify(this);
  }

  compact() {
    var g, gb, header, header0, header1;
    header0 = '';
    header1 = '';
    g = globals;
    gb = g.bits;
    if (gb.minutes.nr > 0) {
      header0 += gb.minutes.nr;
    }
    if (gb.seconds.nr > 0) {
      header1 += gb.seconds.nr;
    }
    header = header0;
    if (header1.length > 0) {
      header += '+' + header1;
    }
    if (gb.handicap.nr > 0) {
      header += `\n(${gb.handicap.nr})`;
    }
    return header;
  }

  makeHandicap() {
    var bonus, g, gb, hcp, refl;
    g = globals;
    gb = g.bits;
    hcp = gb.handicap.nr / 60; // 0/60 to 59/60
    refl = g.MINUTE * gb.minutes.nr; // tertier
    bonus = g.SEC * gb.seconds.nr; // tertier
    this.players = [];
    this.players[0] = [refl + refl * hcp, bonus + bonus * hcp];
    return this.players[1] = [refl - refl * hcp, bonus - bonus * hcp];
  }

  ok() {
    var g, gs;
    g = globals;
    gs = g.settings;
    this.makeHandicap();
    this.clocks = [this.players[0][0], this.players[1][0]];
    this.bonuses = [this.players[0][1], this.players[1][1]];
    this.bonus = ['+' + pretty(gs.bonuses[0]), '+' + pretty(gs.bonuses[1])];
    this.info.orange = getOrange();
    this.info.white = getWhite();
    this.info.green = getGreen();
    this.timeout = false;
    this.paused = true;
    return this.player = -1;
  }

  cancel() {
    this.restore();
    return this.paused = true;
  }

};

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoic2V0dGluZ3MuanMiLCJzb3VyY2VSb290IjoiLi4iLCJzb3VyY2VzIjpbImNvZmZlZVxcc2V0dGluZ3MuY29mZmVlIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7QUFBQSxPQUFBO0VBQVEsT0FBUjtFQUFnQixLQUFoQjtFQUFzQixjQUF0QjtFQUFxQyxXQUFyQztFQUFpRCxNQUFqRDtFQUF3RCxVQUF4RDtFQUFtRSxFQUFuRTtFQUFzRSxHQUF0RTtDQUFBLE1BQUE7O0FBQ0EsT0FBQTtFQUFRLFNBQVI7RUFBa0IsUUFBbEI7RUFBMkIsUUFBM0I7Q0FBQSxNQUFBOztBQUVBLE9BQUEsSUFBYSxZQUFOLE1BQUEsVUFBQTtFQUNOLFdBQWMsQ0FBQSxDQUFBO0lBQ2IsT0FBTyxDQUFDLEdBQVIsQ0FBZSxZQUFZLENBQUMsUUFBaEIsR0FBOEIsTUFBOUIsR0FBMEMsU0FBdEQ7SUFDQSxJQUFHLFlBQVksQ0FBQyxRQUFoQjtNQUE4QixNQUFNLENBQUMsTUFBUCxDQUFjLElBQWQsRUFBaUIsSUFBSSxDQUFDLEtBQUwsQ0FBVyxZQUFZLENBQUMsUUFBeEIsQ0FBakIsRUFBOUI7O0lBQ0EsSUFBQyxDQUFBLFNBQUQsSUFBQyxDQUFBLE9BQVM7TUFBQyxPQUFBLEVBQVEsQ0FBVDtNQUFZLE9BQUEsRUFBUSxDQUFwQjtNQUF1QixRQUFBLEVBQVMsQ0FBaEM7TUFBbUMsU0FBQSxFQUFVO0lBQTdDO0lBQ1YsSUFBQyxDQUFBLFVBQUQsSUFBQyxDQUFBLFFBQVU7TUFBQyxFQUFEO01BQUksRUFBSjs7SUFDWCxJQUFDLENBQUEsWUFBRCxJQUFDLENBQUEsVUFBWTtNQUFDLENBQUEsR0FBRSxFQUFIO01BQU0sQ0FBQSxHQUFFLEVBQVI7O0lBQ2IsSUFBQyxDQUFBLGFBQUQsSUFBQyxDQUFBLFdBQWEsWUFMaEI7SUFNRSxJQUFDLENBQUEsV0FBRCxJQUFDLENBQUEsU0FBVztNQUFDLEdBQUEsR0FBSSxFQUFMO01BQVEsR0FBQSxHQUFJLEVBQVo7O0lBQ1osSUFBQyxDQUFBLFNBQUQs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QUFNLEdBQWhDO0VBUkE7O0VBVWYsRUFBSyxDQUFBLENBQUE7QUFDTixRQUFBLENBQUEsRUFBQTtJQUFFLENBQUEsR0FBSTtJQUNKLEVBQUEsR0FBSyxDQUFDLENBQUM7SUFDUCxJQUFDLENBQUEsWUFBRCxDQUFBO0lBQ0EsSUFBQyxDQUFBLE1BQUQsR0FBVyxDQUFDLElBQUMsQ0FBQSxPQUFPLENBQUMsQ0FBRCxDQUFHLENBQUMsQ0FBRCxDQUFaLEVBQWlCLElBQUMsQ0FBQSxPQUFPLENBQUMsQ0FBRCxDQUFHLENBQUMsQ0FBRCxDQUE1QjtJQUNYLElBQUMsQ0FBQSxPQUFELEdBQVcsQ0FBQyxJQUFDLENBQUEsT0FBTyxDQUFDLENBQUQsQ0FBRyxDQUFDLENBQUQsQ0FBWixFQUFpQixJQUFDLENBQUEsT0FBTyxDQUFDLENBQUQsQ0FBRyxDQUFDLENBQUQsQ0FBNUI7SUFDWCxJQUFDLENBQUEsS0FBRCxHQUFTLENBQUMsR0FBQSxHQUFNLE1BQUEsQ0FBTyxFQUFFLENBQUMsT0FBTyxDQUFDLENBQUQsQ0FBakIsQ0FBUCxFQUE4QixHQUFBLEdBQU0sTUFBQSxDQUFPLEVBQUUsQ0FBQyxPQUFPLENBQUMsQ0FBRCxDQUFqQixDQUFwQztJQUNULElBQUMsQ0FBQSxJQUFJLENBQUMsTUFBTixHQUFlLFNBQUEsQ0FBQTtJQUNmLElBQUMsQ0FBQSxJQUFJLENBQUMsS0FBTixHQUFjLFFBQUEsQ0FBQTtJQUNkLElBQUMsQ0FBQSxJQUFJLENBQUMsS0FBTixHQUFjLFFBQUEsQ0FBQTtJQUNkLElBQUMsQ0FBQSxPQUFELEdBQVc7SUFDWCxJQUFDLENBQUEsTUFBRCxHQUFVO1dBQ1YsSUFBQyxDQUFBLE1BQUQsR0FBVSxDQUFDO0VBWlA7O0VBY0wsTUFBUyxDQUFBLENBQUE7SUFDUixJQUFDLENBQUEsT0FBRCxDQUFBO1dBQ0EsSUFBQyxDQUFBLE1BQUQsR0FBVTtFQUZGOztBQTlGSCIsInNvdXJjZXNDb250ZW50IjpbImltcG9ydCB7Z2xvYmFscyxjbG9uZSxnZXRMb2NhbENvb3JkcyxjcmVhdGVTdGF0ZSxwcmV0dHkscHJldHR5UGFpcixkMixtc3R9IGZyb20gJy9qcy9nbG9iYWxzLmpzJ1xyXG5pbXBvcnQge2dldE9yYW5nZSxnZXRXaGl0ZSxnZXRHcmVlbn0gZnJvbSAnL2pzL2dsb2JhbHMuanMnXHJcblxyXG5leHBvcnQgY2xhc3MgQ1NldHRpbmdzIFxyXG5cdGNvbnN0cnVjdG9yIDogLT4gXHJcblx0XHRjb25zb2xlLmxvZyBpZiBsb2NhbFN0b3JhZ2Uuc2V0dGluZ3MgdGhlbiBcImxvYWRcIiBlbHNlIFwiZGVmYXVsdFwiXHJcblx0XHRpZiBsb2NhbFN0b3JhZ2Uuc2V0dGluZ3MgdGhlbiBPYmplY3QuYXNzaWduIEAsIEpTT04ucGFyc2UgbG9jYWxTdG9yYWdlLnNldHRpbmdzXHJcblx0XHRAYml0cyB8fD0ge21pbnV0ZXM6Mywgc2Vjb25kczoyLCBoYW5kaWNhcDowLCBudW1iZXI5NjA6NTE4fVxyXG5cdFx0QGJvbnVzIHx8PSBbJycsJyddICMgcmVkdW5kYW50LCBzcGFyYXIgdGlkXHJcblx0XHRAYm9udXNlcyB8fD0gWzIqNjAsMio2MF0gIyB0ZXJ0aWVyLCByZWR1bmRhbnQsIHNwYXJhciB0aWRcclxuXHRcdEBjaGVzczk2MCB8fD0gJ1JOQlFLQk5SJyAjIHJlZHVuZGFudCwgc3BhcmFyIHRpZFxyXG5cdFx0QGNsb2NrcyB8fD0gWzE4MCo2MCwxODAqNjBdICMgdGVydGllclxyXG5cdFx0QGluZm8gfHw9IHtvcmFuZ2U6JycsIHdoaXRlOiczKzInLCBncmVlbjonJ30gIyByZWR1bmRhbnQsIHNwYXJhciB0aWRcclxuXHRcdEBwYXVzZWQgPSB0cnVlXHJcblx0XHRAcGxheWVyIHx8PSAtMVxyXG5cdFx0QHRpbWVvdXQgfHw9IGZhbHNlXHJcblxyXG5cdFx0IyBEZXNzYSBmeXJhIG9iamVrdCB2aWxsIG1hbiBpbnRlIHNwYXJhIGkgbG9jYWxTdG9yYWdlXHJcblx0XHRAc2V0dGluZ3MyYml0cygpXHJcblx0XHRAbWFrZUhhbmRpY2FwKClcclxuXHRcdEBzYXZlKDApXHJcblxyXG5cdGJpdHMyc2V0dGluZ3MgOiAtPlxyXG5cdFx0Z2IgPSBnbG9iYWxzLmJpdHNcclxuXHRcdEBiaXRzLm1pbnV0ZXMgICA9IGdiLm1pbnV0ZXMubnJcclxuXHRcdEBiaXRzLnNlY29uZHMgICA9IGdiLnNlY29uZHMubnJcclxuXHRcdEBiaXRzLmhhbmRpY2FwICA9IGdiLmhhbmRpY2FwLm5yXHJcblx0XHRAYml0cy5udW1iZXI5NjAgPSBnYi5udW1iZXI5NjAubnJcclxuXHRcclxuXHRzZXR0aW5nczJiaXRzIDogLT5cclxuXHRcdGdiID0gZ2xvYmFscy5iaXRzXHJcblx0XHRnYi5taW51dGVzLnNldE5yICAgQGJpdHMubWludXRlc1xyXG5cdFx0Z2Iuc2Vjb25kcy5zZXROciAgIEBiaXRzLnNlY29uZHNcclxuXHRcdGdiLmhhbmRpY2FwLnNldE5yICBAYml0cy5oYW5kaWNhcFxyXG5cdFx0Z2IubnVtYmVyOTYwLnNldE5yIEBiaXRzLm51bWJlcjk2MFxyXG5cclxuXHRiYWNrdXAgOiAtPlxyXG5cdFx0QGJpdHMyc2V0dGluZ3MoKVxyXG5cdFx0Z2xvYmFscy5iYWNrdXAgPSBjbG9uZSBAICMga29waWVyYXIgVElMTCBiYWNrdXBcclxuXHJcblx0cmVzdG9yZSA6IC0+XHJcblx0XHRPYmplY3QuYXNzaWduIEAsZ2xvYmFscy5iYWNrdXAgIyBrb3BpZXJhciBGUsOFTiBiYWNrdXBcclxuXHRcdEBzZXR0aW5nczJiaXRzKClcclxuXHJcblx0dGljayA6IC0+XHJcblx0XHRpZiBAcGF1c2VkIHRoZW4gcmV0dXJuXHJcblx0XHRjID0gQGNsb2Nrc1tAcGxheWVyXVxyXG5cdFx0aWYgYyA+IDAgdGhlbiBjIC09IDYwL2ZyYW1lUmF0ZSgpXHJcblx0XHRpZiBjIDw9IDBcclxuXHRcdFx0YyA9IDBcclxuXHRcdFx0QHRpbWVvdXQgPSB0cnVlXHJcblx0XHRcdEBwYXVzZWQgPSB0cnVlXHJcblx0XHRAY2xvY2tzW0BwbGF5ZXJdID0gY1xyXG5cclxuXHRzYXZlIDogLT5cclxuXHRcdGQgPSBuZXcgRGF0ZSgpXHJcblx0XHRpZiBkIC0gbGFzdFN0b3JhZ2VTYXZlIDwgZ2xvYmFscy5IRUFSVEJFQVQgdGhlbiByZXR1cm4gIyBtc1xyXG5cdFx0bGFzdFN0b3JhZ2VTYXZlID0gZFxyXG5cdFx0QGJpdHMyc2V0dGluZ3MoKVxyXG5cdFx0bG9jYWxTdG9yYWdlLnNldHRpbmdzID0gSlNPTi5zdHJpbmdpZnkgQFxyXG5cclxuXHRjb21wYWN0IDogLT5cclxuXHRcdGhlYWRlcjAgPSAnJ1xyXG5cdFx0aGVhZGVyMSA9ICcnXHJcblx0XHRnID0gZ2xvYmFsc1xyXG5cdFx0Z2IgPSBnLmJpdHNcclxuXHRcdGlmIGdiLm1pbnV0ZXMubnIgPiAwIHRoZW4gaGVhZGVyMCArPSBnYi5taW51dGVzLm5yXHJcblx0XHRpZiBnYi5zZWNvbmRzLm5yID4gMCB0aGVuIGhlYWRlcjEgKz0gZ2Iuc2Vjb25kcy5uclxyXG5cdFx0aGVhZGVyID0gaGVhZGVyMFxyXG5cdFx0aWYgaGVhZGVyMS5sZW5ndGggPiAwIHRoZW4gaGVhZGVyICs9ICcrJyArIGhlYWRlcjFcclxuXHRcdGlmIGdiLmhhbmRpY2FwLm5yID4gMCB0aGVuIGhlYWRlciArPSBcIlxcbigje2diLmhhbmRpY2FwLm5yfSlcIlxyXG5cdFx0aGVhZGVyXHJcblxyXG5cdG1ha2VIYW5kaWNhcCA6IC0+XHJcblx0XHRnID0gZ2xvYmFsc1xyXG5cdFx0Z2IgPSBnLmJpdHNcclxuXHRcdGhjcCA9IGdiLmhhbmRpY2FwLm5yIC8gNjAgIyAwLzYwIHRvIDU5LzYwXHJcblx0XHRyZWZsICA9IGcuTUlOVVRFICogZ2IubWludXRlcy5uciAjIHRlcnRpZXJcclxuXHRcdGJvbnVzID0gICAgZy5TRUMgKiBnYi5zZWNvbmRzLm5yICMgdGVydGllclxyXG5cdFx0QHBsYXllcnMgPSBbXVxyXG5cdFx0QHBsYXllcnNbMF0gPSBbcmVmbCArIHJlZmwqaGNwLCBib251cyArIGJvbnVzKmhjcF1cclxuXHRcdEBwbGF5ZXJzWzFdID0gW3JlZmwgLSByZWZsKmhjcCwgYm9udXMgLSBib251cypoY3BdXHJcblxyXG5cdG9rIDogLT5cclxuXHRcdGcgPSBnbG9iYWxzXHJcblx0XHRncyA9IGcuc2V0dGluZ3NcclxuXHRcdEBtYWtlSGFuZGljYXAoKVxyXG5cdFx0QGNsb2NrcyAgPSBbQHBsYXllcnNbMF1bMF0sIEBwbGF5ZXJzWzFdWzBdXVxyXG5cdFx0QGJvbnVzZXMgPSBbQHBsYXllcnNbMF1bMV0sIEBwbGF5ZXJzWzFdWzFdXVxyXG5cdFx0QGJvbnVzID0gWycrJyArIHByZXR0eShncy5ib251c2VzWzBdKSwgJysnICsgcHJldHR5KGdzLmJvbnVzZXNbMV0pXVxyXG5cdFx0QGluZm8ub3JhbmdlID0gZ2V0T3JhbmdlKClcclxuXHRcdEBpbmZvLndoaXRlID0gZ2V0V2hpdGUoKVxyXG5cdFx0QGluZm8uZ3JlZW4gPSBnZXRHcmVlbigpXHJcblx0XHRAdGltZW91dCA9IGZhbHNlXHJcblx0XHRAcGF1c2VkID0gdHJ1ZVxyXG5cdFx0QHBsYXllciA9IC0xXHJcblxyXG5cdGNhbmNlbCA6IC0+IFxyXG5cdFx0QHJlc3RvcmUoKVxyXG5cdFx0QHBhdXNlZCA9IHRydWVcclxuIl19
//# sourceURL=c:\github\2022-007-StateLab\coffee\settings.coffee