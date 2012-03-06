/****************************************************************************
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2012 Adobe Systems Incorporated and it’s licensors
 * All Rights Reserved.
 *  
 * NOTICE: Adobe permits you to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 * ****************************************************************************/

package osUtils
{
	import flash.events.Event;

	public class WebServerEvent extends Event
	{
		public function WebServerEvent(type:String, mString:String = "")
		{
			// Call the constructor of the superclass.
			super(type);
			
			// Set the new property.
			this._message = mString;
		}
		
		/**
		 * Used as a return Event for WebServer.
		 */
		public static const GENERAL_ERROR:String = "generalError";
		
		
		/**
		 * Override the inherited clone() method.
		 * 
		 * @return A WebServerEvent
		 */
		override public function clone():Event {
			return new WebServerEvent(type, _message);
		}
		
		private var _message:String;
		
		public function get message():String {
			return (_message);
		}
		
		public function set message(str:String):void {
			this._message = str;
		}
	}
}