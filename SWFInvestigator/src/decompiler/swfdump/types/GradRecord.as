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
	 * A value object for gradient record data.
	 *
	 * @author Clement Wong
	 */
	public class GradRecord
	{
		
		public function GradRecord(r:int = 0, c:int = 0)
		{
			ratio = r;
			color = c;
		}
		
		public var ratio:int;
		
		/** color as int: 0xAARRGGBB or 0x00RRGGBB */
		public var color:int;
		
		public function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (object is GradRecord)
			{
				var gradRecord:GradRecord = object as GradRecord;
				
				if ( (gradRecord.ratio == this.ratio) &&
					(gradRecord.color == this.color) )
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
		
		public function toString():String
		{
			return "GradRecord(color='" + this.color + "', ratio='" + ratio + "')";
		}
	}

}