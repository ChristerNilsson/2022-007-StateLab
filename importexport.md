# Import Export

export *class*

export *function*

export *variable*

import { *class*, *function*,*variable* } from './*file*.js'

Använder *globals* för att gruppera globala variabler,
ffa för att exporterade variabler är read only.

* Varje tillstånd representeras av en egen klass
* Varje tillstånd utgör ett formulär
* Ett tillstånd ritas upp m h a ett antal kontroller (controls)
	* Dessa kan vara t ex knappar, texter, bilder och annat
	* Kod läggs in i klickhändelserna
* Klasserna kommunicerar enbart via settings, dvs globala variabler