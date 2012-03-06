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
		
	public class GetURL extends Action
	{
		public var url:String;
		public var target:String;
		
		public function GetURL() 
		{
			super(ActionConstants.sactionGetURL);
		}
		
		public override function visit(h:ActionHandler):void {
			h.getURL(this);
		}
		
		public override function equals(object:*):Boolean {
			if (super.equals(object) && object is GetURL) {
				var gURL:GetURL = object as GetURL;
				
				if (gURL.url == this.url
					&& gURL.target == this.target) {
					return (true);
				}
			}
			return (false);
		}
		
	}
}