package sample;
 import prime.signals.Signal1;
 import prime.signals.Signals;

/**
 * MainEvents defines and groups together the events used 
 * in the application and provides a main access point for them. 
 */
class MainEvents extends Signals
{
    public var loadImage:Signal1 < String >;

    public function new ()
    {
        super();
		
		// Instantiate Signal1 that accepts a String as a parameter.
        loadImage = new Signal1();
    }
}