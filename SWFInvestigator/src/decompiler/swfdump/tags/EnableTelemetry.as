package decompiler.swfdump.tags
{
	import decompiler.swfdump.TagHandler;
	
	import flash.utils.ByteArray;

	public class EnableTelemetry extends DefineTag
	{
		public var reserved:uint;
		public var passwordHash:ByteArray;
		
		public function EnableTelemetry()
		{
			super(stagEnableTelemetry);
		}
		
		public override function visit(h:TagHandler):void
		{
			h.enableTelemetry(this);
		}
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = true;
			
			if (super.equals(object) && (object is EnableTelemetry))
			{
				var enableTelemetry:EnableTelemetry = object as EnableTelemetry;
				
				for (var i:int = 0; i<32; i++) {
					if (enableTelemetry.passwordHash[i] != this.passwordHash[i]) {
						isEqual = false;
					}
				}
				
				if (enableTelemetry.reserved != this.reserved) {
					isEqual = false;
				}
			} else {
				isEqual = false;
			}
			
			return(isEqual);
		}
	}
}