# State

* Varje tillstånd måste ha en egen klass
* Ett tillstånd ritas upp m h a ett antal Buttons
* Transition anger vilka knappar som ska ritas upp
* De knappar som leder till nya tillstånd anges mha =>
	* T ex "rubrik ok=>StartState"
	* Knappen **rubrik** går ej att klicka på
	* Knappen **ok** leder till ett nytt tillstånd.

* State-klasserna kan fånga message-händelser för att skräddarsy.
