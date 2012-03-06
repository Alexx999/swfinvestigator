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
	public class Matrix
	{
		public var hasScale:Boolean;
		public var scaleX:int;
		public var scaleY:int;
		public var hasRotate:Boolean;
		public var rotateSkew0:int;
		public var rotateSkew1:int;
		public var translateX:int;
		public var translateY:int;
		
		
		public function Matrix(translateX:int = 0, translateY:int = 0, scaleX:Number = Number.NaN, scaleY:Number = Number.NaN)
		{
			this.translateX = translateX;
			this.translateY = translateY;
			
			if (! isNaN(scaleX) && ! isNaN(scaleY)) {
				setScale(scaleX, scaleY);
			}
		}
		
		public function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (object is Matrix)
			{
				var matrix:Matrix = object as Matrix;
				
				if ( (matrix.hasScale == this.hasScale) &&
					(matrix.scaleX == this.scaleX) &&
					(matrix.scaleY == this.scaleY) &&
					(matrix.hasRotate == this.hasRotate) &&
					(matrix.rotateSkew0 == this.rotateSkew0) &&
					(matrix.rotateSkew1 == this.rotateSkew1) &&
					(matrix.translateX == this.translateX) &&
					(matrix.translateY == this.translateY) )
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
		
		public function toString():String
		{
			var b:String = new String();
			
			if (hasScale)
			{
				b += "s";
				b += Number(scaleX/65536.0).toString() + "," + Number(scaleY/65536.0).toString();
				b += " ";
			}
			
			if (hasRotate)
			{
				b += "r";
				b += Number(rotateSkew0/65536.0).toString() + "," + Number(rotateSkew1/65536.0).toString();
				b += " ";
			}
			
			b += "t";
			b += translateX + "," + translateY;
			
			return b.toString();
		}
		
		/**
		 * SWF Investigator procrastination
		public function nTranslateBits():int
		{
			return SwfEncoder.minBits(SwfEncoder.maxNum(translateX, translateY, 0, 0), 1);
		}
		
		public function nRotateBits():int
		{
			return SwfEncoder.minBits(SwfEncoder.maxNum(rotateSkew0, rotateSkew1,0,0), 1);
		}
		
		public function nScaleBits():int
		{
			return SwfEncoder.minBits(SwfEncoder.maxNum(scaleX, scaleY,0,0), 1);
		}
		 */
		
		public function setRotate(r0:Number, r1:Number):void
		{
			hasRotate = true;
			rotateSkew0 = int((65536*r0));
			rotateSkew1 = int((65536*r1));
		}
		
		public function setScale(x:Number, y:Number):void
		{
			hasScale = true;
			scaleX = int((65536*x));
			scaleY = int((65536*y));
		}
		/*
		public int xformx(int x, int y)
		{
		return (int)(x*(scaleX/65536.0) + y*(rotateSkew1/65536.0) + translateX);
		}
		public int xformy(int x, int y)
		{
		return (int)(x*(rotateSkew0/65536.0) + y*(scaleY/65536.0) + translateY);
		}
		
		public Rect xformRect(Rect in)
		{
		int xmin = xformx(in.xMin, in.yMin);
		int ymin = xformy(in.xMin, in.yMin);
		int xmax = xformx(in.xMin, in.yMin);
		int ymax = xformy(in.xMin, in.yMin);
		
		Rect out = new Rect();
		out.xMin = xmin < xmax ? xmin : xmax;
		out.yMin = ymin < ymax ? ymin : ymax;
		out.xMax = xmin > xmax ? xmin : xmax;
		out.yMax = ymin > ymax ? ymin : ymax;
		
		return out;
		} */
	}
}