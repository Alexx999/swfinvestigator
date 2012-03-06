/****************************************************************************
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2012 Adobe Systems Incorporated and it’s licensors
 * All Rights Reserved.
 *  
 * NOTICE: Adobe permits you to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 * ****************************************************************************/

package LCReceiver
{
	import flash.events.Event;

	/**
	 * A custom Event for LCReceiver Class.
	 */
	public class LCReceiverEvent extends Event
	{
		public function LCReceiverEvent(type:String, args:Array = null)
		{
			super(type);
			this._args = args;
		}
		
		// Define static constant.
        public static const CONNECTION_RETURNED:String = "connectionReturned";

		// Define static constant.
        public static const STATUS_RETURNED:String = "statusReturned";
        
        // Define a public variable to hold the state of the args property.
        private var _args:Array;

        // Define a public variable to hold the state of the args property.
        private var _status:String;
        
        // Override the inherited clone() method.
        override public function clone():Event {
            return new LCReceiverEvent(type, _args);
        }
		
		public function get args():Array {
			return (_args);
		}
		
		/**
		public function set args(argArr:Array):void {
			pArgs = argArr;
		}
		 */
		
		public function get status():String {
			return (_status);
		}
		
		public function set status(str:String):void {
			_status = str;
		}
	}
}