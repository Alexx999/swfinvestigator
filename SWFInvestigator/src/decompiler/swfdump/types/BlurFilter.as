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
	public class BlurFilter extends Filter
	{
		public static const ID:int = 1;
		public override function getID():int { return ID; }
		public var blurX:int;
		public var blurY:int;
		public var passes:int;  // really UB[5] with UB[3] reserved
	}
}