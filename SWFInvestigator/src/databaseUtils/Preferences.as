/****************************************************************************
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2012 Adobe Systems Incorporated and it’s licensors
 * All Rights Reserved.
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
	 * The preferences class processes the database interactions for storing and retrieving preferences
	 */
	public class Preferences
	{
		/**
		 * @private
		 * A pointer the db SQL Connection
		 */
		private var dbConn:SQLConnection;

		/**
		 * @private
		 * The array of information returned from the database statement.
		 */		
		private var prefs:Array;
		
		/**
		 * @private
		 * The object containing the preferences values.
		 */
		private var prefsObj:Object;
		
		/**
		 * @private
		 * The default preferences settings.
		 * The array format makes it easier to add new preferences with new revisions.
		 */
		private var defaults:Object = [
				{name:"remapPort", type:"int", value:9009},
				{name:"historyLength", type:"int", value:4},
				{name:"defaultLCDomain", type:"String", value:"http://www.example.com/"},
				{name:"defaultUserAgent", type:"String", value:"Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US) AppleWebKit/525.28 (KHTML, like Gecko) Version/3.2.2 Safari/525.28.1"},
				{name:"viewerTemplate", type:"String", value:"app:/Viewer/viewerWrapper.html"},
				{name:"autoUpdateCheck", type:"int", value:1},
				{name:"serverPort", type:"int", value:9080},
				{name:"serverIP", type:"String", value:"127.0.0.1"},
				{name:"serverPath", type:"String", value:""},
				{name:"fuzzingDomain", type:"String", value:"http://www.example.com"},
				{name:"xssStrings", type:"String", value:"app:/configs/xssStrings.txt"},
				{name:"xssDescriptions", type:"String", value:"app:/configs/xssDescriptions.xml"},
				{name:"securityStrings", type:"String", value:"app:/configs/securityStrings.txt"},
				{name:"amfDictionary", type:"String", value:"app:/configs/AMFDictionary.txt"}
			];

		
		/**
		 * Constructor
		 * 
		 * @param dbParenConn The pointer to the SQLConnection for the database.
		 */
		public function Preferences(dbParentConn:SQLConnection):void
		{
			this.dbConn = dbParentConn;
		}
		
		/**
		 * @private
		 * A generic error handler that just dumps trace information
		 * 
		 * @param errorObj The SQLErrorEvent
		 */
		private function errorHandler(errorObj:SQLErrorEvent):void {
		    trace("Error ID: " + errorObj.errorID);
       		trace("Message: " + errorObj.error.message);
		}
		
		/**
		 * This creates the table if it does not exist.
		 * 
		 * @param eventObj The SQLEvent from the db connection.
		 */
		public function create_table(eventObj:SQLEvent):void {
			var createStatement:SQLStatement = new SQLStatement();
			createStatement.sqlConnection = this.dbConn;
			createStatement.text = "CREATE TABLE IF NOT EXISTS preferences (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, type TEXT, strvalue TEXT, intvalue INTEGER)";
			createStatement.addEventListener(SQLEvent.RESULT, populate_preferences);
			createStatement.addEventListener(SQLErrorEvent.ERROR, errorHandler);
			createStatement.execute();
		}
		
		/**
		 * @private
		 * This executes the string provided on the database.
		 * 
		 * @param str The string containing the SQL statement.
		 */
		private function insert_string(str:String):void {
			var createStatement:SQLStatement = new SQLStatement();
			createStatement.sqlConnection = this.dbConn;
			createStatement.text = str;
			createStatement.execute();
		}
		
		/**
		 * @private
		 * If the table has just been created, then populate the table with the defaults
		 * 
		 * @param e The SQLEvent from the create_table call
		 */
		private function populate_preferences(e:SQLEvent):void {
			for (var i:int = 0; i < this.defaults.length; i++) {
				if (this.defaults[i].type == "String") {
					insert_string("INSERT INTO preferences (name,type,strvalue) VALUES ('" + this.defaults[i].name + "','" + this.defaults[i].type + "','" + this.defaults[i].value + "')"); 
				} else {
					insert_string("INSERT INTO preferences (name,type,intvalue) VALUES ('" + this.defaults[i].name + "','" + this.defaults[i].type + "'," + this.defaults[i].value + ")"); 
				}
			}
		}
		
		/**
		 * @private
		 * Populate the prefsObj with the information from the database
		 * 
		 * @param e The SQLEvent init_prefereces call to Select *
		 */
		private function init_prefs(e:SQLEvent):void {
			this.prefs = e.target.getResult().data;
			this.prefsObj = this.get_preferences();
		}
		
		/**
		 * Init the class with information from the database.
		 */
		public function init_preferences():void {
			var getPrefs:SQLStatement = new SQLStatement();
			getPrefs.sqlConnection = this.dbConn;
			getPrefs.addEventListener(SQLEvent.RESULT, init_prefs);
			getPrefs.text = "SELECT * FROM preferences;";
			try {
				getPrefs.execute();
			} catch (err:SQLError) {
				mx.controls.Alert.show(err.details,err.message);
			}			
		}
		
		/**
		 * Return an integer pref value
		 * 
		 * @param name The name of the preference
		 * @return The integer value of the preference
		 */
		public function get_int_pref(name:String):int {
			if (prefsObj[name] != null) {
				return (prefsObj[name].value);
			} else {
				return (-1);
			}
		}
		
		/**
		 * Return a string pref value
		 * 
		 * @param name Then name of the preference
		 * @return The string value of the preference.
		 */
		public function get_pref(name:String):String {
			if (prefsObj[name] != null) {
				return (prefsObj[name].value.toString());
			} else {
				return ("");
			}
		}
		
		/**
		 * This function handles a condition where an end-user has updated their version of their application
		 * and the new version allows for new preferences. If the preference doesn't exist in their current
		 * database that was carried over from the previous version, then we insert a new row.
		 * 
		 * @param name The name of the new preference
		 * @param value The name of the value for the new preference
		 */
		private function insertNewPreference(name:String, value:String):void {
			
			var pref:Object;
			for (var i:int = 0; i < this.defaults.length; i++) {
				if (this.defaults[i].name == name) {
					pref = this.defaults[i];
				}
			}
			
			//Currently aborting for unknown prefs
			if (pref == null) {
				return;
			}
			
			if (pref.type == "String") {
				insert_string("INSERT INTO preferences (name,type,strvalue) VALUES ('" + pref.name + "','" + pref.type + "','" + value + "')"); 
			} else {
				insert_string("INSERT INTO preferences (name,type,intvalue) VALUES ('" + pref.name + "','" + pref.type + "'," + value + ")"); 
			}
			
			init_preferences();
		}
		
		/**
		 * Update a preferences value in the database.
		 * 
		 * @param name The name of the preference to update
		 * @param value The new value for the preference
		 * @param finalUpdate A boolean value inidicating whether this is the last in a change of updates (default true)
		 */
		public function update_pref (name:String,value:String,finalUpdate:Boolean=true):void {
			var updateStatement:SQLStatement = new SQLStatement();
			updateStatement.sqlConnection = this.dbConn;
			
			if (this.prefsObj[name] == null) {
				insertNewPreference(name,value);
				return;
			} else if (this.prefsObj[name].type == 'int') {
				updateStatement.text = "UPDATE preferences SET intvalue = :value WHERE name = :name;";
				updateStatement.parameters[":name"] = name;
				updateStatement.parameters[":value"] = int(value);
			} else {
				updateStatement.text = "UPDATE preferences SET strvalue = :value WHERE name = :name;";
				updateStatement.parameters[":name"] = name;
				updateStatement.parameters[":value"] = value;
			}

			updateStatement.execute();
			
			if (finalUpdate) {
				init_preferences();	
			}
		}
		
		
		/**
		 * Return a preferences object containing all the preferences
		 * 
		 * @return The Object containing the preferences values as a hash
		 */
		public function get_preferences():Object {
			var prefsObj:Object = new Object;
			
			if (this.prefs == null) {
				return (prefsObj);
			}
			
			for (var i:int = 0; i < this.prefs.length; i++) {
				prefsObj[this.prefs[i].name] = new Object;
				prefsObj[this.prefs[i].name].type = prefs[i].type
				if (this.prefs[i].type == "int") {
					prefsObj[this.prefs[i].name].value = int(this.prefs[i].intvalue);
				} else if (this.prefs[i].type == "String") {
					prefsObj[this.prefs[i].name].value = this.prefs[i].strvalue;
				}
			}
			
			return (prefsObj);
		}

	}
}