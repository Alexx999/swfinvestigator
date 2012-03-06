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
	 * This class extends EdgeRecord by adding support for curve data.
	 *
	 * @author Clement Wong
	 */
	public class CurvedEdgeRecord extends EdgeRecord
	{
		public var controlDeltaX:int;
		public var controlDeltaY:int;
		public var anchorDeltaX:int;
		public var anchorDeltaY:int;
		
		public override function addToDelta(xTwips:int, yTwips:int):void
		{
			anchorDeltaX += xTwips;
			anchorDeltaY += yTwips;
		}
		
		public function toString():String
		{
			return "Curve: cx=" + controlDeltaX + " cy=" + controlDeltaY + " dx=" + anchorDeltaX + " dy=" + anchorDeltaY;
		}
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is CurvedEdgeRecord))
			{
				var curvedEdgeRecord:CurvedEdgeRecord = object as CurvedEdgeRecord;
				
				if ( (curvedEdgeRecord.controlDeltaX == this.controlDeltaX) &&
					(curvedEdgeRecord.controlDeltaY == this.controlDeltaY) &&
					(curvedEdgeRecord.anchorDeltaX == this.anchorDeltaX) &&
					(curvedEdgeRecord.anchorDeltaY == this.anchorDeltaY) )
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
	}

}