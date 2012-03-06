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
	import flash.utils.ByteArray;

		
	/**
	 * Represents a DefineSound SWF tag.
	 *
	 * @author Clement Wong
	 */
	public class DefineSound extends DefineTag
	{
		public function DefineSound()
		{
			super(stagDefineSound);
		}
		
		public override function visit(h:TagHandler):void
		{
			h.defineSound(this);
		}
		
		public var format:int;
		public var rate:int;
		public var soundSize:int;
		public var soundType:int;
		public var sampleCount:Number; // U32
		public var data:ByteArray;
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is DefineSound))
			{
				var defineSound:DefineSound = object as DefineSound;
				
				if ( (defineSound.format == this.format) &&
					(defineSound.rate == this.rate) &&
					(defineSound.soundSize == this.soundSize) &&
					(defineSound.soundType == this.soundType) &&
					(defineSound.sampleCount == this.sampleCount) )
				{
					isEqual = true;
				} else {
					return false;
				}
				
				if (defineSound.data == null && this.data == null) {
					return true;
				}
				
				if (defineSound.data != null && this.data != null &&
					defineSound.data.length == this.data.length) {
					for (var i:int = 0; i < defineSound.data.length; i++) {
						if (defineSound.data[i] != this.data[i]) {
							return (false);
						}
					}
				} else {
					return false;
				}
			}
			
			return isEqual;
		}
	}

}