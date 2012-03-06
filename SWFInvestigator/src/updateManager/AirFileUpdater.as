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
	import air.update.ApplicationUpdaterUI;
	import air.update.events.UpdateEvent;
	import air.update.events.StatusUpdateEvent;
	import air.update.events.DownloadErrorEvent;
	import air.update.events.StatusUpdateErrorEvent;
	
	import flash.events.ErrorEvent;
	import flash.filesystem.File;
	
	import mx.controls.Alert;
	
	public class AirFileUpdater implements IUpdater
	{
		private var appUpdater:ApplicationUpdaterUI;
		private var manualUpdate:Boolean;
		private var configFile:String;
		
		/**
		 * @public
		 * This constructor will load the config file necessary for the AirFileUpdater.
		 * 
		 * @param configFile A string showing the path of the config file relative to the app: directory
		 */
		public function AirFileUpdater(confFile:String)
		{	
			if (confFile != null) {
				this.configFile = confFile;
			}
			var config:File = File.applicationDirectory.resolvePath(configFile);
			
			this.appUpdater = new ApplicationUpdaterUI();
			this.appUpdater.configurationFile = config;
			this.appUpdater.isNewerVersionFunction = isNewerFunction;
			this.appUpdater.addEventListener(UpdateEvent.INITIALIZED, onUpdate);
			this.appUpdater.addEventListener(ErrorEvent.ERROR, onError);
			this.appUpdater.addEventListener(StatusUpdateErrorEvent.UPDATE_ERROR, statusError);
			this.appUpdater.addEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, downloadError);
			this.appUpdater.addEventListener(StatusUpdateEvent.UPDATE_STATUS, statusUpdate);
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
			this.appUpdater.initialize();
		}
		
		/**
		 * @public
		 * Check for new AIR file updates.
		 * If this is user initiated, then the system will show error messages.
		 * 
		 * @param userInitiated Indicates whether this is a user initiated check
		 */
		public function checkForUpdates(userInitiated:Boolean):void {
			this.manualUpdate = userInitiated;
			if (userInitiated) {
				this.appUpdater.cancelUpdate();
			}
			this.appUpdater.checkNow();
		}

		
		/**
		 * @private
		 * Once the application updater is initialized, we can check for the update
		 * 
		 * @param event The UpdateEvent.INITIALIZED event
		 */
		private function onUpdate(event:UpdateEvent):void {
			if (this.manualUpdate) {
				this.appUpdater.checkNow();
			}
		}
		
		/**
		 * @private
		 * This listens for StatusUpdateEvent update errors
		 * 
		 * @param event The StatusUpdateEvent error event
		 */
		private function statusUpdate(event:StatusUpdateEvent):void {
			if (this.manualUpdate && event.available == false) {
				mx.controls.Alert.show("There is no update available","Sorry");
			}
		}
		
		/**
		 * @private
		 * This error handler will display errors if it is a manual update
		 * 
		 * @param event The EVENT.ErrorEvent from the updater
		 */
		private function onError(event:ErrorEvent):void {
			if (this.manualUpdate) {
				mx.controls.Alert.show("There was an error in the update process:\n\n" + event.toString(),"Update Error");
			}
		}
		
		/**
		 * @private
		 * This listens for StatusUpdateErrorEvent update errors
		 * 
		 * @param event The StatusUpdateErrorEvent error event
		 */
		private function statusError(event:StatusUpdateErrorEvent):void {
			if (this.manualUpdate) {
				mx.controls.Alert.show("Update failed: Could not download or parse the server's update descriptor file.","Sorry");
			}
		}
		
		/**
		 * @private
		 * This listens for DownloadErrorEvent update errors
		 * 
		 * @param event The DownloadErrorEvent error event
		 */
		private function downloadError(event:DownloadErrorEvent):void {
			if (this.manualUpdate) {
				mx.controls.Alert.show("A download error occurred: " + event.errorID,"Sorry");
			}
		}
	}
}