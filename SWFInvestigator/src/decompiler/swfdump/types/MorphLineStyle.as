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
	/**
	 * A value object for morph line style data.
	 *
	 * @author Clement Wong
	 */
	public class MorphLineStyle
	{
		public var startWidth:int;
		public var endWidth:int;
		
		// MorphLineStyle2
		public var startCapsStyle:int;
		public var jointStyle:int;
		public var hasFill:Boolean;
		public var noHScale:Boolean;
		public var noVScale:Boolean;
		public var pixelHinting:Boolean;
		public var noClose:Boolean;
		public var endCapsStyle:int;
		public var miterLimit:int;
		
		public var fillType:MorphFillStyle;
		// end MorphLineStyle2
		
		/** colors as ints: 0xAARRGGBB */
		public var startColor:int;
		public var endColor:int;
		
		public function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (object is MorphLineStyle)
			{
				var morphLineStyle:MorphLineStyle = object as MorphLineStyle;
				
				if ( (morphLineStyle.startWidth == this.startWidth) &&
					(morphLineStyle.endWidth == this.endWidth) &&
					
					(morphLineStyle.startCapsStyle == this.startCapsStyle) &&
					(morphLineStyle.jointStyle == this.jointStyle) &&
					(morphLineStyle.hasFill == this.hasFill) &&
					(morphLineStyle.noHScale == this.noHScale) &&
					(morphLineStyle.noVScale == this.noVScale) &&
					(morphLineStyle.pixelHinting == this.pixelHinting) &&
					(morphLineStyle.noClose == this.noClose) &&
					(morphLineStyle.endCapsStyle == this.endCapsStyle) &&
					(morphLineStyle.miterLimit == this.miterLimit) &&
					morphLineStyle.fillType.equals(this.fillType) &&
					
					(morphLineStyle.startColor == this.startColor) &&
					(morphLineStyle.endColor == this.endColor) )
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}    
	}

}