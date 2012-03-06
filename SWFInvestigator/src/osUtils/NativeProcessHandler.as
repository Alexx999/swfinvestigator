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
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;


	/**
	 * Dispatched when the user chooses 
	 * 
	 * @eventType OSUtils.ProcessReturnEvent.GENERAL_ERROR
	 */
	[Event(name="generalError", type="ProcessReturnEvent")]

	/**
	 * Dispatched when the user chooses to Open the selected URL
	 * 
	 * @eventType OSUtils.ProcessReturnEvent.IO_ERROR
	 */
	[Event(name="ioError", type="ProcessReturnEvent")]
	
	/**
	 * Dispatched when the user chooses to Open the selected URL
	 * 
	 * @eventType OSUtils.ProcessReturnEvent.PROCESS_EXIT
	 */
	[Event(name="processExit", type="ProcessReturnEvent")]
	
	public class NativeProcessHandler extends EventDispatcher
	{
		private var nProcess:NativeProcess;
		
		private var outArray:Array;
		
		private var nProcessStartupInfo:NativeProcessStartupInfo;
		
		private var maxOutputLength:int = -1;
		private var currentArrPos:int = 0;
		
		/**
		 * @public
		 * Constructor class for Native Process Handler
		 * 
		 * @param path The path to the executable
		 * @param arguments The arguments to supply to the executable
		 * @param maxOutput (Optional) The max output length. A value of -1 means everything in one string.
		 */
		public function NativeProcessHandler(path:String, arguments:String, maxOutput:int = -1)
		{
			this.maxOutputLength = maxOutput;
			
			this.nProcessStartupInfo = new NativeProcessStartupInfo();
			this.nProcessStartupInfo.executable = new File(path);
			//this.nProcessStartupInfo.workingDirectory = new File(path.substring(0,path.lastIndexOf("/")));
			
			var processArgs:Vector.<String> = new Vector.<String>();
			var args:Array = arguments.split(/ /);
			for (var i:int = 0; i < args.length; i++) {
				processArgs[i] = args[i];
			}
			this.nProcessStartupInfo.arguments = processArgs;			
		}
		
		/**
		 * @public
		 * Launches the Native Process
		 */
		public function launchProcess():void {
			this.nProcess = new NativeProcess();
			this.nProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, nProcessOnOutputData);
			this.nProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, nProcessOnErrorData);
			this.nProcess.addEventListener(NativeProcessExitEvent.EXIT, nProcessOnExit);
			this.nProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, nProcessOnIOError);
			this.nProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, nProcessOnIOError);
			this.nProcess.start(nProcessStartupInfo);
		}
		
		/**
		 * @private
		 * Event handler for receiving output data
		 * 
		 * @param event A ProgressEvent from NativeProcess
		 */
		private function nProcessOnOutputData(event:ProgressEvent):void
		{
			if (this.outArray == null) {
				this.outArray = new Array();
			}
			
			var str:String = this.nProcess.standardOutput.readUTFBytes(this.nProcess.standardOutput.bytesAvailable);
			
			if (this.outArray[0] == null && this.maxOutputLength == -1) {
				this.outArray[0] = str;
			} else if (this.outArray[0] == null && str.length < this.maxOutputLength) {
				this.outArray[0] = str;
			} else if (this.maxOutputLength == -1 || (this.maxOutputLength != -1 && this.outArray[this.currentArrPos].length + str.length < this.maxOutputLength)) {
				this.outArray[this.currentArrPos] = this.outArray[this.currentArrPos] + str;
			} else {
				var spaceLeft:int = this.maxOutputLength - this.outArray[this.currentArrPos].length;
				this.outArray[this.currentArrPos] = this.outArray[this.currentArrPos] + str.substring(0,spaceLeft);
				this.currentArrPos ++;
					
				var numParts:int = (str.substr(spaceLeft).length / this.maxOutputLength) + 1;
				var curPos:int = spaceLeft;
				for (var i:int = 0; i <numParts; i++) {
					this.outArray[this.currentArrPos] = str.substring(curPos,curPos + this.maxOutputLength);
					curPos = curPos + this.maxOutputLength;
					if (numParts != i + 1) {
						this.currentArrPos++;
					}
				}
			}
		}
		
		/**
		 * @private
		 * Called when a decompiler Native Process encounters an Error event
		 * 
		 * @param event The Error Event
		 */
		private function nProcessOnErrorData(event:ProgressEvent):void
		{
			if (this.outArray == null) { 
				this.outArray = new Array();
				this.outArray[0] = "ERROR -" + this.nProcess.standardError.readUTFBytes(this.nProcess.standardError.bytesAvailable);
			} else {
				this.outArray[this.currentArrPos] = this.outArray[this.currentArrPos] + "ERROR -" + this.nProcess.standardError.readUTFBytes(this.nProcess.standardError.bytesAvailable);
			}
			

			var newEvent:ProcessCompleteEvent = new ProcessCompleteEvent(ProcessCompleteEvent.GENERAL_ERROR,0,this.outArray);
			dispatchEvent(newEvent);
		}
		
		/**
		 * @private
		 * Called when a decompiler Native Process exits
		 * 
		 * @param event The Native Process Exit Event
		 */
		private function nProcessOnExit(event:NativeProcessExitEvent):void
		{
			var newEvent:ProcessCompleteEvent = new ProcessCompleteEvent(ProcessCompleteEvent.PROCESS_EXIT,event.exitCode,this.outArray);
			dispatchEvent(newEvent);
		}
		
		/**
		 * @private
		 * Called when a decompiler Native Process encounters an IO error event
		 * 
		 * @param event The IO Error Event
		 */
		private function nProcessOnIOError(event:IOErrorEvent):void
		{
			if (this.outArray == null) {
				this.outArray = new Array();
			}
			this.outArray[0] = "IOError in communicating with decompiler application\r" + event.toString();
			
			var newEvent:ProcessCompleteEvent = new ProcessCompleteEvent(ProcessCompleteEvent.IO_ERROR,0,this.outArray);
			dispatchEvent(newEvent);
		}
		
	}
}