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

package decompiler.swfdump.tags
{
	import decompiler.tamarin.abcdump.Rect;
	import decompiler.tamarin.abcdump.Tag;
	import decompiler.swfdump.TagHandler;
	
	/**
	 * This class represents a DefineEditText SWF tag.
	 *
	 * @author Clement Wong
	 */
	public class DefineEditText extends DefineTag
	{
		public function DefineEditText()
		{
			super(stagDefineEditText);
		}
		
		public override function visit(h:TagHandler):void
		{
			h.defineEditText(this);
		}
		
		/**
		public Iterator<Tag> getReferences()
		{
			LinkedList<Tag> refs = new LinkedList<Tag>();
			if (font != null)
				refs.add(font);
			
			return refs.iterator();
		}
		 */
		
		public var bounds:Rect;
		public var hasText:Boolean;
		public var wordWrap:Boolean;
		public var multiline:Boolean;
		public var password:Boolean;
		public var readOnly:Boolean;
		public var hasTextColor:Boolean;
		public var hasMaxLength:Boolean;
		public var hasFont:Boolean;
		public var hasFontClass:Boolean;
		public var autoSize:Boolean;
		public var hasLayout:Boolean;
		public var noSelect:Boolean;
		public var border:Boolean;
		public var wasStatic:Boolean;
		public var html:Boolean;
		public var useOutlines:Boolean;
		
		public var font:DefineFont;
		public var fontClass:String;
		public var height:int;
		/** color as int: 0xAARRGGBB */
		public var color:int;
		public var maxLength:int;
		public var align:int;
		public var leftMargin:int;
		public var rightMargin:int;
		public var ident:int;
		public var leading:int;
		public var varName:String;
		public var initialText:String;
		public var csmTextSettings:CSMTextSettings;
		
		public override function equals(object:*):Boolean
		{
			var isEqual:Boolean = false;
			
			if (super.equals(object) && (object is DefineEditText))
			{
				var defineEditText:DefineEditText = object as DefineEditText;
				
				if ((defineEditText.hasText == this.hasText) &&
					(defineEditText.wordWrap == this.wordWrap) &&
					(defineEditText.multiline == this.multiline) &&
					(defineEditText.password == this.password) &&
					(defineEditText.readOnly == this.readOnly) &&
					(defineEditText.hasTextColor == this.hasTextColor) &&
					(defineEditText.hasMaxLength == this.hasMaxLength) &&
					(defineEditText.hasFont == this.hasFont) &&
					(defineEditText.hasFontClass == this.hasFontClass) &&
					(defineEditText.autoSize == this.autoSize) &&
					(defineEditText.hasLayout == this.hasLayout) &&
					(defineEditText.noSelect == this.noSelect) &&
					(defineEditText.border == this.border) &&
					(defineEditText.wasStatic == this.wasStatic) &&
					(defineEditText.html == this.html) &&
					(defineEditText.useOutlines == this.useOutlines) &&
					(defineEditText.font.equals(this.font)) &&
					(defineEditText.height == this.height) &&
					(defineEditText.color == this.color) &&
					(defineEditText.maxLength == this.maxLength) &&
					(defineEditText.align == this.align) &&
					(defineEditText.leftMargin == this.leftMargin) &&
					(defineEditText.rightMargin == this.rightMargin) &&
					(defineEditText.ident == this.ident) &&
					(defineEditText.leading == this.leading) &&
					(defineEditText.fontClass == this.fontClass) &&
					(defineEditText.varName == this.varName) &&
					(defineEditText.initialText == this.initialText) &&
					(defineEditText.bounds.equals(this.bounds) ))
				{
					isEqual = true;
				}
			}
			
			return isEqual;
		}
	}

}