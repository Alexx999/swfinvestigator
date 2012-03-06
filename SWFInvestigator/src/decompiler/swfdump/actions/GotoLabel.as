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
	
	public class GotoLabel extends Action
	{
		public var label:String;
		
		public function GotoLabel()
		{
			super(ActionConstants.sactionGotoLabel);
		}
		
		public override function visit(h:ActionHandler):void {
			h.gotoLabel(this);
		}
		
		public override function equals(object:*):Boolean {
			if (super.equals(object) && object is GotoLabel) {
				var gotoLabel:GotoLabel = object as GotoLabel;
				
				if (gotoLabel.label == this.label) {
					return (true);
				}
			}
			return (false);
		}
	}
}