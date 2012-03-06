/****************************************************************************
 * ADOBE SYSTEMS INCORPORATED
 *  Copyright 2012 Adobe Systems Incorporated and it’s licensors
 *  All Rights Reserved.
 *  
 * NOTICE: Adobe permits you to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 * ****************************************************************************/

package databaseUtils
{
	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	
	
	/**
	 * The PreferencesDB Class is an intermediate API that brokers requests to the FileHistory and Preferences class
	 * 
	 * The FileHistory and Preferences Classes handle the table specific queries.
	 */
	[Bindable]
	public class PreferencesDB extends Object
	{	
		/**
		 * @private
		 * A pointer to the file history Class which manages the file history access for the database.
		 */
		private var fileHistory:FileHistory;

		/**
		 * @private
		 * A pointer to the Decompilers Class which manages the list of decompilers for the database.
		 */
		private var decompilerList:Decompilers;
		
		/**
		 * @private
		 * A pointer to the prefs class which mananges preferences calls.
		 */
		private var prefs:Preferences;
		
		/**
		 * @private
		 * A pointer the SQL Connection to the database.
		 */
		private var dbConn:SQLConnection;
		
		/**
		 * @public
		 * Opens the database supplied in the dbName
		 * 
		 * @param dbName The name of the database file to open
		 */
		public function PreferencesDB(dbName:String = "")
		{
			super();
			this.dbConn = new SQLConnection();
			if (dbName.length == 0) {
				dbName = "app-storage:/PreferencesDB.db";
			} else {
				dbName = "app-storage:/" + dbName;
			}
			var myDB:File = new File(dbName);
			
			this.prefs = new Preferences(dbConn);
			this.fileHistory = new FileHistory(dbConn);
			this.decompilerList = new Decompilers(dbConn);
			
			if (!myDB.exists) {
				this.dbConn.addEventListener(SQLEvent.OPEN, create_table);
				this.dbConn.open(myDB, SQLMode.CREATE);
			} else {
				this.dbConn.addEventListener(SQLEvent.OPEN, initPreferences);
				this.dbConn.open(myDB, SQLMode.UPDATE);
			}
		}
		
		/**
		 * @private
		 * Create the file history and prefs tables if they don't exist
		 *
		 * @param eventObj The SQLEvent from the constructor
		 */
		private function create_table(eventObj:SQLEvent):void {
			this.prefs.create_table(eventObj);
			this.fileHistory.create_table(eventObj);
			this.decompilerList.create_table(eventObj);
			
			//Making the assumption that while the above is asynchronous,
			//that it is roughly sequential.
			initPreferences(null);
		}
		
		/**
		 * @private
		 * A generic error handler that just dumps trace information from SQLErrorEvent
		 * 
		 * @param errorObj The SQLErrorEvent
		 */
		private function errorHandler(errorObj:SQLErrorEvent):void {
		    trace("Error ID: " + errorObj.errorID);
       		trace("Message: " + errorObj.error.message);
		}
		
		/**
		 * @private
		 * This initializes the prefs and fileHistory classes
		 * 
		 * @param eventObj The SQLEvent from the constructor database call.
		 */
		private function initPreferences(eventObj:SQLEvent):void {
			this.prefs.init_preferences();
			this.fileHistory.reset_length(this.prefs.get_int_pref("historyLength"));
		}
		
		/**
		 * @public
		 * This returns a preferences Object with all the preferences
		 * 
		 * @param eventObj The optional SQLEvent from from a database call.
		 * @return The object containing the preferences information in a hash form
		 */
		public function getPreferences(eventObj:SQLEvent = null):Object {
			return (this.prefs.get_preferences());
		}
		
		/**
		 * @public
		 * Get a string preference from the database
		 * 
		 * @param name The name of the preference to return
		 * @return The string value for the requested preference.
		 */
		public function getPref(name:String):String {
			return (this.prefs.get_pref(name));
		}
		
		/**
		 * @public
		 * Get a integer preference from the database.
		 * 
		 * @param name The name of the preference requested
		 * @return The integer value for the preference
		 */
		public function getIntPref(name:String):int {
			return (this.prefs.get_int_pref(name));
		}
		
		/**
		 * @public
		 * Update the preferences table with the supplied information
		 * 
		 * @param name The name of the preference to update as a string
		 * @param value The string value for the new preference
		 * @param finalUpdate A boolean whether there are additional immediate updates as part of a series (default true)
		 */
		public function updatePref(name:String, value:String, finalUpdate:Boolean=true):void {
			this.prefs.update_pref(name,value);
			if (name == "historyLength") {
				this.fileHistory.reset_length(int(value));
			}
		}
		
		/**
		 * @public
		 * A wrapper to the file history class to return the XML representation of the file history for the pull down menu.
		 * 
		 * @return The XML representation of the file history.
		 */
		public function getFileHistory():XML {
			return (this.fileHistory.returnFileHistoryXML());
		}
		
		/**
		 * @public
		 * A wrapper to the file history class to update the file history with a new entry
		 * 
		 * @param name The string containing the name of the file.
		 * @param type The string containing type of the location for the entry (url || file)
		 * @param location The string containing the location of the SWF
		 */
		public function updateFileHistory(name:String, type:String, location:String):void {
			return (this.fileHistory.updateFileHistory(name,type,location));	
		}
		
		/**
		 * @public
		 * A wrapper to the file history class to clear the file history from the database
		 */
		public function clearFileHistory():void {
			this.fileHistory.clearFileHistory();
		}
		
		/**
		 * @public
		 * A wrapper to the Decompiler class to either insert a new entry or update an existing entry
		 * 
		 * @param name The string containing the name of the file.
		 * @param path The string containing the path of the executable
		 * @param arguments The string containing the arguments for the executable
		 */
		public function updateDecompilerList(name:String, path:String, arguments:String):void {
			return (this.decompilerList.updateDecompilerList(name, path, arguments));	
		}
		
		/**
		 * @public
		 * A wrapper to the Decompiler class to return the full table as an Array.
		 * 
		 * @return The full decompilers table array.
		 */
		public function getDecompilerArray():Array {
			return (this.decompilerList.getDecompilersArray());
		}	
		
		/**
		 * @public
		 * A wrapper to the Decompiler class to return the list of Decompiler names.
		 * 
		 * @return The list of names in the decompiler table
		 */
		public function getDecompilerNames():Array {
			return (this.decompilerList.getDecompilerNames());
		}
		
		/**
		 * @public
		 * A wrapper to the Decompiler class to return info for a specific decompiler.
		 * 
		 * @param name The name of the decompiler
		 * @return An object containing the name, path and arguments
		 */
		public function getDecompilerInfo(name:String):Object {
			var obj:Object = this.decompilerList.getDecompilerInfo(name);
			return (obj);
		}
		
		/**
		 * @public
		 * A wrapper to the Decompiler class to delete a specific decompiler
		 * 
		 * @param name The name of the decompiler to delete
		 */
		public function deleteDecompiler(name:String):void {
			this.decompilerList.deleteDecompilerEntry(name);
		}
		
		/**
		 * @public
		 * Close the current DB Connection
		 */
		public function close():void {
			this.dbConn.close();
		}
	}
}