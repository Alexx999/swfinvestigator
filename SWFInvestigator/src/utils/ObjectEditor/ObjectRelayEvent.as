/****************************************************************************
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2012 Adobe Systems Incorporated and it’s licensors
 * All Rights Reserved.
 *  
 * NOTICE: Adobe permits you to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 * ****************************************************************************/
package utils.ObjectEditor
{
	import flash.events.Event;

	public class ObjectRelayEvent extends Event
	{
		private var _sentObject:*;
		
		public function ObjectRelayEvent(type:String,returnObj:* = null)
		{
			// Call the constructor of the superclass.
			super(type);
			
			this._sentObject = returnObj;
		}
		
		/**
		 * Used as a return Event for ObjectRelay
		 */
		public static const OBJECT_RECEIVED:String = "objectReceived";

		/**
		 * Used as a return Event for ObjectRelay
		 */
		public static const SEND_REQUEST:String = "sendRequest";
		
		/**
		 * Used as an error Event for ObjectRelay
		 */
		public static const INIT_ERROR:String = "initError";
		
		
		/**
		 * Override the inherited clone() method.
		 * 
		 * @return A ObjectRelayEvent
		 */
		override public function clone():Event {
			return new ObjectRelayEvent(type, _sentObject);
		}
		
		public function get sentObject ():* {
			return _sentObject;
		}
	}
}