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
	
	/**
	 * A value object for morph grad record data.
	 *
	 * @author Clement Wong
	 */
	public class MorphGradRecord
	{
		public var startRatio:int;
		public var endRatio:int;
		
		/** colors as ints: 0xAARRGGBB */
		public var startColor:int;
		public var endColor:int;
		
		public function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (object is MorphGradRecord)
			{
				var morphGradRecord:MorphGradRecord = object as MorphGradRecord;
				
				if ( (morphGradRecord.startRatio == this.startRatio) &&
					(morphGradRecord.startColor == this.startColor) &&
					(morphGradRecord.endRatio == this.endRatio) &&
					(morphGradRecord.endColor == this.endColor) )
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}    
	}

}