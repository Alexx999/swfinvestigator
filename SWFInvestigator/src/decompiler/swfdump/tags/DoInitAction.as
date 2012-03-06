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
	import decompiler.swfdump.types.ActionList;
	import decompiler.tamarin.abcdump.Tag;

	public class DoInitAction extends Tag
	{
		public var sprite:DefineSprite;
		public var actionList:ActionList;
		
		public function DoInitAction(dSprite:DefineSprite = null)
		{
			super(stagDoInitAction);
			this.sprite = dSprite;
			if (dSprite != null) {
				sprite.initAction = this;
			}
		}
		
		public override function visit(h:TagHandler):void
		{
			h.doInitAction(this);
		}
		
		protected function getSimpleReference():Tag
		{
			return sprite;
		}
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is DoInitAction))
			{
				var doInitAction:DoInitAction = object as DoInitAction;
				
				//assert (doInitAction.sprite.initAction == doInitAction);
				/**
				if (doInitAction.sprite.initAction != doInitAction) {
					throw new SWFFormatError("initActions not equal");
				}
				 */
				
				// [paul] Checking that the sprite fields are equal would
				// lead to an infinite loop, because DefineSprite contains
				// a reference to it's DoInitAction.  Also don't compare
				// the order fields, because they are never the same.
				if ( objectEquals(doInitAction.actionList, this.actionList))
				{
					isEqual = true;
				}
			}
			
			//assert (sprite.initAction == this);
			/**
			if (sprite.initAction != this) {
				throw new SWFFormatError ("initActions don't match");
			}
			*/
			
			return isEqual;
		}
	}
}