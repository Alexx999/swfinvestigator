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
	import decompiler.tamarin.abcdump.Tag;

	/**
	 * This class extends ShapeRecord by adding support for x and y move
	 * deltas, fill styles and line styles.
	 *
	 * @author Clement Wong
	 */
	public class StyleChangeRecord extends ShapeRecord
	{
		public var stateNewStyles:Boolean;
		public var stateLineStyle:Boolean;
		public var stateFillStyle1:Boolean;
		public var stateFillStyle0:Boolean;
		public var stateMoveTo:Boolean;
		
		public var moveDeltaX:int;
		public var moveDeltaY:int;
		
		public var fillstyle0:int;
		/**
		 * This is an index into the fillstyles array starting with 1.
		 */
		public var fillstyle1:int;
		public var linestyle:int;
		
		public var fillstyles:Vector.<FillStyle>;
		public var linestyles:Vector.<LineStyle>;
		
		//The original constructor was overloaded multiple times
		//The logic is a bit complex to adjust for that fact
		public function StyleChangeRecord(moveDeltaX:int = -1, moveDeltaY:int = -1, linestyle:int = -1, fillstyle0:int = -1, fillstyle1:int = -1)
		{
			//Constructor was called with no parameters
			if (moveDeltaX == -1 && moveDeltaY == -1 && linestyle == -1 && fillstyle0 == -1 && fillstyle1 == -1) {
				return;
			}
			
			//Constructor was probably called with just two parameters
			if (linestyle == -1 && fillstyle0 == -1 && fillstyle1 == -1) {
				if (moveDeltaX != 0 || moveDeltaY != 0)
					setMove(moveDeltaX, moveDeltaY);
				return;
			}
			
			//This is where it gets tricky because the three parameter constructors have different meanings for the three parameters
			if (fillstyle0 == -1 && fillstyle1 == -1) {
				if (moveDeltaX > 0) {
					setLinestyle(moveDeltaX);
				}
				
				if (moveDeltaY > 0) {
					setFillStyle0(moveDeltaY);
				}
				
				if (linestyle > 0) {
					setFillStyle1(linestyle);
				}
				
				return;
			}
			
			//Otherwise it was probably the five variable constructor
			if (linestyle > 0)
				setLinestyle(linestyle);
			
			if (fillstyle0 > 0)
				setFillStyle0(fillstyle0);
			
			if (fillstyle1 > 0)
				setFillStyle1(fillstyle1);
			
			if (moveDeltaX != 0 || moveDeltaY != 0)
				setMove(moveDeltaX, moveDeltaY);
		}
		
		public function toString():String
		{
			var retVal:String = "Style: newStyle=" + stateNewStyles + " lineStyle=" + stateLineStyle + " fillStyle=" + stateFillStyle1 + 
				" fileStyle0=" + stateFillStyle0 + " moveTo=" + stateMoveTo;
			
			if (stateMoveTo)
			{
				retVal += " x=" + moveDeltaX + " y=" + moveDeltaY;
			}
			
			return retVal;
		}
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if ( super.equals(object) && (object is StyleChangeRecord) )
			{
				var styleChangeRecord:StyleChangeRecord = object as StyleChangeRecord;
				
				if ( (styleChangeRecord.stateNewStyles == this.stateNewStyles) &&
					(styleChangeRecord.stateLineStyle == this.stateLineStyle) &&
					(styleChangeRecord.stateFillStyle1 == this.stateFillStyle1) &&
					(styleChangeRecord.stateFillStyle0 == this.stateFillStyle0) &&
					(styleChangeRecord.stateMoveTo == this.stateMoveTo) &&
					(styleChangeRecord.moveDeltaX == this.moveDeltaX) &&
					(styleChangeRecord.moveDeltaY == this.moveDeltaY) &&
					(styleChangeRecord.fillstyle0 == this.fillstyle0) &&
					(styleChangeRecord.fillstyle1 == this.fillstyle1) &&
					(styleChangeRecord.linestyle == this.linestyle)) {
					isEqual = true;
				} else {
					return (false);
					
				}
				
				var i:int = 0;
				
				if (styleChangeRecord.fillstyles != null && this.fillstyles != null &&
				    styleChangeRecord.fillstyles.length == this.fillstyles.length) {
					for (i = 0; i < styleChangeRecord.fillstyles.length; i++) {
						if (!styleChangeRecord.fillstyles[i].equals(this.fillstyles[i]) )
						{
							return (false);
						}
					}
					
				} else {
					if (styleChangeRecord.fillstyles == null && this.fillstyles == null) {
						isEqual = true;
					} else {
						return (false);
					}
				}
				
				if (styleChangeRecord.linestyles == null && this.linestyles == null) {
					return (true);
				}
				
				if (styleChangeRecord.linestyles != null && this.linestyles != null &&
					styleChangeRecord.linestyles.length == this.linestyles.length) {
					for (i=0; i < styleChangeRecord.linestyles.length; i++) {
						if (!styleChangeRecord.linestyles[i].equals(this.linestyles[i])) {
							return (false);
						}
					}
				} else {
					return false;
				}
				
				isEqual = true;
			}
			
			return isEqual;
		}
		
		public function setMove(x:int, y:int):void
		{
			stateMoveTo = true;
			moveDeltaX = x;
			moveDeltaY = y;
		}
		
		public override function getReferenceList( list:Vector.<Tag> ):void
		{
			if (fillstyles != null)
			{
				//Iterator<FillStyle> it = fillstyles.iterator();
				//while (it.hasNext())
				for (var i:int =0; i < fillstyles.length; i++)
				{
					var style:FillStyle = fillstyles[i];
					if (style.hasBitmapId() && style.bitmap != null)
						list.push( style.bitmap );
				}
			}
			
		}
		
		public function nMoveBits():int
		{
			//return SwfEncoder.minBits(SwfEncoder.maxNum(moveDeltaX, moveDeltaY, 0, 0), 1);			return SwfEncoder.minBits(SwfEncoder.maxNum(moveDeltaX, moveDeltaY, 0, 0), 1);
			return minBits(maxNum(moveDeltaX, moveDeltaY, 0, 0), 1);
		}
		
		//Copied from SwfEncoder
		private function minBits(number:int, bits:int):int
		{
			var val:int = 1;
			for (var x:int = 1; val <= number && !(bits > 32); x <<= 1) 
			{
				val = val | x;
				bits++;
			}
			
			if (bits > 32)
			{
				//assert false : ("minBits " + bits + " must not exceed 32");
			}
			return bits;
		}
		
		//copied from SWFEncoder
		private function maxNum(a:int, b:int, c:int, d:int):int
		{
			//take the absolute values of the given numbers
			a = Math.abs(a);
			b = Math.abs(b);
			c = Math.abs(c);
			d = Math.abs(d);
			
			//compare the numbers and return the unsigned value of the one with the greatest magnitude
			return a > b
				? (a > c
					? (a > d ? a : d)
					: (c > d ? c : d))
				: (b > c
					? (b > d ? b : d)
					: (c > d ? c : d));
		}

		
		public function setFillStyle1(index:int):void
		{
			stateFillStyle1 = true;
			fillstyle1 = index;
		}
		
		public function setFillStyle0(index:int):void
		{
			stateFillStyle0 = true;
			fillstyle0 = index;
		}
		
		public function setLinestyle(index:int):void
		{
			stateLineStyle = true;
			linestyle = index;
		}
		
		public override function addToDelta(x:int, y:int):void
		{
			moveDeltaX += x;
			moveDeltaY += y;
		}
	}

}