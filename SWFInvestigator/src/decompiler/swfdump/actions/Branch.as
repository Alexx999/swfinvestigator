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

//Adapted from http://opensource.adobe.com/svn/opensource/flex/sdk/trunk/modules/swfutils/src/java/flash/swf/actions/Branch.java
package decompiler.swfdump.actions
{
	import decompiler.swfdump.Action;
	import decompiler.swfdump.ActionConstants;
	import decompiler.swfdump.ActionHandler;
	
	public class Branch extends Action
	{
		public var target:Label;
		
		public function Branch(code:int)
		{
			super(code);
		}
		
		public override function visit(h:ActionHandler):void {
			if (this.code == ActionConstants.sactionJump) {
				h.jump(this);
			} else {
				h.ifAction(this);
			}
		}
		
		public override function equals (object:*):Boolean {
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is Branch)) {
				var branch:Branch = object as Branch;
				
				if (branch.target == this.target) {
					isEqual = true;
				}
			}
			
			return (isEqual);
		}
	}
}