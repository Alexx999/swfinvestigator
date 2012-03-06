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
	
	public class StrictMode extends Action
	{
		public var mode:Boolean;
		
		public function StrictMode(mode:Boolean)
		{
			super(ActionConstants.sactionStrictMode);
			this.mode = mode;
		}
		
		public override function visit(h:ActionHandler):void
		{
			h.strictMode(this);
		}
		
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is StrictMode))
			{
				var strictMode:StrictMode = object as StrictMode;
				
				if (strictMode.mode == this.mode)
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
	}
}