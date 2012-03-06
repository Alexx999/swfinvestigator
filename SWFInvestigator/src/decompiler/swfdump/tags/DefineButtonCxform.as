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
	import decompiler.swfdump.types.CXForm;
	
	public class DefineButtonCxform extends Tag
	{
		public var button:DefineButton;
		public var colorTransform:CXForm;
		
		public function DefineButtonCxform()
		{
			super(stagDefineButtonCxform);
		}
		
		public override function visit(h:TagHandler):void
		{
			h.defineButtonCxform(this);
		}
		
		protected function getSimpleReference():Tag
		{
			return button;
		}
			
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is DefineButtonCxform))
			{
				var defineButtonCxform:DefineButtonCxform = object as DefineButtonCxform;
				
				if ( objectEquals(defineButtonCxform.button, this.button) &&
					objectEquals(defineButtonCxform.colorTransform, this.colorTransform))
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
	}
}