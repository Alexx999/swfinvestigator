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
	
	public class Try extends Action
	{
		public var flags:int;
		
		/** name of variable holding the error object in catch body */
		public var catchName:String;
		
		/** register that holds the catch variable */
		public var catchReg:int;
		
		/** marks end of body and start of catch handler */
		public var endTry:Label;
		/** marks end of catch handler and start of finally handler */
		public var endCatch:Label;
		/** marks end of finally handler */
		public var endFinally:Label;
		
		private var aConstanst:ActionConstants;
		
		
		public function Try()
		{
			super(ActionConstants.sactionTry);
		}
		
		public override function visit(h:ActionHandler):void
		{
			h.tryAction(this);
		}
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is Try))
			{
				var tryAction:Try = object as Try;
				
				if (tryAction.flags == this.flags &&
					tryAction.catchName == this.catchName &&
					tryAction.catchReg == this.catchReg &&
					tryAction.endTry == this.endTry &&
					tryAction.endCatch == this.endCatch &&
					tryAction.endFinally == this.endFinally )
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
		
		public function hasCatch():Boolean
		{
			return (flags & ActionConstants.kTryHasCatchFlag) != 0;
		}
		
		public function hasFinally():Boolean
		{
			return (flags & ActionConstants.kTryHasFinallyFlag) != 0;
		}
		
		public function hasRegister():Boolean
		{
			return (flags & ActionConstants.kTryCatchRegisterFlag) != 0;
		}
	}
}