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
	
	public class DefineBitsJPEG4 extends DefineBits
	{
		public var alphaDataOffset:Number;
		public var alphaData:ByteArray;
		public var deblockParam:uint;
		
		public function DefineBitsJPEG4()
		{
			super(stagDefineBitsJPEG4);
		}
		
		public override function visit(h:TagHandler):void
		{
			h.defineBitsJPEG4(this);
		}
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is DefineBitsJPEG4))
			{
				var defineBitsJPEG4:DefineBitsJPEG4 = object as DefineBitsJPEG4;
				
				if (defineBitsJPEG4.alphaDataOffset == this.alphaDataOffset &&
					defineBitsJPEG4.deblockParam == this.deblockParam) {
					isEqual = true;
					if (defineBitsJPEG4.alphaData.length != this.alphaData.length) {
						return (false);
					}
					for (var i:int = 0; i < this.alphaData.length; i++) {
						if (defineBitsJPEG4.alphaData[i] != this.alphaData[i]) {
							isEqual = false;
						} 
					}
				}
			}
			
			return isEqual;
		}
	}
}