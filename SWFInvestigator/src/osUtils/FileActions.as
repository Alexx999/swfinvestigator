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
	import flash.errors.EOFError;
	import flash.errors.IOError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
	
	import osUtils.FileActionEvent;


	/**
	 * Dispatched when the user chooses 
	 * 
	 * @eventType FileActionEvent.OPEN_RO_COMPLETE
	 */
	[Event(name="openROComplete", type="osUtils.FileActionEvent")]

	/**
	 * Dispatched when the user chooses 
	 * 
	 * @eventType FileActionEvent.OPEN_RW_COMPLETE
	 */
	[Event(name="openRWComplete", type="osUtils.FileActionEvent")]

	/**
	 * Dispatched when the user chooses 
	 * 
	 * @eventType FileActionEvent.CREATE_COMPLETE
	 */
	[Event(name="createComplete", type="osUtils.FileActionEvent")]
	
	/**
	 * Dispatched when there is an IO Error 
	 * 
	 * @eventType FileActionEvent.IO_ERROR
	 */
	[Event(name="ioError", type="osUtils.FileActionEvent")]

	/**
	 * Dispatched when EOF is reached 
	 * 
	 * @eventType FileActionEvent.GENERAL_ERROR	 */
	[Event(name="generalError", type="osUtils.FileActionEvent")]

	
	public class FileActions extends EventDispatcher
	{
		public static const READ:String = "READ";
		public static const WRITE:String = "WRITE";
		public static const CREATE:String = "CREATE";
		
		/**
		 * @public
		 * Pointer to the current File.
		 * It is recommended that the calling class to the starting directory for the file browser.
		 */
		public var currentFile:File;
		

		/**
		 * @private
		 * Pointer to the current stream returned by currentStream
		 */
		private var curStream:FileStream;
		
		/**
		 * @public
		 * Pointer to the current File Stream
		 */
		public function get currentStream():FileStream {
			return (curStream);
		}
		
		/**
		 * @private
		 * Current Mode for the FileStream
		 */
		private var streamMode:String;
		
		/**
		 * @public
		 * Whether the stream is opened for READ, WRITE or CREATE
		 */
		public function get fileMode():String {
			return this.streamMode;
		}

		/**
		 * @private
		 * Tracks the fileState
		 */
		private var state:String;
		
		/**
		 * @public
		 * Whether the file is OPEN or CLOSED
		 */
		public function get fileState():String {
			return (this.state);
		}
		
		/**
		 * @private
		 * Pointer to a temp directory
		 */
		private var tempDir:File;

		/**
		 * @public
		 * Class Constructor
		 * 
		 * @param amfVer The AMF version if this will be an AMF Stream
		 */
		public function FileActions(amfVer:int = -1)
		{
			this.currentFile = new File();
			this.curStream = new FileStream();
			if (amfVer > -1) {
				this.curStream.objectEncoding = amfVer;
			}
		}
		
		/**
		 * @private
		 * Opens the selected file in READ_ONLY mode
		 * 
		 * @event Dispatches Event.COMPLETE when done
		 */
		private function openFileRO(evt:Event):void {
			this.currentFile = evt.target as File;
			try {
				this.curStream.open(this.currentFile, FileMode.READ);
			} catch (ioErr:IOError) {
				var faEvent:FileActionEvent = new FileActionEvent(FileActionEvent.IO_ERROR);
				faEvent.message = "Captured IOError trying to open RO File";
				dispatchEvent(faEvent);
				return;
			}
			this.state = "OPEN";
			dispatchEvent(new FileActionEvent(FileActionEvent.OPEN_RO_COMPLETE));
		}
		
		/**
		 * @private
		 * Opens the selected file for READS and WRITES
		 * 
		 * @event Dispatches Event.COMPLETE when done
		 */
		private function openFileRW(evt:Event):void {
			this.currentFile = evt.target as File;
			var faEvent:FileActionEvent;
			
			try {
				this.curStream.open(this.currentFile, FileMode.UPDATE);
			} catch (ioErr:IOError) {
				faEvent = new FileActionEvent(FileActionEvent.IO_ERROR);
				faEvent.message = "Captured IOError trying to open RW File";
				dispatchEvent(faEvent);
				return;
			} catch (secErr:SecurityError) {
				faEvent = new FileActionEvent(FileActionEvent.IO_ERROR);
				faEvent.message = "Captured Security Error trying to open RW File";
				dispatchEvent(faEvent);
				return;
			}
			this.state = "OPEN";
			dispatchEvent(new FileActionEvent(FileActionEvent.OPEN_RW_COMPLETE));
		}
		
		/**
		 * @private
		 * Opens a new file for writing
		 */
		private function createFile(evt:Event):void {
			this.currentFile = evt.target as File;
			var faEvent:FileActionEvent;
			
			try {
	        	this.curStream.open(this.currentFile, FileMode.WRITE);
			} catch (ioErr:IOError) {
				faEvent = new FileActionEvent(FileActionEvent.IO_ERROR);
				faEvent.message = "Captured IOError trying to create file";
				dispatchEvent(faEvent);
				return;
			} catch (secErr:SecurityError) {
				faEvent = new FileActionEvent(FileActionEvent.IO_ERROR);
				faEvent.message = "Captured Security Error trying to create File";
				dispatchEvent(faEvent);
				return;
			}
			this.state = "OPEN";
			dispatchEvent(new FileActionEvent(FileActionEvent.CREATE_COMPLETE));
		}
		
		/**
		 * @public
		 * Shows the file chooser and opens the file according to fMode
		 * 
		 * @param fFilter The FileFilter to apply to the file chooser
		 * @param fMode Open the File for R,W,RW according to FileActions constants
		 * @param fileName The filename to use during a FileActions.CREATE call
		 */
		public function openFile(fFilter:FileFilter, fMode:String, fileName:String = "changeMe.txt"):void {
		    var arr:Array = new Array();
		    arr[0] = fFilter;
			
			if (this.currentFile == null) {
				dispatchEvent(new FileActionEvent(FileActionEvent.GENERAL_ERROR, "Current file not initialized"));
				return;
			}
			
			//Remove any previous event listeners from the File object
			this.currentFile.removeEventListener(Event.SELECT, openFileRO);
			this.currentFile.removeEventListener(Event.SELECT, openFileRW);
			this.currentFile.removeEventListener(Event.SELECT, createFile);

			this.streamMode = fMode;
		    
		    if (fMode == FileActions.READ) {
		    	this.currentFile.addEventListener(Event.SELECT, openFileRO);
		    	this.currentFile.browseForOpen ("Select File", arr);
		    } else if (fMode == FileActions.WRITE) {
		    	this.currentFile.addEventListener(Event.SELECT, openFileRW);
		    	this.currentFile.browseForOpen ("Select File", arr);
		    } else if (fMode == FileActions.CREATE) {
		    	this.currentFile.addEventListener(Event.SELECT, createFile);
		    	this.currentFile.browseForSave (fileName);
		    }
		}
		
		/**
		 * @public
		 * Create temp file
		 */
		public function createTempFile(tDir:File = null, filename:String = "foo.swf"):void {
			var faEvent:FileActionEvent;

			if (tDir == null) {
				if (this.tempDir == null) {
					this.tempDir = File.createTempDirectory();
				}
			} else {
				this.tempDir = tDir;
			}
			
			this.currentFile = this.tempDir.resolvePath(filename);
			
			try {
				this.curStream.open(this.currentFile, FileMode.WRITE);
			} catch (ioErr:IOError) {
				faEvent = new FileActionEvent(FileActionEvent.IO_ERROR);
				faEvent.message = "Captured IOError trying to create file";
				dispatchEvent(faEvent);
				return;
			} catch (secErr:SecurityError) {
				faEvent = new FileActionEvent(FileActionEvent.IO_ERROR);
				faEvent.message = "Captured Security Error trying to create File";
				dispatchEvent(faEvent);
				return;
			}
			this.streamMode = FileActions.CREATE;
			this.state = "OPEN";
			dispatchEvent(new FileActionEvent(FileActionEvent.CREATE_COMPLETE));
		}
		
		/**
		 * @public
		 * When you don't want to use openFile to let the user choose a file,
		 * you can instead directly open the stream based on curFile.
		 * 
		 * @param fMode Open the File for R,W,RW according to FileActions constants
		 */
		public function openStream(fMode:String):void {
			try {
				if (fMode == FileActions.READ) {
					this.curStream.open(this.currentFile, FileMode.READ);
				} else if (fMode == FileActions.WRITE) { 
					this.curStream.open(this.currentFile, FileMode.UPDATE);
				} else if (fMode == FileActions.CREATE) {
					this.curStream.open(this.currentFile, FileMode.WRITE);
				}
			} catch (ioErr:IOError) {
				var faEvent:FileActionEvent = new FileActionEvent(FileActionEvent.IO_ERROR);
				faEvent.message = "Captured IOError trying to open RO stream";
				dispatchEvent(faEvent);
				return;
			} catch (secErr:SecurityError) {
				faEvent = new FileActionEvent(FileActionEvent.IO_ERROR);
				faEvent.message = "Captured Security Error trying to open a write stream";
				dispatchEvent(faEvent);
				return;
			}
			this.streamMode = fMode;
			this.state = "OPEN";
			if (fMode == FileActions.READ) {
				dispatchEvent(new FileActionEvent(FileActionEvent.OPEN_RO_COMPLETE));
			} else if (fMode == FileActions.WRITE) {
				dispatchEvent(new FileActionEvent(FileActionEvent.OPEN_RW_COMPLETE));
			} else if (fMode == FileActions.CREATE) {
				dispatchEvent(new FileActionEvent(FileActionEvent.CREATE_COMPLETE));
			}
		}
		
		/**
		 * @public
		 * Closes the current file stream
		 */
		public function closeFile():void {
			this.curStream.close();
			this.state = "CLOSED";
		}
		
		/**
		 * @public
		 * Writes an AMF object to the stream
		 */
		public function writeAMF(obj:*):void {
			try {
				//Could put this in a byte array and compress
				//However, I'd rather see raw data at the moment
				this.curStream.writeObject(obj);
			} catch (err:IOError) {
				var faEvent:FileActionEvent = new FileActionEvent(FileActionEvent.IO_ERROR);
				faEvent.message = "Captured IOError trying to write AMF data";
				dispatchEvent(faEvent);
			}
		}
		
		/**
		 * @public
		 * Read an AMF Object
		 * 
		 * @return The AMF Object that was read.
		 */
		public function readAMF():* {
			var faEvent:FileActionEvent;
			if (this.curStream == null || this.curStream.bytesAvailable <= 0) {
				dispatchEvent(new FileActionEvent(FileActionEvent.GENERAL_ERROR));
				return (null);
			}
			try {
				return (this.curStream.readObject());
			} catch (ioErr:IOError) {
				faEvent = new FileActionEvent(FileActionEvent.IO_ERROR);
				faEvent.message = "Caught IOError trying to read AMF data from stream";
				dispatchEvent(faEvent);
				return (null);
			} catch (eofErr:EOFError) {
				faEvent = new FileActionEvent(FileActionEvent.GENERAL_ERROR);
				faEvent.message = "Caught EOFError trying to read AMF data from stream";
				dispatchEvent(faEvent);
				return (null);
			}
		}
		
		/**
		 * @public
		 * Read all the bytes in the stream to the provided ByteArray
		 * 
		 * @param bArray Where the bytes will be stored
		 */
		public function readAllBytes(bArray:ByteArray):void {
			var faEvent:FileActionEvent;
			
			try {
				this.curStream.readBytes(bArray);
			} catch (ioErr:IOError) {
				faEvent = new FileActionEvent(FileActionEvent.IO_ERROR);
				faEvent.message = "Caught IOError trying to read all bytes from stream";
				dispatchEvent(faEvent);
				return;
			} catch (eofErr:EOFError) {
				faEvent = new FileActionEvent(FileActionEvent.GENERAL_ERROR);
				faEvent.message = "Caught EOFError trying to read all bytes from stream";
				dispatchEvent(faEvent);
				return;
			}
		}
		
		/**
		 * @public
		 * Writes a simple string to the file
		 * 
		 * @param str The String to write
		 */
		public function writeString(str:String):void {
			try {
				this.curStream.writeUTFBytes(str);
			} catch (err:IOError) {
				var faEvent:FileActionEvent = new FileActionEvent(FileActionEvent.IO_ERROR);
				faEvent.message = "Caught IOError trying to read all bytes from stream";
				dispatchEvent(faEvent);
			}
		}
		
		/**
		 * @public
		 * Writes a simple string to the file
		 * 
		 * @param bytes The ByteArray to write
		 */
		public function writeBytes(bytes:ByteArray):void {
			try {
				this.curStream.writeBytes(bytes);
			} catch (err:IOError) {
				var faEvent:FileActionEvent = new FileActionEvent(FileActionEvent.IO_ERROR);
				faEvent.message = "Caught IOError trying to read all bytes from stream";
				dispatchEvent(faEvent);
			}
		}
		
		
		/**
		 * @public
		 * This function dumps the contents of the Dictionary file into an array
		 *  
		 * @return A array containing the string in the dictionaries.
		 */
		public function readAsDictionary():Array {			
			var tmpChar:String = "";
			var tmpStr:String = "";
			var nameArr:Array = new Array();
			
			while (this.curStream.bytesAvailable) {
				tmpChar = this.curStream.readUTFBytes(1);
				if (tmpChar != "\n" && tmpChar != "\r") {
					tmpStr += tmpChar;
				} else {
					if (tmpStr.length > 0) {
						nameArr.push(tmpStr);
					}
					tmpStr = "";
				}
			}
			if (tmpStr.length > 0) {
				nameArr.push(tmpStr);
			}
			
			return (nameArr);
		}

		
		/**
		 * Functionality TBD
		 * 
		private function readString ():String {
			return (null);
		}
		 */

	}
}