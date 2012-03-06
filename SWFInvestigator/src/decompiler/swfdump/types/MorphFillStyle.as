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
	 * A value object for morph fill style data.
	 *
	 * @author Clement Wong
	 */
	public class MorphFillStyle
	{
		public static const FILL_BITS:int = 0x40;
		
		public var type:int;
		/** colors as ints: 0xAARRGGBB */
		public var startColor:int;
		public var endColor:int;
		public var startGradientMatrix:Matrix;
		public var endGradientMatrix:Matrix;
		public var gradRecords:Vector.<MorphGradRecord>;
		public var bitmap:DefineTag;
		public var startBitmapMatrix:Matrix;
		public var endBitmapMatrix:Matrix;
		
		// MorphFillStyle for DefineMorphShape2
		public var ratio1:int
		public var ratio2:int;
		
		public function hasBitmapId():Boolean
		{
			return ((type & FILL_BITS) != 0);
		}
		
		public function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (object is MorphFillStyle)
			{
				var morphFillStyle:MorphFillStyle = object as MorphFillStyle;
				
				if ( (morphFillStyle.type == this.type) &&
					(morphFillStyle.startColor == this.startColor) &&
					(morphFillStyle.endColor == this.endColor) &&
					(morphFillStyle.ratio1 == this.ratio1) &&
					(morphFillStyle.ratio2 == this.ratio2) &&
					( ( (morphFillStyle.startGradientMatrix == null) && (this.startGradientMatrix == null) ) ||
						( (morphFillStyle.startGradientMatrix != null) && (this.startGradientMatrix != null) &&
							morphFillStyle.startGradientMatrix.equals(this.startGradientMatrix) ) ) &&
					( ( (morphFillStyle.endGradientMatrix == null) && (this.endGradientMatrix == null) ) ||
						( (morphFillStyle.endGradientMatrix != null) && (this.endGradientMatrix != null) &&
							morphFillStyle.endGradientMatrix.equals(this.endGradientMatrix) ) ) &&
					( ( (morphFillStyle.bitmap == null) && (this.bitmap == null) ) ||
						( (morphFillStyle.bitmap != null) && (this.bitmap != null) &&
							morphFillStyle.bitmap.equals(this.bitmap) ) ) &&
					( ( (morphFillStyle.startBitmapMatrix == null) && (this.startBitmapMatrix == null) ) ||
						( (morphFillStyle.startBitmapMatrix != null) && (this.startBitmapMatrix != null) &&
							morphFillStyle.startBitmapMatrix.equals(this.startBitmapMatrix) ) ) &&
					( ( (morphFillStyle.endBitmapMatrix == null) && (this.endBitmapMatrix == null) ) ||
						( (morphFillStyle.endBitmapMatrix != null) && (this.endBitmapMatrix != null) &&
							morphFillStyle.endBitmapMatrix.equals(this.endBitmapMatrix) ) ) )
				{
					isEqual = true;
				}
				
				if (morphFillStyle.gradRecords != null && this.gradRecords != null &&
					morphFillStyle.gradRecords.length == this.gradRecords.length) {
					for (var i:int = 0; i < this.gradRecords.length; i++) {
						if (!morphFillStyle.gradRecords[i].equals(this.gradRecords[i])) {
							return (false);
						}
					}
				} else {
					return (false);
				}
			}
			
			return isEqual;
		}
	}

}