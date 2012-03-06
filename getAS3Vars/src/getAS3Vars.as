/****************************************************************************
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2012 Adobe Systems Incorporated and it’s licensors
 * All Rights Reserved.
 *  
 * NOTICE: Adobe permits you to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 * ****************************************************************************/

package {
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import ParamHandlers.ObjectParser;

	/**
	 * This is used by the AS3Introspector to wrap a remote SWF so that the data can be retrieved via cross-scripting.
	 */
	public class getAS3Vars extends Sprite
	{
		private var as3Display:Loader;
		private var sUrl:String;
		
		/**
		 * Constructor
		 * Registers the callback functions for the HTML to set up the proxy.
		 */
		public function getAS3Vars()
		{

			ExternalInterface.addCallback("as3fetchVar",as3fetchVar);

			var paramObj:Object = LoaderInfo(this.root.loaderInfo).parameters;
			var fVars:String;
			
			for (var keyStr:String in paramObj) {
				if (keyStr == "swfurl") {
					this.sUrl = paramObj[keyStr];
				} else {
					if (fVars == null) {
						fVars = paramObj[keyStr];
					} else {
						fVars += "&" + paramObj[keyStr];
					}
				}
			}
 			
			this.as3Display = new Loader();
			configureListeners(this.as3Display.contentLoaderInfo);

			var loadStr:String = this.sUrl;
			if (fVars != null && fVars.length > 0) {
				loadStr += "?" + fVars; 
			}
			
			this.as3Display.load(new URLRequest(loadStr));
			addChild(this.as3Display);
		}
		
		/**
		 * @private
		 * Registers listeners (IO_ERROR and COMPLETE) to the IEventDispatcher of the Loader.
		 */
		private function configureListeners(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            dispatcher.addEventListener(Event.COMPLETE, completeHandler);
		}
		
		/**
		 * @private
		 * The IOError Handler will dump the error message to the surrounding HTML to be passed back to Flash Analyzer
		 * 
		 * @param event The IOErrorEvent from the SWF loader.
		 */
        private function ioErrorHandler(event:IOErrorEvent):void {
            ExternalInterface.call("sendMessage","ioErrorHandler: ",event.toString());
        }
        
        /**
         * @private
         * The complete handler which tells Flash Analyzer that the call was a success by sending a message to the surrounding HTML.
         * 
         * @param event The complete event from the SWF Loader.
         */
        private function completeHandler(event:Event):void {
        	ExternalInterface.call("sendMessage","Success: ","SWF is Loaded");
        }
	
		/**
		 * @private
		 * This function is registered with the HTML as a callback to be used when a value needs to be retrieved, assigned or called as a functoin.
		 * 
		 * TODO: The paramString needs to be converted to XML.
		 * 
		 * @param varName The string containing the variable name
		 * @param action The action to be performed on the object ("call","assign")
		 * @param paramString The arguments to pass to the function (default null)
		 * @return The string representing the variable or error.
		 */ 
		private function as3fetchVar(varName:String,action:String,paramString:String = null):String {

			if (varName == null || varName == "") {
				return("Please enter a value to fetch!");
			} else if (action == null || action == "") {
				return("Please send an action!");
			}
			
			var params:Array;
			var args:Array;
			if (paramString != null && paramString.length > 0) {
				params = new Array;
				args = paramString.split("||||||");
				for each (var paramVar:String in args) {
					var temp:Array = paramVar.split("&&&&&&");
					if (temp[0] == "int") {
						params.push(int(temp[1]));
					} else if (temp[0] == "null") {
						params.push(null);
					} else if (temp[0] == "Array") {
						params.push (temp[1].split(","));
					} else if (temp[0] == "Number") {
						params.push (Number(temp[1]));
					} else if (temp[0] == "XML") {
            			params.push(new XML(temp[1]));
            		} else if (temp[0] == "uint") {
            			params.push(uint(Number(temp[1])));
            		} else if (temp[0] == "Boolean") {
            			var b:Boolean = false;
            			if (temp[0] == "true" || temp[0] == "1") {
            				b = true;
            			}
            			params.push(b);
					} else {
						params.push(temp[1]);
					}
				}
			}
				
			var chunks:Array = varName.split(".");
			
			var varArray:DisplayObject = this.as3Display.content;
			var tempArray:Array = new Array();
			var dumbFlag:int = -1;
				
			try {
				for each (var i:* in chunks) {
					if (dumbFlag == -1) {
						if (action == "call" && chunks.length == 1) {
							args = new Array(1);
							tempArray.push(varArray[i].apply(varArray,params));
						} else if (action == "assign" && chunks.length == 1) {
							varArray[i] = params[0];
							return ("Value Assigned");
						} else {
							tempArray.push(varArray[i]);
						}
					} else if ((chunks.length == dumbFlag + 2) && action == "call") {
						tempArray.push(tempArray[dumbFlag][i].apply(tempArray[dumbFlag],params));
					} else if ((chunks.length == dumbFlag + 2) && action == "assign") {
						tempArray[dumbFlag][i] = params[0];
						return("Value Assigned");
					} else {
						tempArray.push(tempArray[dumbFlag][i]);
					}
					dumbFlag++;
				}
			} catch (e:Error) {
				return(e.name + ": " + e.message);
			}

			var varData:* = tempArray.pop();
			var outputData:String = "";

			var oParser:ObjectParser = new ObjectParser();
			outputData += oParser.valueToString(i,varData);
			    	
			return(outputData);
		}
	}
}
