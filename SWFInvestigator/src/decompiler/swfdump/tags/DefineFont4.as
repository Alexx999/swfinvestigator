////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
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
	
	/**
	 * Represents a DefineFont4 SWF tag.
	 * 
	 * @author Peter Farland
	 */
	public class DefineFont4 extends DefineFont //implements Cloneable
	{
		/**
		 * Constructor.
		 */
		public function DefineFont4()
		{
			super(stagDefineFont4);
		}
		
		//--------------------------------------------------------------------------
		//
		// Fields and Bean Properties
		//
		//--------------------------------------------------------------------------
		
		public var hasFontData:Boolean;
		public var smallText:Boolean;
		public var italic:Boolean;
		public var bold:Boolean;
		public var langCode:int;
		public var fontName:String;
		public var data:ByteArray;
		
		/**
		 * The name of the font. This name is significant for embedded fonts at
		 * runtime as it determines how one refers to the font in CSS. In SWF 6 and
		 * later, font names are encoded using UTF-8.
		 */
		public override function getFontName():String
		{
			return fontName;
		}
		
		/**
		 * Reports whether the font face is bold.
		 */
		public override function isBold():Boolean
		{
			return bold;
		}
		
		/**
		 * Reports whether the font face is italic.
		 */
		public override function isItalic():Boolean
		{
			return italic;
		}
		
		//--------------------------------------------------------------------------
		//
		// Visitor Methods
		//
		//--------------------------------------------------------------------------
		
		public override function visit(handler:TagHandler):void
		{
			if (code == stagDefineFont4)
				handler.defineFont4(this);
		}
		
		//--------------------------------------------------------------------------
		//
		// Utility Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @return a shallow copy of this DefineFont4 instance.
		 */
		public function clone():DefineFont4
		{
			var copy:DefineFont4 = new DefineFont4();
			copy.hasFontData = hasFontData;
			copy.smallText = smallText;
			copy.italic = italic;
			copy.bold = bold;
			copy.langCode = langCode;
			copy.fontName = fontName;
			copy.data = data;
			return copy;
		}
		
		/**
		 * Tests whether this DefineFont4 tag is equivalent to another DefineFont4
		 * tag instance.
		 * 
		 * @param object Another DefineFont4 instance to test for equality.
		 * @return true if the given instance is considered equal to this instance
		 */
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (object is DefineFont4 && super.equals(object))
			{
				var defineFont:DefineFont4 = object as DefineFont4;
				
				if ((defineFont.hasFontData == this.hasFontData) &&
					(defineFont.italic == this.italic) &&
					(defineFont.bold == this.bold) &&
					(defineFont.langCode == this.langCode) &&
					(defineFont.smallText == this.smallText) &&
					defineFont.fontName == this.fontName)
				{
					isEqual = true;
				}
				
				if (defineFont.data == null && this.data == null) {
					return (false);
				}
				
				if (defineFont.data != null && this.data != null &&
					defineFont.data.length == this.data.length) {
					for (var i:int =0; i < this.data.length; i++) {
						if (defineFont.data[i] != this.data[i]) {
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