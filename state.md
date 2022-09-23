# State

* Varje tillstånd representeras av en egen klass
* Varje tillstånd utgör ett formulär
* Ett tillstånd ritas upp m h a ett antal kontroller (controls)
	* Dessa kan vara t ex knappar, texter, bilder och annat
* Transitions anger vilka tillstånd klickbara kontroller leder till
	* Transitioner kan leda tillbaks till samma tillstånd
* Ett tillstånd följs av de kontroller som leder till den.
	* T ex "SBasic: basic StartState: ok cancel"
	* Tillståndet SBasic är målet för kontrollen **basic**
	* Tillståndet StartState är målet för kontrollerna **ok** och **cancel**
* Varje transition innebär att ett meddelande skickas.
* State-klasserna fångar dessa meddelanden där man kan lägga in logik
	* Meddelandena utgörs av kontrollernas namn

Att fundera på:

Ska meddelandet hanteras i det sändande eller mottagande tillståndet?
