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
	import decompiler.swfdump.types.ClipActionRecord;
	
	public class ClipActions
	{
		/**
		 * All events used in these clip actions
		 */
		public var allEventFlags:int;
		
		/**
		 * Individual event handlers.  List of ClipActionRecord instances.
		 */
		public var clipActionRecords:Vector.<ClipActionRecord>;
		
		public function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (object is ClipActions)
			{
				var clipActions:ClipActions = object as ClipActions;
				
				if (clipActions.allEventFlags != this.allEventFlags)
					return false;
				
				if ((clipActions.clipActionRecords == null) && (this.clipActionRecords == null))
					return true;
				
				if ((clipActions.clipActionRecords == null) || (this.clipActionRecords == null))
					return false;
				
					
				if (clipActions.clipActionRecords.length != this.clipActionRecords.length) {
					return false;
				}
				
				for (var i:int = 0; i < this.clipActionRecords.length; i++) {
					if (clipActions.clipActionRecords[i] != this.clipActionRecords[i]) {
						return false;
					}
				}
				
				isEqual = true;
			}
			
			return isEqual;
		}
	}
}