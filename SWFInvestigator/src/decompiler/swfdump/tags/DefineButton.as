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
	import decompiler.swfdump.types.ButtonCondAction;
	import decompiler.swfdump.types.ButtonRecord;

	public class DefineButton extends DefineTag
	{
		
		public var buttonRecords:Vector.<ButtonRecord>;
		public var sounds:DefineButtonSound;
		public var cxform:DefineButtonCxform;
		public var scalingGrid:DefineScalingGrid;
		
		/**
		 * false = track as normal button
		 * true = track as menu button
		 */
		public var trackAsMenu:Boolean;
		
		//Added by SWF Investigator
		public var id:int;
		
		/**
		 * actions to execute at particular button events.  For defineButton
		 * this will only have one entry.  For defineButton2 it could have more
		 * than one entry for different conditions.
		 */
		public var condActions:Vector.<ButtonCondAction>;
		
		public function DefineButton(code:int)
		{
			super(code);
		}
		
		public override function visit(h:TagHandler):void
		{
			if (code == stagDefineButton)
				h.defineButton(this);
			else
				h.defineButton2(this);
		}
		
		/**
		public Iterator<Tag> getReferences()
		{
			return new Iterator<Tag>()
				{
					private int record = 0;
					
					public boolean hasNext()
					{
						// skip null entries
						while (record < buttonRecords.length && buttonRecords[record].characterRef == null)
							record++;
						return record < buttonRecords.length;
					}
					public Tag next()
					{
						if ( !hasNext() )
							throw new NoSuchElementException();
						return buttonRecords[record++].characterRef;
					}
					public void remove()
					{
						throw new UnsupportedOperationException();
					}
				};
		}
		 */

		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is DefineButton))
			{
				var defineButton:DefineButton = object as DefineButton;
				
				if (defineButton.trackAsMenu != this.trackAsMenu) {
					return (isEqual);
				}
				
				if (defineButton.buttonRecords.length != this.buttonRecords.length
					|| defineButton.condActions.length != this.condActions.length) {
					return (isEqual);
				}
				
				if (!(objectEquals(defineButton.sounds, this.sounds))
					|| !(objectEquals(defineButton.cxform, this.cxform))) {
						return (isEqual)
				}
				
				isEqual = true;
				var i:int = 0;
				
				for (i = 0; i<defineButton.buttonRecords.length; i++) {
					if (this.buttonRecords[i] != defineButton.buttonRecords[i]) {
						isEqual = false;
					}
				}
				
				for (i = 0; i<defineButton.condActions.length; i++) {
					if (this.condActions[i] != defineButton.condActions[i]) {
						isEqual = false;
					}
				}
			}
			
			return isEqual;
		}
	}
}