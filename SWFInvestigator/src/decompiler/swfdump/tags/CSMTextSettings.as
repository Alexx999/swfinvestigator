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
	
	public class CSMTextSettings extends DefineTag
	{
		public var textReference:DefineTag;
		public var styleFlagsUseSaffron:int; // 0 if off, 1 if on
		public var gridFitType:int; // 0 if none, 1 if pixel, 2 if subpixel
		public var thickness:Number;
		public var sharpness:Number;
		
		public function CSMTextSettings()
		{
			super(stagCSMTextSettings);
		}
		
		public override function visit(h:TagHandler):void
		{
			h.csmTextSettings(this);
		}
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			if (super.equals(object) &&  (object is CSMTextSettings))
			{
				var settings:CSMTextSettings = object as CSMTextSettings;
				if (textReference.equals(settings.textReference) &&
					styleFlagsUseSaffron == settings.styleFlagsUseSaffron &&
					gridFitType == settings.gridFitType &&
					thickness == settings.thickness &&
					sharpness == settings.sharpness)
				{
					isEqual = true;
				}
			}
			return isEqual;
		}
	}
}