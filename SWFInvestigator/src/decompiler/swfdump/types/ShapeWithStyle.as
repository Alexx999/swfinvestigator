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
	import decompiler.tamarin.abcdump.Tag;
	
	/**
	 * A value object for a shape with style data.
	 *
	 * @author Clement Wong
	 */
	public class ShapeWithStyle extends Shape
	{
		//These were ArrayLists
		public var fillstyles:Vector.<FillStyle>;
		public var linestyles:Vector.<LineStyle>;
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if ( super.equals(object) && (object is ShapeWithStyle) )
			{
				var shapeWithStyle:ShapeWithStyle = object as ShapeWithStyle;
				
				if (shapeWithStyle.fillstyles == null && this.fillstyles == null &&
					shapeWithStyle.linestyles == null && this.linestyles == null) {
					return (true);
				}
				
				var i:int = 0;
				isEqual = true;
				
				if (shapeWithStyle.fillstyles != null && this.fillstyles != null &&
					shapeWithStyle.fillstyles.length == this.fillstyles.length) {
					for (i = 0; i < shapeWithStyle.fillstyles.length; i++) {
						if (!(shapeWithStyle.fillstyles[i].equals(this.fillstyles[i]))) {
							return (false);
						} 
					}
				} else {
					return (false);
				}
				
				if (shapeWithStyle.linestyles != null && this.linestyles != null &&
					shapeWithStyle.linestyles.length == this.linestyles.length) {
					for (i = 0; i < shapeWithStyle.linestyles.length; i++) {
						if (!(shapeWithStyle.linestyles[i].equals(this.linestyles[i]))) {
							return (false);
						} 
					}
				} else {
					return (false);
				}
			}
			
			return isEqual;
		}
		
		//refs was List<Tag>
		public override function getReferenceList( refs:Vector.<Tag> ):void
		{
			super.getReferenceList(refs);
			
			if (fillstyles != null)
			{
				//Iterator it = fillstyles.iterator();
				//while (it.hasNext())
				for (var i:int = 0; i < fillstyles.length; i++)
				{
					//FillStyle style = (FillStyle) it.next();
					var style:FillStyle = fillstyles[i];
					
					if (style.hasBitmapId() && style.bitmap != null)
					{
						refs.push( style.bitmap );
					}
				}
			}
		}
	}
}