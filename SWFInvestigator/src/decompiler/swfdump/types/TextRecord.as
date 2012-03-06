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
	import decompiler.tamarin.abcdump.Tag;
	import decompiler.tamarin.abcdump.Tag;
	import decompiler.swfdump.tags.DefineFont;

	/**
	 * A value object for text record data.
	 *
	 * @author Clement Wong
	 */
	public class TextRecord
	{
		private static const HAS_FONT:int = 8;
		private static const HAS_COLOR:int = 4;
		private static const HAS_X:int = 1;
		private static const HAS_Y:int = 2;
		private static const HAS_HEIGHT:int = 8; // yep, same as HAS_FONT.  see player/core/stags.h
		public var flags:int = 128;
		
		/** color as integer 0x00RRGGBB or 0xAARRGGBB */
		public var color:int;
		
		public var xOffset:int;
		public var yOffset:int;
		public var height:int;
		public var font:DefineFont;
		public var entries:Vector.<GlyphEntry>;
		
		public function getReferenceList( refs:Vector.<Tag> ):void
		{
			if (hasFont() && font != null)
				refs.push( font );
		}
		
		public function hasFont():Boolean
		{
			return (flags & HAS_FONT) != 0;
		}
		
		public function hasColor():Boolean
		{
			return (flags & HAS_COLOR) != 0;
		}
		
		public function hasX():Boolean
		{
			return (flags & HAS_X) != 0;
		}
		
		public function hasY():Boolean
		{
			return (flags & HAS_Y) != 0;
		}
		
		public function hasHeight():Boolean
		{
			return (flags & HAS_HEIGHT) != 0;
		}
		
		public function setFont(font:DefineFont):void
		{
			this.font = font;
			flags |= HAS_FONT;
		}
		
		public function setHeight(i:int):void
		{
			this.height = i;
			flags |= HAS_HEIGHT;
		}
		
		public function setColor(color:int):void
		{
			flags |= HAS_COLOR;
			this.color = color;
		}
		
		public function setX(xOffset:int):void
		{
			this.xOffset = xOffset;
			flags |= HAS_X;
		}
		
		public function setY(yOffset:int):void
		{
			this.yOffset = yOffset;
			flags |= HAS_Y;
		}
		
		public function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (object is TextRecord)
			{
				var textRecord:TextRecord = object as TextRecord;
				
				if ( (textRecord.flags == this.flags) &&
					(textRecord.color == this.color) &&
					(textRecord.xOffset == this.xOffset) &&
					(textRecord.yOffset == this.yOffset) &&
					(textRecord.height == this.height) &&
					(textRecord.font == this.font) ) {
					
					isEqual = true;
				} else {
					return (false);
				}
				
				if (textRecord.entries == null && this.entries == null) {
					return (true);
				}
				
				if (textRecord.entries != null && this.entries != null &&
					textRecord.entries.length == this.entries.length) {
						for (var i:int = 0; i < this.entries.length; i++ ) {
							if (textRecord.entries[i] != this.entries[i]) {
								return false;
							}
						}
				}
	
			}
			
			return isEqual;
		}
	}
}