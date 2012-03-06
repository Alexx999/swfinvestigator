/* ***** BEGIN LICENSE BLOCK *****
* Version: MPL 1.1/GPL 2.0/LGPL 2.1
*
* The contents of this file are subject to the Mozilla Public License Version
* 1.1 (the "License"); you may not use this file except in compliance with
* the License. You may obtain a copy of the License at
* http://www.mozilla.org/MPL/
*
* Software distributed under the License is distributed on an "AS IS" basis,
* WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
* for the specific language governing rights and limitations under the
* License.
*
* The Original Code is [Open Source Virtual Machine.].
*
* The Initial Developer of the Original Code is
* Adobe System Incorporated.
* Portions created by the Initial Developer are Copyright (C) 2004-2006
* the Initial Developer. All Rights Reserved.
*
* Contributor(s):
*   Adobe AS3 Team
*
* Alternatively, the contents of this file may be used under the terms of
* either the GNU General Public License Version 2 or later (the "GPL"), or
* the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
* in which case the provisions of the GPL or the LGPL are applicable instead
* of those above. If you wish to allow use of your version of this file only
* under the terms of either the GPL or the LGPL, and not to allow others to
* use your version of this file under the terms of the MPL, indicate your
* decision by deleting the provisions above and replace them with the notice
* and other provisions required by the GPL or the LGPL. If you do not delete
* the provisions above, a recipient may use your version of this file under
* the terms of any one of the MPL, the GPL or the LGPL.
*
* ***** END LICENSE BLOCK ***** */

package decompiler
{

	import decompiler.Logging.ILog;
	import decompiler.Logging.StringWriter;
	import decompiler.swfdump.Action;
	import decompiler.swfdump.ActionDecoder;
	import decompiler.swfdump.SWFDictionary;
	import decompiler.swfdump.SWFFormatError;
	import decompiler.swfdump.TagDecoder;
	import decompiler.swfdump.TagValues;
	import decompiler.swfdump.tags.DefineButton;
	import decompiler.swfdump.tags.DoAction;
	import decompiler.swfdump.tags.DoInitAction;
	import decompiler.swfdump.tags.PlaceObject;
	import decompiler.swfdump.tools.Disassembler;
	import decompiler.swfdump.tools.SwfxPrinter;
	import decompiler.swfdump.types.ActionList;
	import decompiler.swfdump.types.ClipActionRecord;
	import decompiler.swfdump.types.ClipActions;
	import decompiler.tamarin.abcdump.Abc;
	import decompiler.tamarin.abcdump.Rect;
	import decompiler.tamarin.abcdump.Tag;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	//import flash.utils.getDefinitionByName;
	
	public class Swf
	{
		include 'tamarin/abcdump/SWF_Constants.as';
		
		private var bitPos:int;
		private var bitBuf:int;
		private var offset:int;
		
		public var data:ByteArray = new ByteArray();
		
		private var act:Disassembler;
		private var aDecoder:ActionDecoder;
		
		//Added by SWF Investigator
		//Basic Info
		public var rect:Rect;
		public var frameRate:uint;
		public var frameCount:uint;
		public var version:uint;
		public var compressed:Boolean;
		public var length:uint;
		
		//File Attributes
		public var useNetwork:Boolean;
		public var hasMetadata:Boolean;
		public var avm2:Boolean = false;
		public var suppressXDomainCaching:Boolean;
		public var useGPU:Boolean;
		public var useDirectBlit:Boolean;
		public var swfRelativeURLs:Boolean;
		public var hasActions:Boolean = false;
		
		//Data structures
		public var abc:Array = [];
		public var tags:Array = [];
		public var classes:Array;
		
		public var log:ILog;
		private var verboseLog:Boolean = false;
		private var dict:SWFDictionary;
		
		public function Swf(swfData:ByteArray, logger:ILog, dumpVerbose:Boolean = false, decoderMode:Boolean = false)
		{
			this.data.clear();
			this.data.writeBytes(swfData);
			this.data.position = 0;
			this.log = logger;
			this.verboseLog = dumpVerbose;
			
			//The TagDecoder will use this class as just a fancy wrapper for reading from a ByteArray
			//Therefore, we shouldn't try to interpret the byteArray as a SWF.
			if (decoderMode) {
				return;
			}
			
			//Begin SWF Investigator changes
			this.data.endian = Endian.LITTLE_ENDIAN;
			this.dict = new SWFDictionary();
			
			var header:String = data.readUTFBytes(3);
			if (header == "CWS") {
				this.compressed = true;
			}
			
			this.version = data.readUnsignedByte();
			this.length = data.readUnsignedInt();

			if (this.compressed) {
				var udata:ByteArray = new ByteArray;
				udata.endian = "littleEndian";
				//data.position = 8;
				data.readBytes(udata,0,data.length-data.position);
				var csize:int = udata.length;
				udata.uncompress();
				this.log.print("decompressed swf "+csize+" -> "+udata.length + "\r");
				udata.position = 0;
				this.data.clear();
				this.data.writeUTFBytes("FWS");
				this.data.writeByte(this.version);
				this.data.writeUnsignedInt(this.length);
				this.data.writeBytes(udata);
				this.data.position = 8;
			}
			//end SWF Investigator changes
			
			decodeRect();
			this.log.print("size "+ this.rect.toString() + "\r");
			
			this.frameRate = (data.readUnsignedByte()<<8|data.readUnsignedByte());
			this.log.print("frame rate " + this.frameRate + "\r");
			
			this.frameCount = data.readUnsignedShort();
			this.log.print("frame count " + this.frameCount + "\r");
			
			decodeTags()            
		}
		
		public function decodeTags():void
		{
			var type:int, h:int, length:int;
			var offset:int;
			var tDecoder:TagDecoder = new TagDecoder(this);
			tDecoder.setDictionary(this.dict);
			var tag:Tag;
			
			while (data.position < data.length)
			{
				//Added by SWF Investigator
				tag = new Tag();
				tag.position = data.position;
				var eat:int = 0;
				
				type = (h = data.readUnsignedShort()) >> 6;
				
				if (((length = h & 0x3F) == 0x3F)) {
					tag.longRecordHeader = true;	
					length = data.readInt();
				}
				
				if (length < 0) {
					throw new SWFFormatError("Negative length: " + length  + " for tag at position: " + data.position);
				}
				
				var o:int = getOffset();
				
				//Added by SWF Investigator
				tag.type = type;
				tag.tName = tagNames[type];
				tag.size = length;

				//var tValues:TagValues = new TagValues();
				if (type == stagDoABC || type == stagDoABC2) {
					this.avm2 = true;
					data.position += tag.size;
				} else {
					try {
						tag.theTag = tDecoder.decodeTag(tag.type, tag.size);
					} catch (e:Error) {
						//Don't care since not all tags are supported.
						//Just skip to the end
						if (tag.longRecordHeader) {
							data.position = tag.position + tag.size + 6;
						} else {
							data.position = tag.position + tag.size + 2;
						}
					}
				}
				
				if (getOffset() - o != length) {
					tag.SIErrorMessage = "offset mismatch after " + tag.tName + ": read " + (getOffset() - o) + ", expected " + length;
					if (getOffset() - o < length)
					{
						eat = length - (getOffset() - o);
						
					}
					
					if (eat > 0) {
						var trash:ByteArray = new ByteArray();
						trash.length = eat;
						read (trash);
					}
				}
				
				if (this.tags[type] == null) {
					this.tags[type] = [];
				}
				this.tags[type].push(tag);
				
				//This is a swag to a certain extent
				if 	(( type == TagValues.stagDoInitAction) || ( type == TagValues.stagDoAction) || ( type == TagValues.stagDefineButton) 
					|| (type == TagValues.stagDefineButton2) || (type == TagValues.stagPlaceObject2) || (type == TagValues.stagPlaceObject3)) {
					this.hasActions = true;
				}
				
				//File Attributes
				if (type == 69) {
					this.useNetwork = tag.theTag.useNetwork;
					this.avm2 = tag.theTag.actionScript3;
					this.hasMetadata = tag.theTag.hasMetadata;
					this.useDirectBlit = tag.theTag.useDirectBlit;
					this.suppressXDomainCaching = tag.theTag.suppressCrossDomainCaching;
					this.useGPU = tag.theTag.useGPU;
					this.swfRelativeURLs = tag.theTag.swfRelativeUrls;
				}
				
				

				this.log.print(tagNames[type]+" "+length+"b "+int(100*length/data.length)+"%" + "\r");

				//data.position += tag.size;				
			}
		}
		
		public function getTagName(i:int):String {
			return tagNames[i];
		}
		
		
		/**
		 * Dumping Action tags
		 * The following functions are dedicated to dumping tags that relate to Actions or Metadata
		 */ 
		
		private function dumpDoABC(bLength:uint, logger:ILog, keep:Boolean = true, infoIdent:String = ""):void {
			var data2:ByteArray = new ByteArray();
			data2.endian = "littleEndian";
			this.data.readBytes(data2,0,bLength);
			data2.position = 0;
			var abcInfo:Abc = new Abc(data2,logger, this.verboseLog, infoIdent);
			if (keep) {
				this.abc[this.abc.length] = abcInfo;
			}
			abcInfo.dump("   ");
			logger.print("\r");
			data2.clear();
		}
		
		public function dumpABC():void {
			var t1:Tag;
			//var data2:ByteArray;
			
			if (this.tags[stagDoABC2] != null && this.tags[stagDoABC2].length > 0) {
				for each (t1 in this.tags[stagDoABC2]) {
						//var pos1:int = t1.position;
						var bLength:uint = t1.size;
						this.data.position = t1.position;
						data.readUnsignedShort(); //consume tag
						data.readInt(); //consume length
						data.readInt();
						this.log.print("\nabc name "+readString() + "\r");
						bLength -= (data.position- t1.position - 6);
						dumpDoABC(bLength, this.log);
				}
			}
			
			if (this.tags[stagDoABC] != null && this.tags[stagDoABC].length > 0) {
				for each (t1 in this.tags[stagDoABC]) {
					this.data.position = t1.position;
					data.readUnsignedShort();//consume tag
					data.readInt();//consume length
					dumpDoABC(t1.size, this.log);
				}
			}
			
			this.data.position = 0;	
		}
		
		
		
		public function dumpAllActions(logger:ILog = null):void {
			if (logger == null) {logger = this.log;}
			
			var actionTags:Array = [TagValues.stagDoAction,
					TagValues.stagDoInitAction,
					TagValues.stagDefineButton,
					TagValues.stagDefineButton2,
					TagValues.stagPlaceObject2,
					TagValues.stagPlaceObject3];
			
			var dis:Disassembler = new Disassembler(logger,null,"  ",true,1);
			var tDecoder:TagDecoder = new TagDecoder(this);
			tDecoder.setDictionary(this.dict);
			
			for each (var i:int in actionTags) {
			  if (this.tags[i] != null && this.tags[i].length > 0) { // && this.tags[34][i] != null) {
				for each (var t1:Tag in this.tags[i]) {
					if (t1 != null) {
						if (t1.longRecordHeader) {
							data.position = t1.position + 6;
						} else {
							data.position = t1.position + 2;
						}
						var t:Tag;

						if (i == TagValues.stagDefineButton2) {
							var db:DefineButton;
							if (t1.theTag != null && t1.theTag is DefineButton) {
								db = t1.theTag;
							} else {
								t = tDecoder.decodeDefineButton2(t1.size);
								db = t as DefineButton;
							}
							logger.print("\r<DefineButton2 id=\"" + db.id + "\">\r");
							for (var j:int = 0; j < db.condActions.length; j++) {
								logger.print("\r on(" + db.condActions[j].toString() + ") {\r");
								var aList:ActionList = db.condActions[j].actionList;
								aList.visitAll(dis);
								logger.print("}\r");
							}
							logger.print("</DefineButton2>\r\r");
						} else if (i == TagValues.stagDoInitAction) {
							logger.print("<DoInitAction>\r");
							if (t1.theTag && t1 is DoInitAction) {
								t1.theTag.actionList.visitAll(dis);
							} else {
								t = tDecoder.decodeDoInitAction(t1.size);
								(t as DoInitAction).actionList.visitAll(dis);
							}
							logger.print("</DoInitAction>\r\r");
						} else if (i == TagValues.stagPlaceObject2) {
							var p2:PlaceObject;
							if (t1.theTag && t1.theTag is PlaceObject) {
								p2 = t1.theTag;
							} else {
								t = tDecoder.decodePlaceObject23(2,t1.size);
								p2 = t as PlaceObject;
							}
							if (p2.hasClipAction()) {
								logger.print("<PlaceObject2 name=\"" + p2.name + "\">\r");
								for each (var c2:ClipActionRecord in p2.clipActions.clipActionRecords) {
									logger.print("\r onClipEvent(" + SwfxPrinter.printClipEventFlags(c2.eventFlags) +
										(c2.hasKeyPress() ? "<" + c2.keyCode + ">" : "") +
										") {\r");
									c2.actionList.visitAll(dis);
									logger.print(" }\r");
								}
								logger.print("</PlaceObject2>\r\r");
							}
						} else if (i == TagValues.stagPlaceObject3) {
							var p3:PlaceObject;
							if (t1.theTag && t1.theTag is PlaceObject) {
								p3 = t1.theTag;
							} else {
								t = tDecoder.decodePlaceObject23(3,t1.size);
								p3 = t as PlaceObject;
							}
							if (p3.hasClipAction()) {
								logger.print("<PlaceObject3 name=\"" + p3.name + "\">\r");
								for each (var c3:ClipActionRecord in p3.clipActions.clipActionRecords) {
									logger.print("\r onClipEvent(" + SwfxPrinter.printClipEventFlags(c3.eventFlags) +
										(c3.hasKeyPress() ? "<" + c3.keyCode + ">" : "") +
										") {\r");
									c3.actionList.visitAll(dis);
									logger.print(" }\r");
								}
								logger.print("</PlaceObject3>\r\r");
							}
						} else if (i == TagValues.stagDefineButton) {
							logger.print("<DefineButton>\r");
							if (t1.theTag && t1.theTag is DefineButton) {
								t1.theTag.condActions[0].actionList.visitAll(dis);
							} else {
								t = tDecoder.decodeDefineButton(t1.size);
								(t as DefineButton).condActions[0].actionList.visitAll(dis);
							}
							logger.print("</DefineButton>\r\r");
						} else if (i == TagValues.stagDoAction) {
							logger.print("<DoAction>\r");
							try {
								if (t1.theTag && t1.theTag is DoAction) {
								   t = t1.theTag;	
								} else {
								   t = tDecoder.decodeDoAction(t1.size);
								}
							} catch (s:SWFFormatError) {
								t = s.t;
								logger.print("Error encountered: " + s.message + "\r\r");
							}
							(t as DoAction).actionList.visitAll(dis);
							logger.print("</DoAction>\r\r");
						}
					} //end if t1 != null
				} //end for each
			  }// end if length > 1
			}//end for each

		}
		
		public function getMetadata():XML
		{
			if ( this.tags[77] )
			{
				var origPos:uint = this.data.position;
				this.data.position = tags[77][0].position;
				var metadata:XML = new XML(this.data.readUTFBytes(tags[77][0].size) );
				this.data.position = origPos;
				return metadata;
			};
			return null;
		}
		
		
		
		/**
		 * Tag Viewer functions
		 * These functions are for the Tag Viewer tab.
		 */
		
		/**
		 * @public
		 * Returns a byteArray of the selected tag's bytes
		 * 
		 * @param tag The tag to retrieve
		 * @return The ByteArray containing the tag's bytes
		 */
		public function getTagData(tag:Tag):ByteArray
		{
			var ba:ByteArray = new ByteArray();
			this.data.position = tag.position;
			this.data.readBytes(ba, 0, tag.size);
			this.data.position = 0;
			ba.position = 0;
			return ba;			
		}
		
		/**
		 * @public
		 * Returns a string representing the indicated tag.
		 * 
		 * @param tag The tag to inspect
		 * @param dumpFile Indicates whether the tag's binary data should be dumped
		 * @param fileName Indicates the fileName where the binary data will be stored
		 * @return A string representing the tag.
		 */
		public function printTag(tag:Tag,dumpFile:Boolean=false,fileName:String=""):String
		{
			var sw:StringWriter = new StringWriter();
			var sPrinter:SwfxPrinter = new SwfxPrinter(sw);
			var tagName:String;
			var fName:String;
			
			sPrinter.setDecoderDictionary(this.dict);
			
			if (tag.type < 92) {
				tagName = tagNames[tag.type];
			} else {
				tagName = "Obfuscated";
			}
						
			try {
				//var classReference:Class = getDefinitionByName("decompiler.swfdump.tags." + tagName) as Class;
				if (tag.longRecordHeader) {
					data.position = tag.position + 6;
				} else {
					data.position = tag.position + 2;
				}
				
				if (tag.type == stagDoABC) {
					sw.print("<DoABC>\r");
					dumpDoABC(tag.size,sw, false, "  ");
					sw.print("</DoABC>\r");
				} else if (tag.type == stagDoABC2) {
					sw.print("<DoABC2>\r");
					var bLength:uint = tag.size;
					data.readInt();
					sw.print("  abc name "+readString() + "\r");
					bLength -= (data.position- tag.position - 6);
					dumpDoABC(bLength, sw, false, "  ");
					sw.print("</DoABC2>\r");
				} else if (tag.type == TagValues.stagEnd) {
					sw.print("<end/>\r");
				} else {
					var params:Array = new Array();
					if (tag.theTag == null) {
						var tDecoder:TagDecoder = new TagDecoder(this);
						tDecoder.setDictionary(this.dict);
						tDecoder.setHandler(sPrinter);
						params[0] = tag.size;
						//var t:* = tDecoder["decode" + tagName].apply(tDecoder,params);
						tag.theTag = tDecoder.decodeTag(tag.type, tag.size);
					}
					if (dumpFile) {
						sPrinter.external = true;
						sPrinter.externalPrefix = fileName;
					}
					
					/**
					if (tag.theTag.SIErrorMessage != null && tag.theTag.SIErrorMessage.length > 0) {
						sPrinter.error(tag.theTag.SIErrorMessage);
					}
					 */
					
					if (tag.type == 74) {
						//capitilization is different for this one tag
						fName = "csmTextSettings";
					} else {
						fName = tagName.charAt(0).toLowerCase() + tagName.substring(1);
					}
					params[0] = tag.theTag;
					sPrinter[fName].apply(sPrinter,params);
				}
			} catch (s:SWFFormatError) {
				if (s.t == null) {
					return ("");
				} else {
					sw.print("Error in parsing: " + s.message + "\r");
					fName = tagName.charAt(0).toLowerCase() + tagName.substring(1);
					params[0] = s.t;
					sPrinter[fName].apply(sPrinter,params);
				}
			} catch (e:Error) {
				//It is expected to fail since I don't have all the tags defined yet.
				return ("");
			}
			
			return (sw.output);
		}
		
		
		/******
		 * SWF Reader section
		 * Functions below are dedicated to getting bytes from the byteArray
		 * 
		 * @return The Pascal style string
		 */
		
		public function readLengthString():String //throws IOException
		{
			var length:int = readUI8();
			//byte[] b = new byte[length];
			var b:ByteArray = new ByteArray();
			b.length = length;
			readFully(b);
			
			if (b.toString().charCodeAt(b.length -1) == 00) {
				return (b.toString().substr(0,length-1));
			}
			
			return (b.toString());
			
			/**
			// [paul] Flash Authoring and the player null terminate the
			// string, so ignore the last byte when constructing the String.
			if (swfVersion >= 6)
			{
				return new String(b, 0, length - 1, "UTF8").intern();
			}
			else
			{
				// use platform encoding
				return new String(b, 0, length - 1).intern();
			}
			 */
		}

		
		public function readString():String
		{
			var s:String = "";
			var c:int;
			
			while (c=data.readUnsignedByte()) {
				s += String.fromCharCode(c);
				offset++;
			}
			
			offset++;
			
			return s;
		}
		
		public function syncBits():void 
		{
			this.bitPos = 0;
		}
		
		private function decodeRect():void
		{
			syncBits();
			
			//Mod by SWF Investigator
			//var rect:Rect = new Rect();
			this.rect = new Rect();
			
			var nBits:int = readUBits(5)
			this.rect.xMin = readSBits(nBits);
			this.rect.xMax = readSBits(nBits);
			this.rect.yMin = readSBits(nBits);
			this.rect.yMax = readSBits(nBits);
			
			//return this.rect;
			return;
		}
		
		public function readSBits(numBits:int):int
		{
			if (numBits > 32)
				throw new Error("Number of bits > 32");
			
			var num:int = readUBits(numBits);
			var shift:int = 32-numBits;
			// sign extension
			num = (num << shift) >> shift;
			return num;
		}
		
		public function readBit():Boolean// throws IOException
		{
			return readUBits(1) != 0;
		}
		
		public function readUBits(numBits:int):uint
		{
			if (numBits == 0)
				return 0
			
			var bitsLeft:int = numBits;
			var result:int = 0;
			
			if (bitPos == 0) //no value in the buffer - read a byte
			{
				bitBuf = data.readUnsignedByte();
				offset++;
				bitPos = 8;
			}
			
			while (true)
			{
				var shift:int = bitsLeft - bitPos;
				if (shift > 0)
				{
					// Consume the entire buffer
					result |= bitBuf << shift;
					bitsLeft -= bitPos;
					
					// Get the next byte from the input stream
					bitBuf = data.readUnsignedByte();
					offset++;
					bitPos = 8;
				}
				else
				{
					// Consume a portion of the buffer
					result |= bitBuf >> -shift;
					bitPos -= bitsLeft;
					bitBuf &= 0xff >> (8 - bitPos); // mask off the consumed bits
					
					//                if (print) System.out.println("  read"+numBits+" " + result);
					return result;
				}
			}
			//Added by SWF Investigator
			return (result);
		}
		
		/**
		 * Section stolen from SwfDecoder.java in Flex swfdump
		 */
		public function getOffset():uint
		{
			//return offset;
			return data.position;
		}
		
		public function readFixed8():Number //throws IOException
		{
			var val:int = readUI16();
			// FIXME: this doesn't consider sign of original 8.8 value
			return (val / 256.0);
		}
		
		public function readUI8():int
		{
			if (data.position<data.length)
			{
				offset++;
				return data.readUnsignedByte()&0xFF;
			}
			/**
			else if (in)
			{
				offset++;
				return data.readUnsignedByte();
			}
			 */
			else
			{
				return -1;
			}
		}
	
		public function readUI16():int
		{
			syncBits();
			var i:int;
			if (data.length-data.position >= 2)
			{
				i = data.readUnsignedByte() & 0xFF | (data.readUnsignedByte() & 0xFF) << 8;
				//pos += 2;
				offset += 2;
			}
			/**
			else if (in != null)
			{                                 
				i = super.read() | super.read()<<8;
				offset += 2;
			}*/
			else
			{
				return -1;
			}
			return i;
		}
	
		public function readUI32():uint
		{
			var i:uint = data.readUnsignedInt() & 0xFFFFFFFF;
			offset += 4;
			return i;
		}
		
		public function readSI16():int
		{
			offset += 2;
			return data.readShort();
		}
		
		public function readFully(b:ByteArray):void
		{
			var remain:int = b.length;
			var off:int = 0;
			var count:int;
			while (remain > 0)
			{
				/**
				count = read(b, off, remain);
				if (count > 0)
				{
					off += count;
					remain -= count;
				}
				else
				{
					//throw new SwfFormatException("couldn't read " + remain);
				}
				 */
				data.readBytes(b,off,remain);
				offset += remain;
				remain = 0;
			}
		}
		
		public function readSI32():int // throws IOException
		{
			syncBits();
			var i:int;
			if (data.length - data.position >= 4)
			{
				i = data.readUnsignedByte() & 0xFF | (data.readUnsignedByte() & 0xFF) << 8 | (data.readUnsignedByte() & 0xFF) << 16 | data.readUnsignedByte() << 24;
				offset += 4;
				//pos += 4;
			}
			else if (data.position < data.length)
			{
				//i = super.read() | super.read() << 8 | super.read() << 16 | super.read() << 24;
				i = data.readUnsignedByte() | data.readUnsignedByte() << 8 | data.readUnsignedByte() << 16 | data.readUnsignedByte() << 24;
				offset += 4;
			}
			else
			{
				i = -1;
			}
			return i;
		}
		
		//SI - Needs testing
		public function readFloat():Number // throws IOException
		{
			var bits:Number = data.readFloat();
			offset += 4;
			return (bits);
			//int bits = readSI32();
			//return Float.intBitsToFloat( bits );  
		}
		
		//SI - Needs testing
		public function read64():Number //throws IOException
		{
			var ls:uint = readUI32() & 0xFFFFFFFF;
			var hs:Number = readUI32();
			hs = hs * 4294967296;
			hs += ls;
			//var n:Number = ((hs << 32) | ls);
			return (hs);
		}
		
		public function read(ba:ByteArray):void {
			for (var i:int = 0; i < ba.length; i++) {
				ba[i] = readUI8();
			}
		}
		
		//Added by SWF Investigator
		//Logic taken from SWF file format spec
		public function readEncodedU32():int
		{
			var result:uint = data.readUnsignedByte();
			var temp:uint;
			if (!(result & 0x00000080))
			{
				offset++;
				return result;
			}
			temp = data.readUnsignedByte();
			result = (result & 0x0000007f) | temp<<7;
			if (!(result & 0x00004000))
			{
				offset += 2;
				return result;
			}
			temp = data.readUnsignedByte();
			result = (result & 0x00003fff) | temp<<14;
			if (!(result & 0x00200000))
			{
				offset += 3;
				return result;
			}
			temp = data.readUnsignedByte();
			result = (result & 0x001fffff) | temp<<21;
			if (!(result & 0x10000000))
			{
				offset += 4;
				return result;
			}
			temp = data.readUnsignedByte();
			result = (result & 0x0fffffff) | temp<<28;
			offset += 5;
			return result;
		}
		
	}
}