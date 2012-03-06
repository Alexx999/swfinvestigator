////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2006 Adobe Systems Incorporated
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
	 * Represents a DefineFontAlignZones SWF tag.
	 *
	 * @author Brian Deitte
	 */
	public class DefineFontAlignZones extends DefineTag
	{
		public function DefineFontAlignZones()
		{
			super(stagDefineFontAlignZones);
		}
		
		public override function visit(h:TagHandler):void
		{
			h.defineFontAlignZones(this);
		}
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is DefineFontAlignZones))
			{
				var alignZones:DefineFontAlignZones = object as DefineFontAlignZones;
				
				if (font.equals(alignZones.font) &&
					csmTableHint == alignZones.csmTableHint)
				{
					isEqual = true;
				}
				
				if (this.zoneTable == null && alignZones.zoneTable == null) {
					return (true);
				}
				
				if (this.zoneTable != null && alignZones.zoneTable != null &&
					this.zoneTable.length == alignZones.zoneTable.length) {
					for (var i:int = 0; i < alignZones.zoneTable.length; i++) {
						if (!(this.zoneTable[i].equals(alignZones.zoneTable[i]))) {
							return (false);
						}
					}
				} else {
					return (false);
				}
			}
			return isEqual;
		}
		
		public var font:DefineFont3;
		public var csmTableHint:int;
		public var zoneTable:Vector.<ZoneRecord>;
	}

}