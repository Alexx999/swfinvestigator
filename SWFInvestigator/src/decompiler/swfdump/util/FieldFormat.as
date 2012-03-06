package decompiler.swfdump.util
{
	public class FieldFormat
	{
		public static const ALIGN_UNKNOWN:int	= 0;
		public static const ALIGN_LEFT:int		= 1;
		public static const ALIGN_RIGHT:int		= 2;
		public static const ALIGN_CENTER:int	= 3;
		
	
		// Right justifies a long value into a field optionally zero filling the opening. 
		public static function formatLongToHex(sb:String, v:Number, length:int, leadingZeros:Boolean = true):String
		{
			return format(sb, v.toString(16), length, ALIGN_RIGHT, ((leadingZeros) ? '0' : ' '), ' ');
		}
		
		// Right justifies a long value into a fixed length field
		public static function formatLong(sb:String, v:Number, length:int, leadingZeros:Boolean = false):String	
		{ 
			return format(sb, v.toString(), length, ((leadingZeros) ? ALIGN_RIGHT : ALIGN_LEFT), ((leadingZeros) ? '0' : ' '), ' '); 
		}
		
		// basis for all formats 
		public static function format(sb:String, chars:String, length:int, alignment:int, preFieldCharacter:String, postFieldCharacter:String):String
		{
			// find the length of our string 
			var charsCount:int = chars.length;
			
			// position within the field
			var startAt:int = 0;
			if (alignment == ALIGN_RIGHT)
				startAt = length - charsCount;
			else if (alignment == ALIGN_CENTER)
				startAt = (length - charsCount)/2;
			
			// force to right it off edge
			if (startAt < 0)
				startAt = 0;
			
			// truncate it
			if ((startAt + charsCount) > length)
				charsCount = length-startAt;
			
			// now add the pre-field if any
			var i:int;
			for(i=0; i<startAt; i++)
				sb += preFieldCharacter;
			
			// the content
			sb += chars.substring(0, charsCount);
			
			// post field if any
			for(i=startAt+charsCount; i<length; i++)
				sb += postFieldCharacter;
			
			return (sb);
		}
		
	}
}