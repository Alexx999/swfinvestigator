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
	import decompiler.swfdump.types.ActionList;
	import decompiler.tamarin.abcdump.Tag;
	import decompiler.swfdump.TagHandler;

	public class DoAction extends Tag
	{
		public var actionList:ActionList;
		
		public function DoAction(actions:ActionList = null)
		{
			super(stagDoAction);
			this.actionList = actions;
		}
		
		public override function visit(h:TagHandler):void
		{
			h.doAction(this);
		}
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is DoAction))
			{
				var doAction:DoAction = object as DoAction;
				
				if ( objectEquals(doAction.actionList, this.actionList) )
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
		
		public override function hashCode():int {
			var hashCode:int = super.hashCode();
			hashCode += DefineTag.PRIME * actionList.size();
			return hashCode;
		}
	}
}