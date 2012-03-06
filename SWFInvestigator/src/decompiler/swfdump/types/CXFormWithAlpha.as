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
	public class CXFormWithAlpha extends CXForm
	{
		public var alphaMultTerm:int;
		public var alphaAddTerm:int;
		
		/**
		 * SWF Investigator procrastinating
		public function nbits():int
		{
			// FFileWrite's MaxNum method takes only 4 arguments, so finding maximum value of 8 arguments takes three steps:
			int maxMult = SwfEncoder.maxNum(redMultTerm, greenMultTerm, blueMultTerm, alphaMultTerm);
			int maxAdd = SwfEncoder.maxNum(redAddTerm, greenAddTerm, blueAddTerm, alphaAddTerm);
			int maxValue = SwfEncoder.maxNum(maxMult, maxAdd, 0, 0);
			return SwfEncoder.minBits(maxValue, 1);
		}
		 */
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is CXFormWithAlpha))
			{
				var cxFormWithAlpha:CXFormWithAlpha = object as CXFormWithAlpha;
				
				if ( (cxFormWithAlpha.alphaMultTerm == this.alphaMultTerm) &&
					(cxFormWithAlpha.alphaAddTerm == this.alphaAddTerm) )
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
	}
}