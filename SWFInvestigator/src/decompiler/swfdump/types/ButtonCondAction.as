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
	//NEEDED FOR SWF DISASSEMBLY
	public class ButtonCondAction
	{
		/**
		 * SWF 4+: key code
		 Otherwise: always 0
		 Valid key codes:
		 1: left arrow
		 2: right arrow
		 3: home
		 4: end
		 5: insert
		 6: delete
		 8: backspace
		 13: enter
		 14: up arrow
		 15: down arrow
		 16: page up
		 17: page down
		 18: tab
		 19: escape
		 32-126: follows ASCII
		 */
		public var keyPress:int;
		
		public var overDownToIdle:Boolean;
		public var idleToOverDown:Boolean;
		public var outDownToIdle:Boolean;
		public var outDownToOverDown:Boolean;
		public var overDownToOutDown:Boolean;
		public var overDownToOverUp:Boolean;
		public var overUpToOverDown:Boolean;
		public var overUpToIdle:Boolean;
		public var idleToOverUp:Boolean;
		
		/**
		 * actions to perform when this event is detected.
		 */
		public var actionList:ActionList;
		
		public function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (object is ButtonCondAction)
			{
				var buttonCondAction:ButtonCondAction = object as ButtonCondAction;
				
				if ( (buttonCondAction.keyPress == this.keyPress) &&
					(buttonCondAction.overDownToIdle == this.overDownToIdle) &&
					(buttonCondAction.idleToOverDown == this.idleToOverDown) &&
					(buttonCondAction.outDownToIdle == this.outDownToIdle) &&
					(buttonCondAction.outDownToOverDown == this.outDownToOverDown) &&
					(buttonCondAction.overDownToOutDown == this.overDownToOutDown) &&
					(buttonCondAction.overDownToOverUp == this.overDownToOverUp) &&
					(buttonCondAction.overUpToOverDown == this.overUpToOverDown) &&
					(buttonCondAction.overUpToIdle == this.overUpToIdle) &&
					(buttonCondAction.idleToOverUp == this.idleToOverUp) &&
					( ( (buttonCondAction.actionList == null) && (this.actionList == null) ) ||
						( (buttonCondAction.actionList != null) && (this.actionList != null) &&
							buttonCondAction.actionList.equals(this.actionList) ) ) )
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
		
		public function toString():String
		{
			// return the flags as a string
			var b:String = new String();
			
			if (keyPress != 0)      b += "keyPress<"+keyPress+">,";
			if (overDownToIdle)		b += "overDownToIdle,";
			if (idleToOverDown)		b += "idleToOverDown,";
			if (outDownToIdle)		b += "outDownToIdle,";
			if (outDownToOverDown)	b += "outDownToOverDown,";
			if (overDownToOutDown)	b += "overDownToOutDown,";
			if (overDownToOverUp)	b += "overDownToOverUp,";
			if (overUpToOverDown)	b += "overUpToOverDown,";
			if (overUpToIdle)		b += "overUpToIdle,";
			if (idleToOverUp)		b += "idleToOverUp,";
			
			// trim trailing comma
			if (b.length > 0)
				b = b.substr(0,b.length - 1);
			
			return b;
		}
	}
}