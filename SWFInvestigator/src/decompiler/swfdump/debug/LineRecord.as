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

package decompiler.swfdump.debug
{
	import decompiler.swfdump.Action;
	import decompiler.swfdump.ActionHandler;
	import decompiler.swfdump.types.ActionList;
	import decompiler.swfdump.debug.DebugModule;
	
	/**
	 * This class represents a AS2 "line record" byte code.
	 */
	public class LineRecord extends Action
	{
		public function LineRecord(lineno:int, module:DebugModule)
		{
			super(ActionList.sactionLineRecord);
			this.lineno = lineno;
			this.module = module;
		}
		
		public var lineno:int;
		public var module:DebugModule;
		
		public override function visit(h:ActionHandler):void
		{
			h.lineRecord(this);
		}
		
		public override function toString():String
		{
			return module.name + ":" + lineno;
		}
		
		public override function equals(object:*):Boolean
		{
			if (object is LineRecord)
			{
				var other:LineRecord = object as LineRecord;
				return super.equals(other) &&
					other.lineno == this.lineno &&
					super.objectEquals(other.module, this.module);
			}
			else
			{
				return false;
			}
		}
	}
}