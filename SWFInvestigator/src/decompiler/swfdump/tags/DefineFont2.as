////////////////////////////////////////////////////////////////////////////////
//
// ADOBE SYSTEMS INCORPORATED
// Copyright 2003-2006 Adobe Systems Incorporated
// All Rights Reserved.
//
// NOTICE: Adobe permits you to use, modify, and distribute this file
// in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package decompiler.swfdump.tags
{
	import decompiler.swfdump.TagHandler;
	import decompiler.swfdump.types.KerningRecord;
	import decompiler.swfdump.types.Shape;
	import decompiler.tamarin.abcdump.Rect;
	import decompiler.tamarin.abcdump.Tag;
	
	/**
	 * DefineFont2 improves on the functionality of the DefineFont tag.
	 * Enhancements include:
	 * <ul>
	 * <li>32-bit entries in the offset table for fonts with more than 65535
	 * glyphs.</li>
	 * <li>Mapping to device fonts by incorporating all of the functionality of
	 * DefineFontInfo.</li>
	 * <li>Font metrics for improved layout of dynamic glyph text.</li>
	 * </ul>
	 * Note that DefineFont2 reserves space for a font bounds table and
	 * kerning table. This information is not used through Flash Player 7,
	 * though some minimal values must be present for these entries to
	 * define a well formed tag.  A minimal Rect can be supplied for the
	 * font bounds table and the kerning count can be set to 0 to omit the
	 * kerning table. DefineFont2 was introduced in SWF version 3.
	 * 
	 * @author Clement Wong
	 * @author Peter Farland
	 */
	public class DefineFont2 extends DefineFont
	{
		/**
		 * Constructor.
		 */
		
		public function DefineFont2(code:int = stagDefineFont2)
		{
			super(code);
		}
		
		//--------------------------------------------------------------------------
		//
		// Fields and Bean Properties
		//
		//--------------------------------------------------------------------------
		
		public var hasLayout:Boolean;
		public var shiftJIS:Boolean;
		public var smallText:Boolean;
		public var ansi:Boolean;
		public var wideOffsets:Boolean;
		public var wideCodes:Boolean;
		public var italic:Boolean;
		public var bold:Boolean;
		public var langCode:int;
		public var fontName:String;
		
		// U16 if wideOffsets == true, U8 otherwise
		//public char[] codeTable;
		public var codeTable:String;
		public var ascent:int;
		public var descent:int;
		public var leading:int;
		
		public var glyphShapeTable:Vector.<Shape>;
		//public short[] advanceTable;
		public var advanceTable:Vector.<int>;
		public var boundsTable:Vector.<Rect>;
		public var kerningCount:uint;
		public var kerningTable:Vector.<KerningRecord>;
		
		/**
		 * The name of the font. This name is significant for embedded fonts at
		 * runtime as it determines how one refers to the font in CSS. In SWF 6 and
		 * later, font names are encoded using UTF-8. In SWF 5 and earlier, font
		 * names are encoded in a platform specific manner in the codepage of the
		 * system they were authored.
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
		
		/**
		 * Find the immediate, first order dependencies.
		 * 
		 * @return Iterator of immediate references of this DefineFont.
		 */
		/**
		public Iterator<Tag> getReferences()
		{
			List<Tag> refs = new LinkedList<Tag>();
			
			for (int i = 0; i < glyphShapeTable.length; i++)
				glyphShapeTable[i].getReferenceList(refs);
			
			return refs.iterator();
		}
		 */
		
		/**
		 * Invokes the defineFont visitor on the given TagHandler.
		 * 
		 * @param handler The SWF TagHandler.
		 */
		public override function visit(handler:TagHandler):void
		{
			if (code == stagDefineFont2)
				handler.defineFont2(this);
		}
		
		//--------------------------------------------------------------------------
		//
		// Utility Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Tests whether this DefineFont2 tag is equivalent to another DefineFont2
		 * tag instance.
		 * 
		 * @param object Another DefineFont2 instance to test for equality.
		 * @return true if the given instance is considered equal to this instance
		 */
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (object is DefineFont2 && super.equals(object))
			{
				var defineFont:DefineFont2 = object as DefineFont2;
				
				// wideOffsets and wideCodes not considered in the equality check
				// as these are determined at encoding time
				
				if ((defineFont.hasLayout == this.hasLayout) &&
					(defineFont.shiftJIS == this.shiftJIS) &&
					(defineFont.ansi == this.ansi) &&
					(defineFont.italic == this.italic) &&
					(defineFont.bold == this.bold) &&
					(defineFont.langCode == this.langCode) &&
					(defineFont.ascent == this.ascent) &&
					(defineFont.descent == this.descent) &&
					(defineFont.leading == this.leading) &&
					(defineFont.kerningCount == this.kerningCount) &&
					(defineFont.name == this.name) &&
					(defineFont.fontName == this.fontName) &&
					(defineFont.codeTable == this.codeTable) &&
					vectorEquals(defineFont.glyphShapeTable, this.glyphShapeTable) &&
					vectorEquals(defineFont.advanceTable, this.advanceTable) &&
					vectorEquals(defineFont.boundsTable, this.boundsTable) &&
					vectorEquals(defineFont.kerningTable, this.kerningTable))
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
		
		private function vectorEquals (v1:*, v2:*):Boolean {
			if (v1 == null && v2 == null) {
				return (true);
			}
			
			if (v1 == null || v2 == null) {
				return (false);
			}
			
			if (v1.length != v2.length) {
				return (false);
			}
			
			for (var i:int = 0; i < v1.length; i++) {
				if (!(v1[i].equals(v2[i]))) {
					return (false);
				}
			}
			
			return (true);
		}
	}
}