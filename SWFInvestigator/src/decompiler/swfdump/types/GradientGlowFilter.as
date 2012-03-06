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
	public class GradientGlowFilter extends GlowFilter
	{
		public static const ID:int = 4;
		public override function getID():int { return ID; }
		
		public var numcolors:int;
		public var gradientColors:Vector.<int>;
		public var gradientRatio:Vector.<int>;
		public var angle:int;
		public var distance:int;
	}
}