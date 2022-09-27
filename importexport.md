# Import Export

export *class*

export *function*

export *variable*

import { *class*, *function*,*variable* } from './*file*.js'

Använd t ex *globals* för att gruppera globala variabler,
ffa för att exporterade variabler är read only.

* Varje tillstånd representeras av en egen klass
* Varje tillstånd utgör ett formulär
* Ett tillstånd visas grafiskt m h a ett antal kontroller (controls)
	* Dessa kan vara t ex knappar, texter, bilder och annat
	* Kod läggs in i klickhändelserna (se states.coffee)
* Klasserna kommunicerar enbart via globala variabler