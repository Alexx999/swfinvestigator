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
	import flash.utils.ByteArray;
	
	public class Unknown extends Action
	{
		public var data:ByteArray = new ByteArray();

		public function Unknown(code:int)
		{
			super(code);
		}
		
		public override function visit(handler:ActionHandler):void
		{
			handler.unknown(this);
		}
				
		public override function equals(object:*):Boolean
		{			
			if (super.equals(object) && (object is Unknown))
			{
				var unknown:Unknown = object as Unknown;
				
				if (unknown.data.length != this.data.length) {
					return (false)
				}
				
				for (var i:int = 0; i < this.data.length; i++) {
					if (unknown.data[i] != this.data[i]) {
						return (false);
					}
				}
			}
			return (true);
		}
	}
}