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

package decompiler.swfdump.types
{
	public class GlowFilter extends Filter
	{
		public static const ID:int = 2;
		public override function getID():int { return ID; }
		
		public var color:int;
		public var blurX:int;
		public var blurY:int;
		public var strength:int;
		public var flags:int;
	}
}