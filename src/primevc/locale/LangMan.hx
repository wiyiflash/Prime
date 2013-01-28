package primevc.locale;
 import prime.signal.Signal0;


/**
 * ...
 * @author EzeQL
 */
@:build(primevc.locale.LangMacro.build())
class LangMan
{
	public static var instance	(getInstance, null) : LangMan;
		private static function getInstance()
			return (instance == null ? instance = new LangMan() : instance)

	public var current			(default, null) : ILang;
	public var change			(default, null) : Signal0;
	public var bindables		(default, null) : LangManBindables; //class generated by a macro
	
	public function new() {
		change = new Signal0();
		bindables = new LangManBindables();
	}
}

