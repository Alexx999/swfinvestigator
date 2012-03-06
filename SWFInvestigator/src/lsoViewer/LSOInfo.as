/****************************************************************************
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2012 Adobe Systems Incorporated and it’s licensors
 * All Rights Reserved.
 *  
 * NOTICE: Adobe permits you to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 * ****************************************************************************/

package lsoViewer
{
	/**
	 * The LSOInfo class maintains information regarding a Local Shared Object.
	 */
	public class LSOInfo
	{
		import flash.filesystem.File;
		import flash.net.FileReference;

		public function LSOInfo()
		{
		}
		
		/**
		 * The name of the LSO
		 */
		public var LSOname:String;
		
		/**
		 * The domain for the LSO
		 */
		public var domain:String;
		
		/**
		 * The path for the LSO
		 */
		public var pathInfo:String;
		
		/**
		 * The file directory information for where the LSO is stored.
		 */
		public var dirInfo:String;
		
		/**
		 * The name of the SWF that created the LSO (if available)
		 */
		public var swfName:String = "None";
		
		/**
		 * The default name for the SWF if it doesn't need to be renamed.
		 */
		public var defaultSwfName:String = "dumpLSO";
		
		/**
		 * Whether the LSO had the secure flag set.
		 */
		public var secure:Boolean = false;
		
		/**
		 * Whether the LSO was created by Local content
		 */
		public var local:Boolean = false;
		
		/**
		 * This will reset all the information in the class
		 */
		public function clear():void {
			this.pathInfo = "";
			this.dirInfo = "";
			this.domain = "";
			this.LSOname = "";
			this.secure = false;
			this.local = false;
			this.swfName = "None";
		}
		
		/**
		 * Based on the file directory, return the web path for the SWF including domain
		 * 
		 * @return A string representing the path for the LSO
		 */
		public function getWebPath():String
		{
			var myPattern:RegExp = /\\/g;
			var webPath:String = this.dirInfo.replace(myPattern,"/");
			//if (webPath.indexOf("/localhost/") == 0) {
				//webPath = webPath.substr(11);
			//}
			if (this.swfName.indexOf("None") != 0) {
				webPath = webPath.substring(0,webPath.indexOf(this.swfName));
			}
			return webPath;
		}
		
		/**
		 * Construct the complete URL (minus the SWF name) for the SWF that created the LSO.
		 * This is necessary for the determining the sandbox root.
		 * 
		 * @return A string representing the URL of the directory where the SWF lived.
		 */
		public function getLSOURL():String
		{
			var URL:String;
			if (this.secure) {
				URL = "https:/" + this.getWebPath();
			} else if (this.local) {
				//URL = "http:/" + this.getWebPath();
				URL = "file:///C:/" + this.getWebPath().substr(11);
			} else {
				URL = "http:/" + this.getWebPath();
			}
			return (URL);
		}
		
		/**
		 * This returns the directory path for the LSO minus the domain and name of the SWF
		 * 
		 * This is the path that will eventually be used by the SharedObject API
		 * 
		 * @return A string with the LSO path value for the SWF
		 */
		public function getLSOPath():String {

			//If custom name, use the default path (null)
			if (this.swfName.indexOf("None") != 0) {
				return "";	
			}
			
			var temp:String = this.getWebPath().substr(1);
			return (temp.substring(temp.indexOf("/")));
		}
		
		/**
		 * Returns the URL for the iframe src parameter that includes the necessary GET variables.
		 * 
		 * @return A string for the iframe's src parameter.
		 */
		public function getSWFLocation():String
		{
			var mySWFName:String = this.swfName;
			if (mySWFName.indexOf("None") != 0) {
				var sourceFile:File = File.applicationStorageDirectory;
				sourceFile = sourceFile.resolvePath("lsoViewer/dumpLSO.swf");
				var destination:File = File.applicationStorageDirectory;
				destination = destination.resolvePath("lsoViewer/" + this.swfName);
				sourceFile.copyTo(destination, true);
				mySWFName = mySWFName.substr(0,mySWFName.length -4);
			} else {
				mySWFName = this.defaultSwfName;
			}
			
			var returnString:String = "./dumpWrapper.html?" + mySWFName;
			
			returnString += ":lsoName=" + this.LSOname + "&lsoPath=" + this.getLSOPath();
			if (this.secure) {
				returnString += "&lsoSecure=true";
			} else {
				returnString += "&lsoSecure=false";
			}
			
			return (returnString);
		}
		
		/**
		 * Returns the location to be used in the iframe's documentRoot parameter
		 * 
		 * @return A string containing the documentRoot path.
		 */
		public function getDocumentRoot():String {
			return "app-storage:/lsoViewer/";
		}

	}
}