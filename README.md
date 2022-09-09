# 2022-006-StateLab

## Chess clock.
* Click on the numbers and add together.
* Only white texts are clickable.

## Handicap system.
* Default is no handicap.
* The handicap is based on ELO rating difference, with a maximum of 1200.
* The total time is the same, before and after the handicap.
* Current steepness is 20. Contact me if you prefer another value.

### Example:
* You have decided on a game using 10m + 5s.
* Select an ELO rating difference.
* Using 120 (40+80), a tenth (120/1200) of the time will move to the other player.
* The adjusted times will be 11m + 5.5s and 9m + 4.5s

### How to enter numbers
```
1
2
3 = 1 + 2
4
5 = 1 + 4
6 = 2 + 4
7 = 1 + 2 + 4
8
9 = 1 + 8
10 = 2 + 8
11 = 1 + 2 + 8
12 = 4 + 8
13 = 1 + 4 + 8
14 = 2 + 4 + 8
15
..
59 = 2 + 4 + 8 + 15 + 30

Multiply with 20 using handicap
```

### The QR code
* Contains the URL for the application.
* Use your camera or QR reader app.
* Optimized for Android

### Definitions
* reflection = the time you have left
* bonus = time that will be added for every move. (Fischer System)
* hcp = handicap. Expressed in ELO rating difference.
* swap. When using handicap, swaps the times for the players.
* h = hour 0 .. 60
* m = minute 0 .. 60
* s = second 0 .. 60
* elo = handicap 0 .. 1200

### Repeat Game
* Click **pause**
* Click **new**
* Click **ok**
* Click one of the players.

###
Example table
```
The effect on 1h - 1h, using different handicaps.
 ELO difference 
   0            1h - 1h
 100           55m - 1h5m
 200           50m - 1h10m
 300           45m - 1h15m
 400           40m - 1h20m
 500           35m - 1h25m
 600           30m - 1h30m
 700           25m - 1h35m
 800           20m - 1h40m
 900           15m - 1h45m
1000           10m - 1h50m
1100            5m - 1h55m
1200            0m - 2h

Bonus times are also handicapped.
```