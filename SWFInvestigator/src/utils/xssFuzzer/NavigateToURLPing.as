/****************************************************************************
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2012 Adobe Systems Incorporated and it’s licensors
 * All Rights Reserved.
 *  
 * NOTICE: Adobe permits you to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 * ****************************************************************************/

package {
	//Compile with mxmlc
	import flash.display.Sprite;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	public class NavigateToURLPing extends Sprite {
		public function NavigateToURLPing() {
			var url:URLRequest = new URLRequest("javascript:sendPingBack();");
			navigateToURL(url,"_self");
		}
	}
}