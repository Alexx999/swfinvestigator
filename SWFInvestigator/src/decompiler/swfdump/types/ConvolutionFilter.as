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
	public class ConvolutionFilter extends Filter
	{
		public static const ID:int = 5;
		public override function getID():int { return ID; }
		
		public var matrixX:int;
		public var matrixY:int;
		public var divisor:Number;
		public var bias:Number;
		public var matrix:Vector.<Number>;
		public var color:int;
		public var flags:int;
	}
}