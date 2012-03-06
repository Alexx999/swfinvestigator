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
	import decompiler.swfdump.types.SoundInfo;
	import decompiler.tamarin.abcdump.Tag;
	
	/**
	 * This represents a StartSound SWF tag.
	 *
	 * @author Clement Wong
	 */
	public class StartSound extends Tag
	{
		public function StartSound()
		{
			super(stagStartSound);
		}
		
		public override function visit(h:TagHandler):void
		{
			h.startSound(this);
		}
		
		public function getSimpleReference():Tag
		{
			return sound;
		}
		
		/**
		 * ID of sound character to play
		 */
		public var sound:DefineSound;
		
		/**
		 * sound style information
		 */
		public var soundInfo:SoundInfo;
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is StartSound))
			{
				var startSound:StartSound = object as StartSound;
				
				if ( objectEquals(startSound.sound, this.sound) &&
					objectEquals(startSound.soundInfo, this.soundInfo))
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
	}
}