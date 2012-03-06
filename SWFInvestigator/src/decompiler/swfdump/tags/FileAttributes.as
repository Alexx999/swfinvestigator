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
	
	public class FileAttributes extends Tag
	{
		public var hasMetadata:Boolean;
		public var actionScript3:Boolean;
		public var suppressCrossDomainCaching:Boolean;
		public var swfRelativeUrls:Boolean;
		public var useNetwork:Boolean;
		public var useGPU:Boolean;
		public var useDirectBlit:Boolean;
		
		public function FileAttributes()
		{
			super(stagFileAttributes);
		}
		
		public override function visit(handler:TagHandler):void
		{
			handler.fileAttributes(this);
		}
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is FileAttributes))
			{
				var tag:FileAttributes = object as FileAttributes;
				
				if ((tag.hasMetadata == this.hasMetadata) &&
					(tag.actionScript3 == this.actionScript3) &&
					(tag.suppressCrossDomainCaching == this.suppressCrossDomainCaching) &&
					(tag.swfRelativeUrls == this.swfRelativeUrls) &&
					(tag.useDirectBlit == this.useDirectBlit) &&
					(tag.useGPU == this.useGPU) &&
					(tag.useNetwork == this.useNetwork))
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
		
	}
}