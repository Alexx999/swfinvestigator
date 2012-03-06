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

	public class GotoFrame extends Action
	{
		public var frame:int;
		
		public function GotoFrame()
		{
			super(ActionConstants.sactionGotoFrame);
		}
		
		public override function visit(h:ActionHandler):void {
			h.gotoFrame(this);
		}
		
		public override function equals(object:*):Boolean {
			if (super.equals(object) && object is GotoFrame) {
				var gotoFrame:GotoFrame = object as GotoFrame;
				
				if (gotoFrame.frame == this.frame) {
					return (true);
				}
			}
			return (false);
		}
	}
}