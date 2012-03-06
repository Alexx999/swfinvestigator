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

package decompiler.swfdump.tags
{
	import decompiler.swfdump.TagHandler;
	
	public class DefineBitsLossless extends DefineBits
	{
		public static const FORMAT_8_BIT_COLORMAPPED:int = 3;
		public static const FORMAT_15_BIT_RGB:int = 4;
		public static const FORMAT_24_BIT_RGB:int = 5;
		
		public var format:int;
		public var colorData:Vector.<int>;

		public function DefineBitsLossless(code:int)
		{
			super(code);
		}
		
		public override function visit(h:TagHandler):void
		{
			if (code == stagDefineBitsLossless)
				h.defineBitsLossless(this);
			else
				h.defineBitsLossless2(this);
		}
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is DefineBitsLossless))
			{
				var defineBitsLossless:DefineBitsLossless = object as DefineBitsLossless;
				
				if (defineBitsLossless.format == this.format) {
					isEqual = true;
					if (defineBitsLossless.colorData.length != this.colorData.length) {
						return (false);
					}
					for (var i:int = 0; i < defineBitsLossless.colorData.length; i++) {
						if (defineBitsLossless.colorData[i] != this.colorData[i]) {
							isEqual = false;
						}
					}
				}
			}
			
			return isEqual;
		}
		
	}
}