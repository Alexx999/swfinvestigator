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
	import flash.utils.ByteArray;

	public class DefineBinaryData extends DefineTag
	{
		public var reserved:int;
		public var data:ByteArray;
		
		public function DefineBinaryData()
		{
			super (stagDefineBinaryData);
		}
		
		public override function visit(h:TagHandler):void {
			h.defineBinaryData(this);
		}
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is DefineBinaryData))
			{
				var defineBinaryData:DefineBinaryData = object as DefineBinaryData;
				
				if (defineBinaryData.data.length != this.data.length) {
					isEqual = false;
					return (isEqual);
				}
				
				isEqual = true;
				
				for (var i:int = 0; i < this.data.length; i++) {
					if (defineBinaryData.data[i] != this.data[i]) {
						isEqual = false;
					}
				}
			}
			
			return isEqual;
		}
	}
}