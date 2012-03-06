/****************************************************************************
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2012 Adobe Systems Incorporated and it’s licensors
 * All Rights Reserved.
 *  
 * NOTICE: Adobe permits you to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 * ****************************************************************************/

package ParamHandlers
{
	/**
	 * This class is used by dumpLSO,getAS3Vars and the Intruder classes to parse objects.
	 * 
	 * The purpose of this class is to deconstruct an object into various forms such as a String, XML, etc.
	 * 
	 * This is a centralized library so that improvements to the parser get reflected into all of the
	 * sub classes.
	 * 
	 * TODO: XML and other formats.
	 */
	public class ObjectParser
	{
		import flash.utils.describeType;
		import flash.external.ExternalInterface;
		import mx.utils.ObjectUtil;
		
		public function ObjectParser()
		{
		}

		
		/**
		 * @private
		 * A recursive function to convert an Object to a String.
		 * 
		 * @param thisObject The Object that is being inspected.
		 * @param indent The string representing the indent type.
		 * @return A string containing the information regarding the object.
		 */
		private function parseObject (thisObject:Object, indent:String):String {
			var myIndent:String = "*" + indent;
			var myOutputString:String = "";
				
			for (var j:* in thisObject) {
			    var stuff:* = thisObject[j];
			    if (stuff == null) {
			    	myOutputString += "\r" + j + ":\t null";
			    } else if (stuff == undefined) {
					myOutputString += "\r" + j + ":\t undefined";
			    } else if (stuff.toString().indexOf("[object Object]") == 0 || stuff.toString().indexOf("[object AMFGeneric]") == 0) {
			    	myOutputString += "\r " + myIndent + " " + j;
					var classInfo:XML = describeType(stuff);
			    	if (classInfo.@name.toString() == "Array") {
			    		var myArr:Array = stuff;
			    		myOutputString += " (Class - " + classInfo.@name.toString() + ")";
			    		myOutputString += parseObject(myArr, myIndent);
			    	} else if (stuff is Date) {
			    		myOutputString += " (Date):\t" + stuff.toString(); 
			    	}else {
			    		if (classInfo.@alias.toString()) {
			    			myOutputString += " (Class - " + classInfo.@name.toString() + " Alias - " + classInfo.@alias.toString() + ")";
			    		} else {
			    			myOutputString += " (Class - " + classInfo.@name.toString() + ")";
			    		}
			    		myOutputString += parseObject(stuff, myIndent);
			    	}	
			    } else {
			    	myOutputString += "\r " + myIndent + " " + j + " (" + typeof(stuff) + "):\t" + stuff;
			    }
			}
			return (myOutputString);
		}
		
		/**
		 * This function will convert an array of variables into a single string.
		 * 
		 * This is used by sections such as dumpLSO to dump everything in the LSO.
		 * 
		 * @param ... This takes "... rest" as a parameter because there could be multiple types sent to this function.
		 * @return A string representing the array of objects.
		 */
		public function arrayToString(... rest):String {
			var outputData:String = "";
			
			for (var i:* in rest[0]) {
				outputData += this.valueToString(i, rest[0][i]);
			}
			
			return (outputData);
		}

		/**
		 * This converts a single value or object to a string
		 * 
		 * @param ... This takes "... rest" as a parameter because there could be multiple types sent to this function.
		 * @return A string representing the object.
		 */
		public function valueToString(... rest):String {
			
			var outputData:String = "";

			if (rest[1] == null) {
				outputData += "\r" + rest[0] + ":\t null";
			} else if (rest[1] == undefined) {
				outputData += "\r" + rest[0] + ":\t undefined";
			} else if (rest[1].toString().indexOf("[object Object]") == 0 || rest[1].toString().indexOf("[object AMFGeneric]") == 0) {
				var classInfo:XML = describeType(rest[1]);
				outputData += "\r" + rest[0];
			    if (classInfo.@name.toString() == "Array") {
			    	outputData += " (" + classInfo.@name.toString() + ")";
			    	var myArr:Array = rest[1];
			    	outputData += this.parseObject(myArr,"");
			    } else if (rest[1] is Date) {
			    		outputData += " (Date):\t" + rest[1].toString(); 
			    } else {
			    	if (classInfo.@alias.toString()) {
			    		outputData += " (" + classInfo.@name.toString() + " Alias - " + classInfo.@alias.toString() + ")";
			    	} else {
			    		outputData += " (" + classInfo.@name.toString() + ")";
			    	}
			    	outputData += this.parseObject(rest[1],"");
			    }
			} else {
			    outputData += "\r" + rest[0] + " (" + typeof(rest[1]) + "):\t" + rest[1].toString();
			}
			return (outputData);
		}

	}
}