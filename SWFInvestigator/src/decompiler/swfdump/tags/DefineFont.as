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
	/**
	 * A DefineFont tag defines the shape outlines of each glyph used in a
	 * particular font.
	 * <p>
	 * The DefineFont tag id can be used by subsequent DefineText tags to refer
	 * to the font definition. As with all SWF character ids, font ids must be
	 * unique amongst all character ids in a SWF file.
	 * <p>
	 * The first version of DefineFont was introduced in SWF 1.
	 * <p>
	 * The second version, DefineFont2, was introduced in SWF 3.
	 * <p>
	 * The third version, DefineFont3, was introduced in SWF 8, along with
	 * DefineFontAlignZones for advanced anti-aliasing.
	 * <p>
	 * In SWF 9, DefineFontName was introduced to record the formal font name
	 * and copyright information for an embedded font.
	 * <p>
	 * The fourth version, DefineFont4, was introduced in SWF 10.  
	 * <p>
	 * Note that DefineFont tags cannot be used for dynamic text. Dynamic text
	 * requires the DefineFont2 tag (or later).
	 * 
	 * @see DefineFont1
	 * @see DefineFont2
	 * @see DefineFont3
	 * @see DefineFont4
	 * 
	 * @author Clement Wong
	 * @author Peter Farland
	 */
	
	//Was a Java Abstract
	public class DefineFont extends DefineTag
	{
		//Was originally protected
		public function DefineFont(code:int)
		{
			super(code);
		}
		
		public var license:DefineFontName;
		
		//These were abstracts in Java
		public function getFontName():String{return("");};
		public function isBold():Boolean{return false;};
		public function isItalic():Boolean{return false;};
	}

}