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
	import decompiler.swfdump.types.ActionList;
	import decompiler.tamarin.abcdump.Tag;

	public class SWFFormatError extends Error
	{
		public const FileFormatError:int  = 0;
		public const NoSuchElement:int = 1;
		public const IOError:int = 2;
		public const ASError:int = 3;
		
		public var aList:ActionList;
		public var t:Tag;
		
		public function SWFFormatError(message:String, errorID:int = 0)
		{
			if (errorID == 0) {
				message = "File Format Error: " + message;
			} else if (errorID == 1) {
				message = "No Such Element Error: " + message;
			} else if (errorID == 2) {
				message = "IO Error: " + message;
			} else if (errorID == 3) {
				message = "ActionScript Error: " + message;
			}
			
			super (message, errorID);
		}
	
	}
}