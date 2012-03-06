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
	import decompiler.swfdump.SWFFormatError;
	import decompiler.swfdump.TagHandler;
	import decompiler.tamarin.abcdump.Rect;
	import decompiler.tamarin.abcdump.Tag;

	public class DefineScalingGrid extends Tag
	{
		public var scalingTarget:DefineTag;
		public var rect:Rect = new Rect();
		
		public function DefineScalingGrid(tag:DefineTag = null)
		{
			super(stagDefineScalingGrid);
			
			//assert tag instanceof DefineSprite || tag instanceof DefineButton;
			if (tag && (!(tag is DefineSprite) && !(tag is DefineButton))) {
				throw new SWFFormatError("ScalingGrid provided with invalid tag.");
			}
			
			if (tag is DefineSprite)
			{
				(tag as DefineSprite).scalingGrid = this;
			}
		}
		
		public override function visit(h:TagHandler):void
		{
			h.defineScalingGrid( this );
		}
		
		protected function getSimpleReference():Tag
		{
			return scalingTarget;
		}
		
		public override function equals(other:*):Boolean
		{
			return ((other is DefineScalingGrid)
				&& (other.scalingTarget == scalingTarget)
				&& (other.rect.equals( rect )));
		}
	}
}