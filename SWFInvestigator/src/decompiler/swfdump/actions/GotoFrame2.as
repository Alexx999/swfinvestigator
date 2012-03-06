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
	
	public class GotoFrame2 extends Action
	{
		public var playFlag:int;
		
		public function GotoFrame2()
		{
			super(ActionConstants.sactionGotoFrame2);
		}
		
		public override function visit(h:ActionHandler):void {
			h.gotoFrame2(this);
		}
		
		public override function equals(object:*):Boolean {
			if (super.equals(object) && object is GotoFrame2) {
				var gotoFrame2:GotoFrame2 = object as GotoFrame2;
				
				if (gotoFrame2.playFlag == this.playFlag) {
					return (true);
				}
			}
			return (false);
		}
	}
}