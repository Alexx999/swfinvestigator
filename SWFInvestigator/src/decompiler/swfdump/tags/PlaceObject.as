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
	import decompiler.swfdump.TagValues;
	import decompiler.swfdump.types.CXForm;
	import decompiler.swfdump.types.ClipActions;
	import decompiler.swfdump.types.Filter;
	import decompiler.swfdump.types.Matrix;
	import decompiler.tamarin.abcdump.Tag;

	public class PlaceObject extends Tag
	{
		public var flags:int;
		private static const HAS_CLIP_ACTION:int = 1 << 7;
		private static const HAS_CLIP_DEPTH:int = 1 << 6;
		private static const HAS_NAME:int = 1 << 5;
		private static const HAS_RATIO:int = 1 << 4;
		private static const HAS_CXFORM:int = 1 << 3;
		private static const HAS_MATRIX:int = 1 << 2;
		private static const HAS_CHARACTER:int = 1 << 1;
		private static const HAS_MOVE:int = 1 << 0;
		
		public var flags2:int;
		private static const HAS_IMAGE:int = 1 << 4;
		private static const HAS_CLASS_NAME:int = 1 << 3;
		private static const HAS_CACHE_AS_BITMAP:int = 1 << 2;
		private static const HAS_BLEND_MODE:int = 1 << 1;
		private static const HAS_FILTER_LIST:int = 1 << 0;
		
		public var ratio:int;
		public var name:String;
		public var clipDepth:int;
		public var clipActions:ClipActions;
		public var depth:int;
		public var matrix:Matrix;
		public var colorTransform:CXForm;
		public var ref:DefineTag;
		public var filters:Vector.<Filter>;
		public var blendMode:int;
		public var className:String;
		
		public function PlaceObject(code:int = -1, m:Matrix = null, ref:DefineTag =null, depth:int=0, name:String = "")
		{
			if (code == -1) {
				code = TagValues.stagPlaceObject2;
				this.depth = depth;
				setRef(ref);
				setMatrix(m);
				setName(name);
			}
			
			super(code);

		}
		
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is PlaceObject))
			{
				var placeObject:PlaceObject = object as PlaceObject;
				
				// not comparing filters list
				if ( (placeObject.flags == this.flags) &&
					(placeObject.flags2 == this.flags2) &&
					(placeObject.ratio == this.ratio) &&
					objectEquals(placeObject.name, this.name) &&
					(placeObject.clipDepth == this.clipDepth) &&
					objectEquals(placeObject.clipActions, this.clipActions) &&
					(placeObject.depth == this.depth) &&
					objectEquals(placeObject.matrix, this.matrix) &&
					objectEquals(placeObject.colorTransform, this.colorTransform) &&
					objectEquals(placeObject.ref, this.ref) &&
					(placeObject.blendMode == this.blendMode) &&
					objectEquals(placeObject.className, this.className) )
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
		
		public override function hashCode():int {
			var hashCode:int = super.hashCode();
			hashCode += DefineTag.PRIME * flags;
			hashCode += DefineTag.PRIME * ratio;
			if (name!=null) {
				//SWF Investigator - Cheating
				//hashCode += name.hashCode();
				hashCode += name.length;
			}
			hashCode += DefineTag.PRIME * depth;
			return hashCode;
		}
		
		
		public override function visit(h:TagHandler):void
		{
			if (code == stagPlaceObject)
				h.placeObject(this);
			else if (code == stagPlaceObject2)
				h.placeObject2(this);
			else // if (code == stagPlaceObject3)
				h.placeObject3(this);
		}
		
		public function getSimpleReference():Tag
		{
			return hasCharID()? ref : null;
		}
		
		public function setRef(ref:DefineTag):void
		{
			/**
			 * SWF Investigator commenting out because I don't track all tags yet therefore this will always throw.
			if (ref == null)
				throw new SWFFormatError("DefineTag ref is null in PlaceObject");
				//throw new NullPointerException();
			*/
			this.ref = ref;
			flags = ref != null ? flags|HAS_CHARACTER : flags&~HAS_CHARACTER;
		}
		
		public function setMatrix(m:Matrix):void
		{
			this.matrix = m;
			flags = m != null ? flags|HAS_MATRIX : flags&~HAS_MATRIX;
		}
		
		public function hasClipAction():Boolean
		{
			return (flags & HAS_CLIP_ACTION) != 0;
		}
		
		public function hasClipDepth():Boolean
		{
			return (flags & HAS_CLIP_DEPTH) != 0;
		}
		
		public function setClipDepth(clipDepth:int):void
		{
			this.clipDepth = clipDepth;
			flags |= HAS_CLIP_DEPTH;
		}
		
		public function hasName():Boolean
		{
			return (flags & HAS_NAME) != 0;
		}
		
		public function hasRatio():Boolean
		{
			return (flags & HAS_RATIO) != 0;
		}
		
		public function setRatio(ratio:int):void
		{
			this.ratio = ratio;
			flags |= HAS_RATIO;
		}
		
		public function hasCharID():Boolean
		{
			return (flags & HAS_CHARACTER) != 0;
		}
		
		public function hasMove():Boolean
		{
			return (flags & HAS_MOVE) != 0;
		}
		
		public function hasMatrix():Boolean
		{
			return (flags & HAS_MATRIX) != 0;
		}
		
		public function hasCxform():Boolean
		{
			return (flags & HAS_CXFORM) != 0;
		}
		
		public function hasFilterList():Boolean
		{
			return (flags2 & HAS_FILTER_LIST) != 0;
		}
		
		public function setFilterList(value:Vector.<Filter>):void
		{
			filters = value;
			flags2 = value != null ? flags2|HAS_FILTER_LIST : flags2&~HAS_FILTER_LIST;
		}
		
		public function hasBlendMode():Boolean
		{
			return (flags2 & HAS_BLEND_MODE) != 0;
		}
		
		public function setBlendMode(value:int):void
		{
			blendMode = value;
			flags2 = value != 0 ? flags2|HAS_BLEND_MODE : flags2&~HAS_BLEND_MODE;
		}
		
		public function hasCacheAsBitmap():Boolean
		{
			return (flags2 & HAS_CACHE_AS_BITMAP) != 0;
		}
		
		public function setCacheAsBitmap(value:Boolean):void
		{
			flags2 = value ? flags2|HAS_CACHE_AS_BITMAP : flags2&~HAS_CACHE_AS_BITMAP;
		}
		
		public function setCxform(cxform:CXForm):void
		{
			this.colorTransform = cxform;
			flags = cxform != null ? flags|HAS_CXFORM : flags&~HAS_CXFORM;
		}
		
		public function setName(instanceName:String):void
		{
			this.name = instanceName;
			flags = instanceName != null ? flags|HAS_NAME : flags&~HAS_NAME;
		}
		
		public function setClipActions(actions:ClipActions):void
		{
			clipActions = actions;
			flags = actions != null ? flags|HAS_CLIP_ACTION : flags&~HAS_CLIP_ACTION;
		}
		
		public function setClassName(className:String):void
		{
			this.className = className;
			flags2 = className != null ? flags2|HAS_CLASS_NAME : flags2&~HAS_CLASS_NAME;
		}
		
		public function hasClassName():Boolean
		{
			return (flags2 & HAS_CLASS_NAME) != 0;
		}
		
		public function setHasImage(value:Boolean):void
		{
			flags2 = value ? flags2|HAS_IMAGE : flags2&~HAS_IMAGE;
		}
		
		public function hasImage():Boolean
		{
			return (flags2 & HAS_IMAGE) != 0;
		}
		
	}
}