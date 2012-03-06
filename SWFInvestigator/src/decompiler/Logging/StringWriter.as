/****************************************************************************
 * ADOBE SYSTEMS INCORPORATED
 *  Copyright 2012 Adobe Systems Incorporated and it’s licensors
 *  All Rights Reserved.
 *  
 * NOTICE: Adobe permits you to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 * ****************************************************************************/

package decompiler.Logging {
	
	import decompiler.Logging.ILog;

	/**
	 * This is a class used by the decompiler to output data.
	 */
	final public class StringWriter implements ILog {

		/**
		 * @public
		 * The String containing the output from the decompiler.
		 */
		public var output:String = "";
		
		/**
		 * @public
		 * The STring containing the error output from the decompiler.
		 */
		public var errorOutput:String = "";
		
		/**
		 * @public
		 * In the case of a long string, an array of strings can be used instead.
		 */
		public var outArray:Array = new Array();
		
		/**
		 * @public
		 * How many characters per page in the text viewer
		 */
		public var wrapLength:uint = 75000;
		
		/**
		 * @private
		 * The global defining whether to use a string or an array of Strings.  The default is one string.
		 */
		private var outType:String = "String";
		
		/**
		 * @private
		 * The current position within the array of output.
		 */
		private var currentIndex:int = 0;
		
		/**
		 * @private
		 * Whether to keep errors seperate
		 */
		private var seperateErrors:Boolean;
		
		/**
		 * @public
		 * Constructor
		 * 
		 * @param diffErrors Whether to log errors seperately from the main stream
		 */
		public function StringWriter(outputType:String = "String", diffErrors:Boolean = true) {
			this.outType = outputType;
			this.seperateErrors = diffErrors;
		}
		
		/**
		 * @public
		 * The print function that acts as a callback for the decompiler.  This will write information to a string and/or Array.
		 * 
		 * @param rest A ... rest list of things to print to the desired location.
		 */
		public function print( ... rest ):void 		
		{
			var prepend:String = "";
			
			if (rest.length == 0) {
				return;
			}
			
			if (outType == "Array") {
				if (this.outArray.length == 0) {
					this.outArray.push(new String());
				} else if (this.outArray[currentIndex].length >= this.wrapLength) {
					this.outArray.push(new String());
					this.currentIndex++;
				}
			}
			
			if (outType == "Array") {
				this.outArray[currentIndex] += prepend + rest;
			} else {
				this.output += prepend + rest;
			}
		}
		
		/**
		 * @public
		 * Store errors separetly?
		 * 
		 * @param ... The strings to save
		 */
		public function errorPrint (... rest):void {
			if (this.seperateErrors) {
				this.errorOutput += rest + "\r";
			} else {
				this.print(rest);
			}
		}
		
		/**
		 * @public
		 * Clear previous strings for re-use
		 */
		public function clear():void {
			this.errorOutput = "";
			this.output = "";
			this.outArray = [];
		}
		
	}
	
}