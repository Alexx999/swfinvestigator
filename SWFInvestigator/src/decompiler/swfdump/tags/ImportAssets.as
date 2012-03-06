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

package decompiler.swfdump.tags
{
	import decompiler.swfdump.TagHandler;
	import decompiler.swfdump.types.ImportRecord;
	import decompiler.tamarin.abcdump.Tag;
	import flash.utils.ByteArray;
	
	/**
	 * This represents a ImportAssets SWF tag.
	 *
	 * @author Clement Wong
	 */
	public class ImportAssets extends Tag
	{
		public function ImportAssets(code:int)
		{
			super(code);
		}
		
		public override function visit(h:TagHandler):void
		{
			if (code == stagImportAssets)
				h.importAssets(this);
			else
				h.importAssets2(this);
		}
		
		public var url:String;
		public var importRecords:Vector.<ImportRecord>;
		
		public var downloadNow:Boolean;
		public var SHA1:ByteArray;
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is ImportAssets))
			{
				var importAssets:ImportAssets = object as ImportAssets;
				
				if ( importAssets.url == this.url &&
					(importAssets.downloadNow == this.downloadNow) &&
					digestEquals(importAssets.SHA1, this.SHA1))
				{
					isEqual = true;
				}
				
				if (importAssets.importRecords == null && this.importRecords == null) {
					return (true);
				}
				
				if (importAssets.importRecords != null && this.importRecords != null &&
					importAssets.importRecords.length == this.importRecords.length) {
					for (var i:int = 0; i < importAssets.importRecords.length; i++) {
						if (!(objectEquals(importAssets.importRecords[i], this.importRecords[i]))) {
							return (false);
						}
					}
				} else {
					return (false);
				}
			}
			
			return isEqual;
		}
		
		private function digestEquals(d1:ByteArray, d2:ByteArray):Boolean
		{
			if (d1 == null && d2 == null)
			{
				return true;
			}
			else
			{
				for (var i:int = 0; i < 20; i++)
				{
					if (d1[i] != d2[i])
					{
						return false;
					}
				}
				return true;
			}
		}
	}

}