package decompiler.tamarin.abcdump
{
	import decompiler.swfdump.TagHandler;
	import decompiler.swfdump.TagValues;

	
	public class Tag extends TagValues
	{		
		public var tName:String;
		public var type:uint;
		public var size:uint;
		public var position:uint;
		//Added by SWF Investigator
		public var longRecordHeader:Boolean;
		public var theTag:*;
		
		//For remembering errors that occur during decoding
		public var SIErrorMessage:String;
		
		public var code:int;
		
		public function Tag(tagCode:int = 0)
		{
			this.code = tagCode;
		}
		
		//For swfdump
		public function visit (h:TagHandler):void {};
		
		public function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (object is Tag)
			{
				var tag:Tag = object as Tag;
				
				if (tag.code == this.code)
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
		
		public function hashCode():int
		{
			return code;
		}
		
		public static function objectEquals (o1:*, o2:*):Boolean
		{
			return o1 == o2 || o1 != null && o1.equals(o2);
		}
	}
}