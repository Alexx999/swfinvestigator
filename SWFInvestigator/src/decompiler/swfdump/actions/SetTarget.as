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
	
	/**
	 * Represents an AS2 "set target" byte code.
	 *
	 * @author Clement Wong
	 */
	public class SetTarget extends Action
	{
		/**
		 * name of target object for subsequent actions.  Empty string ("") means
		 * the current movie.
		 */
		public var targetName:String;
		
		public function SetTarget()
		{
			super(ActionConstants.sactionSetTarget);
		}
		
		public override function visit(h:ActionHandler):void
		{
			h.setTarget(this);
		}
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is SetTarget))
			{
				var setTarget:SetTarget = object as SetTarget;
				
				if (setTarget.targetName == this.targetName)
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
	}
}