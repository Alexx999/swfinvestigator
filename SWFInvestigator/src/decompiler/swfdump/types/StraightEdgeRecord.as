////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package decompiler.swfdump.types
{
	/**
	 * This class extends EdgeRecord by adding support for an x and y
	 * delta.
	 *
	 * @author Clement Wong
	 */
	public class StraightEdgeRecord extends EdgeRecord
	{
		public var deltaX:int = 0;
		public var deltaY:int = 0;
		
		public function setX(x:int):StraightEdgeRecord
		{
			deltaX = x;
			return this;
		}
		
		public function setY(y:int):StraightEdgeRecord
		{
			deltaY = y;
			return this;
		}
		
		public function StraightEdgeRecord(deltaX:int = 0, deltaY:int = 0)
		{
			this.deltaX = deltaX;
			this.deltaY = deltaY;
		}
		
		public override function addToDelta(xTwips:int, yTwips:int):void
		{
			deltaX += xTwips;
			deltaY += yTwips;
		}
		public function toString():String
		{
			return "Line: x=" + deltaX + " y=" + deltaY;
		}
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (object is StraightEdgeRecord)
			{
				var straightEdgeRecord:StraightEdgeRecord = object as StraightEdgeRecord;
				
				if ( (straightEdgeRecord.deltaX == this.deltaX) &&
					(straightEdgeRecord.deltaY == this.deltaY) )
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
	}

}