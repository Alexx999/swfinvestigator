package decompiler.swfdump.types
{
	public final class PushNum
	{
		public var type:String;
		public var num:Number;
		
		//Used for Float, Byte, Double and Short
		public function PushNum(typeName:String, val:Number)
		{
			this.type = typeName;
			this.num = val;
		}
	}
}