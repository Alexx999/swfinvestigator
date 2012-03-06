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
	import decompiler.tamarin.abcdump.Tag;
	
	public class DefineTag extends Tag
	{
		
		public function DefineTag(code:int)
		{
			super(code);
		}
		
		public var name:String;
		private var id:int;
		public static const PRIME:int  = 1000003;
		
		public function getID():int {
			return (id);
		}
		
		public function setID(sID:int):void {
			this.id = sID;
		}
		
		public function toString():String {
			//SWF Investigator - there is no super.toString();
			//return name != null ? name : super.toString();
			return name != null ? name : "Unknown";
		}
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is DefineTag))
			{
				var defineTag:DefineTag = object as DefineTag;
				
				if ( objectEquals(defineTag.name, this.name) )
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
		 
		public override function hashCode():int
		{
			var hashCode:int = super.hashCode();
			
			if (name != null)
			{
				hashCode ^= strHashCode(name)<<1;
			}
			
			return hashCode;
		}
		
		//Approximation of Java String.hashCode
		private function strHashCode(str:String):int {
			var sum:int;
			var len:int = str.length;
			for (var i:int = 0; i < len; i++) {
				sum += str.charCodeAt(i) * Math.pow(31, len-i-1);	
			}
			return (sum);
		}
	}
}