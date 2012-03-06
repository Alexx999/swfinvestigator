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
	import decompiler.tamarin.abcdump.Tag;
	import flash.utils.ByteArray;
	
	public class DefineBits extends DefineTag
	{
		/** there is only one JPEG table in the entire movie */
		public var jpegTables:GenericTag;
		public var data:ByteArray;
		
		// Only used by DefineBitsLossless subclass, but adding here to keep track
		// of the default width/height if discovered during JPEG creation...
		public var width:int;
		public var height:int;
		
		public function DefineBits(code:int)
		{
			super (code)
		}
		
		public override function visit(h:TagHandler):void
		{
			if (code == stagDefineBitsJPEG2)
				h.defineBitsJPEG2(this);
			else
				h.defineBits(this);
		}
		
		protected function getSimpleReference():Tag
		{
			return jpegTables;
		}
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is DefineBits))
			{
				var defineBits:DefineBits = object as DefineBits;
				
				if ( (defineBits.width == this.width) &&
					(defineBits.height == this.height) &&
					objectEquals(defineBits.jpegTables,  this.jpegTables) )
				{
					isEqual = true;
				}
				
				if (this.data.length != defineBits.data.length) {
					isEqual = false;
					return (isEqual);
				}
				
				for (var i:int = 0; i < this.data.length; i++) {
					if (this.data[i] != defineBits.data[i]) {
						isEqual = false;
					}
				}
			}
			
			return isEqual;
		}
	}
}