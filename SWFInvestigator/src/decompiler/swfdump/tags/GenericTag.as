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
	import decompiler.tamarin.abcdump.Tag;
	import decompiler.swfdump.TagHandler;
	import flash.utils.ByteArray;

	public class GenericTag extends Tag
	{
		public function GenericTag(code:int)
		{
			super(code);
		}
	
		public override function visit(h:TagHandler):void
		{
			switch (code)
			{
				case stagJPEGTables:
					h.jpegTables(this);
					break;
				case stagProtect:
					h.protect(this);
					break;
				case stagSoundStreamBlock:
					h.soundStreamBlock(this);
					break;
				default:
					h.unknown(this);
					break;
			}
		}
	
		public var data:ByteArray;
	
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
		
			if (equals(object) && (object is GenericTag))
			{
				var genericTag:GenericTag = object as GenericTag;
			
				if ( objectEquals(genericTag.data, this.data) )
				{
					isEqual = true;
				}
			}
		
			return isEqual;
		}
	}
}