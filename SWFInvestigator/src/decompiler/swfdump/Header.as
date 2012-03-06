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
	import decompiler.tamarin.abcdump.Rect;
	
	//NEEDED FOR SWF DISASSEMBLY
	public class Header
	{
		//Overlaps with exist code. Kill?
		public var compressed:Boolean;
		public var version:int;
		public var length:Number;
		public var size:Rect;
		public var rate:int;
		public var framecount:int;
		
		public function Header()
		{
		}
		
		public static function useCompression(version:int):Boolean
		{
			/**
			if ((System.getProperty("flex.swf.uncompressed") != null))
				return false;
			**/
			
			return version >= 6;
		}
	}
}