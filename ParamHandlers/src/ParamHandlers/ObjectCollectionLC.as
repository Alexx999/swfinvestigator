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
	import flash.events.EventDispatcher;
	import flash.net.LocalConnection;
	
	
	/**
	 * Dispatched the status of the send
	 * 
	 * @eventType StatusEvent.STATUS
	 */
	[Event(name="paramsReturned", type="CollectionReturnEvent")]
	
	
	public class ObjectCollectionLC extends EventDispatcher
	{
		public var returnedObject:*;
		
		private var lConn:LocalConnection;
		
		private var lConnAddress:String;
				
		public function ObjectCollectionLC()
		{
			this.lConn = new LocalConnection();
			this.lConn.client = this;
			
			//One of the few times I actually mean this...
			this.lConn.allowDomain("*");
			
			var rNum:Number = Math.round(Math.random() * 100000);
			
			//Hopefull this will avoid name collisions
			this.lConn.connect("objectReceiver-" + rNum.toString());
			
			this.lConnAddress = this.lConn.domain + ":objectReceiver-" + rNum.toString();
		}
		
		public function fetchOEValue():void {
			this.lConn.send("app#FlashAnalyzer:objectEditor","sendObject",this.lConnAddress);
		}
		
		public function objectReceiver(theObject:*):void {
			this.returnedObject = theObject;
			dispatchEvent(new CollectionReturnEvent(CollectionReturnEvent.PARAMS_RETURNED));
		}
		
		public function close():void {
			this.lConn.close();
		}
	}
}