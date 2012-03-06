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
	 * A value object for line style data.
	 *
	 * @author Clement Wong
	 */
	public class LineStyle
	{
		
		public function LineStyle(color:int=0, width:int = 0)
		{
			this.color = color;
			this.width = width;
		}
		
		public var width:int;
		
		/** color as int: 0xAARRGGBB or 0x00RRGGBB */
		public var color:int;
		
		public function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (object is LineStyle)
			{
				var lineStyle:LineStyle = object as LineStyle;
				
				if ( (lineStyle.width == this.width) &&
					(lineStyle.color == this.color) )
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
		
		// Shape6 only:
		public var flags:int;
		// NOTE: As of this point, the SWF format spec documents the bitflags as being
		// UB[1], UB[2], etc.  This is incorrect.  Both authoring and the player apparently interpret
		// the flags as a UI16 (stored little-endian) and mask off the bits themselves.
		//
		// This isn't really in keeping with the way bitflags are stored in the rest of the format,
		// but since we've shipped, I think its now too late to remedy, and the spec will need to
		// be updated.
		//
		// Argh!  The bits in the spec are listed low-to-high, not left-to-right!
		
		// TODO - add getters/setters for the other bitflags.
		public function hasFillStyle():Boolean
		{
			return ((flags & 0x0008) != 0);
		}
		
		public function hasMiterJoint():Boolean
		{
			return ((flags & 0x0030) == 0x0020);
		}
		
		public var miterLimit:int;  // UB[2] iff jointstyle = 2, 8.8 fixedpoint
		public var fillStyle:FillStyle; // if hasFillFlag;
	}

}