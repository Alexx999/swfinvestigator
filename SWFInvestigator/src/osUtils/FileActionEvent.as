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
	
	/**
	 * The PopUpReturnEvent class is used by GetSWFURL and ObjectCollection to signal when they completed obtaining data.
	 */
	public class FileActionEvent extends Event
	{
		
		// Public constructor.
		public function FileActionEvent(type:String, mString:String = "") {
			// Call the constructor of the superclass.
			super(type);
			
			// Set the new property.
			this._message = mString;
		}
		
		/**
		 * Used as a return Event for FileActions.
		 */
		public static const OPEN_RO_COMPLETE:String = "openROComplete";

		/**
		 * Used as a return Event for FileActions.
		 */
		public static const OPEN_RW_COMPLETE:String = "openRWComplete";

		/**
		 * Used as a return Event for FileActions.
		 */
		public static const CREATE_COMPLETE:String = "createComplete";
		
		/**
		 * Used as a return Event for FileActions.
		 */
		public static const IO_ERROR:String = "ioError";
		
		/**
		 * Used as a return Event for FileActions.
		 */
		public static const GENERAL_ERROR:String = "generalError";
		
		
		/**
		 * Override the inherited clone() method.
		 * 
		 * @return A FileActionEvent
		 */
		override public function clone():Event {
			return new FileActionEvent(type, _message);
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

