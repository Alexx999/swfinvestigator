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
	import decompiler.swfdump.TagHandler;
	
	public class SetBackgroundColor extends Tag
	{
		
		public function SetBackgroundColor(color:int = 0)
		{
			super(stagSetBackgroundColor);
			this.color = color;
		}
		
		public override function visit(h:TagHandler):void
		{
			h.setBackgroundColor(this);
		}
		
		/** color as int: 0x00RRGGBB */
		public var color:int;
		
		public override function hashCode():int
		{
			return super.hashCode() ^ color;
		}
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is SetBackgroundColor))
			{
				var setBackgroundColor:SetBackgroundColor = object as SetBackgroundColor;
				
				if (setBackgroundColor.color == this.color)
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
	}
}