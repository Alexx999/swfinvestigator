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
	import decompiler.swfdump.tags.DefineSprite;
	import decompiler.tamarin.abcdump.Tag;
	import decompiler.swfdump.TagHandler;
	import decompiler.swfdump.Header;
	import decompiler.swfdump.types.TagList

	public class DefineSprite extends DefineTag
	{
		
		public function DefineSprite(spriteName:String = "", source:DefineSprite = null) // semi-shallow copy
		{
			super(stagDefineSprite);
			this.tagList = new TagList();
			if (source != null) {
				this.name = source.name;
				this.tagList.tags.push( source.tagList.tags );
				this.initAction = source.initAction;
				this.framecount = source.framecount;
				this.header = source.header;
				if (source.scalingGrid != null)
				{
					scalingGrid = new DefineScalingGrid();
					scalingGrid.scalingTarget = this;
					scalingGrid.rect.xMin = source.scalingGrid.rect.xMin;
					scalingGrid.rect.xMax = source.scalingGrid.rect.xMax;
					scalingGrid.rect.yMin = source.scalingGrid.rect.yMin;
					scalingGrid.rect.yMax = source.scalingGrid.rect.yMax;
				}
			} else if (spriteName != "") {
				this.name = spriteName;
			}
		}
		
		public override function visit(h:TagHandler):void
		{
			h.defineSprite(this);
		}
		
		/**
		public Iterator<Tag> getReferences()
		{
			ArrayList<Tag> list = new ArrayList<Tag>();
			for (Iterator i = tagList.tags.iterator(); i.hasNext();)
			{
				Tag tag = (Tag) i.next();
				for (Iterator<Tag> j = tag.getReferences(); j.hasNext();)
				{
					list.add(j.next());
				}
			}
			return list.iterator();
		}
		 */
		
		public var framecount:int;
		public var tagList:TagList;
		public var initAction:DoInitAction;
		public var scalingGrid:DefineScalingGrid;
		
		// the header of the SWF this sprite originally came from.  Tells us its framerate and SWF version.
		public var header:Header;
		
		// This is a utility field that helps creating a display list but is not
		// involved in SWF encoding/decoding of DefineSprite
		public var depthCounter:int;
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is DefineSprite))
			{
				var defineSprite:DefineSprite = object as DefineSprite;
				
				if ( (defineSprite.framecount == this.framecount) &&
					objectEquals(defineSprite.tagList, this.tagList) &&
					objectEquals(defineSprite.scalingGrid, this.scalingGrid) &&
					objectEquals(defineSprite.initAction, this.initAction))
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
		
		public override function hashCode():int
		{
			var hashCode:int = super.hashCode();
			
			/**
			 * SWF Investigator being lazy
			if (name != null)
			{
				hashCode += name.hashCode();
			}
			 */
			
			hashCode += DefineTag.PRIME * framecount;
			if (tagList.tags!=null) {
				hashCode += DefineTag.PRIME * tagList.tags.length;
			}
			if (initAction !=null) {
				if (initAction.actionList!=null) {
					hashCode += DefineTag.PRIME * initAction.actionList.size();
				}
			}
			return hashCode;
		}
		
		public override function toString():String
		{
			var stringBuffer:String = new String();
			
			stringBuffer += "DefineSprite: name = " + name +
				", framecount = " + framecount +
				", tagList = " + tagList +
				", initAction = " + initAction;
			
			return stringBuffer;
		}
		
		/*
		private void fitRect(Rect inner, Rect outer)
		{
		if (outer.xMin == 0 && outer.xMax == 0 && outer.yMin==0 && outer.yMax==0)
		{
		outer.xMin = inner.xMin;
		outer.xMax = inner.xMax;
		outer.yMin = inner.yMin;
		outer.yMax = inner.yMax;
		}
		else
		{
		outer.xMin = inner.xMin < outer.xMin ? inner.xMin : outer.xMin;
		outer.yMin = inner.yMin < outer.yMin ? inner.yMin : outer.yMin;
		outer.xMax = inner.xMax > outer.xMax ? inner.xMax : outer.xMax;
		outer.yMax = inner.yMax > outer.yMax ? inner.yMax : outer.yMax;
		}
		}
		
		public Rect getBounds()
		{
		Iterator it = timeline.tags.iterator();
		Rect bounds = new Rect();
		loop: while (it.hasNext())
		{
		Tag t = (Tag) it.next();
		switch (t.code)
		{
		case stagShowFrame:
		// stop at end of first frame
		break loop;
		case stagPlaceObject:
		case stagPlaceObject2:
		PlaceObject po = (PlaceObject) t;
		switch (po.ref.code)
		{
		case stagDefineEditText:
		// how to calculate bounds?
		break;
		case stagDefineSprite:
		DefineSprite defineSprite = (DefineSprite) po.ref;
		Rect spriteBounds = defineSprite.getBounds();
		Rect newBounds = po.hasMatrix() ? po.matrix.xformRect(spriteBounds) : spriteBounds;
		fitRect(newBounds, bounds);
		break;
		case stagDefineShape:
		case stagDefineShape2:
		case stagDefineShape3:
		DefineShape defineShape = (DefineShape) po.ref;
		fitRect(defineShape.bounds, bounds);
		break;
		}
		break;
		}
		}
		return bounds;
		} */
	}
}