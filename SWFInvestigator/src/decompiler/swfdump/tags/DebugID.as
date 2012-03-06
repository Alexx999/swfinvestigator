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
	import decompiler.tamarin.abcdump.Tag;
	import decompiler.swfdump.TagValues;
	import decompiler.swfdump.types.FlashUUID;
	import decompiler.swfdump.TagHandler;
	
	public class DebugID extends Tag
	{
		public var uuid:FlashUUID;
		
		public function DebugID(code:*)
		{
			var tValues:TagValues = new TagValues();
			var ret:int;
			
			if (code is FlashUUID) {
				this.uuid = code;
				ret = TagValues.stagDebugID;
			} else {
				ret = code
			}
			
			super (ret);
		}
		
		public override function visit(h:TagHandler):void
		{
			h.debugID(this);
		}
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is DebugID))
			{
				var debugID:DebugID = object as DebugID;
				
				if ( debugID.uuid.equals(this.uuid))
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
		
	}
}