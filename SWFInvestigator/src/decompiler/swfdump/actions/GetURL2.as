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

	public class GetURL2 extends Action
	{
		public var method:int;
		
		public function GetURL2()
		{
			super(ActionConstants.sactionGetURL2);
		}
		
		public override function visit(h:ActionHandler):void {
			h.getURL2(this);
		}
		
		public override function equals (object:*):Boolean {
			if (super.equals(object) && object is GetURL2) {
				var gURL2:GetURL2 = object as GetURL2;
			
				if (gURL2.method == this.method) {
					return (true);
				}
			}
			
			return (false);
		}
	}
}