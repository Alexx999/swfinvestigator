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
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.display.InteractiveObject;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	public class DragAndDropManager
	{
		private var callbackFunction:Function;
		private var obj:InteractiveObject;
		
		/**
		 * Constructor
		 * 
		 * @param target The InteractiveObject that the DragManager will listen on
		 * @param callback The callback function that the DragManager will call when it has a file. This function must take three parameters: data:ByteArray, filename:string, url:String
		 */
		public function DragAndDropManager(target:InteractiveObject, callback:Function)
		{
			this.obj = target;
			obj.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, onDragIn);
			obj.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, onDragDrop);
			this.callbackFunction = callback;
		}
		
		/**
		 * Allows the caller to verify NativeDragManager is supported
		 * 
		 * @return A boolean indicating support
		 */
		public static function isSupported():Boolean {
			return NativeDragManager.isSupported;
		}
		
		/**
		 * Called when the user drags an item into the component area
		 * 
		 * @param e The NativeDragEvent for the DragIn event
		 */
		private function onDragIn(e:NativeDragEvent):void
		{
			//check and see if files are being drug in
			if(e.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT))
			{
				//get the array of files
				var files:Array = e.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
				
				//make sure only one file is dragged in (i.e. this app doesn't
				//support dragging in multiple files)
				if(files.length == 1)
				{
					//accept the drag action
					NativeDragManager.acceptDragDrop(this.obj);
				}
			}
		}
		
		/**
		 * Called when the user drops an item over the component
		 * It is assumed the receiver will do the data validation
		 * 
		 * @param e The NativeDragEvent for the DragDrop event
		 */
		private function onDragDrop(e:NativeDragEvent):void
		{
			//get the array of files being drug into the app
			var arr:Array = e.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
			
			//grab the files file
			var f:File = File(arr[0]);
			
			//create a FileStream to work with the file
			var fs:FileStream = new FileStream();
			
			//open the file for reading
			fs.open(f, FileMode.READ);
			
			//read the file as a ByteArray
			var data:ByteArray = new ByteArray();
			fs.readBytes(data,0,fs.bytesAvailable);
			
			//close the file
			fs.close();
			
			//Return the data to the callback function
			this.callbackFunction(data, f.name, f.url);
		}
	}
}