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
	 * ExportAssets makes portions of a SWF file available for import by
	 * other SWF files (see ImportAssets). For example, ten Flash movies
	 * that are all part of the same website can share an embedded custom
	 * font if one movie embeds the font and exports the font
	 * character. Each exported character is identified by a string. Any
	 * type of character can be exported.
	 *
	 * @author Clement Wong
	 * @since SWF5
	 */
	public class ExportAssets extends Tag
	{
		public function ExportAssets()
		{
			super(stagExportAssets);
		}
		
		public override function visit(h:TagHandler):void
		{
			h.exportAssets(this);
		}
		
		/**
		public Iterator<Tag> getReferences()
		{
			return exports.iterator();
		}
		 */
		
		/** list of DefineTags exported by this ExportTag */
		public var exports:Vector.<Tag> = new Vector.<Tag>;
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is ExportAssets))
			{
				var exportAssets:ExportAssets = object as ExportAssets;
				
				if (exportAssets.exports == null && this.exports == null) {
					return (true);
				}
				
				if (exportAssets.exports != null && this.exports != null &&
					exportAssets.exports.length == this.exports.length) {
					for (var i:int = 0; i < exportAssets.exports.length; i++) {
						if (!(objectEquals(exportAssets.exports[i],this.exports[i]))) {
							return (false);
						}
					}
				}

				isEqual = true;
				
			}
			
			return isEqual;
		}
	}

}