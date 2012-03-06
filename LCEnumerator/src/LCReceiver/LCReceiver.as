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
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.net.LocalConnection;
	
	[Event(name="connectionReturned", type="LCReceiver.LCReceiverEvent")]
	[Event(name="statusReturned", type="LCReceiver.LCReceiverEvent")]
	/**
	 * A generic class for a LocalConnection so as not to expose the main SWF functions.
	 */
	public dynamic class LCReceiver extends EventDispatcher
	{
		private var conn:LocalConnection;
		
		/**
		 * Constructor
		 * Sets up LocalConnection
		 */
		public function LCReceiver(allowDomain:String="")
		{
			this.conn = new LocalConnection;
			if (allowDomain.length > 0) {
				this.conn.allowDomain(allowDomain);
			}
			this.conn.client = this;
		}
		
		/**
		 * @private
		 * Propogate a success or failure message to the main SWF
		 * 
		 * @param e A StatusEvent from the LocalConnection attempt to add a listener
		 */
		private function bubbleStatus(e:StatusEvent):void {
			var sEvent:LCReceiverEvent = new LCReceiverEvent(LCReceiverEvent.STATUS_RETURNED);
			switch (e.level) {
                case "status":
                    sEvent.status = "LocalConnection.receive() succeeded";
                    break;
                case "error":
                    sEvent.status = "LocalConnection.receive() failed";
                    break;
				default :
					sEvent.status = e.level + ": " + e.code;
            }
            	
            dispatchEvent(sEvent);
		}
		
		/**
		 * This function adds the args received from the LocalConnection into LCReceiver event to be passed to the parent SWF
		 * 
		 * @param args The array of arguments to send in the event handler
		 */
		public function bubbleArgs(args:Array):void {
			var aEvent:LCReceiverEvent = new LCReceiverEvent(LCReceiverEvent.CONNECTION_RETURNED,args);
			//aEvent.args = args;
			dispatchEvent(aEvent);
		}
		
		/**
		 * Attempt to add a LocalConnection.connect using supplied name.
		 * 
		 * @param connectionName The name of the function to listen on.
		 */
		public function connect(connectionName:String):void {
			this.conn.addEventListener(StatusEvent.STATUS,bubbleStatus);
			this.conn.connect(connectionName);
		}
		
		/**
		 * Close the LocalConnection
		 */
		public function close():void {
			try {
				this.conn.close();
			} catch (e:ArgumentError) {
				//Thrown if the connection was never opened.
				//Don't really care.
			}
		}
	}
}