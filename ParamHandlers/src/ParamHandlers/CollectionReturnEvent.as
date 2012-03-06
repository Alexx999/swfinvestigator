/****************************************************************************
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2012 Adobe Systems Incorporated and it’s licensors
 * All Rights Reserved.
 *  
 * NOTICE: Adobe permits you to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 * ****************************************************************************/

package ParamHandlers
{
	import flash.events.Event;
	
	/**
	 * The CollectionReturnEvent class is fired when an object collection has closed.
	 */
    public class CollectionReturnEvent extends Event
    {

        // Public constructor.
        public function CollectionReturnEvent(type:String, enabled:Boolean=false) {
                // Call the constructor of the superclass.
                super(type);
    
                // Set the new property.
                this._isEnabled = enabled;
        }
        
        /**
         * When used as a return Event for ObjectCollection
         */
        public static const PARAMS_RETURNED:String = "paramsReturned";

		/**
		 * When used to instruct the hosting environment to launch the ObjectEditor
		 */
		public static const LAUNCH_EDITOR:String = "launchEditor";

		
        // Define a public variable to hold the state of the enable property.
        private var _isEnabled:Boolean;
		
		
		public function get isEnabled():Boolean {
			return _isEnabled;
		}
		

		/**
		 * Override the inherited clone() method.
		 * 
		 * @return A PopUpReturnEvent
		 */
        override public function clone():Event {
            return new CollectionReturnEvent(type, _isEnabled);
        }

    }
}

