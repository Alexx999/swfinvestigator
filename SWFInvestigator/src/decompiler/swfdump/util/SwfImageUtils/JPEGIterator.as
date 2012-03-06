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

package decompiler.swfdump.util.SwfImageUtils
{
	import flash.utils.ByteArray;
	
	/**
	 * A variety of utilities for dealing with the image formats that are
	 * part of the SWF spec.
	 *
	 * @author Roger Gonzalez
	 */
	
	public class JPEGIterator
	{
		private var jpeg:ByteArray = null;
		private var offset:int = 0;
		private var length:int = 0;
		private var nextOffset:int = -1;
		private var valid:Boolean = false;
		private var code:uint;
		
		public function JPEGIterator( jpeg:ByteArray )
		{
			this.jpeg = jpeg;
			reset();
		}
		
		public function getValid():Boolean
		{
			return this.valid;
		}
		
		public function getCode():uint
		{
			return this.code;
		}
		
		public function getLength():int
		{
			return this.length;
		}
		
		public function size():int
		{
			if ( !valid )
				return -1;
			
			if ( nextOffset == -1 )
				return jpeg.length - offset;
			else
				return nextOffset - offset;
		}
		
		
		public function getOffset():int
		{
			return this.offset;
		}
		
		public function reset():Boolean
		{
			valid = ((jpeg.length >= 4)
				&& (jpeg[0] == 0xff)
				&& (jpeg[1] == 0xd8)
				&& (jpeg[jpeg.length-2] == 0xff)
				&& (jpeg[jpeg.length-1] == 0xd9));
			offset = 0;
			nextOffset = offsetOfNextBlock();
			code = jpeg[1];
			length = 0;
			return valid;
		}
		
		public function offsetOfNextBlock():int
		{
			var i:int = offset + 2 + length;
			
			while (i < jpeg.length)
			{
				if ((code == 0xda) && (jpeg[i] !=  0xff))
					++i;
				else if (i+1 >= jpeg.length)
					return -1;
				else if ( jpeg[i+1] == 0xff ) // padding
					++i;
				else if ((code == 0xda) && (jpeg[i+1] == 0x00))
					i += 2;
				else
					break;
			}
			
			return i;
		}
		
		public function next():Boolean
		{
			if (!valid)
				return false;
			
			// entry state assumes that we are on the
			// start of a valid record, i.e. that
			// offset points at 0xff and that offset+1
			// is a code.  if the current record has
			// a length, it is assumed to be set.
			
			offset = nextOffset;
			if ((offset >= jpeg.length) || (offset == -1))
			{
				valid = false;
				offset = jpeg.length;
				return false;
			}
			
			code = jpeg[offset+1];
			
			if ((code == 0x00) || (code == 0x01)
				|| ((code >= 0xd0) && (code <= 0xd9)))
			{
				length = 0;
			}
			else if (offset + 3 >= jpeg.length)
				valid = false;
			else
			{
				length = ((jpeg[offset+2]&0xff)<<8)
					+  (jpeg[offset+3]&0xff);
			}
			nextOffset = offsetOfNextBlock();
			return valid;
		}
	}
}