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
		
	public class RemoveObject extends Tag
	{
		public var depth:int;
		public var ref:DefineTag;
		
		public function RemoveObject(code:int)
		{
			super(code);
		}
		
		public override function visit(h:TagHandler):void
		{
			if (code == stagRemoveObject)
				h.removeObject(this);
			else
				h.removeObject2(this);
		}
		
		public function getSimpleReference():Tag
		{
			return ref;
		}
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is RemoveObject))
			{
				var removeObject:RemoveObject = object as RemoveObject;
				
				if ( (removeObject.depth == this.depth) &&
					objectEquals(removeObject.ref, this.ref) )
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
	}
}