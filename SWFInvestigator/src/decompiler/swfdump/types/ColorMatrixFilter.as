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
	public class ColorMatrixFilter extends Filter
	{
		public static const ID:int = 6;
		public override function getID():int { return ID; }
		
		public var values:Vector.<Number> = new Vector.<Number>(20);
	}
}