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
	
	public class StoreRegister extends Action
	{
		public var register:int;
		
		public function StoreRegister(register:int)
		{
			super(ActionConstants.sactionStoreRegister);
			this.register = register;
		}
		
		public override function visit(h:ActionHandler):void
		{
			h.storeRegister(this);
		}
		
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is StoreRegister))
			{
				var storeRegister:StoreRegister = object as StoreRegister;
				
				if (storeRegister.register == this.register)
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
	}
}