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
	public class CXForm
	{
		public function CXForm()
		{
		}
		
		public var hasAdd:Boolean;
		public var hasMult:Boolean;
		
		public var redMultTerm:int;
		public var greenMultTerm:int;
		public var blueMultTerm:int;
		public var redAddTerm:int;
		public var greenAddTerm:int;
		public var blueAddTerm:int;
		
		public function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (object is CXForm)
			{
				var cxForm:CXForm = object as CXForm;
				
				if ( (cxForm.hasAdd == this.hasAdd) &&
					(cxForm.hasMult == this.hasMult) &&
					(cxForm.redMultTerm == this.redMultTerm) &&
					(cxForm.greenMultTerm == this.greenMultTerm) &&
					(cxForm.blueMultTerm == this.blueMultTerm) &&
					(cxForm.redAddTerm == this.redAddTerm) &&
					(cxForm.greenAddTerm == this.greenAddTerm) &&
					(cxForm.blueAddTerm == this.blueAddTerm) )
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
		
		public function toString():String
		{
			return redMultTerm + "r" + (redAddTerm>=0 ? "+" : "") + redAddTerm + " " +
				greenMultTerm + "g" + (greenAddTerm>=0 ? "+" : "") + greenAddTerm + " " +
				blueMultTerm + "b" + (blueAddTerm>=0 ? "+" : "") + blueAddTerm;
		}
		
		/**
		public int nbits()
		{
			// two step process to find maximum value of 6 numbers because "FSWFStream::MaxNum" takes only 4 arguments
			int max = SwfEncoder.maxNum(redMultTerm, greenMultTerm, blueMultTerm, redAddTerm);
			max = SwfEncoder.maxNum(greenAddTerm, blueAddTerm, max, 0);
			return SwfEncoder.minBits(max, 1);
		}
		 */
	}
}