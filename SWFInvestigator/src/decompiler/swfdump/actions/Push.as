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
	import decompiler.swfdump.types.PushNum;
	import decompiler.swfdump.ActionFactory;
	
	public class Push extends Action
	{
		
		/** the value to push */
		public var value:*;
		
		public function Push(v:* = null)
		{
			super(ActionConstants.sactionPush);
			this.value = v;
		}
		
		public override function visit(h:ActionHandler):void
		{
			h.push(this);
		}
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is Push))
			{
				var push:Push = object as Push;
				
				if (super.objectEquals(push.value, this.value)) 
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
		
		
		public static function getTypeCode(value:*):int
		{
			if (value == null) return ActionConstants.kPushNullType;
			if (value is String && value == ActionFactory.UNDEFINED) return ActionConstants.kPushUndefinedType;
			if (value is String)  return ActionConstants.kPushStringType;
			if (value is PushNum && value.type == "Float")  return ActionConstants.kPushFloatType;
			if (value is PushNum && value.type == "Byte")  return ActionConstants.kPushRegisterType;
			if (value is Boolean)  return ActionConstants.kPushBooleanType;
			if (value is PushNum && value.type == "Double")  return ActionConstants.kPushDoubleType;
			if (value is int)  return ActionConstants.kPushIntegerType;
			if (value is PushNum && value.type == "Short")
				return ((uint(value.num) & 0xFFFF) < 256) ? ActionConstants.kPushConstant8Type : ActionConstants.kPushConstant16Type;
			//assert (false);
			return ActionConstants.kPushStringType;
		}
		
	}
}