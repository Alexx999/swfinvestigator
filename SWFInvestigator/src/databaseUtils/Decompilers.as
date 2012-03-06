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
	 * The decompiler class manages the database calls for retrieving the available decompilers in the preferences pull down menu.
	 */
	public final class Decompilers
	{
		
		/**
		 * @private
		 * Name of default decompiler. Also defined in Preferences.as
		 */
		private var defaultDecompiler:String = "internal";
		
		/**
		 * An Array representing the results of the SQL database information
		 */
		public var decompilersArray:Array;
		
		/**
		 * @private
		 * A pointer to the database connection
		 */
		private var dbConn:SQLConnection;
		
		
		/**
		 * Constructor
		 * 
		 * @param dbParenConn A pointer to the SQLConnection object for the database.
		 */
		public function Decompilers(dbParentConn:SQLConnection)
		{
			this.dbConn = dbParentConn;
		}
		
		/**
		 * Returns the Array of decompilers for the preferences menu
		 * 
		 * @return The Array of decompiler information, including paths and args, is returned
		 */
		public function getDecompilersArray():Array {
			if (this.decompilersArray == null) {
				this.getDecompilerList()	
			}
			return (this.decompilersArray);
		}


		/**
		 * Returns the List of decompilers names for the pull down menu
		 * 
		 * @return The Array of decompiler names is returned
		 */
		public function getDecompilerNames():Array {
			if (this.decompilersArray == null) {
				this.getDecompilerList()	
			}
			
			var tempArray:Array = new Array();
			
			for (var i:int = 0; i < this.decompilersArray.length; i++) {
				tempArray.push(this.decompilersArray[i].name);
			}
			
			return (tempArray);
		}
		
		
		/**
		 * Creates the decompiler table if it did not previously exist.
		 * 
		 * @param eventObj The SQLEvent from the event listener
		 */
		public function create_table(eventObj:SQLEvent):void {
			var createStatement:SQLStatement = new SQLStatement();
			createStatement.sqlConnection = this.dbConn;
			createStatement.text = "CREATE TABLE IF NOT EXISTS decompilers (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, path TEXT, arguments TEXT)";
			createStatement.addEventListener(SQLErrorEvent.ERROR, errorHandler);
			createStatement.addEventListener(SQLEvent.RESULT, insertInternal);
			createStatement.execute();
		}
		
		
		/**
		 * Called by create_table to place the default "internal" entry into the table
		 * @param eventObj The SQLEvent from the create_table event listener
		 */
		private function insertInternal(eventObj:SQLEvent):void {
			insertNewDecompiler(this.defaultDecompiler, this.defaultDecompiler, "");
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
		 * Performs the db call to retrieve the decompilers and populates decompilersArray using displayFileResults.
		 * 
		 * @param eventObj An optional SQLEvent if this was fired from an event listener.
		 */
		private function getDecompilerList(eventObj:SQLEvent = null):void {
			var dbStatement:SQLStatement = new SQLStatement();
			dbStatement.sqlConnection = this.dbConn;
			dbStatement.addEventListener(SQLEvent.RESULT, populateDecArray);
			dbStatement.text = "SELECT * FROM decompilers;";
			try {
				dbStatement.execute();
			} catch (err:SQLError) {
				mx.controls.Alert.show(err.details,err.message);
			}			
		}
		
		/**
		 * @private
		 * The event listener for getDecompilerList which populates the decompilersArray
		 * 
		 * @param eventObj The SQLEvent from the event listener call
		 */
		private function populateDecArray(eventObj:SQLEvent):void {
			this.decompilersArray = eventObj.target.getResult().data;
		}
		
		/**
		 * @private
		 * Checks to see if the file already exists within the file history.
		 * 
		 * @param name The name of the file to search for
		 * @return An integer representing where in the array the file exists
		 */ 
		private function checkDecEntryExists(name:String):int {
			if (this.decompilersArray == null || this.decompilersArray.length == 0) {
				return (-1);
			}
			
			for (var i:int = 0; i < this.decompilersArray.length; i++) {
				if (this.decompilersArray[i].name == name) {
					return(i);
				}
			}
			
			return (-1);
		}
		
		/**
		 * @private
		 * Inserts a new value into the decompilers table
		 * 
		 * @param name The string containing the name of the file
		 * @param path The string representing the location of the decompiler
		 * @param arguments The string representing the default arguments for the decompiler
		 */
		private function insertNewDecompiler(name:String, path:String, arguments:String):void {			
			var dbStatement:SQLStatement = new SQLStatement();
			
			dbStatement.sqlConnection = this.dbConn;
			dbStatement.addEventListener(SQLEvent.RESULT, this.getDecompilerList);
			dbStatement.addEventListener(SQLErrorEvent.ERROR, errorHandler);
			dbStatement.text = "INSERT INTO decompilers (name, path, arguments) values (:name, :path, :arguments)";
			dbStatement.parameters[":name"] = name;
			dbStatement.parameters[":path"] = path;
			dbStatement.parameters[":arguments"] = arguments;
			dbStatement.execute();
		}
		
		/**
		 * @private
		 * Updates the path and arguments value in the decompilers table
		 * 
		 * @param name The string containing the name of the file
		 * @param path The string representing the location of the decompiler
		 * @param arguments The string representing the default arguments for the decompiler
		 */
		private function updateDecompilerTable(name:String, path:String, arguments:String):void {			
			var dbStatement:SQLStatement = new SQLStatement();
			
			dbStatement.sqlConnection = this.dbConn;
			dbStatement.addEventListener(SQLEvent.RESULT, this.getDecompilerList);
			dbStatement.addEventListener(SQLErrorEvent.ERROR, errorHandler);
			dbStatement.text = "UPDATE decompilers SET path = :path, arguments = :arguments WHERE name = :name";
			dbStatement.parameters[":name"] = name;
			dbStatement.parameters[":path"] = path;
			dbStatement.parameters[":arguments"] = arguments;
			dbStatement.execute();
		}
		
		/**
		 * @public
		 * Either insert new entry into the decompiler list or update the existing entry
		 * 
		 * @param name The string containing the name of the file
		 * @param path The string representing the location of the decompiler
		 * @param arguments The string representing the default arguments for the decompiler
		 */
		
		public function updateDecompilerList(name:String, path:String, arguments:String):void {
			if (this.checkDecEntryExists(name) == -1) {
				this.insertNewDecompiler(name, path, arguments);
			} else {
				this.updateDecompilerTable(name, path, arguments);
			}
		}
		
		/**
		 * @public
		 * Deletes an entry from the decompilers list according to its name
		 * 
		 * @param name The string representing the name of the decompiler
		 */
		public function deleteDecompilerEntry(name:String):void {
			var dbStatement:SQLStatement = new SQLStatement();
			dbStatement.sqlConnection = this.dbConn;
			dbStatement.addEventListener(SQLEvent.RESULT, this.getDecompilerList);
			dbStatement.addEventListener(SQLErrorEvent.ERROR, errorHandler);
			dbStatement.text = "DELETE from decompilers where name = :name";
			dbStatement.parameters[":name"] = name;
			dbStatement.execute();
		}
		
		/**
		 * @public
		 * Returns the information for a specific decompiler
		 * 
		 * @param name The name of decompiler to look up
		 * @return An object containing the name, path and arguments
		 */
		public function getDecompilerInfo(name:String):Object {
			var pos:int = checkDecEntryExists(name);
			if (pos == -1) {
				return (null);
			} else {
				return (this.decompilersArray[pos]);
			}
		}

	}
}