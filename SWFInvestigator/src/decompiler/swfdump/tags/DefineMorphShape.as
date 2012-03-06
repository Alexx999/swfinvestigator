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
	import decompiler.swfdump.types.MorphFillStyle;
	import decompiler.swfdump.types.MorphLineStyle;
	import decompiler.swfdump.types.Shape;
	import decompiler.tamarin.abcdump.Rect;
	import decompiler.tamarin.abcdump.Tag;
	
	/**
	 * Represents a DefineMorphShape SWF tag.
	 *
	 * @author Clement Wong
	 */
	public class DefineMorphShape extends DefineTag
	{
		public function DefineMorphShape(code:int)
		{
			super(code);
		}
		
		public override function visit(h:TagHandler):void
		{
			if (code == stagDefineMorphShape)
				h.defineMorphShape(this);
			else // if (code == stagDefineMorphShape2)
				h.defineMorphShape2(this);
		}
		
		/**
		public Iterator<Tag> getReferences()
		{
			// This is yucky.
			List<Tag> refs = new LinkedList<Tag>();
			
			if (startEdges != null)
				startEdges.getReferenceList(refs);
			
			if (endEdges != null)
				endEdges.getReferenceList(refs);
			
			if (fillStyles != null)
			{
				for (int i = 0; i < fillStyles.length; i++)
				{
					MorphFillStyle style = fillStyles[i];
					if (style != null && style.hasBitmapId() && style.bitmap != null)
					{
						refs.add(style.bitmap);
					}
				}
			}
			
			return refs.iterator();
		}
		 */
		
		public var startBounds:Rect;
		public var endBounds:Rect;
		public var startEdgeBounds:Rect;
		public var endEdgeBounds:Rect;
		public var reserved:int;
		public var usesNonScalingStrokes:Boolean;
		public var usesScalingStrokes:Boolean;
		public var fillStyles:Vector.<MorphFillStyle>;
		public var lineStyles:Vector.<MorphLineStyle>;
		public var startEdges:Shape;
		public var endEdges:Shape;
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is DefineMorphShape))
			{
				var defineMorphShape:DefineMorphShape = object as DefineMorphShape;
				
				if ( defineMorphShape.code == this.code &&
					defineMorphShape.startBounds.equals( this.startBounds) &&
					defineMorphShape.endBounds.equals( this.endBounds) &&
					defineMorphShape.startEdges.equals( this.startEdges) &&
					defineMorphShape.endEdges.equals( this.endEdges) )
				{
					isEqual = true;
					var i:int;
					
					if (defineMorphShape.fillStyles != null && this.fillStyles != null &&
						defineMorphShape.fillStyles.length == this.fillStyles.length) {
						for (i=0; i < this.fillStyles.length; i++) {
							if (!this.fillStyles[i].equals(defineMorphShape.fillStyles[i])) {
								isEqual = false;
							}
						}
					} else if (defineMorphShape.fillStyles != null || this.fillStyles != null) {
						isEqual = false;
					}
					
					if (!isEqual) {
						return (false);
					}
					
					if (defineMorphShape.lineStyles != null && this.lineStyles != null &&
						defineMorphShape.lineStyles.length == this.lineStyles.length) {
						for (i=0; i < this.lineStyles.length; i++) {
							if (!this.lineStyles[i].equals(defineMorphShape.lineStyles[i])) {
								isEqual = false;
							}
						}
					} else if (defineMorphShape.lineStyles != null || this.lineStyles != null) {
						isEqual = false;
					}
					
					if (!isEqual) {
						return (false);
					}
					
					
					if (this.code == stagDefineMorphShape2)
					{
						isEqual = defineMorphShape.startEdgeBounds.equals( this.startEdgeBounds) &&
							defineMorphShape.endEdgeBounds.equals( this.endEdgeBounds) &&
							defineMorphShape.usesNonScalingStrokes == this.usesNonScalingStrokes &&
							defineMorphShape.usesScalingStrokes == this.usesScalingStrokes;
					}
				}
			}
			
			return isEqual;
		}
	}

}