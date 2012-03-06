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
	//NEEDED FOR SWF DISASSEMBLY
	import decompiler.swfdump.tags.DefineTag;
	
	public class ButtonRecord
	{
		public var hitTest:Boolean;
		public var down:Boolean;
		public var over:Boolean;
		public var up:Boolean;
		
		public var characterRef:DefineTag;
		public var placeDepth:int;
		public var placeMatrix:Matrix;
		
		/** only valid if this record is in a DefineButton2 */
		public var colorTransform:CXFormWithAlpha;
		public var filters:Vector.<Filter>;
		public var blendMode:int = -1; // -1 ==> not set
		
		public function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (object is ButtonRecord)
			{
				var buttonRecord:ButtonRecord = object as ButtonRecord;
				
				if ( (buttonRecord.hitTest == this.hitTest) &&
					(buttonRecord.down == this.down) &&
					(buttonRecord.over == this.over) &&
					(buttonRecord.up == this.up) &&
					(buttonRecord.blendMode == this.blendMode) &&
					compareFilters(buttonRecord.filters, this.filters) &&
					( ( (buttonRecord.characterRef == null) && (this.characterRef == null) ) ||
						( (buttonRecord.characterRef != null) && (this.characterRef != null) &&
							buttonRecord.characterRef.equals(this.characterRef) ) ) &&
					(buttonRecord.placeDepth == this.placeDepth) &&
					( ( (buttonRecord.placeMatrix == null) && (this.placeMatrix == null) ) ||
						( (buttonRecord.placeMatrix != null) && (this.placeMatrix != null) &&
							buttonRecord.placeMatrix.equals(this.placeMatrix) ) ) &&
					( ( (buttonRecord.colorTransform == null) && (this.colorTransform == null) ) ||
						( (buttonRecord.colorTransform != null) && (this.colorTransform != null) &&
							buttonRecord.colorTransform.equals(this.colorTransform) ) ) )
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
		

		private function compareFilters(filterList1:Vector.<Filter>, filterList2:Vector.<Filter>):Boolean
		{
			if (filterList1 == filterList2) return true;
			if (filterList1 == null || filterList2 == null) return false;
			if (filterList1.length != filterList2.length) return false;
			for (var i:int = 0, size:int = filterList1.length; i < size; i++)
			{
				// TODO: should really be comparing content...
				if (filterList1[i] != filterList2[i])
				{
					return false;
				}
			}
			return true;
		}

		
		public function getFlags():String
		{
			var b:String = new String();
			if (blendMode != -1) b += "hasBlendMode,";
			if (filters != null) b += "hasFilterList,";
			if (hitTest) b += "hitTest,";
			if (down) b += "down,";
			if (over) b += "over,";
			if (up) b += "up,";
			if (b.length > 0)
				b = b.substr(0, b.length -1);

			return b;
		}
	}
}