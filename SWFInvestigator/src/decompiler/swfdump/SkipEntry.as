////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package decompiler.swfdump
{
	import decompiler.swfdump.actions.WaitForFrame;

	internal class SkipEntry
	{
		public var action:WaitForFrame;
		public var skipTarget:int;
		
		public function SkipEntry(a:WaitForFrame, sTarget:int)
		{
			this.action = a;
			this.skipTarget = sTarget;
		}
	}
}