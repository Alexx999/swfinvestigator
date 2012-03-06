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
	import decompiler.swfdump.types.SoundInfo;
	
	public class DefineButtonSound extends Tag
	{
		public function DefineButtonSound()
		{
			super(stagDefineButtonSound);
		}

		
		public override function visit(h:TagHandler):void
		{
			h.defineButtonSound(this);
		}
		
		/**
		public Iterator<Tag> getReferences()
		{
			ArrayList<Tag> list = new ArrayList<Tag>(5);
			list.add(button);
			if (sound0 != null)
				list.add(sound0);
			if (sound1 != null)
				list.add(sound1);
			if (sound2 != null)
				list.add(sound2);
			if (sound3 != null)
				list.add(sound3);
			return list.iterator();
		}
		 */
		
		public var sound0:DefineTag;
		public var info0:SoundInfo;
		public var sound1:DefineTag;
		public var info1:SoundInfo;
		public var sound2:DefineTag;
		public var info2:SoundInfo;
		public var sound3:DefineTag;
		public var info3:SoundInfo;
		
		public var button:DefineButton;
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is DefineButtonSound))
			{
				var defineButtonSound:DefineButtonSound = object as DefineButtonSound;
				
				// [ed] don't compare button because that would be infinite recursion
				if ( objectEquals(defineButtonSound.sound0, this.sound0) &&
					objectEquals(defineButtonSound.info0, this.info0) &&
					objectEquals(defineButtonSound.sound1, this.sound1) &&
					objectEquals(defineButtonSound.info1, this.info1) &&
					objectEquals(defineButtonSound.sound2, this.sound2) &&
					objectEquals(defineButtonSound.info2, this.info2) &&
					objectEquals(defineButtonSound.sound3, this.sound3) &&
					objectEquals(defineButtonSound.info3, this.info3))
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
	}
}