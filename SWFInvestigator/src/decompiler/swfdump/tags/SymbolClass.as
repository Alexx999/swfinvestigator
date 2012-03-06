////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package decompiler.swfdump.tags
{
	import decompiler.swfdump.TagHandler;
	import decompiler.tamarin.abcdump.Tag;
	
	public class SymbolClass extends Tag
	{
		public function SymbolClass()
		{
			super(stagSymbolClass);
		}
		
		public override function visit(h:TagHandler):void
		{
			h.symbolClass(this);
		}
		
		
		//public Map<String, Tag> class2tag = new HashMap<String, Tag>();
		public var class2tag:Object = new Object();
		public var topLevelClass:String;
		
		//Added by SWF Investigator
		public var class2idref:Object = new Object();
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is SymbolClass))
			{
				var symbolClasses:SymbolClass = object as SymbolClass;
				
				if ( objectEquals(symbolClasses.class2tag, this.class2tag) )
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
	}
}