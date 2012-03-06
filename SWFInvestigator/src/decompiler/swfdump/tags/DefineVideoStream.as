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
	
	public class DefineVideoStream extends DefineTag
	{
		public var numFrames:int;
		public var width:int;
		public var height:int;
		public var deblocking:int;
		public var smoothing:Boolean;
		public var codecID:int;
		
		public function DefineVideoStream()
		{
			super(stagDefineVideoStream);
		}
		
		public override function visit(h:TagHandler):void
		{
			h.defineVideoStream(this);
		}
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is DefineVideoStream))
			{
				var defineVideoStream:DefineVideoStream = object as DefineVideoStream;
				
				if ( (defineVideoStream.numFrames == this.numFrames) &&
					(defineVideoStream.width == this.width) &&
					(defineVideoStream.height == this.height) &&
					(defineVideoStream.deblocking == this.deblocking) &&
					(defineVideoStream.smoothing == this.smoothing) &&
					(defineVideoStream.codecID == this.codecID) )
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
	}
}