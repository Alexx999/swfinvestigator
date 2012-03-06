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
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	
	import mx.controls.Alert;

	/**
	 * The fileHistory class manages the database calls for retrieving the file History for the file pull down menu.
	 */
	public class FileHistory
	{
		/**
		 * @private
		 * The XML representing the file history
		 */
		private var fileXML:XML;
		
		/**
		 * An Array representing the results of the SQL database information
		 */
		public var fHistory:Array;
		
		/**
		 * @private
		 * A pointer to the database connection
		 */
		private var dbConn:SQLConnection;
		
		/**
		 * @private
		 * The default length for the file history
		 */
		private var maxFileHistory:int = 4;
		
		/**
		 * @private
		 * Global to keep track of current position when shifting data
		 */
		private var positionTracker:int;
		
		/**
		 * Constructor
		 * 
		 * @param dbParenConn A pointer to the SQLConnection object for the database.
		 */
		public function FileHistory(dbParentConn:SQLConnection)
		{
			this.dbConn = dbParentConn;
		}
		
		/**
		 * Returns the XML representation of the file history for the pull down menu
		 * 
		 * @return An XML representation of the file history
		 */
		public function returnFileHistoryXML():XML {
			this.getFileHistory();
			if (this.fHistory == null || this.fHistory.length == 0) {
				this.fileXML = <menuitem label="Open Recent" enabled="false"></menuitem>;
			} else {
				this.fileXML = <menuitem label="Open Recent" enabled="true"></menuitem>;
				for (var i:int = this.fHistory.length - 1; i > -1; i--) {
					var tempXML:XML = new XML("<menuitem label=\"" + this.fHistory[i].name + "\" data=\"" + this.fHistory[i].type + "|" + this.fHistory[i].location + "\"/>");
					fileXML.appendChild(tempXML);					
				}
			}
			return (this.fileXML);
		}
		
		/**
		 * Creates the file history table if it did not previously exist.
		 * 
		 * @param eventObj The SQLEvent from the event listener
		 */
		public function create_table(eventObj:SQLEvent):void {
			var createStatement:SQLStatement = new SQLStatement();
			createStatement.sqlConnection = this.dbConn;
			createStatement.text = "CREATE TABLE IF NOT EXISTS fileHistory (id INTEGER PRIMARY KEY AUTOINCREMENT, position INTEGER ASC, name TEXT, type TEXT, location TEXT)";
			createStatement.addEventListener(SQLErrorEvent.ERROR, errorHandler);
			createStatement.execute();
		}
		
		/**
		 * Resets the default file history length to the new value
		 * 
		 * @param len An int representing the new default history length.
		 */
		public function reset_length(len:int):void {
			this.maxFileHistory = len;
			this.clearFileHistory(len);
		}
		
		/**
		 * @private
		 * A default error handler which only dumps trace information.
		 * 
		 * @param errorObj The SQLErrorEvent from the failed query.
		 */
		private function errorHandler(errorObj:SQLErrorEvent):void {
		    trace("Error ID: " + errorObj.errorID);
       		trace("Message: " + errorObj.error.message);
		}
		
		/**
		 * @private
		 * Performs the db call to retrieve the file history and populates the fHistory array using displayFileResults.
		 * 
		 * @param eventObj An optional SQLEvent if this was fired from an event listener.
		 */
		private function getFileHistory(eventObj:SQLEvent = null):void {
			var getFHistory:SQLStatement = new SQLStatement();
			getFHistory.sqlConnection = this.dbConn;
			getFHistory.addEventListener(SQLEvent.RESULT, displayFileResults);
			getFHistory.text = "SELECT * FROM fileHistory;";
			try {
				getFHistory.execute();
			} catch (err:SQLError) {
				mx.controls.Alert.show(err.details,err.message);
			}			
		}
		
		/**
		 * @private
		 * The event listener for getFileHistory which populates the fHistory Array
		 * 
		 * @param eventObj The SQLEvent from the event listener call
		 */
		private function displayFileResults(eventObj:SQLEvent):void {
			this.fHistory = eventObj.target.getResult().data;
		}
		
		/**
		 * @private
		 * Checks to see if the file already exists within the file history.
		 * 
		 * @param name The name of the file to search for
		 * @param type The type of file location (a string).
		 * @param location The location where the file exists (as a string)
		 * @return An integer representing where in the array the file exists
		 */ 
		private function checkFHExists(name:String,type:String,location:String):int {
			if (this.fHistory == null || this.fHistory.length == 0) {
				return (-1);
			}
			
			for (var i:int = 0; i < this.fHistory.length; i++) {
				if (this.fHistory[i].name == name && this.fHistory[i].location == location && this.fHistory[i].type == type) {
					return(this.fHistory[i].position);
				}
			}
			
			return (-1);
		}
		
		/**
		 * @private
		 * Inserts a new value into the file history
		 * 
		 * @param position An int represnting where in the history to insert the information
		 * @param name The string containing the name of the file
		 * @param type The string representing the type of location
		 * @param location The string representing the location of the file
		 */
		private function insertHistoryLocation(position:int, name:String, type:String, location:String):void {			
			var dbStatement:SQLStatement = new SQLStatement();
			
			dbStatement.sqlConnection = this.dbConn;
			dbStatement.addEventListener(SQLEvent.RESULT, this.getFileHistory);
			dbStatement.addEventListener(SQLErrorEvent.ERROR, errorHandler);
			dbStatement.text = "INSERT INTO fileHistory (position, name, type, location) values (:position, :name, :type, :location)";
			dbStatement.parameters[":position"] = position;
			dbStatement.parameters[":name"] = name;
			dbStatement.parameters[":type"] = type;
			dbStatement.parameters[":location"] = location;
			dbStatement.execute();
		}
		
		/**
		 * @private
		 * Deletes an entry from the file history at the specified position
		 * 
		 * @param position An int representing the position in the array to delete
		 */
		private function deleteFileHistory(position:int):void {
			var dbStatement:SQLStatement = new SQLStatement();
			this.positionTracker = position;
			dbStatement.sqlConnection = this.dbConn;
			dbStatement.addEventListener(SQLEvent.RESULT, this.shiftFileHistoryDown);
			dbStatement.addEventListener(SQLErrorEvent.ERROR, errorHandler);
			dbStatement.text = "DELETE from fileHistory where position = :position";
			dbStatement.parameters[":position"] = position;
			dbStatement.execute();
		}
		
		/**
		 * @private
		 * Shifts the entries in the file history down to accomadate for a new entry.
		 * 
		 * @param eventObjt The SQLEvent from the event listener
		 */
		private function shiftFileHistoryDown (eventObj:SQLEvent):void {
			var dbStatement:SQLStatement = new SQLStatement();
			dbStatement.sqlConnection = this.dbConn;
			if (this.positionTracker > 0) {
				this.positionTracker -= 1;
				dbStatement.addEventListener(SQLEvent.RESULT, this.shiftFileHistoryDown);
			}
			dbStatement.addEventListener(SQLErrorEvent.ERROR, errorHandler);
			dbStatement.text = "UPDATE fileHistory set position = :new where position = :old";
			dbStatement.parameters[":new"] = this.positionTracker + 1;
			dbStatement.parameters[":old"] = this.positionTracker;
			dbStatement.execute();
		}
		
		/**
		 * Updates the file history with the newly specified values
		 * 
		 * @param name The string representing the name of the file
		 * @param type The string represneting the type of location (url || file)
		 * @param location The string representing the file's location
		 */
		public function updateFileHistory(name:String, type:String, location:String):void {
			var itemExists:int = this.checkFHExists(name,type,location);
			
			if (itemExists == 0) {
				//already the first item
				return;
			}
			
			if (this.fHistory != null && this.fHistory.length == this.maxFileHistory && itemExists == -1) {
				this.deleteFileHistory(this.maxFileHistory - 1);
			} else if (this.fHistory != null && this.fHistory.length > 0) {
				if (itemExists == -1) {
					this.positionTracker = this.fHistory.length;
					this.shiftFileHistoryDown(null);
				} else {
					this.deleteFileHistory(itemExists);
				}
			}
			this.insertHistoryLocation(0,name,type,location);
		}
		
		/**
		 * Deletes all entries from the file history from the specified value and greater
		 * 
		 * @param pos The minimum position to start deleting entries from (default 0);
		 */
		public function clearFileHistory(pos:int = 0):void {
			var dbStatement:SQLStatement = new SQLStatement();
			dbStatement.sqlConnection = this.dbConn;
			dbStatement.addEventListener(SQLErrorEvent.ERROR, errorHandler);
			dbStatement.text = "DELETE FROM fileHistory WHERE position >= :pos";
			dbStatement.parameters[":pos"] = pos;
			dbStatement.execute();
		}

	}
}