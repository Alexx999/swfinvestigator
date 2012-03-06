/****************************************************************************
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2012 Adobe Systems Incorporated and it’s licensors
 * All Rights Reserved.
 *  
 * NOTICE: Adobe permits you to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 * ****************************************************************************/

package utils
{
	import databaseUtils.PreferencesDB;
	
	import flash.display.Loader;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.html.HTMLHost;
	import flash.html.HTMLLoader;
	import flash.net.URLRequest;
	
	import utils.AMFFuzzer;
	import utils.AS3Compiler.ABCEditor;
	import utils.ObjectEditor.ObjectEditor;
	import utils.xssFuzzer.xssPanel;
	import utils.MiniWebServer;
	
	/**
	 * This class is used to launch different windows typically chosen from the View menu
	 */
	public class utilWindow
	{
		//Defaults for Encoder/Decoder Window	
		private var encDecLocation:String = "app:/utils/EncDecUtils.swf";
		private var encDecWidth:int = 550;
		private var encDecHeight:int = 530;
		
		//Defaults for the LCEnumerator Window
		private var LCEnumLocation:String = "app:/lcEnumerator/LCWrapper.html";
		private var LCEnumWidth:int = 590;
		private var LCEnumHeight:int = 700;
		
		//Defaults for the Remap Browser Window
		private var RemapBrowserLocation:String = "app:/utils/remapBrowser/RemapBrowser.html";
		private var rBrowserWidth:int = 640;
		private var rBrowserHeight:int = 640;

		//Local copy of the preferences DB
		private var prefsDB:PreferencesDB;
	
		/**
		 * Constructor for utilWindow
		 * 
		 * @param prefDB a pointer to the preferences DB
		 */
		public function utilWindow(prefDB:PreferencesDB)
		{
			this.prefsDB = prefDB;
		}
		
		/**
		 * @private
		 * Launches the Preferences window based on the prefsWindow class
		 */ 
		private function loadPreferences():void {
			var newWindow:prefsWindow = new prefsWindow(); 
			newWindow.prefDB = this.prefsDB;
			newWindow.initInfo();
			newWindow.open(true);
		}
		
		/**
		 * Launches the About menu based on the AboutMenu() class
		 */
		private function loadAboutWindow():void {
			var newWindow:AboutMenu = new AboutMenu(); 
			newWindow.open(true);
		}
		
		/**
		 * @private
		 * Launches the AMF Query Window based on the AMFTransmitter class
		 */
		private function loadAMFQuery():void {
			var newWindow:AMFTransmitter = new AMFTransmitter(); 
			newWindow.open(true);
		}

		/**
		 * @private
		 * Launches the AMF Identifier window
		 */
		private function loadAMFIdent():void {
			var newWindow:AMFIdentifier = new AMFIdentifier();
			newWindow.prefDB = this.prefsDB;
			newWindow.open(true);
		}
		
		/**
		 * @private
		 * Launches the AMF Fuzzer Window
		 */
		private function loadAMFFuzzer():void {
			var newWindow:AMFFuzzer = new AMFFuzzer(); 
			newWindow.open(true);
		}


		/**
		 * @private
		 * Launches the Object Editor
		 */
		private function loadObjectEditor():void {
			var newWindow:ObjectEditor = new ObjectEditor(); 
			newWindow.open(true);
		}

		/**
		 * @private
		 * Launches the SettingsViewer
		 */
		private function loadSettingsViewer():void {
			var newWindow:SettingsViewer = new SettingsViewer(); 
			newWindow.open(true);
		}
		
		/**
		 * @private
		 * Launches the StringToBin Window based on the StringToBinFile class
		 */
		private function loadStringToBin():void {
			var newWindow:StringToBinFile = new StringToBinFile(); 
			newWindow.open(true);
		}
		
		/**
		 * @private
		 * Launches the as3Compiler Window
		 */
		private function loadAS3Compiler():void {
			var newWindow:ABCEditor = new ABCEditor(); 
			newWindow.open(true);
		}
		
		/**
		 * @private
		 * Launches the XSS Fuzzer Window
		 */
		private function loadXSSFuzzer():void {
			var newWindow:xssPanel = new xssPanel(); 
			newWindow.prefDB = this.prefsDB;
			newWindow.open(true);
		}
		
		/**
		 * @private
		 * Launches the MiniWebServer
		 */
		private function loadMiniWebServer():void {
			var newWindow:MiniWebServer = new MiniWebServer(); 
			newWindow.prefDB = this.prefsDB;
			newWindow.open(true);
		}

		/**
		 * @private
		 * Launches the LSOViewer Window based on the StringToBinFile class
		 */
		private function loadLSOViewer():void {
			var newWindow:LSOViewer = new LSOViewer(); 
			newWindow.open(true);
		}
		/**
		 * @private
		 * Used to launch the Encoder/Decoder window once the Enc/Dec SWF is loaded.
		 * 
		 * @param e The complete event from the SWF Loader that loads the Enc/Dec SWF.
		 */
		private function loadEncDec(e:Event):void {
			var options:NativeWindowInitOptions = new NativeWindowInitOptions();
			options.systemChrome = NativeWindowSystemChrome.STANDARD;
			options.type = NativeWindowType.NORMAL;
			options.transparent = false;
			options.resizable = true;
			
			var newWindow:NativeWindow = new NativeWindow(options);
    		newWindow.title = "Encoder/Decoder";
    		newWindow.width = encDecWidth;
    		newWindow.height = encDecHeight;
			newWindow.stage.align = StageAlign.TOP_LEFT;
			newWindow.stage.scaleMode = StageScaleMode.NO_SCALE;
			
			newWindow.stage.addChild(e.target.loader);
			newWindow.activate();
		}
		
		/**
		 * Used to launch the LC Enumerator Window
		 * 
		 * @param info The object containing the defaults for the LocalConnection
		 */
		private function loadLCEnum(info:Object):void {
			var options:NativeWindowInitOptions = new NativeWindowInitOptions();
			options.systemChrome = NativeWindowSystemChrome.STANDARD;
			options.type = NativeWindowType.NORMAL;
			options.transparent = false;
			options.resizable = true;
			
			var rect:Rectangle = new Rectangle(0,0,this.LCEnumWidth,this.LCEnumHeight);
			
			var htmlLoader:HTMLLoader = HTMLLoader.createRootWindow(true,options,true,rect);
			
			var location:String;
			if (info.domain != "") {
				location = this.LCEnumLocation + "?url=" + info.protocol + info.domain;
			} else {
				location = this.LCEnumLocation + "?url=" + this.prefsDB.getPref("defaultLCDomain");
			}
			htmlLoader.load(new URLRequest(location));
		}
		
		/**
		 * @private
		 * Used to launch the Remote Browser Window
		 */
		private function loadRBrowser():void {
			var options:NativeWindowInitOptions = new NativeWindowInitOptions();
			options.systemChrome = NativeWindowSystemChrome.STANDARD;
			options.type = NativeWindowType.NORMAL;
			options.transparent = false;
			options.resizable = true;
			
			var rect:Rectangle = new Rectangle(0,0,this.rBrowserWidth,this.rBrowserHeight);
			
			var htmlLoader:HTMLLoader = HTMLLoader.createRootWindow(true,options,true,rect);
			htmlLoader.userAgent = this.prefsDB.getPref('defaultUserAgent');
			htmlLoader.htmlHost = new HTMLHost();
			
			htmlLoader.load(new URLRequest(this.RemapBrowserLocation));
		}
		
		/**
		 * Called by SWF Investigator whenever a new window needs to be created for items under View
		 * 
		 * This is typically for LC Enumerator, Preferences, About, AMF Query, etc.
		 * 
		 * @param type The string containing the type of window to be opened
		 * @param info An object of information to pass to the window.
		 */
		public function createNewRootWindow(type:String,info:Object):void {
			var urlRequest:URLRequest;
			var swfLoader:Loader = new Loader();
			
			if (type == "EncDec") {
				urlRequest = new URLRequest(this.encDecLocation);
				swfLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadEncDec);
				swfLoader.load(urlRequest);
			} else if (type == "LCEnum") {
				this.loadLCEnum(info);
			} else if (type == "Preferences") {
				this.loadPreferences();
			} else if (type == "About") {
				this.loadAboutWindow();
			} else if (type == "AMFQuery") {
				this.loadAMFQuery();
			} else if (type == "AMFIdent") {
				this.loadAMFIdent();
			} else if (type == "RemapBrowser") {
				this.loadRBrowser();
			} else if (type == "ObjectEditor") {
				this.loadObjectEditor();
			} else if (type == "SettingsViewer") {
				this.loadSettingsViewer();
			} else if (type == "StringToBin") {
				this.loadStringToBin();
			} else if (type == "LSOViewer") {
				this.loadLSOViewer();
			} else if (type == "as3Compiler") {
				this.loadAS3Compiler();
			} else if (type == "xssFuzzer") {
				this.loadXSSFuzzer();
			} else if (type == "AMFFuzz") {
				this.loadAMFFuzzer();
			} else if (type == "miniWebServer") {
				this.loadMiniWebServer();
			}
		}

	}
}