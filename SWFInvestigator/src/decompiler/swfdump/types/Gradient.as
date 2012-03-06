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
	 * A value object for gradient data. 
	 *
	 * @author Roger Gonzalez
	 */
	public class Gradient
	{
		public static const SPREAD_MODE_PAD:int = 0;
		public static const SPREAD_MODE_REFLECT:int = 1;
		public static const SPREAD_MODE_REPEAT:int = 2;
		public static const INTERPOLATION_MODE_NORMAL:int = 0;
		public static const INTERPOLATION_MODE_LINEAR:int = 1;
		
		public var spreadMode:int;
		public var interpolationMode:int;
		public var records:Vector.<GradRecord>;
		
		public function equals(o:*):Boolean
		{
			if (!(o is Gradient))
				return false;
			
			var otherGradient:Gradient = o as Gradient;
			if ((otherGradient.spreadMode != this.spreadMode)
				|| (otherGradient.interpolationMode != this.interpolationMode)) {
				return false;
			}
			
			if (otherGradient.records == null && this.records == null) {
				return true;
			} 
			
			if (otherGradient.records != null && this.records != null &&
				otherGradient.records.length == this.records.length) {
				for (var i:int = 0; i < this.records.length; i++) {
					if (otherGradient.records[i] != this.records[i]) {
						return (false)
					}
				}
			} else {
				return (false);
			}
			
			return (true);			
		}
	}

}