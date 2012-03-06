/****************************************************************************
 * ADOBE SYSTEMS INCORPORATED
 *  Copyright 2012 Adobe Systems Incorporated and it’s licensors
 *  All Rights Reserved.
 *  
 * NOTICE: Adobe permits you to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 * ****************************************************************************/

package decompiler.Logging
{
	public interface ILog
	{
		function print (... rest):void
		function errorPrint (... rest):void
		function clear():void;
	}
}