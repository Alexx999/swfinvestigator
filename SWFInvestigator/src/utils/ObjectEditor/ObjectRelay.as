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
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.net.LocalConnection;
	
	import utils.ObjectEditor.ObjectRelayEvent;

	/**
	 * Dispatched the status of the send
	 * 
	 * @eventType StatusEvent.STATUS
	 */
	[Event(name="status", type="StatusEvent")]
	
	/**
	 * Dispatched when an object has been received
	 * 
	 * @eventType ObjectRelayEvent.OBJECT_RECEIVED
	 */
	[Event(name="objectReceived", type="ObjectRelayEvent")]

	/**
	 * Dispatched when the Relay fails to set up the LC.connect
	 * 
	 * @eventType ObjectRelayEvent.INIT_ERROR
	 */
	[Event(name="initError", type="ObjectRelayEvent")]

	/**
	 * Dispatched when a remote editor wants the current object
	 * 
	 * @eventType ObjectRelayEvent.SEND_REQUEST
	 */
	[Event(name="sendRequest", type="ObjectRelayEvent")]
	
	public class ObjectRelay extends EventDispatcher
	{
		private var lConn:LocalConnection;
		
		public var remoteConnection:String;
		
		public var connected:Boolean = false;
		
		public function ObjectRelay()
		{
			this.lConn = new LocalConnection();
			this.lConn.client = this;
			
			//One of the few times I actually mean this...
			this.lConn.allowDomain("*");
			this.lConn.addEventListener(StatusEvent.STATUS, onStatus);
		}
		
		/**
		 * @public
		 * Attempt to set up a LocalConnection listener on "objectEditor"
		 */
		public function initConnection():void {
			try {
				this.lConn.connect("objectEditor");
				this.connected = true;
			} catch (argError:ArgumentError) {
				dispatchEvent(new ObjectRelayEvent(ObjectRelayEvent.INIT_ERROR));
			}
		}
		
		/**
		 * @private
		 * Just pass the status event up the food chain
		 * 
		 * @param e The StatusEvent.STATUS event.
		 */
		private function onStatus (e:StatusEvent):void {
			dispatchEvent(e);
		}
		
		/**
		 * @public
		 * This is called via LocalConnection to request an object from the Object Editor
		 * 
		 * @param theConnName Where the object should be sent back via LocalConnection
		 */
		public function sendObject(theConnName:String):void {
			this.remoteConnection = theConnName;
			dispatchEvent(new ObjectRelayEvent(ObjectRelayEvent.SEND_REQUEST));
		}
		
		/**
		 * @public
		 * Send an edited object back to the caller
		 * 
		 * @param theObject The object to be sent back
		 */
		public function returnObject(theObject:*):void {
			lConn.send(this.remoteConnection, "objectReceiver",theObject);
		}
		
		/**
		 * @public
		 * Called when an object needs to be edited in the Object Editor
		 * 
		 * @param theObject The Object that will be edited.
		 */
		public function editObject(theObject:*):void {
			var orEvent:ObjectRelayEvent = new ObjectRelayEvent(ObjectRelayEvent.OBJECT_RECEIVED, theObject); 
			dispatchEvent(orEvent);
		}
		
		/**
		 * @public
		 * Called to unregister the LocalConnection
		 */
		public function close():void {
			this.lConn.close();
		}
	}
}