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
	import decompiler.tamarin.abcdump.Tag;
	import decompiler.swfdump.TagHandler;
	import flash.utils.ByteArray;
	
	public class VideoFrame extends Tag
	{
		public var stream:DefineVideoStream;
		public var frameNum:int;
		public var videoData:ByteArray;
		
		public function VideoFrame()
		{
			super(stagVideoFrame);
		}
		
		public override function visit(h:TagHandler):void
		{
			h.videoFrame(this);
		}
		
		public function getSimpleReference():Tag
		{
			return stream;
		}
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is VideoFrame))
			{
				var videoFrame:VideoFrame = object as VideoFrame;
				
				if ( objectEquals(videoFrame.stream, this.stream) &&
					(videoFrame.frameNum == this.frameNum) &&
					videoFrame.videoData.length == this.videoData.length) {
					isEqual = true;
				}

				for (var i:int = 0; i < videoData.length; i ++) {
					if (videoFrame.videoData[i] != videoData[i]) {
						isEqual = false;
					}
				}
			}
			
			return isEqual;
		}
	}
}