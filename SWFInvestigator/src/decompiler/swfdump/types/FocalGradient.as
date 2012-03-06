////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package decompiler.swfdump.types
{
	/**
	 * A value object for focal gradient data.
	 *
	 * @author Roger Gonzalez
	 */
	public class FocalGradient extends Gradient
	{
		//was float
		public var focalPoint:Number;
		
		public override function equals(o:*):Boolean
		{
			if (!(o is FocalGradient) || !super.equals(o))
				return false;
			
			var otherGradient:FocalGradient = o as FocalGradient;
			return (otherGradient.focalPoint == focalPoint);
		}
	}

}