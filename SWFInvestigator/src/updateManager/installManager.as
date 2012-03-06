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
	import flash.desktop.NativeProcess;
	
	import mx.controls.Alert;

	public class installManager
	{
		private var updater:IUpdater;
		private var configFile:String = "configs/updateConfig.xml";
		
		/**
		 * @public
		 * This constructor will initialize the updater
		 */
		public function installManager()
		{
			if (NativeProcess.isSupported) {
				this.updater = new NativeFileUpdater(configFile) as IUpdater;
			} else {
				this.updater = new AirFileUpdater(configFile) as IUpdater;
			}
			try {
				this.updater.initialize();
			} catch (e:Error) {
				if (e.message) {
					mx.controls.Alert.show ("Could not initialize updater!");
				}
			}
		}
		
		/**
		 * @public
		 * This will check for updates using whichever installer is appropriate.
		 * If this is a manual check then the system will show errors.
		 * 
		 * @param manualCheck This indicates whether the call was initiated through user action.
		 */
		public function checkForUpdates(manualCheck:Boolean = false):void {
			try {
				this.updater.checkForUpdates(manualCheck);
			} catch (e:Error) {
				if (manualCheck) {
					mx.controls.Alert.show("There was an error during the update process.\n\n" + e.message, "Update Error");
				}
			}
		}
	}
}