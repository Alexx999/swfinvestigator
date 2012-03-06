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
	public class ClipActionRecord
	{
		public static const unused31:int = 0x80000000;
		public static const unused30:int = 0x40000000;
		public static const unused29:int = 0x20000000;
		public static const unused28:int = 0x10000000;
		public static const unused27:int = 0x08000000;
		public static const unused26:int = 0x04000000;
		public static const unused25:int = 0x02000000;
		public static const unused24:int = 0x01000000;
		
		public static const unused23:int = 0x00800000;
		public static const unused22:int = 0x00400000;
		public static const unused21:int = 0x00200000;
		public static const unused20:int = 0x00100000;
		public static const unused19:int = 0x00080000;
		public static const construct:int = 0x00040000;
		public static const keyPress:int = 0x00020000;
		public static const dragOut:int = 0x00010000;
		
		public static const dragOver:int = 0x00008000;
		public static const rollOut:int = 0x00004000;
		public static const rollOver:int = 0x00002000;
		public static const releaseOutside:int = 0x00001000;
		public static const release:int = 0x00000800;
		public static const press:int = 0x00000400;
		public static const initialize:int = 0x00000200;
		public static const data:int = 0x00000100;
		
		public static const keyUp:int = 0x00000080;
		public static const keyDown:int = 0x00000040;
		public static const mouseUp:int = 0x00000020;
		public static const mouseDown:int = 0x00000010;
		public static const mouseMove:int = 0x00000008;
		public static const unload:int = 0x00000004;
		public static const enterFrame:int = 0x00000002;
		public static const load:int =  0x00000001;
		
		/**
		 * event(s) to which this handler applies
		 */
		public var eventFlags:int;
		
		/**
		 * if eventFlags.press is true, contains the key code to trap
		 * @see ButtonCondAction
		 */
		public var keyCode:int;
		
		/**
		 * actions to perform
		 */
		public var actionList:ActionList;
		
		public function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (object is ClipActionRecord)
			{
				var clipActionRecord:ClipActionRecord = object as ClipActionRecord;
				
				if ( (clipActionRecord.eventFlags == this.eventFlags) &&
					(clipActionRecord.keyCode == this.keyCode) &&
					( ( (clipActionRecord.actionList == null) && (this.actionList == null) ) ||
						( (clipActionRecord.actionList != null) && (this.actionList != null) &&
							clipActionRecord.actionList.equals(this.actionList) ) ) )
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
		
		public function hasKeyPress():Boolean
		{
			return (eventFlags & keyPress) != 0;
		}
	}
}