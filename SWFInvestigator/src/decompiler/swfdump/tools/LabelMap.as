package decompiler.swfdump.tools
{
	import decompiler.swfdump.actions.Label;
	
	import flash.utils.Dictionary;
	
	internal class LabelMap
	{
		//private static final serialVersionUID:Number = -7907644739362458461L;
		
		private var lMap:Dictionary;
		
		public function getLabelEntry(l:Label):LabelEntry
		{
			if (lMap == null) {
				this.lMap = new Dictionary();
			}
			var entry:LabelEntry = lMap[l];
			if (entry == null)
			{
				entry = new LabelEntry(null,null);
				lMap[l] = entry;
			}
			return entry;
		}
	}
}