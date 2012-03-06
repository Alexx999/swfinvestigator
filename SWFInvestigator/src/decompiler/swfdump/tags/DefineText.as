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
	import decompiler.swfdump.types.Matrix;
	import decompiler.swfdump.types.TextRecord;
	import decompiler.tamarin.abcdump.Rect;
	import decompiler.tamarin.abcdump.Tag;
	
	/**
	 * Represents a DefineText SWF tag.
	 *
	 * @author Clement Wong
	 */
	public class DefineText extends DefineTag
	{
		public function DefineText(code:int)
		{
			super(code);
			records=new Vector.<TextRecord>();
		}
		
		public override function visit(h:TagHandler):void
		{
			if (code == stagDefineText)
				h.defineText(this);
			else
				h.defineText2(this);
		}
		
		/**
		public Iterator<Tag> getReferences()
		{
			LinkedList<Tag> refs = new LinkedList<Tag>();
			for (int i = 0; i < records.size(); ++i )
				records.get(i).getReferenceList( refs );
			
			return refs.iterator();
		}
		 */
		
		public var bounds:Rect;
		public var matrix:Matrix;
		public var records:Vector.<TextRecord>;
		public var csmTextSettings:CSMTextSettings;
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is DefineText))
			{
				var defineText:DefineText = object as DefineText;
				
				if ( defineText.bounds.equals(this.bounds) &&
					defineText.matrix.equals(this.matrix))
				{
					isEqual = true;
				}
				
				if (defineText.records == null && this.records == null) {
					return (true);
				}
				
				if (defineText.records != null && this.records != null &&
					defineText.records.length == this.records.length) {
					for (var i:int = 0; i < this.records.length; i++) {
						if (!(defineText.records[i].equals(this.records[i]))) {
							return (false);
						}
					}
				} else {
					return (false);
				}
			}
			
			return isEqual;
		}
		
		public override function hashCode():int
		{
			var hashCode:int = super.hashCode();
			
			if (bounds!=null)
			{
				hashCode += bounds.hashCode();
			}
			
			if (records!=null) {
				hashCode += records.length;
			}
			return hashCode;
		}
	}

}