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
	import decompiler.swfdump.types.FlashUUID;
	import decompiler.swfdump.types.MD5;
	
	import flash.utils.ByteArray;

	public final class FlashUUID
	{
		private static const kUUIDSize:int = 16;
		
		public function FlashUUID(b:ByteArray)
		{
			if (b == null) b = new ByteArray();
			this.bytes = bytes;
		}
		

		public var bytes:ByteArray;
		
		public function toString():String
		{
			//return MD5.stringify(bytes);
			return (MD5.hashBinary(this.bytes));
		}
		
		public function hashCode():int
		{
			var length:int = bytes.length;
			var code:int = length;
			for (var i:int=0; i < length; i++)
			{
				code = (code << 1) ^ bytes[i];
			}
			return code;
		}
		
		public function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (object is FlashUUID)
			{
				var flashUUID:FlashUUID = (object as FlashUUID);
				var test:Boolean;
				
				if (flashUUID.bytes.length != this.bytes.length) {
					return (false);
				}
				
				for (var i:int = 0; i < this.bytes.length; i++) {
					if (this.bytes[i] != flashUUID.bytes[i]) {
						return (false);
					}
				}

				isEqual = true;
			}
			
			return isEqual;
		}
	}
}