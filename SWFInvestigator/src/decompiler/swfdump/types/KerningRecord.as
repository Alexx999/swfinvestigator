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
	 * A value object for kerning record data.
	 *
	 * @author Clement Wong
	 */
	public class KerningRecord
	{
		public var code1:int;
		public var code2:int;
		public var adjustment:int;
		
		public function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (object is KerningRecord)
			{
				var kerningRecord:KerningRecord = object as KerningRecord;
				
				if ( (kerningRecord.code1 == this.code1) &&
					(kerningRecord.code2 == this.code2) &&
					(kerningRecord.adjustment == this.adjustment) )
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
	}

}