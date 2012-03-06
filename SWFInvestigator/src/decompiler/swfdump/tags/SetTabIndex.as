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
	import decompiler.swfdump.TagValues;

	public class SetTabIndex extends Tag
	{
		
		public var depth:int;
		public var index:int;
		
		public function SetTabIndex(depth:int, index:int)
		{
			super(TagValues.stagSetTabIndex);
			this.depth = depth;
			this.index = index;
		}
		
		public override function visit(tagHandler:TagHandler):void
		{
			tagHandler.setTabIndex(this);
		}
		
		public override function equals(object:*):Boolean
		{
			if (super.equals(object) && object is SetTabIndex)
			{
				var other:SetTabIndex = object as SetTabIndex;
				return other.depth == this.depth && other.index == this.index;
			}
			else
			{
				return false;
			}
		}
	}
}