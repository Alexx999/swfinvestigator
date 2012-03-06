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

package decompiler.swfdump.debug
{
	public class DebugModule
	{
		public var id:Number;
		public var bitmap:int;
		public var name:String;
		public var text:String;
		
		/** offsets[n] = offset of line n */
		public var offsets:Vector.<int>;
		
		/** index[n] = index of end of line n in text */
		public var index:Vector.<int>;
		
		/* is this module potentially corrupt; see 81918 */
		public var corrupt:Boolean = false;
		
		public function addOffset(lr:LineRecord, offset:int):Boolean
		{
			var worked:Boolean = true;
			if (lr.lineno < offsets.length)
			{
				offsets[lr.lineno] = offset;
			}
			else
			{
				// We have a condition 81918/78188 whereby Matador can produce a swd
				// where module ids were not unique, resulting in collision of offset records.
				// The best we can do is to mark the entire module as bad
				corrupt = true;
				worked = false;
			}
			return worked;
		}
		
		public function equals(obj:*):Boolean
		{
			if (obj == this) return true;
			if (!(obj is DebugModule)) return false;
			var other:DebugModule = obj as DebugModule;
			return this.bitmap == other.bitmap &&
				this.name == other.name &&
				this.text == other.text;
		}
		
		public function hashCode():int
		{	var nameHash:int = 0;
			var textHash:int = 0;
			var i:int;
			
			for (i=0; i< this.name.length; i++) {
				nameHash += uint(name.charAt(i)) * (31^(name.length -1));
			}
			
			for (i=0; i< this.text.length; i++) {
				textHash += uint(text.charAt(i)) * (31^(text.length -1));
			}
			
			return (nameHash ^ textHash ^ this.bitmap);
		}
		
		public function setText(text:String):void
		{
			this.text = text;
			
			var count:int = 1;
			
			var length:int = text.length;
			var last:int;
			var i:int;
			for (i=eolIndexOf(text); i != -1; i = eolIndexOf(text,last))
			{
				last = i+1;
				count++;
			}
			// allways make room for the last line whether it is empty or not.
			count++;
			
			this.index = new Vector.<int>(count);
			this.index[0] = 0;
			count = 1;
			for (i=eolIndexOf(text); i != -1; i = eolIndexOf(text,last))
			{
				index[count++] = last = i+1;
			}
			index[count++] = length;
			
			this.offsets = new Vector.<int>(count);
		}
		
		public function getLineNumber(offset:int):int
		{
			var closestMatch:int = 0;
			for(var i:int=0; i < offsets.length; i++)
			{
				var delta:int = offset - offsets[i];
				if(delta >= 0 && delta < (offset - offsets[closestMatch]))
					closestMatch = i;
			}
			return closestMatch;
		}
				
		public static function eolIndexOf(text:String, i:int = 0):int
		{
			var at:int = -1;
			
			// scan starting at location i
			var size:int = text.length;
			
			while(i < size && at < 0)
			{
				var c:String = text.charAt(i);
				
				// newline?
				if (c == '\n') {
					// carriage return?
					at = i;					
				} else if (c == '\r') {
					at = i;
					
					// might be cr/newline...chew pacman chew...
					if (i+1 < size && text.charAt(i+1) == '\n') {
						at++;
					}
				} else if (c == '\f') {
					// some crack may use form feeds?
					at = i;
				}
				
				i++;
			}
			return at;
		}
		
		public static function main(args:Array):void
		{
			new DebugModule().setText("hello");
		}
	}
}