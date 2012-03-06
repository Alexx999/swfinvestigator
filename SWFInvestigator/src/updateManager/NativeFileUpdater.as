/****************************************************************************
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2012 Adobe Systems Incorporated and it’s licensors
 * All Rights Reserved.
 *  
 * NOTICE: Adobe permits you to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 * ****************************************************************************/

package updateManager
{
	import air.update.events.DownloadErrorEvent;
	import air.update.events.StatusUpdateErrorEvent;
	import air.update.events.StatusUpdateEvent;
	
	import com.riaspace.nativeApplicationUpdater.NativeApplicationUpdater;
	
	import flash.desktop.NativeApplication;
	import flash.events.ErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;

	public class NativeFileUpdater implements IUpdater
	{
		namespace updater = "http://updater.riaspace.com";
		
		private var updater:NativeApplicationUpdater;
		private var manualUpdate:Boolean;
		
		/**
		 * @public
		 * This constructor will load the config file necessary for the AirFileUpdater.
		 * 
		 * @param configFile A string showing the path of the config file relative to the app: directory
		 */
		public function NativeFileUpdater(configFile:String)
		{
			var config:File = File.applicationDirectory.resolvePath(configFile);
			var cStream:FileStream = new FileStream();
			cStream.open(config, FileMode.READ);
			var configXML:XML = new XML(cStream.readUTFBytes(cStream.bytesAvailable));
			cStream.close();
			
			//There is probably a more elegant way to do this...
			var configList:XMLList = configXML.elements();
			
			for each (var item:XML in configList) {
				if (item.toXMLString().indexOf("native_url") > 0) {
					var updateURL:String = item.toString();
				}
			}
			
			this.updater = new NativeApplicationUpdater();
			this.updater.updateURL = updateURL;
			this.updater.isNewerVersionFunction = isNewerFunction;
			this.updater.addEventListener(DownloadErrorEvent.DOWNLOAD_ERROR,updater_errorHandler);
			this.updater.addEventListener(StatusUpdateErrorEvent.UPDATE_ERROR, updater_errorHandler);
			this.updater.addEventListener(StatusUpdateEvent.UPDATE_STATUS, updater_statusHandler);
			this.updater.addEventListener(ErrorEvent.ERROR,updater_errorHandler);

		}
		
		/**
		 * @private
		 * Compares versions to see if there is a newer version available.
		 * Assumes version is in X.Y.Z format where X,Y and Z are numbers
		 * 
		 * @param currentVersion A string representing the current version
		 * @param updateVersion A string represneting the updated version
		 * @return True if there is a newer version, false if the data is bad or it is not new
		 */
		private function isNewerFunction(currentVersion:String, updateVersion:String):Boolean
		{
			var curNums:Array = currentVersion.split(".");
			var updateNums:Array = updateVersion.split(".");
			if (updateNums == null || updateNums.length != 3) {
				return false;
			}
			
			var testNum:Number = parseInt(updateNums[0]);
			var curNum:Number = parseInt(curNums[0]);
			
			if (isNaN(testNum)) {
				return false;
			} else if (curNum > testNum) {
				return false;
			}
			
			testNum = parseInt(updateNums[1]);
			curNum = parseInt(curNums[1]);
			
			if (isNaN(testNum)) {
				return false;
			} else if (curNum > testNum) {
				return false;
			}
			
			testNum = parseInt(updateNums[2]);
			curNum = parseInt(curNums[2]);
			
			if (isNaN(testNum)) {
				return false;
			} else if (curNum >= testNum) {
				return false;
			}
			
			return true;
		}
		
		/**
		 * @public
		 * Initialize the application updater
		 */
		public function initialize():void {
			this.updater.initialize();
		}
		
		/**
		 * @public
		 * This function will check for new native installer updates
		 * If it is user initiated, then the system will show more errors.
		 * 
		 * @param userInitiated Indicates whether this was a request from the user.
		 */
		public function checkForUpdates(userInitiated:Boolean):void {
			this.manualUpdate = userInitiated;
			if (userInitiated) {
				if (this.updater.currentState == NativeApplicationUpdater.DOWNLOADING || this.updater.currentState == NativeApplicationUpdater.INSTALLING) {
					mx.controls.Alert.show("The updater appears to be " + this.updater.currentState + ". Please wait if you have a slow connection or try restarting the app. This also may be caused by the application being unable to find the update on the server.","Sorry");
					return;
				}
				//This is a hack since the NativeApplicationUpdater doesn't support resetting
				this.updater.currentState = NativeApplicationUpdater.READY;
			}
			this.updater.checkNow();
		}
		
		/**
		 * @private
		 * This error handler will show errors if it is a manual update
		 * 
		 * @param event The ErrorEvent from the updater
		 */
		private function updater_errorHandler(event:ErrorEvent):void {
			if (this.manualUpdate) {
				mx.controls.Alert.show("There was an error in the update process:\n\n" + event.toString(),"Update Error");
			}
		}
		
		/**
		 * @private
		 * Handler for the update Alert dialogue. If the user clicked "Install", then the dowload will begin.
		 * 
		 * @param event The closeEvent from the Alert dialogue
		 */
		private function alertHandler(event:CloseEvent):void {
			if (event.detail==Alert.YES) {
				updater.downloadUpdate();
			}
		}
		
		/**
		 * @private
		 * This error handler will show errors if it is a manual update
		 * 
		 * @param event The ErrorEvent from the updater
		 */
		private function updater_statusHandler(event:StatusUpdateEvent):void {
			if (this.manualUpdate && event.available == false) {
				if (this.updater.isNewerVersionFunction.call(this.updater,this.updater.currentVersion,this.updater.updateVersion) == false) {
					mx.controls.Alert.show("No updates available","Sorry!");
				}
			} else if (event.available) {
				Alert.yesLabel = "Install";
				Alert.noLabel = "Cancel"
				var Message:String = "The newest version is: " + this.updater.updateVersion + "\n";
				Message += "Your version is: " + this.updater.currentVersion;
				Alert.show(Message,"Update Available",3,null,alertHandler);
				
				Alert.yesLabel = "Yes";
				Alert.noLabel = "No"
				event.preventDefault();
			}
		}
	}
}