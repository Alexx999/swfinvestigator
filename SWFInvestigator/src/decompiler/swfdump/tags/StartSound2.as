package decompiler.swfdump.tags
{
	import decompiler.swfdump.TagHandler;
	import decompiler.swfdump.types.SoundInfo;

	public class StartSound2 extends DefineTag
	{
		public function StartSound2()
		{
			super(stagStartSound2);
		}
		
		public override function visit(h:TagHandler):void
		{
			h.startSound2(this);
		}
		
		/**
		 * sound style information
		 */
		public var soundInfo:SoundInfo;
		
		/**
		 * sound class name
		 */
		public var soundClassName:String;
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is StartSound2))
			{
				var startSound2:StartSound2 = object as StartSound2;
				
				if ((startSound2.soundClassName == this.soundClassName) &&
					objectEquals(startSound2.soundInfo, this.soundInfo))
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
	}
}