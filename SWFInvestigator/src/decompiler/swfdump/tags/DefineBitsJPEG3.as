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
	import flash.utils.ByteArray;
	
	public class DefineBitsJPEG3 extends DefineBits
	{
		public var alphaDataOffset:Number;
		public var alphaData:ByteArray;
		
		public function DefineBitsJPEG3()
		{
			super(stagDefineBitsJPEG3);
		}
		
		public override function visit(h:TagHandler):void
		{
			h.defineBitsJPEG3(this);
		}
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is DefineBitsJPEG3))
			{
				var defineBitsJPEG3:DefineBitsJPEG3 = object as DefineBitsJPEG3;
				
				if (defineBitsJPEG3.alphaDataOffset == this.alphaDataOffset) {
					isEqual = true;
					if (defineBitsJPEG3.alphaData.length != this.alphaData.length) {
						return (false);
					}
					for (var i:int = 0; i < this.alphaData.length; i++) {
						if (defineBitsJPEG3.alphaData[i] != this.alphaData[i]) {
							isEqual = false;
						} 
					}
				}
			}
			
			return isEqual;
		}
	}
}