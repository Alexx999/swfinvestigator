////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package decompiler.swfdump.types
{
	import decompiler.swfdump.tags.DefineTag;

	/**
	 * A value object for fill style data.
	 *
	 * @author Clement Wong
	 */
	public class FillStyle
	{
		public static const FILL_SOLID:int = 0;
		
		public static const FILL_GRADIENT:int = 0x10;
		public static const FILL_LINEAR_GRADIENT:int = 0x10;
		public static const FILL_RADIAL_GRADIENT:int = 0x12;
		public static const FILL_FOCAL_RADIAL_GRADIENT:int = 0x13;
		
		public static const FILL_VECTOR_PATTERN:int = 0x20;
		public static const FILL_RAGGED_CROSSHATCH:int = 0x20;
		public static const FILL_DIAGONAL_LINES:int = 0x21;
		public static const FILL_CROSSHATCHED_LINES:int = 0x22;
		public static const FILL_STIPPLE:int = 0x23;
		
		public static const FILL_BITS:int = 0x40;
		public static const FILL_BITS_CLIP:int = 0x01; // set if bitmap is clipped. otherwise repeating
		public static const FILL_BITS_NOSMOOTH:int = 0x02; // set if bitmap should not be smoothed
		
		public var type:int;
		
		/** color as int: 0xAARRGGBB or 0x00RRGGBB */
		public var color:int;
		public var gradient:Gradient;
		public var matrix:Matrix;
		public var bitmap:DefineTag;
		
		public function FillStyle(type:int = 0, mtrx:Matrix = null, bitmap:DefineTag = null)
		{
			if (mtrx == null) {
				this.type = FILL_SOLID;
				this.color = type;
			} else {
				setType(type);
			}
			this.matrix = mtrx;
			this.bitmap = bitmap;
		}
		
		public function getType():int
		{
			return type;
		}
		
		public function hasBitmapId():Boolean
		{
			return ((type & FILL_BITS) != 0);
		}
		
		public function setType(type:int):void
		{
			this.type = type;
			/**
			assert ((type == FILL_SOLID) ||
				(type == FILL_GRADIENT) ||
				(type == FILL_LINEAR_GRADIENT) ||
				(type == FILL_RADIAL_GRADIENT) ||
				(type == FILL_VECTOR_PATTERN) ||
				(type == FILL_RAGGED_CROSSHATCH) ||
				(type == FILL_STIPPLE) ||
				(type == FILL_BITS) ||
				(type == (FILL_BITS | FILL_BITS_CLIP)) ||
				(type == (FILL_BITS | FILL_BITS_NOSMOOTH)) ||
				(type == (FILL_BITS | FILL_BITS_NOSMOOTH | FILL_BITS_CLIP))   
			);
			 */
		}
		
		public function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (object is FillStyle)
			{
				var fillStyle:FillStyle = object as FillStyle;
				
				if ( (fillStyle.type == this.type) &&
					(fillStyle.color == this.color) &&
					( ( (fillStyle.gradient == null) && (this.gradient == null) ) ||
						(fillStyle.gradient.equals( this.gradient )) ) &&
					( ( (fillStyle.matrix == null) && (this.matrix == null) ) ||
						( (fillStyle.matrix != null) && (this.matrix != null) &&
							fillStyle.matrix.equals(this.matrix) )) &&
					( ( (fillStyle.bitmap == null) && (this.bitmap == null) ) ||
						( (fillStyle.bitmap != null) && (this.bitmap != null) &&
							fillStyle.bitmap.equals(this.bitmap) ) ) )
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
	}

}