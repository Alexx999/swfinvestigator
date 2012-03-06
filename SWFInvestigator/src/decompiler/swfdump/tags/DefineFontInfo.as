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
	
	/**
	 * Represents a DefineFontInfo SWF tag.
	 *
	 * @since SWF1
	 * @author Clement Wong
	 */
	public class DefineFontInfo extends Tag
	{
		public function DefineFontInfo(code:int)
		{
			super(code);
		}
		
		public override function visit(h:TagHandler):void
		{
			if (code == stagDefineFontInfo)
				h.defineFontInfo(this);
			else
				h.defineFontInfo2(this);
		}
		
		protected function getSimpleReference():Tag
		{
			return font;
		}
		
		public var font:DefineFont1;
		public var name:String;
		public var shiftJIS:Boolean;
		public var ansi:Boolean;
		public var italic:Boolean;
		public var bold:Boolean;
		public var wideCodes:Boolean; // not in equality check- sometimes determined from other vars at encoding time
		
		/** U16 if widecodes == true, U8 otherwise.  provides the character
		 * values for each glyph in the font. */
		//public char[] codeTable;
		public var codeTable:String;
		
		/** langcode - valid for DefineFont2 only */
		public var langCode:int;
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is DefineFontInfo))
			{
				var defineFontInfo:DefineFontInfo = object as DefineFontInfo;
				
				// [paul] Checking that the font fields are equal would
				// lead to an infinite loop, because DefineFont contains a
				// reference to it's DefineFontInfo.
				if ( defineFontInfo.name == this.name &&
					(defineFontInfo.shiftJIS == this.shiftJIS) &&
					(defineFontInfo.ansi == this.ansi) &&
					(defineFontInfo.italic == this.italic) &&
					(defineFontInfo.bold == this.bold) &&
					//Arrays.equals(defineFontInfo.codeTable, this.codeTable) &&
					(defineFontInfo.codeTable == this.codeTable) && 
					(defineFontInfo.langCode == this.langCode) )
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}    
	}

}