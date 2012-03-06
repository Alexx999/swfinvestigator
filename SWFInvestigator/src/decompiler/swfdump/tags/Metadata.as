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
	
	public class Metadata extends Tag
	{
		public function Metadata()
		{
			super(stagMetadata);
		}
		
		public override function visit(h:TagHandler):void
		{
			h.metadata(this);
		}
		
		public override function equals(o:*):Boolean
		{
			return ((o != null) && (o is Metadata) && ((o as Metadata).xml == xml));
		}
		
		public var xml:String;
		
	}
}