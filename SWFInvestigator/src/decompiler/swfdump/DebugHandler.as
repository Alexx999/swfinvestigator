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

package decompiler.swfdump
{
	import decompiler.swfdump.debug.LineRecord;
	import decompiler.swfdump.debug.RegisterRecord;
	import decompiler.swfdump.debug.DebugModule;
	import decompiler.swfdump.types.FlashUUID;
	
	public interface DebugHandler //extends DebugTags
	{
		function header(version:int):void;
		
		function uuid(id:FlashUUID):void;
		function module(dm:DebugModule):void;
		function offset(offset:int, lr:LineRecord):void;
		function registers(offset:int, r:RegisterRecord):void;
		
		function breakpoint(offset:int):void;
		
		function error(message:String):void;
		
	}
}