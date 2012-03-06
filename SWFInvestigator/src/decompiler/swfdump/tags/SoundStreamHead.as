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
	
	/**
	 * This represents a SoundStreamHead SWF tag.
	 *
	 * @author Clement Wong
	 */
	public class SoundStreamHead extends Tag
	{
		public static const sndCompressNone:int = 0;
		public static const sndCompressADPCM:int = 1;
		public static const sndCompressMP3:int = 2;
		public static const sndCompressNoneI:int = 3;
		
		public function SoundStreamHead(code:int)
		{
			super(code);
		}
		
		public override function visit(h:TagHandler):void
		{
			if (code == stagSoundStreamHead)
				h.soundStreamHead(this);
			else
				h.soundStreamHead2(this);
		}
		
		public var playbackRate:int;
		public var playbackSize:int;
		public var playbackType:int;
		public var compression:int;
		public var streamRate:int;
		public var streamSize:int;
		public var streamType:int;
		public var streamSampleCount:int;
		public var latencySeek:int;
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is SoundStreamHead))
			{
				var soundStreamHead:SoundStreamHead = object as SoundStreamHead;
				
				if ((soundStreamHead.playbackRate == this.playbackRate) &&
					(soundStreamHead.playbackSize == this.playbackSize) &&
					(soundStreamHead.playbackType == this.playbackType) &&
					(soundStreamHead.compression == this.compression) &&
					(soundStreamHead.streamRate == this.streamRate) &&
					(soundStreamHead.streamSize == this.streamSize) &&
					(soundStreamHead.streamType == this.streamType) &&
					(soundStreamHead.streamSampleCount == this.streamSampleCount) &&
					(soundStreamHead.latencySeek == this.latencySeek))
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
	}

}