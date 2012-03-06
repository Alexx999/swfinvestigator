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

package decompiler.swfdump.actions
{
	import decompiler.swfdump.Action;
	import decompiler.swfdump.ActionConstants;
	import decompiler.swfdump.ActionHandler;
	import decompiler.swfdump.types.ActionList;
	
	public class Label extends Action
	{
		public function Label()
		{
			super(ActionList.sactionLabel);
		}
		
		public override function visit(h:ActionHandler):void
		{
			h.label(this);
		}
		
		public override function equals(object:*):Boolean
		{
			// labels should always be unique unless they really are the same object
			return (this == object);
		}
		
		public override function hashCode():int
		{
			// Action.hashCode() allways returns the code, but we want a real hashcode
			// since every instance of Label needs to be unique
			return super.objectHashCode();
		}
	}
}