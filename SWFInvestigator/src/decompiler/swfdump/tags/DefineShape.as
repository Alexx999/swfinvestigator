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
	import decompiler.tamarin.abcdump.Rect;
	import decompiler.tamarin.abcdump.Tag;
	import decompiler.swfdump.TagHandler;
	import decompiler.swfdump.types.ShapeWithStyle;
	
	/**
	 * Represents a DefineShape SWF tag.
	 *
	 * @author Clement Wong
	 */
	public class DefineShape extends DefineTag
	{
		public function DefineShape(code:int)
		{
			super(code);
		}
		
		public override function visit(h:TagHandler):void
		{
			switch(code)
			{
				case stagDefineShape:
					h.defineShape(this);
					break;
				case stagDefineShape2:
					h.defineShape2(this);
					break;
				case stagDefineShape3:
					h.defineShape3(this);
					break;
				case stagDefineShape4:
					h.defineShape4(this);
					break;
				default:
					//assert (false);
					this.SIErrorMessage = "Unknown define shape type: " + code;
					break;
			}
		}
		
		/**
		public Iterator<Tag> getReferences()
		{
			LinkedList<Tag> refs = new LinkedList<Tag>();
			
			shapeWithStyle.getReferenceList( refs );
			
			return refs.iterator();
		}
		 */
		
		public var bounds:Rect;
		public var shapeWithStyle:ShapeWithStyle;
		public var usesFillWindingRule:Boolean;
		public var usesNonScalingStrokes:Boolean;
		public var usesScalingStrokes:Boolean;
		public var edgeBounds:Rect;
		
		public var scalingGrid:DefineScalingGrid;
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is DefineShape))
			{
				var defineShape:DefineShape = object as DefineShape;
				
				if ( defineShape.bounds.equals(this.bounds) &&
					defineShape.shapeWithStyle.equals(this.shapeWithStyle) &&
					defineShape.edgeBounds.equals(this.edgeBounds) &&
					(defineShape.usesFillWindingRule == this.usesFillWindingRule) &&
					(defineShape.usesNonScalingStrokes == this.usesNonScalingStrokes) &&
					(defineShape.usesScalingStrokes == this.usesScalingStrokes))
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
		
		public override function hashCode():int {
			var hashCode:int = super.hashCode();
			hashCode += DefineTag.PRIME * bounds.hashCode();
			if (shapeWithStyle.shapeRecords !=null) {
				hashCode += DefineTag.PRIME * shapeWithStyle.shapeRecords.length;
			}
			if (shapeWithStyle.linestyles !=null) {
				hashCode += DefineTag.PRIME * shapeWithStyle.linestyles.length;
			}
			return hashCode;
		}
		
	}

}