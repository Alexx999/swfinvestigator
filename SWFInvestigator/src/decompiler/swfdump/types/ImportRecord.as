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

package decompiler.swfdump.types
{
	
	import decompiler.swfdump.TagHandler;
	import decompiler.swfdump.tags.DefineTag;
	
	/**
	 * This represents an import record, which is serialized as a member
	 * of an ImportAssets tag.  We subclass DefineTag because definitions
	 * are the things that get imported; any tag that refers to a
	 * definition can also refer to an import of another definition.
	 *
	 * @author Edwin Smith
	 */
	public class ImportRecord extends DefineTag
	{
		public function ImportRecord()
		{
			super(stagImportAssets);
		}
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is ImportRecord))
			{
				var importRecord:ImportRecord = object as ImportRecord;
				
				if ( importRecord.name == this.name)
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}    
		
		public override function visit(h:TagHandler):void
		{
			// this can't be visited, but you can visit the ImportAssets that owns this record.
			//assert (false);
		}
	}

}