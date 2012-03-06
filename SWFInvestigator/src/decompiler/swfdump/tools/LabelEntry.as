package decompiler.swfdump.tools
{
	import decompiler.swfdump.Action;
	
	internal class LabelEntry
	{
		public var name:String;
		public var source:Action;
		
		public function LabelEntry(name:String, source:Action)
		{
			this.name = name;
			this.source = source;
		}
	}
}