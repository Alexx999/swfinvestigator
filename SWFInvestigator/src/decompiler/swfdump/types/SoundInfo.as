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
	public class SoundInfo
	{
		public static const UNINITIALIZED:int = -1;
		
		public var syncStop:Boolean;
		public var syncNoMultiple:Boolean;
		
		// they are unsigned, so if they're -1, they're not initialized.
		public var inPoint:Number = UNINITIALIZED;
		public var outPoint:Number = UNINITIALIZED;
		public var loopCount:int = UNINITIALIZED;
		
		/** pos44:32, leftLevel:16, rightLevel:16 */
		public var records:Vector.<Number> = new Vector.<Number>;
		
		public function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (object is SoundInfo)
			{
				var soundInfo:SoundInfo = object as SoundInfo;
				
				if ( (soundInfo.syncStop == this.syncStop) &&
					(soundInfo.syncNoMultiple == this.syncNoMultiple) &&
					(soundInfo.inPoint == this.inPoint) &&
					(soundInfo.outPoint == this.outPoint) &&
					(soundInfo.loopCount == this.loopCount))
				{
					isEqual = true;
				}
				
				if (soundInfo.records.length != this.records.length) {
					return (false);
				}
				
				for (var i:int =0; i <soundInfo.records.length; i++) {
					if (soundInfo.records[i] != this.records[i]) {
						isEqual = false;
					}
				}
			}
			
			return isEqual;
		}
	}
}