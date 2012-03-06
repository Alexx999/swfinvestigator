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

package decompiler.swfdump.types
{
	import decompiler.swfdump.TagHandler;
	import decompiler.tamarin.abcdump.Tag;
	
	/**
	 * A value object for shape data.
	 *
	 * @author Clement Wong
	 */
	public class Shape
	{
		public var shapeRecords:Vector.<ShapeRecord>;
		
		public function visitDependents(h:TagHandler):void
		{
			//Iterator<ShapeRecord> it = shapeRecords.iterator();
			//while (it.hasNext())
			for (var i:int = 0; i < shapeRecords.length; i++)
			{
				//ShapeRecord rec = it.next();
				//rec.visitDependents(h);
				shapeRecords[i].visitDependents(h);
			}
		}
		
		//refs was List<Tag> refs
		public function getReferenceList( refs:Vector.<Tag> ):void
		{
			//Iterator<ShapeRecord> it = shapeRecords.iterator();
			
			//while (it.hasNext())
			for (var i:int = 0; i < shapeRecords.length; i++)
			{
				//ShapeRecord rec = it.next();
				//rec.getReferenceList( refs );
				shapeRecords[i].getReferenceList(refs);
			}
		}
		
		public function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (object is Shape)
			{
				var shape:Shape = object as Shape;
				
				if (shape.shapeRecords == null && this.shapeRecords == null) {
					return (true);
				}
				
				isEqual = true;
				
				if (shape.shapeRecords != null && this.shapeRecords != null &&
					shape.shapeRecords.length == this.shapeRecords.length)
				{
					for (var i:int = 0; i < shapeRecords.length; i++) {
						if (shape.shapeRecords[i] != this.shapeRecords[i]) {
							isEqual = false;
						}
					}
				} else {
					isEqual = false;
				}
			}
			
			return isEqual;
		}
	}

}