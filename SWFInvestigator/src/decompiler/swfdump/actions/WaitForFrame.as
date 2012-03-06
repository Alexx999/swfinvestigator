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
	
	public class WaitForFrame extends Action
	{
		/**
		 * Frame number to wait for (WaitForFrame only).  WaitForFrame2 takes
		 * its frame argument from the stack.
		 */
		public var frame:int;
		
		/**
		 *  label marking the number of actions to skip if frame is not loaded
		 */
		public var skipTarget:Label;
		
		public function WaitForFrame(code:int)
		{
			super(code);
		}
		
		public override function visit(h:ActionHandler):void
		{
			if (code == ActionConstants.sactionWaitForFrame)
				h.waitForFrame(this);
			else
				h.waitForFrame2(this);
		}
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is WaitForFrame))
			{
				var waitForFrame:WaitForFrame = object as WaitForFrame;
				
				//Need to do toString()?
				if ( (waitForFrame.frame == this.frame) && 
					(waitForFrame.skipTarget == this.skipTarget) )
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
	}
}