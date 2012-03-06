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

package decompiler.swfdump.tags
{
	import decompiler.swfdump.TagHandler;
	import decompiler.tamarin.abcdump.Tag;
	
	/**
	 * This represents a EnableDebugger SWF tag.  This supports AS2 and
	 * AS3.
	 *
	 * @author Clement Wong
	 */
	public class EnableDebugger extends Tag
	{
		
		public function EnableDebugger(code:int = 0, password:String = null)
		{
			if (password != null) {
				code = stagEnableDebugger2;
				this.password = password;
			}
			super(code);
		}
		
		public override function visit(h:TagHandler):void
		{
			if (code == stagEnableDebugger)
				h.enableDebugger(this);
			else
				h.enableDebugger2(this);
		}
		
		public var password:String;
		public var reserved:int;
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is EnableDebugger))
			{
				var enableDebugger:EnableDebugger = object as EnableDebugger;
				
				if ( enableDebugger.password == this.password )
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
	}

}