/****************************************************************************
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2012 Adobe Systems Incorporated and it’s licensors
 * All Rights Reserved.
 *  
 * NOTICE: Adobe permits you to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 * ****************************************************************************/

package popUps
{
	import flash.events.Event;
	
	/**
	 * The PopUpReturnEvent class is used by GetSWFURL and ObjectCollection to signal when they completed obtaining data.
	 */
    public final class PopUpReturnEvent extends Event
    {
		
		// Define a public variable to hold the state of the enable property.
		private var _isEnabled:Boolean;

        // Public constructor.
        public function PopUpReturnEvent(type:String, enabled:Boolean=false) {
                // Call the constructor of the superclass.
                super(type);
    
                // Set the new property.
                this._isEnabled = enabled;
        }
		
		public function get isEnabled():Boolean {
			return (_isEnabled);
		}

		/**
         * When used as a return Event for GetSwfUrl.
         */
        public static const URL_RETURNED:String = "urlReturned";

		/**
         * When used as a return Event for GetFileLocation.
         */
        public static const FILE_RETURNED:String = "fileReturned";

		/**
		 * Override the inherited clone() method.
		 * 
		 * @return A PopUpReturnEvent
		 */
        override public function clone():Event {
            return new PopUpReturnEvent(type, _isEnabled);
        }
    }
}

