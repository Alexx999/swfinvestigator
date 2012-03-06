package utils.AS3Compiler
{
	import decompiler.Logging.ILog;
	
	/**
	 * ESC can't handle dotted packages well yet.
	 * Make testing easier by having a package-less class with a few static functions in it.
	 */
	public class Printer
	{
		static private var _logger:ILog = null;
		static public function set logger(value:ILog):void {
			_logger = value;
		}
		
		public static function print(...args):void {
			var s:String = args.join(" - ");
			if (_logger!=null) {
				_logger.print(s);
			}
		}
	}
}