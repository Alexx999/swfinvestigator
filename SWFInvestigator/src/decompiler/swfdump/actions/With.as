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
	import decompiler.swfdump.actions.Label;
	
	public class With extends Action
	{
		public var endWith:Label;

		public function With()
		{
			super(ActionConstants.sactionWith);
		}
	
		
		public override function visit(h:ActionHandler):void
		{
			h.WithAction(this);
		}
		
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is With))
			{
				var w:With = object as With;
				
				//Need to do toString()/hashCode
				if ( w.endWith == this.endWith)
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
	}
}