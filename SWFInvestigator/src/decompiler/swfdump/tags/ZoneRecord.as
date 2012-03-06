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
	/**
	 * This represents a ZoneRecord SWF tag.
	 *
	 * @author Brian Deitte
	 */
	public class ZoneRecord
	{
		public function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			if (super.equals(object) &&  (object is ZoneRecord))
			{
				var record:ZoneRecord = object as ZoneRecord;
				if (this.numZoneData != record.numZoneData ||
					this.zoneMask != record.zoneMask) {
					return false;
				}
				
				if (this.zoneData == null && record.zoneData == null) {
					return true;
				}
				
				isEqual = true;
				
				if (this.zoneData != null && record.zoneData != null &&
					this.zoneData.length == record.zoneData.length) {
					for (var i:int = 0; i < this.zoneData.length; i++) {
						if (this.zoneData[i] != record.zoneData[i]) {
							return false;
						}
					}
				} else {
					return false;
				}
			}
			return isEqual;
		}
		
		public var numZoneData:int;
		public var zoneData:Vector.<Number>;
		public var zoneMask:int;
	}

}