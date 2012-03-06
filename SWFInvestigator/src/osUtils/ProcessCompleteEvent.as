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
    public class ProcessCompleteEvent extends Event
    {

        // Public constructor.
        public function ProcessCompleteEvent(type:String, eCode:int = 0, dArray:Array=null) {
                // Call the constructor of the superclass.
                super(type);
    
                // Set the new property.
                this._dataArray = dArray;
				
				this._exitCode = eCode;
        }

		/**
         * Used as a return Event for NativeProcessHandler.
         */
        public static const PROCESS_EXIT:String = "processExit";

		/**
         * Used as a return Event for NativeProcessHandler.
         */
        public static const IO_ERROR:String = "ioError";

		/**
		 * Used as a return Event for NativeProcessHandler.
		 */
		public static const GENERAL_ERROR:String = "generalError";


		/**
		 * @private
		 * Holds the returned data from the process
		 */
		private var _dataArray:Array;
		
		public function get dataArray():Array {
			return _dataArray;
		}
		
		/**
		 * @private
		 * The exit code from the process
		 */
		private var _exitCode:int;
		
		public function get exitCode():int {
			return (_exitCode);
		}

		/**
		 * Override the inherited clone() method.
		 * 
		 * @return A ProcessCompleteEvent
		 */
        override public function clone():Event {
            return new ProcessCompleteEvent(type, _exitCode, dataArray);
        }
    }
}

