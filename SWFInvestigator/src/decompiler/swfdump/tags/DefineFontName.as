////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package decompiler.swfdump.tags
{	
	import decompiler.swfdump.TagHandler;
	
	/**
	 * Stores the name and copyright information for a font.
	 *
	 * @author Brian Deitte
	 */
	public class DefineFontName extends DefineTag
	{
		public function DefineFontName()
		{
			super(stagDefineFontName);
		}
		
		public override function visit(h:TagHandler):void
		{
			h.defineFontName(this);
		}
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is DefineFontName))
			{
				var defineFontName:DefineFontName = object as DefineFontName;
				isEqual = (this.font.equals(defineFontName.font) &&
					(this.fontName == defineFontName.fontName) &&
					(this.copyright == defineFontName.copyright));
			}
			
			return isEqual;
		}
		
		public var font:DefineFont;
		public var fontName:String;
		public var copyright:String;
	}

}