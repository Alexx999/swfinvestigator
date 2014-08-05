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
		
	import decompiler.Swf;
	import decompiler.swfdump.SWFFormatError;
	import decompiler.swfdump.tags.*;
	import decompiler.swfdump.types.BevelFilter;
	import decompiler.swfdump.types.BlurFilter;
	import decompiler.swfdump.types.ButtonRecord;
	import decompiler.swfdump.types.CXForm;
	import decompiler.swfdump.types.CXFormWithAlpha;
	import decompiler.swfdump.types.ColorMatrixFilter;
	import decompiler.swfdump.types.ConvolutionFilter;
	import decompiler.swfdump.types.CurvedEdgeRecord;
	import decompiler.swfdump.types.DropShadowFilter;
	import decompiler.swfdump.types.FillStyle;
	import decompiler.swfdump.types.Filter;
	import decompiler.swfdump.types.FocalGradient;
	import decompiler.swfdump.types.GlowFilter;
	import decompiler.swfdump.types.GlyphEntry;
	import decompiler.swfdump.types.GradRecord;
	import decompiler.swfdump.types.Gradient;
	import decompiler.swfdump.types.GradientBevelFilter;
	import decompiler.swfdump.types.GradientGlowFilter;
	import decompiler.swfdump.types.ImportRecord;
	import decompiler.swfdump.types.KerningRecord;
	import decompiler.swfdump.types.LineStyle;
	import decompiler.swfdump.types.Matrix;
	import decompiler.swfdump.types.MorphFillStyle;
	import decompiler.swfdump.types.MorphGradRecord;
	import decompiler.swfdump.types.MorphLineStyle;
	import decompiler.swfdump.types.Shape;
	import decompiler.swfdump.types.ShapeRecord;
	import decompiler.swfdump.types.ShapeWithStyle;
	import decompiler.swfdump.types.SoundInfo;
	import decompiler.swfdump.types.StraightEdgeRecord;
	import decompiler.swfdump.types.StyleChangeRecord;
	import decompiler.swfdump.types.TextRecord;
	import decompiler.tamarin.abcdump.Rect;
	import decompiler.tamarin.abcdump.Tag;
	
	import flash.utils.ByteArray;
	
	import mx.controls.Button;

	public class TagDecoder extends TagValues
	{
		import decompiler.swfdump.types.ButtonCondAction;
		
		include '../tamarin/abcdump/SWF_Constants.as';

		private var r:Swf;
		private var keepOffsets:Boolean;
		//Si - This is supposed to be passed in...
		private var jpegTables:GenericTag;
		private var handler:TagHandler = new TagHandler();
		private var header:Header;
		
		public var dict:SWFDictionary;
		
		public function TagDecoder(s:Swf)
		{
			this.r = s;
			this.header = decodeHeader();
		}
		
		public function setDictionary(d:SWFDictionary):void {
			this.dict = d;
			handler.setDecoderDictionary(d);
		}
		
		//Added by SWF Investigator
		public function setHandler(h:TagHandler):void {
			this.handler = h;
		}
		
		public function setKeepOffsets(b:Boolean):void
		{
			keepOffsets = b;
		}
		
		public function getSwfVersion():int
		{
			return header.version;
		}
		
		private function decodeTags(handler:TagHandler):void //throws IOException
		{
			var type:int;
			var h:int;
			var length:uint;
			var currentOffset:uint;
			
			do
			{
				currentOffset = r.getOffset();
				
				type = (h = r.readUI16()) >> 6;
				
				// is this a long tag header (>=63 bytes)?
				if (((length = h & 0x3F) == 0x3F))
				{
					// [ed] the player treats this as a signed field and stops if it is negative.
					length = r.readSI32();
					if (length < 0)
					{
						handler.error(null,"negative tag length: " + length + " at offset " + currentOffset);
						break;
					}
				}
				var o:uint = r.getOffset();
				var eat:uint = 0;
				
				
				if (type != 0)
				{
					var t:Tag = decodeTag(type, length);
					if (r.getOffset() - o != length)
					{
						handler.error(null,"offset mismatch after " + tagNames[t.code] + ": read " + (r.getOffset() - o) + ", expected " + length);
						if (r.getOffset() - o < length)
						{
							eat = length - (r.getOffset() - o);
							
						}
					}
					handler.setOffsetAndSize(currentOffset, r.getOffset() - currentOffset);
					handler.any( t );
					t.visit(handler);
					if (eat > 0) // try to recover.  (flash 8 sometimes writes nonsense, usually in fonts)
					{
						var b:ByteArray = new ByteArray();
						b.length = eat;
						r.read( b );
						
					}
				}
			}
			while (type != 0);
		}

		
		public function decodeTag(type:int, length:int):Tag // throws IOException
		{
			var t:Tag;
			var pos:int = r.getOffset();
			
			switch (type)
			{
				case stagProductInfo:
					t = decodeSerialNumber();
					break;
				case stagShowFrame:
					t = new ShowFrame();
					break;
				case stagMetadata:
					t = decodeMetadata();
					break;
				case stagDefineShape:
				case stagDefineShape2:
				case stagDefineShape3:
				case stagDefineShape4:
					t = decodeDefineShape(type);
					break;
				case stagPlaceObject:
					t = decodePlaceObject(length);
					break;
				case stagRemoveObject:
				case stagRemoveObject2:
					t = decodeRemoveObject(type);
					break;
				case stagDefineBinaryData:
					t = decodeDefineBinaryData(length);
					break;
				case stagDefineBits:
					t = decodeDefineBits(length);
					break;
				case stagDefineButton:
					t = decodeDefineButton(length);
					break;
				case stagJPEGTables:
					t = jpegTables = decodeJPEGTables(length);
					break;
				case stagSetBackgroundColor:
					t = decodeSetBackgroundColor();
					break;
				case stagDefineFont:
					t = decodeDefineFont();
					break;
				case stagDefineText:
				case stagDefineText2:
					t = decodeDefineText(type);
					break;
				case stagDoAction:
					t = decodeDoAction(length);
					break;
				case stagDefineFontInfo:
				case stagDefineFontInfo2:
					t = decodeDefineFontInfo(type, length);
					break;
				case stagDefineSound:
					t = decodeDefineSound(length);
					break;
				case stagStartSound:
					t = decodeStartSound();
					break;
				case stagDefineButtonSound:
					t = decodeDefineButtonSound();
					break;
				case stagSoundStreamHead2:
				case stagSoundStreamHead:
					t = decodeSoundStreamHead(type);
					break;
				case stagSoundStreamBlock:
					t = decodeSoundStreamBlock(length);
					break;
				case stagDefineBitsLossless:
					t = decodeDefineBitsLossless(length);
					break;
				case stagDefineBitsJPEG2:
					t = decodeDefineJPEG2(length);
					break;
				case stagDefineButtonCxform:
					t = decodeDefineButtonCxform();
					break;
				case stagProtect:
					t = decodeProtect(length);
					break;
				case stagPlaceObject2:
					t = decodePlaceObject23(stagPlaceObject2, length);
					break;
				case stagPlaceObject3:
					t = decodePlaceObject23(stagPlaceObject3, length);
					break;
				case stagDefineButton2:
					t = decodeDefineButton2(length);
					break;
				case stagDefineBitsJPEG3:
					t = decodeDefineJPEG3(length);
					break;
				case stagDefineBitsLossless2:
					t = decodeDefineBitsLossless2(length);
					break;
				case stagDefineEditText:
					t = decodeDefineEditText();
					break;
				case stagDefineSprite:
					t = decodeDefineSprite(pos+length);
					break;
				case stagDefineScalingGrid:
					t = decodeDefineScalingGrid();
					break;
				case stagFrameLabel:
					t = decodeFrameLabel(length);
					break;
				case stagDefineMorphShape:
					t = decodeDefineMorphShape();
					break;
				case stagDefineMorphShape2:
					t = decodeDefineMorphShape2();
					break;
				case stagDefineFont2:
					t = decodeDefineFont2(length);
					break;
				case stagDefineFont3:
					t = decodeDefineFont3(length);
					break;
				case stagDefineFont4:
					t = decodeDefineFont4(length);
					break;
				case stagExportAssets:
					t = decodeExportAssets();
					break;
				case stagImportAssets:
				case stagImportAssets2:
					t = decodeImportAssets(type);
					break;
				case stagEnableDebugger2:
				case stagEnableDebugger:
					t = decodeEnableDebugger(type);
					break;
				case stagDoInitAction:
					t = decodeDoInitAction(length);
					break;
				case stagDefineVideoStream:
					t = decodeDefineVideoStream();
					break;
				case stagVideoFrame:
					t = decodeVideoFrame(length);
					break;
				/**
				case stagDebugID:
					t = decodeDebugID(type, length);
					break;
				*/
				case stagScriptLimits:
					t = decodeScriptLimits();
					break;
				case stagSetTabIndex:
					t = decodeSetTabIndex();
					break;
				/**
				 * handled by tamarin code
				case stagDoABC:
				case stagDoABC2:
					t = decodeDoABC(type, length);
					break;
				*/
				case stagSymbolClass:
					t = decodeSymbolClass();
					break;
				case stagFileAttributes:
					t = decodeFileAttributes();
					break;
				case stagDefineFontAlignZones:
					t = decodeDefineFontAlignZones();
					break;
				case stagCSMTextSettings:
					t = decodeCSMTextSettings();
					break;
				case stagDefineSceneAndFrameLabelData:
					t = decodeDefineSceneAndFrameData(length);
					break;
				case stagDefineFontName:
					t = decodeDefineFontName();
					break;
				case stagDefineBitsJPEG4:
					t = decodeDefineJPEG4(length);
					break;
				case stagStartSound2:
					t = decodeStartSound2();
					break;
				case stagEnableTelemetry:
					t = decodeEnableTelemetry(length);
					break;
				/**
				 * Used by certain obfuscation tools
				case 253:
					t = decodeDoAction(length);
					break;
				*/
				default:
					t = decodeUnknown(length, type);
					break;
			}
			
			var consumed:int = r.getOffset() - pos;
			
			// [preilly] It looks like past Authoring tools have generated some SWF's with
			// stagSoundStreamHead tags of length 4 with compression set to mp3, but the tag
			// really has 6 bytes in it and the player always reads the 6 bytes, so ignore the
			// difference between the consumed and the length for this special case.
			if ((consumed != length) && (type == stagSoundStreamHead) && (consumed != (length + 2)))
			{
				throw new SWFFormatError (tagNames[type] + " at pos "+pos+ ": " + consumed +
					" bytes were read. " + length + " byte were required.");
			}
			return t;
		}

		private function decodeDefineSceneAndFrameData(length:int):Tag //throws IOException
		{
			var t:DefineSceneAndFrameLabelData = new DefineSceneAndFrameLabelData();
			/**
			t.data = new ByteArray();//length
			t.data.length = length;
			r.readFully(t.data);
			 */
			t.sceneCount = r.readEncodedU32();
			var i:int;
			if (t.sceneCount > 0) {
				t.sceneInfo = new Vector.<Object>;
			}
			for (i=0; i< t.sceneCount; i++) {
				t.sceneInfo.push(new Object());
				t.sceneInfo[i].offset = r.readEncodedU32();
				t.sceneInfo[i].name = r.readString();
			}
			
			t.frameLabelCount = r.readEncodedU32();
			if (t.frameLabelCount > 0) {
				t.frameInfo = new Vector.<Object>;
			}
			for (i = 0; i < t.frameLabelCount; i++) {
				t.frameInfo.push(new Object());
				t.frameInfo[i].number = r.readEncodedU32();
				t.frameInfo[i].label = r.readString();
			}
			
			return t;
		}
		
		
		private function decodeSymbolClass():Tag //throws IOException
		{
			var t:SymbolClass = new SymbolClass();
			var count:int = r.readUI16();
			
			//t.class2tag = new HashMap<String, Tag>(count);
			t.class2tag = new Object();
			
			for (var i:int=0; i < count; i++)
			{
				var idref:int = r.readUI16();
				var name:String = r.readString();
				if (idref == 0)
				{
					t.topLevelClass = name;
					continue;
				}
				var ref:DefineTag = dict.getTagByID(idref);
				t.class2tag[name] = ref;
				//Added by SWF Investigator
				t.class2idref[name] = idref;
				dict.addIdName(idref,name);
				
				if (ref && ref.name != null && ref.name.length > 0)
				{
					if (!ref.name == name)
					{
						handler.error(t,"SymbolClass: symbol " + idref + " already exported as " + ref.name);
					}
					//else
					//{
					// FIXME: is this right?  seem to be getting redundant message in swfdumps that work right in the player
					// FIXME: We should eventually enforce that export names not be used in zaphod movies,
					// FIXME: but in the short term, all this message means is that the symbol was both exported
					// FIXME: via ExportAssets and also associated with a class via SymbolClass.  They have
					// FIXME: different semantic meanings, so this error is a bit off-base.  --rg 
					//	handler.error(t,"Redundant SymbolClass of " + ref.name + ".  Found " + ref.getClass().getName() + " of same name in dictionary.");
					//}
				}
				else
				{
					var other:DefineTag = dict.getTag(name);
					if (other != null)
					{
						var id:int = dict.getId(other);
						handler.error(t,"Symbol " + name + " already refers to ID " + id);
					} else if (ref) {
						ref.name = name;
						dict.addName(ref, name);
					}	
				}
			}
			return t;
		}
		
		private function decodeSetTabIndex():Tag // throws IOException
		{
			var depth:int = r.readUI16();
			var index:int = r.readUI16();
			return new SetTabIndex(depth, index);
		}
		
		private function decodeUnknown(length:int, code:int):Tag //throws IOException
		{
			var t:GenericTag;
			t = new GenericTag(code);
			t.data = new ByteArray();//length
			t.data.length = length;
			r.readFully(t.data);
			return t;
		}
		
		private function decodeScriptLimits():ScriptLimits // throws IOException
		{
			var scriptLimits:ScriptLimits = new ScriptLimits(r.readUI16(), r.readUI16());
			return scriptLimits;
		}
		
		private function decodeDefineFontInfo(code:int, length:int):Tag //throws IOException
		{
			var t:DefineFontInfo;
			t = new DefineFontInfo(code);
			var pos:int = r.getOffset();
			
			var idref:int = r.readUI16();
			t.font = dict.getTagByID(idref) as DefineFont1;
			if (t.font.fontInfo != null)
			{
				handler.error(t,"font " + idref + " info redefined");
			}
			t.font.fontInfo = t;
			t.name = r.readLengthString();
			
			r.syncBits();
			
			r.readUBits(3); // reserved
			t.shiftJIS = r.readBit();
			t.ansi = r.readBit();
			t.italic = r.readBit();
			t.bold = r.readBit();
			t.wideCodes = r.readBit();
			
			if (code == stagDefineFontInfo2)
			{
				if (!t.wideCodes)
					handler.error(t,"widecodes must be true in DefineFontInfo2");
				if (getSwfVersion() < 6)
					handler.error(t,"DefineFont2 not valid before SWF6");
				t.langCode = r.readUI8();
			}
			
			length -= r.getOffset() - pos;
			var i:int;
			
			if (t.wideCodes)
			{
				length = length / 2;
				//t.codeTable = new char[length];
				t.codeTable = new String();
				for (i = 0; i < length; i++)
				{
					//t.codeTable[i] = (char)r.readUI16();
					t.codeTable += String.fromCharCode(r.readUI16());
				}
			}
			else
			{
				//t.codeTable = new char[length];
				t.codeTable = new String();
				for (i = 0; i < length; i++)
				{
					//t.codeTable[i] = (char)r.readUI8();
					t.codeTable += String.fromCharCode(r.readUI8());
				}
			}
			return t;
		}
		
		public function decodeDoAction(length:int):Tag // throws IOException
		{
			var t:DoAction = new DoAction();
			var actionDecoder:ActionDecoder = new ActionDecoder(r,null);
			actionDecoder.setKeepOffsets(keepOffsets);
			try {
				t.actionList = actionDecoder.decode(length);
			} catch (s:SWFFormatError) {
				t.actionList = s.aList;
				s.t = t;
				throw s;
			}
			return t;
		}
		
		private function decodeDefineText(type:int):Tag //throws IOException
		{
			var t:DefineText = new DefineText(type);
			
			var id:int = r.readUI16();
			t.bounds = decodeRect();
			t.matrix = decodeMatrix();
			
			var glyphBits:int = r.readUI8();
			var advanceBits:int = r.readUI8();
			// todo range check - glyphBits and advanceBits must be <= 32
			var list:Vector.<TextRecord> = new Vector.<TextRecord>;
			
			var code:int;
			while ((code = r.readUI8()) != 0)
			{
				list.push(decodeTextRecord(type, code, glyphBits, advanceBits));
			}
			
			t.records = list;
			
			dict.add(id, t);
			return t;
		}
		
		private function decodeGlyphEntries(glyphBits:int, advanceBits:int, count:int):Vector.<GlyphEntry> //throws IOException
		{
			var e:Vector.<GlyphEntry> = new Vector.<GlyphEntry>(count);
			
			r.syncBits();
			for (var i:int = 0; i < count; i++)
			{
				var ge:GlyphEntry = new GlyphEntry();
				
				ge.setIndex( r.readUBits(glyphBits) );
				ge.advance = r.readSBits(advanceBits);
				
				e[i] = ge;
			}
			
			return e;
		}
		
		private function decodeTextRecord(defineText:int, flags:int, glyphBits:int, advanceBits:int):TextRecord //throws IOException
		{
			var t:TextRecord = new TextRecord();
			
			t.flags = flags;
			
			if (t.hasFont())
			{
				var idref:int = r.readUI16();
				t.font = dict.getTagByID(idref) as DefineFont;
			}
			
			if (t.hasColor())
			{
				switch (defineText)
				{
					case stagDefineText:
						t.color = decodeRGB(r);
						break;
					case stagDefineText2:
						t.color = decodeRGBA(r);
						break;
					default:
						//assert false;
				}
			}
			
			if (t.hasX())
			{
				t.xOffset = r.readSI16();
			}
			
			if (t.hasY())
			{
				t.yOffset = r.readSI16();
			}
			
			if (t.hasHeight())
			{
				t.height = r.readUI16();
			}
			
			var count:int = r.readUI8();
			t.entries = decodeGlyphEntries(glyphBits, advanceBits, count);
			
			return t;
		}
		
		private function decodeVideoFrame(length:int):Tag // throws IOException
		{
			var t:VideoFrame;
			t = new VideoFrame();
			var pos:int = r.getOffset();
			
			var idref:int = r.readUI16();
			t.stream = dict.getTagByID(idref) as DefineVideoStream;
			t.frameNum = r.readUI16();
			
			length -= r.getOffset() - pos;
			
			t.videoData = new ByteArray();//length
			t.videoData.length = length;
			r.readFully(t.videoData);
			return t;
		}
		
		private function decodeDefineVideoStream():Tag// throws IOException
		{
			var t:DefineVideoStream;
			t = new DefineVideoStream();
			var id:int = r.readUI16();
			t.numFrames = r.readUI16();
			t.width = r.readUI16();
			t.height = r.readUI16();
			
			r.syncBits();
			
			r.readUBits(4); // reserved
			t.deblocking = r.readUBits(3);
			t.smoothing = r.readBit();
			
			t.codecID = r.readUI8();
			
			dict.add(id, t);
			return t;
		}
		
		public function decodeDoInitAction(length:int):Tag // throws IOException
		{
			var t:DoInitAction;
			t = new DoInitAction();
			var idref:int = r.readUI16();
			try
			{
				t.sprite = dict.getTagByID(idref) as DefineSprite;
				if (t.sprite.initAction != null)
				{
					handler.error(t,"Sprite " + idref + " initaction redefined");
				}
				else
				{
					t.sprite.initAction = t;
				}
			}
			catch (e:Error)
			{
				handler.error(t,e.message);
			}
			
			var actionDecoder:ActionDecoder = new ActionDecoder(r,null);
			actionDecoder.setKeepOffsets(keepOffsets);
			t.actionList = actionDecoder.decode(length-2);
			return t;
		}
		
		private function decodeEnableDebugger(code:int):Tag //throws IOException
		{
			var t:EnableDebugger;
			t = new EnableDebugger(code);
			if (code == stagEnableDebugger2)
			{
				if (getSwfVersion() < 6)
					handler.error(t,"EnableDebugger2 not valid before SWF 6");
				t.reserved = r.readUI16(); // reserved
			}
			t.password = r.readString();
			return t;
		}
		
		private function decodeImportAssets(code:int):Tag // throws IOException
		{
			var t:ImportAssets;
			t = new ImportAssets(code);
			
			t.url = r.readString();
			if (code == stagImportAssets2)
			{
				t.downloadNow = (r.readUI8() == 1);
				if (r.readUI8() == 1) // hasDigest == 1
				{
					t.SHA1 = new ByteArray();
					t.SHA1.length = 20;
					r.readFully(t.SHA1);
				}
			}
			
			var count:int = r.readUI16();
			t.importRecords = new Vector.<ImportRecord>;
			
			for (var i:int=0; i < count; i++)
			{
				var ir:ImportRecord = new ImportRecord();
				var id:int = r.readUI16();
				ir.name = r.readString();
				t.importRecords.push(ir);
				dict.add(id, ir);
				dict.addName(ir, ir.name);
			}
			return t;
		}
		
		private function decodeExportAssets():Tag // throws IOException
		{
			var t:ExportAssets;
			t = new ExportAssets();
			
			var count:int = r.readUI16();
			
			t.exports = new Vector.<Tag>;
			
			for (var i:int=0; i < count; i++)
			{
				var idref:int = r.readUI16();
				var name:String = r.readString();
				var ref:DefineTag = dict.getTagByID(idref);
				t.exports.push(ref);
				if (ref && ref.name != null)
				{
					if (ref.name != name)
						handler.error(t,"ExportAsset: symbol " + idref + " already exported as " + ref.name);
					else
						handler.error(t,"redundant export of "+ref.name);
				}
				else if (ref!=null)
				{
					var other:DefineTag = dict.getTag(name);
					if (other != null)
					{
						var id:int = dict.getId(other);
						handler.error(t,"Symbol "+name+" already refers to ID "+id);
					}
					ref.name = name;
					dict.addName(ref, name);
				}
			}
			return t;
		}
		
		private function decodeDefineFont2(length:int):Tag //throws IOException
		{
			var t:DefineFont2 = new DefineFont2();
			return decodeDefineFont2And3(t, length);
		}
		
		private function decodeDefineFont3(length:int):Tag //throws IOException
		{
			var t:DefineFont3 = new DefineFont3();
			return decodeDefineFont2And3(t, length);
		}
		
		private function decodeDefineFont2And3(t:DefineFont2, length:int):Tag //throws IOException
		{
			
			var pos:int = r.getOffset();
			var i:int;
			var id:int = r.readUI16();
			
			r.syncBits();
			
			t.hasLayout = r.readBit();
			t.shiftJIS = r.readBit();
			t.smallText = r.readBit();
			t.ansi = r.readBit();
			t.wideOffsets = r.readBit();
			t.wideCodes = r.readBit();
			// enable after we're sure that bug 147073 isn't a bug.  If it is a bug, then this can be
			// removed as well as the stageDefineFont3-specific code in TagEncoder.defineFont2()
			//if (t.code == stagDefineFont3 && ! t.wideCodes)
			//{
			//    handler.error(t,"widecodes must be true in DefineFont3");
			//}
			
			t.italic = r.readBit();
			t.bold = r.readBit();
			
			t.langCode = r.readUI8();
			
			t.fontName = r.readLengthString();
			
			var numGlyphs:int = r.readUI16();
			
			//long[] offsets = new long[numGlyphs];
			//Offset table
			var offsets:Vector.<Number> = new Vector.<Number>(numGlyphs);
			for (i = 0; i < numGlyphs; i++)
			{
				if (t.wideOffsets)
					offsets[i] = r.readUI32();
				else
					offsets[i] = r.readUI16();
			}
			
			var codeTableOffset:uint = 0;
			
			length -= r.getOffset() - pos;

			//Commented out by SWF Investigator
			//I think the numGlyphs check was a misinterpretation of the spec
			if (numGlyphs > 0 || length > 0)
			{
				if (t.wideOffsets)
					codeTableOffset = r.readUI32();
				else
					codeTableOffset = r.readUI16();
			}			

			t.glyphShapeTable = new Vector.<Shape>(numGlyphs);
			
			for (i = 0; i < numGlyphs; i++)
			{
				var glyphLength:int;
				if (i < (numGlyphs - 1))
					glyphLength = (offsets[i+1] - offsets[i]);
				else
					glyphLength = (codeTableOffset - offsets[i]);
			
				t.glyphShapeTable[i] = decodeGlyph(stagDefineShape3, glyphLength);
			}
			
			//t.codeTable = new char[numGlyphs];
			t.codeTable = new String();
			if (t.wideCodes)
			{
				for (i = 0; i < numGlyphs; i++)
					//t.codeTable[i] = (char) r.readUI16();
					t.codeTable += String.fromCharCode(r.readUI16());
			}
			else
			{
				for (i = 0; i < numGlyphs; i++)
					//t.codeTable[i] = (char) r.readUI8();
					t.codeTable += String.fromCharCode(r.readUI8());
			}
			
			if (t.hasLayout)
			{	
				t.ascent = r.readSI16();
				t.descent = r.readSI16();
				t.leading = r.readSI16();

				//t.advanceTable = new short[numGlyphs];
				t.advanceTable = new Vector.<int>(numGlyphs);
				for (i = 0; i < numGlyphs; i++)
				{
					t.advanceTable[i] = r.readSI16();
				}
				
				
				t.boundsTable = new Vector.<Rect>(numGlyphs);
				for (i = 0; i < numGlyphs; i++)
				{
					t.boundsTable[i] = decodeRect();
				}
				
				//Probably should be if data available
				t.kerningCount = r.readUI16();
				t.kerningTable = new Vector.<KerningRecord>(t.kerningCount);
				for (i = 0; i < t.kerningCount; i++)
				{
					t.kerningTable[i] = decodeKerningRecord(t.wideCodes);
				}
			}
			
			dict.add(id, t);
			dict.addFontFace( t );
			return t;
		}
		
		private function decodeDefineFont4(length:int):Tag //throws IOException
		{
			var t:DefineFont4 = new DefineFont4();
			var pos:int = r.getOffset();
			
			var id:int = r.readUI16();
			
			r.syncBits();
			r.readUBits(5); // reserved
			t.hasFontData = r.readBit();
			//t.smallText = r.readBit();
			t.italic = r.readBit();
			t.bold = r.readBit();
			
			//t.langCode = r.readUI8();
			t.fontName = r.readString();
			
			if (t.hasFontData)
			{
				length -= r.getOffset() - pos;
				//t.data = new byte[length];
				t.data = new ByteArray();
				t.data.length = length;
				r.readFully(t.data);
			}
			
			dict.add(id, t);
			dict.addFontFace(t);
			return t;
		}
		
		private function decodeKerningRecord(wideCodes:Boolean):KerningRecord //throws IOException
		{
			var kr:KerningRecord = new KerningRecord();
			
			kr.code1 = (wideCodes) ? r.readUI16() : r.readUI8();
			kr.code2 = (wideCodes) ? r.readUI16() : r.readUI8();
			kr.adjustment = r.readUI16();
			
			return kr;
		}

		/**		
		private function decodeDefineMorphShape():Tag //throws IOException
		{
			return decodeDefineMorphShape(stagDefineMorphShape);
		}
		 */
		
		private function decodeDefineMorphShape2():Tag //throws IOException
		{
			return decodeDefineMorphShape(stagDefineMorphShape2);
		}
		
		private function decodeDefineMorphShape(code:int = stagDefineMorphShape):Tag //throws IOException
		{
			var t:DefineMorphShape = new DefineMorphShape(code);
			var id:int = r.readUI16();
			t.startBounds = decodeRect();
			t.endBounds = decodeRect();
			if (code == stagDefineMorphShape2)
			{
				t.startEdgeBounds = decodeRect();
				t.endEdgeBounds = decodeRect();
				r.readUBits(6);
				t.usesNonScalingStrokes = r.readBit();
				t.usesScalingStrokes = r.readBit();
			}
			var offset:int = r.readUI32(); // offset to EndEdges
			t.fillStyles = decodeMorphFillstyles(code);
			t.lineStyles = decodeMorphLinestyles(code);
			t.startEdges = decodeShape(stagDefineShape3);
			if (offset != 0)
				t.endEdges = decodeShape(stagDefineShape3);
			dict.add(id, t);
			return t;
		}
		
		private function decodeMorphLinestyles(code:int):Vector.<MorphLineStyle> //throws IOException
		{
			var count:int = r.readUI8();
			if (count == 0xFF)
			{
				count = r.readUI16();
			}
			
			var styles:Vector.<MorphLineStyle> = new Vector.<MorphLineStyle>(count);
			
			for (var i:int = 0; i < count; i++)
			{
				var s:MorphLineStyle = new MorphLineStyle();
				s.startWidth = r.readUI16();
				s.endWidth = r.readUI16();
				if (code == stagDefineMorphShape2)
				{
					s.startCapsStyle = r.readUBits(2);
					s.jointStyle = r.readUBits(2);
					s.hasFill = r.readBit();
					s.noHScale = r.readBit();
					s.noVScale = r.readBit();
					s.pixelHinting = r.readBit();
					r.readUBits(5); // reserved
					s.noClose = r.readBit();
					s.endCapsStyle = r.readUBits(2);
					if (s.jointStyle == 2)
					{
						s.miterLimit = r.readUI16();
					}
				}
				if (!s.hasFill)
				{
					s.startColor = decodeRGBA(r);
					s.endColor = decodeRGBA(r);
				}
				if (s.hasFill)
				{
					s.fillType = decodeMorphFillStyle(code);
				}
				
				styles[i] = s;
			}
			
			return styles;
		}
		
		private function decodeMorphFillstyles(shape:int):Vector.<MorphFillStyle> //throws IOException
		{
			var count:int = r.readUI8();
			if (count == 0xFF)
			{
				count = r.readUI16();
			}
			
			var styles:Vector.<MorphFillStyle> = new Vector.<MorphFillStyle>(count);
			
			for (var i:int = 0; i < count; i++)
			{
				styles[i] = decodeMorphFillStyle(shape);
			}
			
			return styles;
		}
		
		private function decodeMorphFillStyle(shape:int):MorphFillStyle //throws IOException
		{
			var s:MorphFillStyle = new MorphFillStyle();
			
			s.type = r.readUI8();
			switch (s.type)
			{
				case FillStyle.FILL_SOLID: // 0x00
					s.startColor = decodeRGBA(r);
					s.endColor = decodeRGBA(r);
					break;
				case FillStyle.FILL_GRADIENT: // 0x10 linear gradient fill
				case FillStyle.FILL_RADIAL_GRADIENT: // 0x12 radial gradient fill
				case FillStyle.FILL_FOCAL_RADIAL_GRADIENT: // 0x13 focal radial gradient fill
					s.startGradientMatrix = decodeMatrix();
					s.endGradientMatrix = decodeMatrix();
					s.gradRecords = decodeMorphGradient();
					if (s.type == FillStyle.FILL_FOCAL_RADIAL_GRADIENT && shape == stagDefineMorphShape2)
					{
						s.ratio1 = r.readSI16();
						s.ratio2 = r.readSI16();
					}
					break;
				case FillStyle.FILL_BITS: // 0x40 tiled bitmap fill
				case (FillStyle.FILL_BITS | FillStyle.FILL_BITS_CLIP): // 0x41 clipped bitmap fill
				case (FillStyle.FILL_BITS | FillStyle.FILL_BITS_NOSMOOTH): // 0x42 tiled non-smoothed fill
				case (FillStyle.FILL_BITS | FillStyle.FILL_BITS_CLIP | FillStyle.FILL_BITS_NOSMOOTH): // 0x43 clipped non-smoothed fill
					var idref:int = r.readUI16();
					try
					{
						s.bitmap = dict.getTagByID(idref);
					}
					catch (e:Error)
					{
						handler.error(null,e.message);
						s.bitmap = null;
					}
					s.startBitmapMatrix = decodeMatrix();
					s.endBitmapMatrix = decodeMatrix();
					break;
				default:
					throw new SWFFormatError("unrecognized fill style type: " + s.type);
			}
			
			return s;
		}
		
		private function decodeMorphGradient():Vector.<MorphGradRecord> //throws IOException
		{
			var num:int = r.readUI8();
			var gradRecords:Vector.<MorphGradRecord> = new Vector.<MorphGradRecord>(num);
			
			for (var i:int = 0; i < num; i++)
			{
				var g:MorphGradRecord = new MorphGradRecord();
				g.startRatio = r.readUI8();
				g.startColor = decodeRGBA(r);
				g.endRatio = r.readUI8();
				g.endColor = decodeRGBA(r);
				
				gradRecords[i] = g;
			}
			
			return gradRecords;
		}

		
		private function decodeFrameLabel(length:int):Tag // throws IOException
		{
			var t:FrameLabel = new FrameLabel();
			var pos:int = r.getOffset();
			t.label = r.readString();
			if (getSwfVersion() >= 6)
			{
				if (length - r.getOffset() + pos == 1)
				{
					var anchor:int = r.readUI8();
					if (anchor != 0 && anchor != 1)
						handler.error(t,"illegal anchor value: "+anchor+".  Must be 0 or 1");
					// player treats any nonzero value as true
					t.anchor = (anchor != 0);
				}
			}
			return t;
		}
		
		private function decodeDefineEditText():Tag // throws IOException
		{
			var t:DefineEditText;
			t = new DefineEditText();
			var id:int = r.readUI16();
			t.bounds = decodeRect();
			
			r.syncBits();
			
			t.hasText = r.readBit();
			t.wordWrap = r.readBit();
			t.multiline = r.readBit();
			t.password = r.readBit();
			t.readOnly = r.readBit();
			t.hasTextColor = r.readBit();
			t.hasMaxLength = r.readBit();
			t.hasFont = r.readBit();
			t.hasFontClass = r.readBit(); // FP 9.0.45 or later
			t.autoSize = r.readBit();
			t.hasLayout = r.readBit();
			t.noSelect = r.readBit();
			t.border = r.readBit();
			t.wasStatic = r.readBit();
			t.html = r.readBit();
			t.useOutlines = r.readBit();
			
			if (t.hasFont)
			{
				var idref:int = r.readUI16();
				t.font = dict.getTagByID(idref) as DefineFont;
				t.height = r.readUI16();
			}
			
			if (t.hasFontClass)
			{
				t.fontClass = r.readString();
				t.height = r.readUI16();
			}
			
			if (t.hasTextColor)
			{
				t.color = decodeRGBA(r);
			}
			
			if (t.hasMaxLength)
			{
				t.maxLength = r.readUI16();
			}
			
			if (t.hasLayout)
			{
				t.align = r.readUI8();
				t.leftMargin = r.readUI16();
				t.rightMargin = r.readUI16();
				t.ident = r.readUI16();
				t.leading = r.readSI16(); // see errata, leading is signed
			}
			
			t.varName = r.readString();
			
			if (t.hasText)
			{
				t.initialText = r.readString();
			}
			
			dict.add(id, t);
			return t;
		}

		
		private function decodeDefineScalingGrid():Tag //throws IOException
		{
			var t:DefineScalingGrid = new DefineScalingGrid();
			var idref:int = r.readUI16();
			try
			{
				t.scalingTarget = dict.getTagByID(idref);
				if (t.scalingTarget is DefineSprite)
				{
					var targetSprite:DefineSprite = t.scalingTarget as DefineSprite;
					if (targetSprite.scalingGrid != null)
					{
						handler.error(t,"Sprite " + idref + " scaling grid redefined" );
					}
					targetSprite.scalingGrid = t;
				}
				else if (t.scalingTarget is DefineButton)
				{
					var targetButton:DefineButton = t.scalingTarget as DefineButton;
					if (targetButton.scalingGrid != null)
					{
						handler.error(t,"Button " + idref + " scaling grid redefined");
					}
					targetButton.scalingGrid = t;
				}
			}
			catch (e:Error)
			{
				return null;
			}
			t.rect = decodeRect();
			return t;
		}
		
		private function decodeDefineBitsLossless2(length:int):Tag //throws IOException
		{
			var t:DefineBitsLossless;
			t = new DefineBitsLossless(stagDefineBitsLossless2);
			var r1:Swf = r;
			
			var pos:int = r1.getOffset();
			
			var id:int = r1.readUI16();
			t.format = r1.readUI8();
			t.width = r1.readUI16();
			t.height = r1.readUI16();
			
			//byte[] data;
			var data:ByteArray;
			
			switch (t.format)
			{
				case 3:
					var colorTableSize:int = r1.readUI8()+1;
					length -= r1.getOffset() - pos;
					//data = new byte[length];
					data = new ByteArray();
					data.length = length;
					//data.position = 0;
					r1.readFully(data);
					data.position = 0;
					data.uncompress();
					//r1 = new SwfDecoder(new InflaterInputStream(new ByteArrayInputStream(data)), getSwfVersion());
					r1 = new Swf(data,null,false,true);
					decodeAlphaColorMapData(r1, t, colorTableSize);
					break;
				case 4:
				case 5:
					length -= r1.getOffset() - pos;
					//data = new byte[length];
					data = new ByteArray();
					data.length = length;
					//data.position = 0;
					r1.readFully(data);
					data.position = 0;
					data.uncompress();
					//r1 = new SwfDecoder(new InflaterInputStream(new ByteArrayInputStream(data)), getSwfVersion());
					r1 = new Swf(data,null,false,true);
					//t.data = new byte[t.width * t.height * 4];
					t.data = new ByteArray();
					t.data.length = t.width * t.height * 4;
					//t.data.position = 0;
					r1.readFully(t.data);
					break;
				default:
					throw new SWFFormatError("Illegal bitmap format " + t.format);
			}
			
			dict.add(id, t);
			return t;
		}
		
		private function decodeAlphaColorMapData(r1:Swf, tag:DefineBitsLossless, tableSize:int):void //throws IOException
		{
			var width:int = tag.width;
			var height:int = tag.height;
			
			//tag.colorData = new int[tableSize];
			tag.colorData = new Vector.<int>(tableSize);
			
			var i:int;
			for (i = 0; i < tableSize; i++)
			{
				tag.colorData[i] = decodeRGBA(r1);
			}
			
			if (width % 4 != 0)
			{
				width = (width / 4 + 1) * 4;
			}
			
			var data_size:int = width * height;
			
			//tag.data = new byte[data_size];
			tag.data = new ByteArray();
			tag.data.length = data_size;
			//tag.data.position = 0;
			//r1.read(tag.data);
			
			i = 0;
			var b:int;
			while (i < data_size)
			{
				b = r1.readUI8();
				if (b != -1)
				{
					tag.data[i] = b; //(byte) b;
					i++;
				}
				else
				{
					break;
				}
			}
			
			var extra:int = 0;
			while (r1.readUI8() != -1)
			{
				extra++;
			}
			
			if (extra > 0)
			{
				throw new SWFFormatError(extra + " bytes of bitmap data (" + width + "x" + height + ") not read!");
			}
			else if (i != data_size)
			{
				throw new SWFFormatError("(" + width + "x" + height + ") data buffer " + (data_size - i) + " bytes too big...");
			}
		}
		
		private function decodeDefineJPEG4(length:int):Tag
		{
			return(decodeDefineJPEG3AndJPEG4(length,true));
		}
		
		private function decodeDefineJPEG3(length:int):Tag
		{
			return(decodeDefineJPEG3AndJPEG4(length,false));
		}
		
		private function decodeDefineJPEG3AndJPEG4(length:int,jpeg4:Boolean):Tag //throws IOException
		{
			//var t:DefineBitsJPEG3;
			var t:*;
			if (jpeg4) {
				t = new DefineBitsJPEG4();
			} else {
				t = new DefineBitsJPEG3();
			}
			var pos:int = r.getOffset();
			var id:int = r.readUI16();
			t.alphaDataOffset = r.readUI32();
			
			if (jpeg4) {
				t.deblockParam = r.readUI16();
			}
			
			//t.data = new byte[(int) t.alphaDataOffset];
			t.data = new ByteArray();
			t.data.length = t.alphaDataOffset;
			//t.data.position = 0;
			r.readFully(t.data);
			
			length -= r.getOffset() - pos;
			//byte[] temp = new byte[length];
			var temp:ByteArray = new ByteArray();
			temp.length = length;
			//temp.position = 0;
			r.readFully(temp);
			
			//SwfDecoder r1 = new SwfDecoder(new InflaterInputStream(new ByteArrayInputStream(temp)), getSwfVersion());
			temp.uncompress();
			var r1:Swf = new Swf(temp,null,false,true);
			var alpha:int, i:int = 0;
			//byte[] alphaData = new byte[length];
			var alphaData:ByteArray = new ByteArray();
			alphaData.length = length;
			//alphaData.position = 0;
			
			while ((alpha = r1.readUI8()) != -1)
			{
				if (i == alphaData.length)
				{
					//byte[] b = new byte[i + length];
					var b:ByteArray = new ByteArray();
					b.length = i + length;
					//b.position = 0;
					//System.arraycopy(alphaData, 0, b, 0, alphaData.length);
					b.writeBytes(alphaData,0,alphaData.length);
					alphaData = b;
				}
				alphaData[i] = alpha;//(byte)alpha;
				i++;
			}
			
			//t.alphaData = new byte[i];
			t.alphaData = new ByteArray();
			t.alphaData.length = i;
			//t.alphaData.position = 0;
			//System.arraycopy(alphaData, 0, t.alphaData, 0, i);
			t.alphaData.writeBytes(alphaData,0,i);
			
			dict.add(id, t);
			return t;
		}
		
		private function decodePlaceObject(length:int):Tag //throws IOException
		{
			var t:PlaceObject = new PlaceObject(stagPlaceObject);
			var pos:int = r.getOffset();
			var idref:int = r.readUI16();
			t.depth = r.readUI16();
			t.setMatrix(decodeMatrix());
			if (length - r.getOffset() + pos != 0)
			{
				t.setCxform(decodeCxform());
			}
			t.setRef(dict.getTagByID(idref));
			return t;
		}
		
		public function decodePlaceObject2(length:uint):Tag {
			return (decodePlaceObject23(stagPlaceObject2,length));
		}
		
		public function decodePlaceObject3(length:uint):Tag {
			return (decodePlaceObject23(stagPlaceObject3,length));
		}
		
		public function decodePlaceObject23(type:int, length:int):Tag //throws IOException
		{
			var t:PlaceObject = new PlaceObject(type);
			var pos:int = r.getOffset();
			t.flags = r.readUI8();
			if (type == stagPlaceObject3)
			{
				t.flags2 = r.readUI8();
			}
			t.depth = r.readUI16();
			if (t.hasClassName())
			{
				t.className = r.readString();
			}
			if (t.hasCharID())
			{
				var idref:int = r.readUI16();
				t.setRef(dict.getTagByID(idref));
			}
			if (t.hasMatrix())
			{
				t.matrix = decodeMatrix();
			}
			if (t.hasCxform())
			{
				t.setCxform(decodeCxforma());
			}
			if (t.hasRatio())
			{
				t.ratio = r.readUI16();
			}
			if (t.hasName())
			{
				t.name = r.readString();
			}
			if (t.hasClipDepth())
			{
				t.clipDepth = r.readUI16();
			}
			if (type == stagPlaceObject3)
			{
				if (t.hasFilterList())
				{
					t.filters = decodeFilterList();
				}
				if (t.hasBlendMode())
				{
					t.blendMode = r.readUI8();
				}
			}
			if (t.hasClipAction())
			{
				var actionDecoder:ActionDecoder = new ActionDecoder(r,null);
				actionDecoder.setKeepOffsets(keepOffsets);
				t.clipActions = actionDecoder.decodeClipActions(length - (r.getOffset() - pos));
			}
			return t;
		}
		
		private function decodeDefineFont():Tag //throws IOException
		{
			var t:DefineFont1;
			t = new DefineFont1();
			var id:int = r.readUI16();
			var offset:int = r.readUI16();
			var numGlyphs:int = offset/2;
			
			t.glyphShapeTable = new Vector.<Shape>(numGlyphs);
			
			// skip the offset table
			var i:int;
			for (i = 1; i < numGlyphs; i++)
			{
				r.readUI16();
			}
			
			for (i = 0; i < numGlyphs; i++)
			{
				t.glyphShapeTable[i] = decodeShape(stagDefineShape3);
			}
			
			dict.add(id, t);
			dict.addFontFace( t );
			return t;
		}
		
		private function decodeSetBackgroundColor():Tag //throws IOException
		{
			var t:SetBackgroundColor;
			t = new SetBackgroundColor( decodeRGB(r));
			return t;
		}
		
		/**
		 * decode jpeg tables.  only one per movie.  second and subsequent
		 * occurences of this tag are ignored by the player.
		 * @param length
		 * @return
		 * @throws IOException
		 */
		private function decodeJPEGTables(length:int):GenericTag //throws IOException
		{
			var t:GenericTag;
			t = new GenericTag(stagJPEGTables);
			t.data = new ByteArray();//length
			t.data.length = length;
			r.readFully(t.data);
			return t;
		}
		
		public function decodeDefineButton(length:int):Tag // throws IOException
		{
			var startPos:int = r.getOffset();
			var t:DefineButton;
			t = new DefineButton(stagDefineButton);
			var id:int = r.readUI16();
			
			//ArrayList<ButtonRecord> list = new ArrayList<ButtonRecord>();
			var list:Vector.<ButtonRecord> = new Vector.<ButtonRecord>();
			var record:ButtonRecord;
			do
			{
				record = decodeButtonRecord(t.code);
				if (record != null)
				{
					list.push(record);
				}
			}
			while (record != null);
			
			t.buttonRecords = new Vector.<ButtonRecord>(list.length);
			//list.toArray(t.buttonRecords);
			
			// old school button actions only handle one possible transition
			var consumed:int = r.getOffset()-startPos;
			t.condActions = new Vector.<ButtonCondAction>(1);
			t.condActions[0] = new ButtonCondAction();
			t.condActions[0].overDownToOverUp = true;
			var actionDecoder:ActionDecoder = new ActionDecoder(r,null);
			actionDecoder.setKeepOffsets(keepOffsets);
			t.condActions[0].actionList = actionDecoder.decode(length-consumed);
			t.trackAsMenu = false;
			
			//Added by SWF Investigator
			t.id = id;
			//dict[id] = t;
			dict.add(id,t);
			return t;
		}

		
		public function decodeDefineButton2(length:int):Tag //throws IOException
		{
			var endpos:int = r.getOffset()+length;
			//var endpos:int = offset+length;
			var t:DefineButton = new DefineButton(stagDefineButton2);
			
			var id:int = r.readUI16();
			
			r.syncBits();
			r.readUBits(7); // reserved
			t.trackAsMenu = r.readBit();
			
			var actionOffset:int = r.readUI16();
			
			// read button data
			//ArrayList<Object> list = new ArrayList<Object>(5);
			var list:Vector.<ButtonRecord> = new Vector.<ButtonRecord>;
			var record:ButtonRecord;
			while ((record = decodeButtonRecord(t.code)) != null)
			{
				list.push(record);
			}
			
			//t.buttonRecords = new Vector.<ButtonRecord>(list.length);
			//list.toArray(t.buttonRecords);
			//list.clear();
			t.buttonRecords = list;
			
			if (actionOffset > 0)
			{
				//list = new ArrayList<Object>();
				var list2:Vector.<ButtonCondAction> = new Vector.<ButtonCondAction>;
				
				var pos:int = r.getOffset();
				while ((actionOffset = r.readUI16()) > 0)
				{
					//list.add(decodeButtonCondAction(actionOffset-2));
					list2.push(decodeButtonCondAction(actionOffset-2));
					if (r.getOffset() != pos+actionOffset)
					{
						//throw new SwfFormatException("incorrect offset read in ButtonCondAction. read "+actionOffset+"");
						throw new SWFFormatError("incorrect offset read in ButtonCondAction. read "+actionOffset);
					}
					pos = r.getOffset();
				}
				// actionOffset == 0 means this will be the last record
				//list.add(decodeButtonCondAction(endpos-r.getOffset()));
				list2.push(decodeButtonCondAction(endpos-r.getOffset()));
				
				//t.condActions = new ButtonCondAction[list.size()];
				//list.toArray(t.condActions);
				t.condActions = list2;
			}
			else
			{
				t.condActions = new Vector.<ButtonCondAction>(0);
			}
			while (r.getOffset() < endpos)
			{
				var b:int = r.readUI8();
				if (b != 0)
				{
					//throw new SwfFormatException("nonzero data past end of DefineButton2");
					throw new SWFFormatError("nonzero data past end of DefineButton2");
				}
			}
			
			//dict.add(id, t);
			//Added by SWF Investigator
			t.id = id;
			dict.add(id,t);
			return t;
		}
		
		private function decodeButtonCondAction(length:int):ButtonCondAction // throws IOException
		{
			var a:ButtonCondAction = new ButtonCondAction();
			r.syncBits();
			a.keyPress = r.readUBits(7);
			a.overDownToIdle = r.readBit();
			
			a.idleToOverDown = r.readBit();
			a.outDownToIdle = r.readBit();
			a.outDownToOverDown = r.readBit();
			a.overDownToOutDown = r.readBit();
			a.overDownToOverUp = r.readBit();
			a.overUpToOverDown = r.readBit();
			a.overUpToIdle = r.readBit();
			a.idleToOverUp = r.readBit();
			
			//actionDecoder:ActionDecoder = new ActionDecoder(r,swd);
			var actionDecoder:ActionDecoder = new ActionDecoder(r,null);
			actionDecoder.setKeepOffsets(keepOffsets);
			a.actionList = actionDecoder.decode(length-2);
			
			return a;
		}
		
		private function decodeButtonRecord(type:int):ButtonRecord //throws IOException
		{
			var hasFilterList:Boolean = false, hasBlendMode:Boolean = false;
			var b:ButtonRecord = new ButtonRecord();
			
			r.syncBits();
			
			var reserved:int;
			if (type == stagDefineButton2)
			{
				reserved = r.readUBits(2);
				hasBlendMode = r.readBit();
				hasFilterList = r.readBit();
			}
			else
			{
				reserved = r.readUBits(4);
			}
			b.hitTest = r.readBit();
			b.down = r.readBit();
			b.over = r.readBit();
			b.up = r.readBit();
			
			if (reserved == 0 && !b.hitTest && !b.down && !b.over && !b.up)
			{
				return null;
			}
			
			var idref:int = r.readUI16();
			b.characterRef = dict.getTagByID(idref);
			b.placeDepth = r.readUI16();
			b.placeMatrix = decodeMatrix();
			
			if (type == stagDefineButton2)
			{
				b.colorTransform = decodeCxforma();
				if (hasFilterList)
				{
					b.filters = decodeFilterList();
				}
				if (hasBlendMode)
				{
					b.blendMode = r.readUI8();
				}
			}
			
			return b;
		}
		
		private function decodeFilterList():Vector.<Filter> // throws IOException
		{
			var filters:Vector.<Filter> = new Vector.<Filter>();
			var count:int = r.readUI8();
			for (var i:int = 0; i < count; ++i)
			{
				var filterID:int = r.readUI8();
				switch( filterID )
				{
					// NOTE: the filter decoding is pretty much just "save enough bits to regenerate", and ignores
					// the real formatting of the filters (i.e. fixed 8.8 types, etc.)  If you need the actual
					// values rather than just acting as a passthrough, you will need to enhance the types.
					
					case DropShadowFilter.ID:    filters.push( decodeDropShadowFilter() );    break;
					case BlurFilter.ID:          filters.push( decodeBlurFilter() );          break;
					case GlowFilter.ID:          filters.push( decodeGlowFilter() );          break;
					case BevelFilter.ID:         filters.push( decodeBevelFilter() );         break;
					case GradientGlowFilter.ID:  filters.push( decodeGradientGlowFilter() );  break;
					case ConvolutionFilter.ID:   filters.push( decodeConvolutionFilter() );   break;
					case ColorMatrixFilter.ID:   filters.push( decodeColorMatrixFilter() );   break;
					case GradientBevelFilter.ID: filters.push( decodeGradientBevelFilter() ); break;
				}
			}
			return filters;
		}
		
		
		private function decodeCxforma():CXFormWithAlpha // throws IOException
		{
			var c:CXFormWithAlpha = new CXFormWithAlpha();
			r.syncBits();
			c.hasAdd = r.readBit();
			c.hasMult = r.readBit();
			var nbits:int = r.readUBits(4);
			if (c.hasMult)
			{
				c.redMultTerm = r.readSBits(nbits);
				c.greenMultTerm = r.readSBits(nbits);
				c.blueMultTerm = r.readSBits(nbits);
				c.alphaMultTerm = r.readSBits(nbits);
			}
			if (c.hasAdd)
			{
				c.redAddTerm = r.readSBits(nbits);
				c.greenAddTerm = r.readSBits(nbits);
				c.blueAddTerm = r.readSBits(nbits);
				c.alphaAddTerm = r.readSBits(nbits);
			}
			return c;
		}
		
		private function decodeDefineBinaryData(length:int):Tag //throws IOException
		{
			var t:DefineBinaryData = new DefineBinaryData();
			var pos:uint = r.getOffset();
			var id:int = r.readUI16();
			t.reserved = r.readSI32();
			length -= r.getOffset() - pos;
			t.data = new ByteArray(); //length
			t.data.length = length;
			r.readFully(t.data);
			dict.add(id, t);
			return t;
		}
		
		private function decodeDefineBits(length:int):Tag //throws IOException
		{
			var t:DefineBits;
			t = new DefineBits(stagDefineBits);
			var pos:uint = r.getOffset();
			var id:int = r.readUI16();
			length -= r.getOffset() - pos;
			t.data = new ByteArray(); //length
			t.data.length = length;
			r.readFully(t.data);
			t.jpegTables = jpegTables;
			dict.add(id, t);
			return t;
		}
		
		private function decodeRemoveObject(code:int):Tag// throws IOException
		{
			var t:RemoveObject;
			t = new RemoveObject(code);
			if (code == stagRemoveObject)
			{
				var idref:int = r.readUI16();
				t.ref = dict.getTagByID(idref);
			}
			t.depth = r.readUI16();
			return t;
		}

		
		private function decodeCxform():CXForm //throws IOException
		{
			var c:CXForm = new CXForm();
			r.syncBits();
			
			c.hasAdd = r.readBit();
			c.hasMult = r.readBit();
			var nbits:int = r.readUBits(4);
			if (c.hasMult)
			{
				c.redMultTerm = r.readSBits(nbits);
				c.greenMultTerm = r.readSBits(nbits);
				c.blueMultTerm = r.readSBits(nbits);
			}
			if (c.hasAdd)
			{
				c.redAddTerm = r.readSBits(nbits);
				c.greenAddTerm = r.readSBits(nbits);
				c.blueAddTerm = r.readSBits(nbits);
			}
			return c;
		}
		
		private function decodeMetadata():Tag  //throws IOException
		{
			var t:Metadata = new Metadata();
			t.xml = r.readString();
			return t;
		}
		
		private function decodeDefineShape(shape:int):Tag //throws IOException
		{
			var t:DefineShape = new DefineShape(shape);
			
			var id:int = r.readUI16();
			t.bounds = decodeRect();
			if (shape == stagDefineShape4)
			{
				t.edgeBounds = decodeRect();
				r.readUBits(5);
				t.usesFillWindingRule = r.readBit();
				t.usesNonScalingStrokes = r.readBit();
				t.usesScalingStrokes = r.readBit();
			}
			t.shapeWithStyle = decodeShapeWithStyle(shape);
			
			dict.add(id, t);
			return t;
		}
		
		private function decodeShapeWithStyle(shape:int):ShapeWithStyle //throws IOException
		{
			var sw:ShapeWithStyle = new ShapeWithStyle();
			
			r.syncBits();
			
			sw.fillstyles = decodeFillstyles(shape);
			sw.linestyles = decodeLinestyles(shape);
			
			var s:Shape = decodeShape(shape);
			
			sw.shapeRecords = s.shapeRecords;
			
			return sw;
		}
		
		private function decodeLinestyles(shape:int):Vector.<LineStyle> //throws IOException
		{
			//ArrayList<LineStyle> a = new ArrayList<LineStyle>();
			var a:Vector.<LineStyle> = new Vector.<LineStyle>();
			
			var count:int = r.readUI8();
			if (count == 0xFF)
			{
				count = r.readUI16();
			}
			
			for (var i:int = 0; i < count; i++)
			{
				a.push(decodeLineStyle(shape));
			}
			
			return a;
		}

		
		private function decodeLineStyle(shape:int):LineStyle //throws IOException
		{
			var s:LineStyle = new LineStyle();
			s.width = r.readUI16();
			
			if (shape == stagDefineShape4)
			{
				s.flags = r.readUI16();
				if (s.hasMiterJoint())
					s.miterLimit = r.readUI16();    // 8.8 fixedpoint
			}
			if ((shape == stagDefineShape4) && (s.hasFillStyle()))
			{
				s.fillStyle = decodeFillStyle(shape);
			}
			else if ((shape == stagDefineShape3) || (shape == stagDefineShape4))
			{
				s.color = decodeRGBA(r);
			}
			else
			{
				s.color = decodeRGB(r);
			}
			
			return s;
		}
		
		private function decodeFillstyles(shape:int):Vector.<FillStyle> //throws IOException
		{
			//ArrayList<FillStyle> a = new ArrayList<FillStyle>();
			var a:Vector.<FillStyle> = new Vector.<FillStyle>();
			
			var count:int = r.readUI8();
			if (count == 0xFF)
			{
				count = r.readUI16();
			}
			
			for (var i:int = 0; i < count; i++)
			{
				a.push(decodeFillStyle(shape));
			}
			
			return a;
		}
		
		private function decodeFillStyle(shape:int):FillStyle //throws IOException
		{
			var s:FillStyle = new FillStyle();
			
			s.type = r.readUI8();
			switch (s.type)
			{
				case FillStyle.FILL_SOLID: // 0x00
					if (shape == stagDefineShape3 || shape == stagDefineShape4)
						s.color = decodeRGBA(r);
					else if (shape == stagDefineShape2 || shape == stagDefineShape)
						s.color = decodeRGB(r);
					else
						throw new SWFFormatError("bad shape code");
					break;
				case FillStyle.FILL_GRADIENT: // 0x10 linear gradient fill
				case FillStyle.FILL_RADIAL_GRADIENT: // 0x12 radial gradient fill
				case FillStyle.FILL_FOCAL_RADIAL_GRADIENT: // 0x13 focal radial gradient fill
					s.matrix = decodeMatrix();
					s.gradient = decodeGradient(shape, s.type);
					break;
				case FillStyle.FILL_BITS: // 0x40 tiled bitmap fill
				case (FillStyle.FILL_BITS | FillStyle.FILL_BITS_CLIP): // 0x41 clipped bitmap fill
				case (FillStyle.FILL_BITS | FillStyle.FILL_BITS_NOSMOOTH): // 0x42 tiled non-smoothed fill
				case (FillStyle.FILL_BITS | FillStyle.FILL_BITS_CLIP | FillStyle.FILL_BITS_NOSMOOTH): // 0x43 clipped non-smoothed fill
					var idref:int = r.readUI16();
					try
					{
						s.bitmap = dict.getTagByID(idref);
					}
					//catch (IllegalArgumentException)
					catch (e:Error)
					{
						s.bitmap = null;
						//handler.error(t,e.getMessage());
						handler.error(null,e.message);
					}
					s.matrix = decodeMatrix();
					break;
				default:
					throw new SWFFormatError("unrecognized fill style type: " + s.type);
			}
			
			return s;
		}
		
		private function decodeProtect(length:int):Tag// throws IOException
		{
			var t:GenericTag;
			t = new GenericTag(stagProtect);
			t.data = new ByteArray(); //length
			r.readFully(t.data);
			return t;
		}
		
		private function decodeDefineButtonCxform():Tag //throws IOException
		{
			var t:DefineButtonCxform;
			t = new DefineButtonCxform();
			var idref:int = r.readUI16();
			t.button = dict.getTagByID(idref) as DefineButton;
			if (t.button.cxform != null)
			{
				handler.error(t,"button " + dict.getId(t.button) + " cxform redefined");
			}
			t.button.cxform = t;
			t.colorTransform = decodeCxform();
			return t;
		}
		
		private function decodeDefineJPEG2(length:int):Tag //throws IOException
		{
			var t:DefineBits = new DefineBits(stagDefineBitsJPEG2);
			var pos:int = r.getOffset();
			var id:int = r.readUI16();
			length -= r.getOffset() - pos;
			t.data = new ByteArray();
			t.data.length = length;
			r.readFully(t.data);
			
			dict.add(id, t);
			return t;
		}
		
		private function decodeDefineBitsLossless(length:int):Tag// throws IOException
		{
			var t:DefineBitsLossless = new DefineBitsLossless(stagDefineBitsLossless);
			var r1:Swf = r;
			
			var pos:int = r1.getOffset();
			
			var id:int = r1.readUI16();
			t.format = r1.readUI8();
			t.width = r1.readUI16();
			t.height = r1.readUI16();
			
			var data:ByteArray;
			
			switch (t.format)
			{
				case 3:
					var tableSize:int = r1.readUI8() + 1;
					length -= r1.getOffset() - pos;
					data = new ByteArray(); //length
					data.length = length;
					//data.position = 0;
					r1.readFully(data);
					data.position =0;
					data.uncompress();
					//r1 = new SwfDecoder(new InflaterInputStream(new ByteArrayInputStream(data)), getSwfVersion());
					r1 = new Swf(data,null,false, true);
					decodeColorMapData(r1, t, tableSize);
					break;
				case 4:
				case 5:
					length -= r1.getOffset() - pos;
					data = new ByteArray(); //length
					data.length = length;
					//data.position = 0;
					r1.readFully(data);
					data.position = 0;
					data.uncompress();
					//r1 = new SwfDecoder(new InflaterInputStream(new ByteArrayInputStream(data)), getSwfVersion());
					r1 = new Swf(data,null,false, true);
					//t.data = new byte[t.width * t.height * 4];
					t.data = new ByteArray();
					t.data.length = t.width * t.height * 4;
					//t.data.position = 0;
					r1.readFully(t.data);
					break;
				default:
					throw new SWFFormatError("Illegal bitmap format " + t.format);
			}
			
			dict.add(id, t);
			return t;
		}
		
		private function decodeColorMapData(r1:Swf, tag:DefineBitsLossless, tableSize:int):void //throws IOException
		{
			//tag.colorData = new int[tableSize];
			tag.colorData = new Vector.<int>(tableSize);
			
			for (var i:int = 0; i < tableSize; i++)
			{
				tag.colorData[i] = decodeRGB(r1);
			}
			
			var width:int = tag.width;
			var height:int = tag.height;
			
			if (width % 4 != 0)
			{
				width = (width / 4 + 1) * 4;
			}
			
			//tag.data = new byte[width * height];
			tag.data = new ByteArray();
			tag.data.length = width & height;
			//tag.data.position = 0;
			
			r1.readFully(tag.data);
		}
		
		private function decodeSoundStreamBlock(length:int):Tag //throws IOException
		{
			var t:GenericTag = new GenericTag(stagSoundStreamBlock);
			//t.data = new byte[length];
			t.data = new ByteArray();
			t.data.length = length;
			r.readFully(t.data);
			return t;
		}
		
		private function decodeSoundStreamHead(code:int):Tag // throws IOException
		{
			var t:SoundStreamHead;
			t = new SoundStreamHead(code);
			r.syncBits();
			
			// mixFormat
			r.readUBits(4); // reserved
			t.playbackRate = r.readUBits(2);
			t.playbackSize = r.readUBits(1);
			t.playbackType = r.readUBits(1);
			
			// format
			t.compression = r.readUBits(4);
			t.streamRate = r.readUBits(2);
			t.streamSize = r.readUBits(1);
			t.streamType = r.readUBits(1);
			
			t.streamSampleCount = r.readUI16();
			
			if (t.compression == SoundStreamHead.sndCompressMP3)
			{
				t.latencySeek = r.readSI16();
			}
			return t;
		}

		private function decodeDefineButtonSound():Tag // throws IOException
		{
			var t:DefineButtonSound;
			t = new DefineButtonSound();
			var idref:int = r.readUI16();
			t.button = dict.getTagByID(idref) as DefineButton;
			if (t.button.sounds != null)
			{
				handler.error(t,"button " + idref + " sound redefined");
			}
			t.button.sounds = t;
			
			idref = r.readUI16();
			if (idref != 0)
			{
				t.sound0 = dict.getTagByID(idref);
				t.info0 = decodeSoundInfo();
			}
			idref = r.readUI16();
			if (idref != 0)
			{
				t.sound1 = dict.getTagByID(idref);
				t.info1 = decodeSoundInfo();
			}
			idref = r.readUI16();
			if (idref != 0)
			{
				t.sound2 = dict.getTagByID(idref);
				t.info2 = decodeSoundInfo();
			}
			idref = r.readUI16();
			if (idref != 0)
			{
				t.sound3 = dict.getTagByID(idref);
				t.info3 = decodeSoundInfo();
			}
			return t;
		}
		
		private function decodeStartSound():Tag // throws IOException
		{
			var t:StartSound;
			t = new StartSound();
			var idref:int = r.readUI16();
			t.sound = dict.getTagByID(idref) as DefineSound;
			t.soundInfo = decodeSoundInfo();
			return t;
		}
		
		private function decodeStartSound2():Tag // throws IOException
		{
			var t:StartSound2;
			t = new StartSound2();
			t.soundClassName = r.readString();
			t.soundInfo = decodeSoundInfo();
			return t;
		}
		
		private function decodeSoundInfo():SoundInfo // throws IOException
		{
			var i:SoundInfo = new SoundInfo();
			
			r.syncBits();
			
			r.readUBits(2); // reserved
			i.syncStop = r.readBit();
			i.syncNoMultiple = r.readBit();
			
			var hasEnvelope:Boolean = r.readBit();
			var hasLoops:Boolean = r.readBit();
			var hasOutPoint:Boolean = r.readBit();
			var hasInPoint:Boolean = r.readBit();
			
			if (hasInPoint)
			{
				i.inPoint = r.readUI32();
			}
			if (hasOutPoint)
			{
				i.outPoint = r.readUI32();
			}
			if (hasLoops)
			{
				i.loopCount = r.readUI16();
			}
			if (hasEnvelope)
			{
				var points:int = r.readUI8();
				i.records = new Vector.<Number>(points);
				for (var k:int = 0; k < points; k++)
				{
					i.records[k] = r.read64();
				}
			}
			
			return i;
		}
		
		private function decodeDefineSound(length:int):Tag // throws IOException
		{
			var t:DefineSound;
			t = new DefineSound();
			var pos:int = r.getOffset();
			
			var id:int = r.readUI16();
			
			r.syncBits();
			
			t.format = r.readUBits(4);
			t.rate = r.readUBits(2);
			t.soundSize = r.readUBits(1);
			t.soundType = r.readUBits(1);
			t.sampleCount = r.readUI32();
			
			length -= r.getOffset() - pos;
			
			t.data = new ByteArray();
			t.data.length = length;
			r.readFully(t.data);
			
			dict.add(id, t);
			return t;
		}
		
		private function decodeDropShadowFilter():DropShadowFilter //throws IOException
		{
			var f:DropShadowFilter = new DropShadowFilter();
			f.color = decodeRGBA( r );
			f.blurX = r.readSI32();
			f.blurY = r.readSI32();
			f.angle = r.readSI32();
			f.distance = r.readSI32();
			f.strength = r.readUI16();  // really fixed8
			f.flags = r.readUI8();
			return f;
		}
		private function decodeBlurFilter():BlurFilter // throws IOException
		{
			var f:BlurFilter = new BlurFilter();
			f.blurX = r.readSI32(); // FIXED
			f.blurY = r.readSI32();
			f.passes = r.readUI8();
			return f;
		}
		
		private function decodeGlowFilter():GlowFilter //throws IOException
		{
			var f:GlowFilter = new GlowFilter();
			f.color = decodeRGBA( r );
			f.blurX = r.readSI32();
			f.blurY = r.readSI32();
			f.strength = r.readUI16();          // fixed 8.8
			f.flags = r.readUI8();  // bunch of fields
			return f;
		}
		
		private function decodeBevelFilter():BevelFilter //throws IOException
		{
			var f:BevelFilter = new BevelFilter();
			f.highlightColor = decodeRGBA(r);
			f.shadowColor = decodeRGBA(r);
			f.blurX = r.readSI32();
			f.blurY = r.readSI32();
			f.angle = r.readSI32();
			f.distance = r.readSI32();
			f.strength = r.readUI16();  // fixed 8.8
			f.flags = r.readUI8();  // bunch of fields
			return f;
		}
		
		private function decodeGradientGlowFilter():GradientGlowFilter // throws IOException
		{
			var f:GradientGlowFilter  = new GradientGlowFilter();
			f.numcolors = r.readUI8();
			f.gradientColors = new Vector.<int>(f.numcolors);
			var i:int;
			for (i = 0; i < f.numcolors; ++i)
				f.gradientColors[i] = decodeRGBA( r );
			f.gradientRatio = new Vector.<int>(f.numcolors);
			for (i = 0; i < f.numcolors; ++i)
				f.gradientRatio[i] = r.readUI8();
			//        f.color = decodeRGBA( r );
			f.blurX = r.readSI32();
			f.blurY = r.readSI32();
			f.angle = r.readSI32();
			f.distance = r.readSI32();
			f.strength = r.readUI16();  // fixed 8.8
			f.flags = r.readUI8();  // bunch of fields
			
			return f;
		}
		
		private function decodeConvolutionFilter():ConvolutionFilter //throws IOException
		{
			var f:ConvolutionFilter = new ConvolutionFilter();
			f.matrixX = r.readUI8();
			f.matrixY = r.readUI8();
			f.divisor = r.readFloat();
			f.bias = r.readFloat();
			f.matrix = new Vector.<Number>(f.matrixX*f.matrixY);
			for (var i:int = 0; i <f.matrixX*f.matrixY; ++i)
				f.matrix[i] = r.readFloat();
			f.color = decodeRGBA( r );
			f.flags = r.readUI8();
			return f;
		}
		
		private function decodeColorMatrixFilter():ColorMatrixFilter //throws IOException
		{
			var f:ColorMatrixFilter = new ColorMatrixFilter();
			
			for (var i:int = 0; i < 20; ++i)
			{
				f.values[i] = r.readFloat();
			}
			return f;
		}
		
		private function decodeGradientBevelFilter():GradientBevelFilter // throws IOException
		{
			var f:GradientBevelFilter = new GradientBevelFilter();
			f.numcolors = r.readUI8();
			f.gradientColors = new Vector.<int>(f.numcolors);
			var i:int;
			for (i = 0; i < f.numcolors; ++i)
				f.gradientColors[i] = decodeRGBA( r );
			f.gradientRatio = new Vector.<int>(f.numcolors);
			for (i = 0; i < f.numcolors; ++i)
				f.gradientRatio[i] = r.readUI8();
			//        f.shadowColor = decodeRGBA( r );
			//        f.highlightColor = decodeRGBA( r );
			f.blurX = r.readSI32();
			f.blurY = r.readSI32();
			f.angle = r.readSI32();
			f.distance = r.readSI32();
			f.strength = r.readUI16();
			f.flags = r.readUI8();
			
			return f;
			
		}
		
		private function decodeGradient(shape:int, filltype:int):Gradient //throws IOException
		{
			var gradient:Gradient = (filltype == FillStyle.FILL_FOCAL_RADIAL_GRADIENT)? new FocalGradient() : new Gradient();
			r.syncBits();
			gradient.spreadMode = r.readUBits( 2 );
			gradient.interpolationMode = r.readUBits( 2 );
			var count:int = r.readUBits( 4 );
			gradient.records = new Vector.<GradRecord>(count);
			
			for (var i:int = 0; i < count; i++)
			{
				gradient.records[i] = decodeGradRecord(shape);
			}
			
			if (filltype == FillStyle.FILL_FOCAL_RADIAL_GRADIENT)
			{
				(gradient as FocalGradient).focalPoint = r.readFixed8();
			}
			
			return gradient;
		}
		
		private function decodeGradRecord(shape:int):GradRecord //throws IOException
		{
			var g:GradRecord = new GradRecord();
			g.ratio = r.readUI8();
			
			switch (shape)
			{
				case stagDefineShape:
				case stagDefineShape2:
					g.color = decodeRGB(r);
					break;
				case stagDefineShape3:
				case stagDefineShape4:
					g.color = decodeRGBA(r);
					break;
			}
			
			return g;
		}
		
		private function decodeMatrix():Matrix // throws IOException
		{
			var m:Matrix = new Matrix();
			
			r.syncBits();
			m.hasScale = r.readBit();
			if (m.hasScale)
			{
				var nScaleBits:int = r.readUBits(5);
				m.scaleX = r.readSBits(nScaleBits);
				m.scaleY = r.readSBits(nScaleBits);
			}
			
			m.hasRotate = r.readBit();
			if (m.hasRotate)
			{
				var nRotateBits:int = r.readUBits(5);
				m.rotateSkew0 = r.readSBits(nRotateBits);
				m.rotateSkew1 = r.readSBits(nRotateBits);
			}
			
			var nTranslateBits:int = r.readUBits(5);
			m.translateX = r.readSBits(nTranslateBits);
			m.translateY = r.readSBits(nTranslateBits);
			
			return m;
		}
		
		private function decodeRGBA(r:Swf):int// throws IOException
		{
			var color:int = r.readUI8() << 16; // red
			color |= r.readUI8() << 8; // green
			color |= r.readUI8(); // blue
			color |= r.readUI8() << 24; // alpha
			
			// resulting format is 0xAARRGGBB
			return color;
		}
		
		private function decodeRGB(r:Swf):int // throws IOException
		{
			var color:int = r.readUI8() << 16; // red
			color |= r.readUI8()<<8; // green
			color |= r.readUI8(); // blue
			
			// resulting format is 0x00RRGGBB
			return color;
		}
		
		private function decodeGlyph(shape:int, count:int):Shape //throws IOException
		{
			var s1:Shape = new Shape();
			
			r.syncBits();
			
			// SDK-18153 - Hack to work around third-party generated SWFs that
			// do not include at least one shape record in glyph SHAPE.
			if (count > 0)
			{
				// we use int[1] so we can pass numBits by reference
				//int[] numFillBits = new int[] { r.readUBits(4) };
				//int[] numLineBits = new int[] { r.readUBits(4) };
				var numFillBits:Vector.<int> = new Vector.<int>;
				var numLineBits:Vector.<int> = new Vector.<int>;
				numFillBits.push(r.readUBits(4));
				numLineBits.push(r.readUBits(4))
				
				if (count > 1)
				{
					s1.shapeRecords = decodeShapeRecords(shape, numFillBits, numLineBits);
				}
			}
			
			return s1;
		}
		
		private function decodeShape(shape:int):Shape //throws IOException
		{
			var s1:Shape = new Shape();
			
			r.syncBits();
			
			// we use int[1] so we can pass numBits by reference
			var numFillBits:Vector.<int> = new Vector.<int>;
			var numLineBits:Vector.<int> = new Vector.<int>;
			numFillBits.push(r.readUBits(4));
			numLineBits.push(r.readUBits(4));
			//int[] numFillBits = new int[] { r.readUBits(4) };
			//int[] numLineBits = new int[] { r.readUBits(4) };
			
			s1.shapeRecords = decodeShapeRecords(shape, numFillBits, numLineBits);
			
			return s1;
		}

		private function decodeShapeRecords(shape:int, numFillBits:Vector.<int>, numLineBits:Vector.<int>):Vector.<ShapeRecord> //throws IOException
		{
			var list:Vector.<ShapeRecord> = new Vector.<ShapeRecord>();
			var endShapeRecord:Boolean = false;
			do
			{
				if (r.readBit())
				{
					// edge
					if (r.readBit())
					{
						// line
						list.push(decodeStraightEdgeRecord());
					}
					else
					{
						// curve
						list.push(decodeCurvedEdgeRecord());
					}
				}
				else
				{
					// style change
					var stateNewStyles:Boolean = r.readBit();
					var stateLineStyle:Boolean = r.readBit();
					var stateFillStyle1:Boolean = r.readBit();
					var stateFillStyle0:Boolean = r.readBit();
					var stateMoveTo:Boolean = r.readBit();
					
					if (stateNewStyles || stateLineStyle || stateFillStyle1 ||
						stateFillStyle0 || stateMoveTo)
					{
						var s:StyleChangeRecord = decodeStyleChangeRecord(stateNewStyles, stateLineStyle,
							stateFillStyle1, stateFillStyle0, stateMoveTo,
							shape, numFillBits, numLineBits);
						
						list.push(s);
					}
					else
					{
						endShapeRecord = true;
					}
				}
			}
			while (!endShapeRecord);
			
			return list;
		}
		
		private function decodeCurvedEdgeRecord():CurvedEdgeRecord //throws IOException
		{
			var s:CurvedEdgeRecord = new CurvedEdgeRecord();
			var nbits:int = 2+r.readUBits(4);
			s.controlDeltaX = r.readSBits(nbits);
			s.controlDeltaY = r.readSBits(nbits);
			s.anchorDeltaX = r.readSBits(nbits);
			s.anchorDeltaY = r.readSBits(nbits);
			return s;
		}
		
		private function decodeStraightEdgeRecord():StraightEdgeRecord //throws IOException
		{
			var nbits:int = 2 + r.readUBits(4);
			var dx:int, dy:int;
			
			if (r.readBit())
			{
				// general line
				dx = r.readSBits(nbits);
				dy = r.readSBits(nbits);
				return new StraightEdgeRecord(dx, dy);
			}
			else
			{
				if (r.readBit())
				{
					// vertical
					dy = r.readSBits(nbits);
					return new StraightEdgeRecord(0, dy);
				}
				else
				{
					// horizontal
					dx = r.readSBits(nbits);
					return new StraightEdgeRecord(dx, 0);
				}
			}
		}
		
		private function decodeStyleChangeRecord(stateNewStyles:Boolean,
			stateLineStyle:Boolean,
			stateFillStyle1:Boolean,
			stateFillStyle0:Boolean,
			stateMoveTo:Boolean,
			shape:int,
			numFillBits:Vector.<int>,
			numLineBits:Vector.<int>):StyleChangeRecord //throws IOException
		{
			var s:StyleChangeRecord = new StyleChangeRecord();
			
			s.stateNewStyles = stateNewStyles;
			s.stateLineStyle = stateLineStyle;
			s.stateFillStyle1 = stateFillStyle1;
			s.stateFillStyle0 = stateFillStyle0;
			s.stateMoveTo = stateMoveTo;
			
			if (s.stateMoveTo)
			{
				var moveBits:int = r.readUBits(5);
				s.moveDeltaX = r.readSBits(moveBits);
				s.moveDeltaY = r.readSBits(moveBits);
			}
			
			if (s.stateFillStyle0)
			{
				s.fillstyle0 = r.readUBits(numFillBits[0]);
			}
			
			if (s.stateFillStyle1)
			{
				s.fillstyle1 = r.readUBits(numFillBits[0]);
			}
			
			if (s.stateLineStyle)
			{
				s.linestyle = r.readUBits(numLineBits[0]);
			}
			
			if (s.stateNewStyles)
			{
				s.fillstyles = decodeFillstyles(shape);
				s.linestyles = decodeLinestyles(shape);
				
				r.syncBits();
				
				numFillBits[0] = r.readUBits(4);
				numLineBits[0] = r.readUBits(4);
			}
			return s;
		}
		
		private function decodeDefineSprite(endpos:int):Tag //throws IOException
		{
			var t:DefineSprite = new DefineSprite();
			t.header = header;
			var id:int = r.readUI16();
			t.framecount = r.readUI16();
			decodeTags(t.tagList);
			while (r.getOffset() < endpos)
			{
				// extra data at end of sprite.  must be zero
				var b:int = r.readUI8();
				if (b != 0)
				{
					throw new SWFFormatError ("nonzero data past end of sprite");
				}
			}
			//Si change for dict.add
			//t.name = id.toString();
			dict.add(id, t);
			return t;
		}
		
		public function decodeSerialNumber():Tag // throws IOException
		{
			var product:int = r.readSI32();
			var edition:int = r.readSI32();
			
			var version:ByteArray = new ByteArray();//length 2
			version.length = 2;
			r.read(version);
			var majorVersion:uint = version[0];
			var minorVersion:uint = version[1];
			
			var build:Number = r.read64();
			var compileDate:Number = r.read64();
			
			return new ProductInfo(product, edition, majorVersion, minorVersion, build, compileDate);
		}
		
		private function decodeHeader():Header //throws IOException, FatalParseException
		{
			var header:Header = new Header();
			
			//Si - cheating :-)
			header.version = r.version;
			header.length = r.length;
			header.compressed = r.compressed;
			header.framecount = r.frameCount;
			header.rate = r.frameRate;
			header.size = r.rect;
			
			return header;
		}
		
		public function decodeFileAttributes():Tag //throws IOException
		{
			var tag:FileAttributes = new FileAttributes();
			r.syncBits();
			r.readUBits(1); //reserved
			tag.useDirectBlit = r.readBit();
			tag.useGPU = r.readBit();
			tag.hasMetadata = r.readBit();
			tag.actionScript3 = r.readBit();
			tag.suppressCrossDomainCaching = r.readBit();
			tag.swfRelativeUrls = r.readBit();
			tag.useNetwork = r.readBit();
			r.readUBits(24); //reserved
			return tag;
		}
		
		public function decodeDefineFontAlignZones():Tag //throws IOException
		{
			var zones:DefineFontAlignZones = new DefineFontAlignZones();
			var fontID:int = r.readUI16();
			zones.font = dict.getTagByID(fontID) as DefineFont3;
			zones.font.zones = zones;
			zones.csmTableHint = r.readUBits(2);
			r.readUBits(6);  // reserved
			zones.zoneTable = new Vector.<ZoneRecord>(zones.font.glyphShapeTable.length);
			for (var i:int = 0; i < zones.font.glyphShapeTable.length; i++)
			{
				var record:ZoneRecord = new ZoneRecord();
				zones.zoneTable[i] = record;
				record.numZoneData = r.readUI8();
				record.zoneData = new Vector.<Number>(record.numZoneData);
				for (var j:int = 0; j < record.numZoneData; j++)
				{
					record.zoneData[j] = r.readUI32();
				}
				record.zoneMask = r.readUI8();
			}
			return zones;
		}
		
		public function decodeCSMTextSettings():Tag// throws IOException
		{
			var tag:CSMTextSettings = new CSMTextSettings();
			var textID:int = r.readUI16();
			if (textID != 0)
			{
				tag.textReference = dict.getTagByID(textID);
				if (tag.textReference is DefineText)
				{
					(tag.textReference as DefineText).csmTextSettings = tag;
				}
				else if (tag.textReference is DefineEditText)
				{
					(tag.textReference as DefineEditText).csmTextSettings = tag;
				}
				else
				{
					handler.error(tag,"CSMTextSettings' textID must reference a valid DefineText or DefineEditText.  References " + tag.textReference);
				}
			}
			tag.styleFlagsUseSaffron = r.readUBits(2);
			tag.gridFitType = r.readUBits(3);
			r.readUBits(3); // reserved
			// FIXME: thickness/sharpness should be read in as 32 bit IEEE Single Precision format in little Endian
			tag.thickness = r.readUBits(32);
			tag.sharpness = r.readUBits(32);
			r.readUBits(8); // reserved
			return tag;
		}
		
		public function decodeDefineFontName():Tag //throws IOException
		{
			var tag:DefineFontName = new DefineFontName();
			var fontID:int = r.readUI16();
			tag.font = dict.getTagByID(fontID) as DefineFont;
			tag.font.license = tag;
			tag.fontName = r.readString();
			tag.copyright = r.readString();
			return tag;
		}
		
		private function decodeEnableTelemetry(length:uint):Tag
		{
			var tag:EnableTelemetry = new EnableTelemetry();
			r.syncBits();
			tag.reserved = r.readUBits(16); // read reserved value
			tag.passwordHash = new ByteArray();
			if (length > 2) {
				for (var i:int=0; i<32; i++) {
					tag.passwordHash.writeByte(r.readUI8());
				}
			}
			return(tag);
		}


		private function decodeRect():Rect // throws IOException
		{
			r.syncBits();
			
			var rect:Rect = new Rect();
			
			var nBits:int = r.readUBits(5);
			rect.xMin = r.readSBits(nBits);
			rect.xMax = r.readSBits(nBits);
			rect.yMin = r.readSBits(nBits);
			rect.yMax = r.readSBits(nBits);
			
			return rect;
		}
		
	}
}