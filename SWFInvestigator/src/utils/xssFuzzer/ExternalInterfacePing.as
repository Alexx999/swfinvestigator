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
  import flash.external.ExternalInterface;
  import flash.display.Sprite;

  public class ExternalInterfacePing extends Sprite {
     public function ExternalInterfacePing() {
	  ExternalInterface.call("sendPingBack");
     }
  }
}