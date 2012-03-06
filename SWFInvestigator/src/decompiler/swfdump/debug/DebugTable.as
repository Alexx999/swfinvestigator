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
	import decompiler.swfdump.DebugHandler;
	import decompiler.swfdump.DebugTags;
	import decompiler.swfdump.debug.LineRecord;
	import decompiler.swfdump.debug.RegisterRecord;
	import decompiler.swfdump.debug.DebugModule;
	import decompiler.swfdump.types.FlashUUID;
	import decompiler.swfdump.util.IntMap;
	
	public class DebugTable extends DebugTags
		implements DebugHandler
	{
		public var fUUID:FlashUUID;
		public var version:int;
		public var lines:IntMap;
		public var regs:IntMap;
		
		public function DebugTable()
		{
			this.lines = new IntMap();
			this.regs = new IntMap();
		}
		
		public function breakpoint(offset:int):void
		{
		}
		
		public function header(version:int):void
		{
			this.version = version;
		}
		
		public function uuid(id:FlashUUID):void
		{
			this.fUUID = id;
		}
		
		public function module(dm:DebugModule):void
		{
		}
		
		public function offset(offset:int, lr:LineRecord):void
		{
			lines.put(offset, lr);
		}
		
		public function registers(offset:int, r:RegisterRecord):void
		{
			this.regs.put(offset, r);
		}
		
		public function getLine(offset:int):LineRecord
		{
			return (lines.get(offset) as LineRecord);
		}
		
		public function getRegisters(offset:int):RegisterRecord
		{
			return (regs.get(offset) as RegisterRecord);
		}
		
		public function error(msg:String):void
		{
		}
	}
}