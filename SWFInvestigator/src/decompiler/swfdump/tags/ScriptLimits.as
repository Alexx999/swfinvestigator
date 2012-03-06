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
	import decompiler.tamarin.abcdump.Tag;
	import decompiler.swfdump.TagHandler;
	import decompiler.swfdump.TagValues;
	
	public class ScriptLimits extends Tag
	{
		public var scriptRecursionLimit:int;
		public var scriptTimeLimit:int;
		
		public function ScriptLimits(sRecursionLimit:int, sTimeLimit:int)
		{
			super(TagValues.stagScriptLimits);
			
			this.scriptRecursionLimit = sRecursionLimit;
			this.scriptTimeLimit = sTimeLimit;
		}
		
		public override function visit(tagHandler:TagHandler):void
		{
			tagHandler.scriptLimits(this);
		}
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is ScriptLimits))
			{
				var scriptLimits:ScriptLimits = object as ScriptLimits;
				
				if ( (scriptLimits.scriptRecursionLimit == this.scriptRecursionLimit) &&
					(scriptLimits.scriptTimeLimit == this.scriptTimeLimit) )
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
	}
}