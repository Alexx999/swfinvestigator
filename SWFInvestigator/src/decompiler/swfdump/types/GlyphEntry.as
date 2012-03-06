////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package decompiler.swfdump.types
{
	import decompiler.tamarin.abcdump.Rect;
	import decompiler.swfdump.tags.ZoneRecord;
	
	/**
	 * A value object for glyph entry data.
	 *
	 * @author Clement Wong
	 */
	public class GlyphEntry //implements Cloneable
	{
		private var original:GlyphEntry;
		private var index:int;
		public var advance:int;
		
		//Utilities for DefineFont
		public var character:String;
		public var bounds:Rect;
		public var zoneRecord:ZoneRecord;
		public var shape:Shape;
		
		/**
		public function clone():Object
		{
			Object clone = null;
			
			try
			{
				clone = super.clone();
				((GlyphEntry) clone).original = this;
			}
			catch (CloneNotSupportedException cloneNotSupportedException)
			{
				// preilly: We should never get here, but just in case print a stack trace.
				cloneNotSupportedException.printStackTrace();
			}
			
			return clone;
		}
		 */
		
		public function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (object is GlyphEntry)
			{
				var glyphEntry:GlyphEntry = object as GlyphEntry;
				
				if ( (glyphEntry.index == this.index) &&
					(glyphEntry.advance == this.advance) )
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
		
		public function getIndex():int
		{
			var result:int;
			
			if (original != null)
			{
				result = original.getIndex();
			}
			else
			{
				result = index;
			}
			
			return result;
		}
		
		public function setIndex(index:int):void
		{
			this.index = index;
		}
		
		// Retained for coldfusion.document.CFFontManager implementation
		public function setShape(s:Shape):void
		{
			this.shape = s;
		}
		
		public function getShape():Shape
		{
			return this.shape;
		}
	}

}