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

package decompiler.swfdump
{
	/**
	 * Represents the collection of definitions in a SWF.
	 */
	import decompiler.swfdump.SWFFormatError;
	import decompiler.swfdump.tags.DefineTag;
	import decompiler.swfdump.tags.DefineFont;
	import decompiler.tamarin.abcdump.Tag;
	
	import flash.utils.Dictionary;
	
	public class SWFDictionary
	{
		private static var INVALID_TAG:DefineTag = new DefineTag(TagValues.stagEnd);// { public void visit(TagHandler t) {} };
		//Map<Integer, DefineTag> ids: = new HashMap<Integer, DefineTag>();
		private var ids:Array = new Array();
		//Map<DefineTag, Integer> tags = new HashMap<DefineTag, Integer>();
		private var tags:Dictionary = new Dictionary();
		//Map<String, DefineTag> names = new HashMap<String, DefineTag>();
		private var names:Object = new Object();
		//Map<String, DefineFont> fonts = new HashMap<String, DefineFont>();
		private var fonts:Object = new Object();
		private var nextId:int = 1;
		
		//Added by SWF Investigator
		private var ids2Names:Array = new Array();
		
		public function containsId(id:int):Boolean
		{
			//return ids.containsKey(new Integer(id));
			if (ids[id] != null) {
				return true;
			}
			return false;
		}
		
		public function containsTag(tag:DefineTag):Boolean
		{
			//return tags.containsKeyTag(tag);
			if (tags[tag] != null) {
				return (true);
			}
			return (false);
		}
		
		public function getId(tag:DefineTag):int
		{
			if (tag == null || tag == INVALID_TAG)
			{
				return -1;//throw new NullPointerException("no ids for null tags");
			}
			else
			{
				// when we're encoding, we should definitely find the tag here.
				//var idobj:* = tags.get(tag);
				var idobj:int = -1;
				
				//if (idobj == null)
				if (tags[tag] == null)
				{
					// When we're decoding, we don't fill in the tags map, and so we'll have
					// to search for the tag to see what it had when we read it in.
					
					//Iterator iterator = ids.entrySet().iterator();
					//while (iterator.hasNext())
					for(var entry:* in ids)
					{
						//Entry entry = (Entry) iterator.next();
						
						// [ets 1/14/04] we use an exact comparison here instead of equals() because this point
						// should only be reached during *decoding*, by tools that want to report the id
						// that is only stored in the ids map.  Since each DefineTag from a single swf will
						// be a unique object, this should be safe.  During encoding, we will find ID's stored
						// in the tags map, and the ids map should be empty.  if we use equals(), it is possible
						// for tools to report the wrong ID, because the defineTags may not be fully decoded yet,
						// for example the ExportAssets may not have been reached, so the tag might not have its
						// name yet, and therefore compare equal to another unique but yet-unnamed tag.
						
						//if (entry.getValue() == tag)
						if (ids[entry] == tag)
						{
							//idobj = entry.getKey();
							idobj = entry;
							break;
						}
					}//end for
				}//end if tags
				
				if (idobj == -1)
				{
					//assert false : ("encoding error, " + tag.name + " not in dictionary");
				}
				
				//return ((Integer) idobj).intValue();
				return (idobj);
			}//end else
		}
		
		/**
		 * This is the method used during encoding.
		 */
		/**
		public function add(tag:DefineTag):int
		{
			//assert (tag != null);
			//Integer obj = tags.get(tag);
			if (tags[tag]!=null)
			{
				//throw new IllegalArgumentException("symbol " +tag+ " redefined");
				//return obj.intValue();
				return (tags[tag]);
			}
			else
			{
				//Integer key = new Integer(nextId++);
				var id:int = nextId++;
				//tags.put(tag, key);
				tags[tag] = id;
				//ids.put(key, tag);
				ids[id] = tag;
				//return key.intValue();
				return (id);
			}
		}*/
		
		/**
		 * This is method used during decoding.
		 *
		 * @param id
		 * @param s
		 * @throws IllegalArgumentException if the dictionary already has that id
		 */
		public function add(id:int, s:DefineTag):void
		//throws IllegalArgumentException
		{
			//Integer key = new Integer(id);
			//Tag t = ids.get(key);
			var t:Tag = ids[id];
			if (t == null)
			{
				//ids.put(key, s);
				ids[id] = s;
				// This DefineTag is potentially very generic, for example
				// it's name is most likely null, so don't bother adding
				// it to the tags Map.
			}
			else
			{
				/**
				 * Due to non-linear processing, Si may call this function multiple times. Ignore issue.
				if (t.equals(s))
					//throw new IllegalArgumentException("symbol " + id + " redefined by identical tag");
					throw new SWFFormatError("symbol " + id + " redefined by identical tag");
				else
					//throw new IllegalArgumentException("symbol " + id + " redefined by different tag");
					throw new SWFFormatError("symbol " + id + " redefined by different tag");
				*/
				//Si - Update for the new tag
				//ids[id] = s;

			}
		}
		
		public function addName(s:DefineTag, name:String):void
		{
			//names.put(name, s);
			names[name] = s;
		}
		
		/**
		 * Added by SWF Investigator
		 */
		public function addIdName(id:uint, name:String):void {
			ids2Names[id] = name;
		}
		
		/**
		 * Added by SWF Investigator
		 */
		public function getName(id:uint):String {
			return (ids2Names[id]);
		}
		
		private static function makeFontKey(name:String, bold:Boolean, italic:Boolean ):String
		{
			return name + (bold? "_bold_" : "_normal_") + (italic? "_italic" : "_regular");
		}
		
		public function addFontFace(defineFont:DefineFont):void
		{
			//fonts.put( makeFontKey(defineFont.getFontName(), defineFont.isBold(), defineFont.isItalic() ), defineFont );
			fonts[makeFontKey(defineFont.getFontName(), defineFont.isBold(), defineFont.isItalic() )] = defineFont;
		}
		
		public function getFontFace(name:String, bold:Boolean, italic:Boolean):DefineFont
		{
			//return fonts.get( makeFontKey( name, bold, italic ) );
			return fonts[makeFontKey( name, bold, italic )];
		}
		
		public function contains(name:String):Boolean
		{
			//return names.containsKey(name);
			if (names[name] != null) {
				return true;
			}
			return false;
		}
		
		public function getTag(name:String):DefineTag
		{
			//return names.get(name);
			return names[name];
		}
		
		/**
		 * @throws IllegalArgumentException if the id is not defined
		 * @param idref
		 * @return
		 */
		public function getTagByID(idref:int):DefineTag
		//throws IllegalArgumentException
		{
			//Integer key = new Integer(idref);
			//DefineTag t = ids.get(key);
			var t:DefineTag = ids[idref];
			/**
			if (t == null)
			{
				// [tpr 7/6/04] work around authoring tool bug of bogus 65535 ids
				if(idref != 65535)
					throw new SWFFormatError("symbol " + idref + " not defined");
				else
					return INVALID_TAG;
			}
			 */
			return t;
		}
		
		// method added to support Flash Authoring - jkamerer 2007.07.30
		public function setNextId(nId:int):void
		{
			this.nextId = nId;
		}
		
		// method added to support Flash Authoring - jkamerer 2007.07.30
		public function getNextId():int
		{
			return nextId;
		}
	}
}