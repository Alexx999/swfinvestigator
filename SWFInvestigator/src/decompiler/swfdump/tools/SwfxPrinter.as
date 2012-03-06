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

package decompiler.swfdump.tools
{
	import decompiler.Logging.ILog;
	import decompiler.Swf;
	import decompiler.swfdump.SWFDictionary;
	import decompiler.swfdump.TagHandler;
	import decompiler.swfdump.TagValues;
	import decompiler.swfdump.tags.*;
	import decompiler.swfdump.types.*;
	import decompiler.swfdump.util.SwfImageUtils.JPEG;
	import decompiler.tamarin.abcdump.Tag;
	
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import mx.utils.Base64Encoder;

	public class SwfxPrinter extends TagHandler
	{
		include '../../tamarin/abcdump/SWF_Constants.as';

		/**
		 * this value should get set after the header is parsed
		 */
		private var swfVersion:int = 0;
		
		private var abc:Boolean = false;
		private var showActions:Boolean = true;
		private var showOffset:Boolean = false;
		private var showByteCode:Boolean = false;
		private var showDebugSource:Boolean = false;
		private var glyphs:Boolean = true;
		public var external:Boolean = false;
		public var externalPrefix:String = null;
		private var externalDirectory:String = null;
		private var decompile:Boolean;
		private var defunc:Boolean;
		private var indentLength:int = 0;
		private var tabbedGlyphs:Boolean = false;
		private var out:ILog;
		private var dict:SWFDictionary;
		
		private static const digits:Array = new Array(
			'0', '1', '2', '3', '4', '5', '6', '7',
			'8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
		
		private function hexify(input:ByteArray):String
		{
			var output:String = new String;
			const hex:String = "0123456789abcdef";
			const length:int = input.length;
			for(var i:int = 0; i < length; i++) {
				output += hex.charAt((input[i] & 0xF0) >> 4);
				output += hex.charAt(input[i] & 0x0F);
			}
			return output;
		}
		
		private function outputBase64(input:ByteArray):void {
			var base64Enc:Base64Encoder = new Base64Encoder;
			base64Enc.encodeBytes(input);
			out.print(base64Enc.toString());
		}
		
		public function SwfxPrinter(out:ILog)
		{
			this.out = out;
		}
		
		private function printActions(list:ActionList):void
		{
			if (decompile)
			{
				/*
				AsNode node;
				try
				{
				node = new Decompiler(defunc).decompile(list);
				new PrettyPrinter(out, indent).list(node);
				return;
				}
				catch (Exception e)
				{
				indent();
				out.println("// error while decompiling.  falling back to disassembler");
				}
				*/
			}
			
			var disassembler:Disassembler = new Disassembler(out, null, "", showOffset, indentLength);
			if (showDebugSource)
			{
				disassembler.setShowDebugSource(showDebugSource);
				disassembler.setComment("// ");
			}
			list.visitAll(disassembler);
		}
		
		private function indent():void
		{
			for (var i:int = 0; i < indentLength; i++)
			{
				out.print("  ");
			}
		}
		
		
		public override function productInfo(productInfo:ProductInfo):void
		{
			open(productInfo);
			out.print(" product='" + productInfo.getProductString() + "'");
			out.print(" edition='" + productInfo.getEditionString() + "'");
			out.print(" version='" + productInfo.getMajorVersion() + "." + productInfo.getMinorVersion() + "'");
			out.print(" build='" + productInfo.getBuild() + "'");
			var d:Date = new Date(productInfo.getCompileDate());

			out.print(" compileDate='" + d.toUTCString() + "'");
			close();
		}
		
		public override function metadata(tag:Metadata):void
		{
			open(tag);
			end();
			indent();
			out.print(tag.xml + "\r");
			closeTag(tag);
		}
		
		public override function fileAttributes(tag:FileAttributes):void
		{
			open(tag);
			out.print(" useDirectBlit='" + tag.useDirectBlit + "'");
			out.print(" useGPU='" + tag.useGPU + "'");
			out.print(" hasMetadata='" + tag.hasMetadata + "'");
			out.print(" actionScript3='" + tag.actionScript3 + "'");
			out.print(" suppressCrossDomainCaching='" + tag.suppressCrossDomainCaching + "'");
			out.print(" swfRelativeUrls='" + tag.swfRelativeUrls + "'");
			out.print(" useNetwork='" + tag.useNetwork + "'");
			close();
		}
		
		public override function setDecoderDictionary(dict:SWFDictionary):void
		{
			this.dict = dict;
		}
		
		public override function setOffsetAndSize(offset:int, size:int):void
		{
			// Note: 'size' includes the size of the tag's header
			// so it is either length + 2 or length + 6.
			
			if (showOffset)
			{
				indent();
				out.print("<!--" +
					" offset=" + offset +
					" size=" + size +
					" -->\r");
			}
		}
		
		private function open(tag:Tag):void
		{
			indent();
			//out.print("<" + TagValues.names[tag.code]);
			out.print("<" + tagNames[tag.code]);
		}
		
		private function end():void
		{
			out.print(">\r");
			indentLength++;
		}
		
		private function openCDATA():void
		{
			indent();
			out.print("<![CDATA[\r");
			indentLength++;
		}
		
		private function closeCDATA():void
		{
			indentLength--;
			indent();
			out.print("]]>\r");
		}
		
		private function close():void
		{
			out.print("/>\r");
		}
		
		private function closeTag(tag:Tag):void
		{
			indentLength--;
			indent();
			//out.print("</" + TagValues.names[tag.code] + ">\r");
			out.print("</" + tagNames[tag.code] + ">\r");
		}
		
		//Modified by SWF Investigator to include the tag
		public override function error(tag:Tag,s:String):void
		{
			indent();
			out.print("<!-- error: " + s + " -->");
			if (tag != null) {
				tag.SIErrorMessage += s;
			}
		}
		
		public override function unknown(tag:GenericTag):void
		{
			indent();
			out.print("<!-- unknown tag=" + tag.code + " length=" +
				(tag.data != null ? tag.data.length : 0) + " -->");
		}
		
		public override function showFrame(tag:ShowFrame):void
		{
			open(tag);
			close();
		}
		
		public override function defineShape(tag:DefineShape):void
		{
			printDefineShape(tag, false);
		}
		
		private function printDefineShape(tag:DefineShape, alpha:Boolean):void
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			out.print(" bounds='" + tag.bounds + "'");
			if (tag.code == TagValues.stagDefineShape4)
			{
				out.print(" edgebounds='" + tag.edgeBounds + "'");
				out.print(" usesNonScalingStrokes='" + tag.usesNonScalingStrokes + "'");
				out.print(" usesScalingStrokes='" + tag.usesScalingStrokes + "'");
			}
			
			end();
			
			printShapeWithStyles(tag.shapeWithStyle, alpha);
			
			closeTag(tag);
		}
		
		private function id(tag:DefineTag):String
		{
			var id:int = dict.getId(tag);
			return id.toString();
			/*
			if (tag.name != null) {
				return tag.name;
			} else {
				return tag.getID().toString();
			}*/
		}
		
		/**
		 * @param rgb as an integer, 0x00RRGGBB
		 * @return string formatted as #RRGGBB
		 */
		public function printRGB(rgb:int):String
		{
			var b:String = new String();
			b += '#';
			var red:int = (rgb >> 16) & 255;
			b += digits[(red >> 4) & 15];
			b += digits[red & 15];
			var green:int = (rgb >> 8) & 255;
			b += digits[(green >> 4) & 15];
			b += digits[green & 15];
			var blue:int = rgb & 255;
			b += digits[(blue >> 4) & 15];
			b += digits[blue & 15];
			return b;
		}
		
		/**
		 * @param rgb as an integer, 0xAARRGGBB
		 * @return string formatted as #RRGGBBAA
		 */
		public function printRGBA(rgb:int):String
		{
			var b:String = new String();
			b += '#';
			var red:int = (rgb >> 16) & 255;
			b += digits[(red >> 4) & 15];
			b += digits[red & 15];
			var green:int = (rgb >> 8) & 255;
			b += digits[(green >> 4) & 15];
			b += digits[green & 15];
			var blue:int = rgb & 255;
			b += digits[(blue >> 4) & 15];
			b += digits[blue & 15];
			var alpha:int = (rgb >> 24) & 255;
			b += digits[(alpha >> 4) & 15];
			b += digits[alpha & 15];
			return b;
		}
		
		public override function placeObject(tag:PlaceObject):void
		{
			open(tag);
			out.print(" idref='" + idRef(tag.ref) + "'");
			out.print(" depth='" + tag.depth + "'");
			out.print(" matrix='" + tag.matrix + "'");
			if (tag.colorTransform != null)
				out.print(" colorXform='" + tag.colorTransform + "'");
			close();
		}
		
		public override function removeObject(tag:RemoveObject):void
		{
			open(tag);
			out.print(" idref='" + idRef(tag.ref) + "'");
			close();
		}
		
		
		public override function defineBits(tag:DefineBits):void
		{
			if (tag.jpegTables == null)
			{
				out.print("<!-- warning: no JPEG table tag found. -->\r");
			}
			
			open(tag);
			out.print(" id='" + id(tag) + "'");
			
			if (external)
			{
				/**
				String path = externalDirectory
					+ externalPrefix
					+ "image"
					+ dict.getId(tag)
					+ ".jpg";
				
				out.println(" src='" + path + "' />");
				try
				{
					FileOutputStream image = new FileOutputStream(path, false);
					SwfImageUtils.JPEG jpeg = new SwfImageUtils.JPEG(tag.jpegTables.data, tag.data);
					jpeg.write(image);
					image.close();
				}
				catch (IOException e)
				{
					out.println("<!-- error: unable to write external asset file " + path + "-->");
				}
				 */
				var fileName:String = this.externalPrefix + "-" + dict.getId(tag) + ".jpg";
				var outData:ByteArray = new ByteArray();
				var jpeg:JPEG = new JPEG(tag.jpegTables.data, tag.data);
				jpeg.write(outData);
				var fileRef:FileReference = new FileReference();
				//fileRef.save(tag.data,fileName);
				fileRef.save(outData,fileName);
				this.external = false;
			}
			//else
			//{
				out.print(" encoding='base64'");
				end();
				outputBase64(tag.data);
				closeTag(tag);
			//}
		}
		
		public override function defineButton(tag:DefineButton):void
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			end();
			if (showActions)
			{
				openCDATA();
				// todo print button records
				printActions(tag.condActions[0].actionList);
				closeCDATA();
			}
			else
			{
				out.print("<!-- " + tag.condActions[0].actionList.size() + " action(s) elided -->\r");
			}
			closeTag(tag);
		}
		
		public override function jpegTables(tag:GenericTag):void
		{
			open(tag);
			out.print(" encoding='base64'");
			end();
			outputBase64(tag.data);
			closeTag(tag);
		}
		
		public override function setBackgroundColor(tag:SetBackgroundColor):void
		{
			open(tag);
			out.print(" color='" + printRGB(tag.color) + "'");
			close();
		}
		
		public override function defineFont(tag:DefineFont1):void
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			end();
			
			if (glyphs)
			{
				for (var i:int = 0; i < tag.glyphShapeTable.length; i++)
				{
					indent();
					out.print("<glyph>\r");
					
					var shape:Shape = tag.glyphShapeTable[i];
					indentLength++;
					printShapeWithTabs(shape);
					indentLength--;
					
					indent();
					out.print("</glyph>\r");
				}
			}
			closeTag(tag);
		}
		
		public override function defineText(tag:DefineText):void
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			out.print(" bounds='" + tag.bounds + "'");
			out.print(" matrix='" + tag.matrix + "'");
			
			end();
			
			//Iterator it = tag.records.iterator();
			
			//while (it.hasNext())
			for (var i:int = 0; i < tag.records.length; i++)
			{
				var tr:TextRecord  = tag.records[i]; //(TextRecord)it.next();
				printTextRecord(tr, tag.code);
			}
			
			closeTag(tag);
		}
		
		public override function doAction(tag:DoAction):void
		{
			open(tag);
			end();
			
			if (showActions)
			{
				openCDATA();
				printActions(tag.actionList);
				closeCDATA();
			}
			else
			{
				out.print("<!-- " + tag.actionList.size() + " action(s) elided -->\r");
			}
			closeTag(tag);
		}
		
		
		
		public override function defineFontInfo(tag:DefineFontInfo):void
		{
			open(tag);
			out.print(" idref='" + idRef(tag.font) + "'");
			out.print(" ansi='" + tag.ansi + "'");
			out.print(" italic='" + tag.italic + "'");
			out.print(" bold='" + tag.bold + "'");
			out.print(" wideCodes='" + tag.wideCodes + "'");
			out.print(" langCold='" + tag.langCode + "'");
			out.print(" name='" + tag.name + "'");
			out.print(" shiftJIS='" + tag.shiftJIS + "'");
			end();
			indent();
			for (var i:int = 0; i < tag.codeTable.length; i++)
			{
				out.print(tag.codeTable.charCodeAt(i));
				if ((i + 1) % 16 == 0)
				{
					out.print('\r');
					indent();
				}
				else
				{
					out.print(' ');
				}
			}
			if (tag.codeTable.length % 16 != 0)
			{
				out.print('\r');
				indent();
			}
			closeTag(tag);
		}
		
		public override function defineSound(tag:DefineSound):void
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			out.print(" format='" + tag.format + "'");
			out.print(" rate='" + tag.rate + "'");
			out.print(" size='" + tag.size + "'");
			out.print(" type='" + tag.type + "'");
			out.print(" sampleCount='" + tag.sampleCount + "'");
			out.print(" soundDataSize='" + tag.data.length + "'");
			end();
			openCDATA();
			outputBase64(tag.data);
			closeCDATA();
			closeTag(tag);
		}
		
		public override function startSound(tag:StartSound):void
		{
			open(tag);
			out.print(" soundid='" + idRef(tag.sound) + "'");
			printSoundInfo(tag.soundInfo);
			closeTag(tag);
		}
		
		private function printSoundInfo(info:SoundInfo):void
		{
			out.print(" syncStop='" + info.syncStop + "'");
			out.print(" syncNoMultiple='" + info.syncNoMultiple + "'");
			if (info.inPoint != SoundInfo.UNINITIALIZED)
			{
				out.print(" inPoint='" + info.inPoint + "'");
			}
			if (info.outPoint != SoundInfo.UNINITIALIZED)
			{
				out.print(" outPoint='" + info.outPoint + "'");
			}
			if (info.loopCount != SoundInfo.UNINITIALIZED)
			{
				out.print(" loopCount='" + info.loopCount + "'");
			}
			end();
			if (info.records != null && info.records.length > 0)
			{
				openCDATA();
				for (var i:int = 0; i < info.records.length; i++)
				{
					out.print(info.records[i] + "\r");
				}
				closeCDATA();
			}
		}
		
		public override function defineButtonSound(tag:DefineButtonSound):void
		{
			open(tag);
			out.print(" buttonId='" + idRef(tag.button) + "'");
			close();
		}
		
		public override function soundStreamHead(tag:SoundStreamHead):void
		{
			open(tag);
			close();
		}
		
		public override function soundStreamBlock(tag:GenericTag):void
		{
			open(tag);
			close();
		}
		
		public override function defineBinaryData(tag:DefineBinaryData):void
		{
			open(tag);
			var i:int = parseInt(id(tag));
			out.print(" id='" + i + "'");
			if (dict.containsId(i)) {
				var s:String = dict.getName(i);
				if (s != null && s.length > 0) {
					out.print(" idrefName='" + s + "'");
				}
			}
			out.print(" length='" + tag.data.length + "' />\r" );
			if (external) {
				var fileName:String = this.externalPrefix + "-" + dict.getId(tag) + ".jpg";
				var fileRef:FileReference = new FileReference();
				fileRef.save(tag.data,fileName);
				this.external = false;
			}
		}
		
		public override function defineBitsLossless(tag:DefineBitsLossless):void
		{
		 	open(tag);
		 	out.print(" id='" + id(tag) + "' width='" + tag.width + "' height='" + tag.height + "'");
		 
		 	if (external)
		 	{
				/**
		 		var path:String = externalDirectory
		 		+ externalPrefix
		 		+ "image"
		 		+ dict.getId(tag)
		 		+ ".bitmap";
		 
		 		out.print(" src='" + path + "' />\r");
		 		try
		 		{
		 			FileOutputStream image = new FileOutputStream(path, false);
		 			image.write(tag.data);
		 			image.close();
		 		}
		 		catch (IOException e)
		 		{
		 			out.println("<!-- error: unable to write external asset file " + path + "-->");
		 		}
				 */
			 	var fileName:String = this.externalPrefix + "-" + dict.getId(tag) + ".bmp";
				var fileRef:FileReference = new FileReference();
				fileRef.save(tag.data,fileName);
				this.external = false;
		 	}
		 	//else
		 	//{
		 		out.print(" encoding='base64'");
		 		end();
		 		outputBase64(tag.data);
		 		closeTag(tag);
		 	//}
		}
		
		public function obfuscated(tag:DoAction):void {
			doAction(tag);
		}
		
		public override function defineBitsJPEG2(tag:DefineBits):void
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			
			if (external)
			{
				/**
				var path:String = externalDirectory
					+ externalPrefix
					+ "image"
					+ dict.getId(tag)
					+ ".jpg";
				
				out.print(" src='" + path + "' />\r");
				try
				{
					FileOutputStream image = new FileOutputStream(path, false);
					image.write(tag.data);
					image.close();
				}
				catch (IOException e)
				{
					out.println("<!-- error: unable to write external asset file " + path + "-->");
				}
				 */
				var fileName:String = this.externalPrefix + "-" + dict.getId(tag) + ".jpg";
				var fileRef:FileReference = new FileReference();
				fileRef.save(tag.data,fileName);
				this.external = false;
			}
			//else
			//{
				out.print(" encoding='base64'");
				end();
				outputBase64(tag.data);
				closeTag(tag);
			//}
		}
		
		public override function defineShape2(tag:DefineShape):void
		{
			printDefineShape(tag, false);
		}
		
		public override function defineButtonCxform(tag:DefineButtonCxform):void
		{
			open(tag);
			out.print(" buttonId='" + idRef(tag.button) + "'");
			close();
		}
		
		public override function protect(tag:GenericTag):void
		{
			open(tag);
			if (tag.data != null)
				out.print(" password='" + hexify(tag.data) + "'");
			close();
		}
		
		public override function placeObject2(tag:PlaceObject):void
		{
			placeObject23(tag);
		}
		
		public override function placeObject3(tag:PlaceObject):void
		{
			placeObject23(tag);
		}
		
		private function placeObject23(tag:PlaceObject):void
		{
			if (tag.hasCharID())
			{
				if (tag.ref.name != null)
				{
					indent();
					out.print("<!-- instance of " + tag.ref.name + " -->\r");
				}
			}
			
			open(tag);
			if (tag.hasClassName())
				out.print(" className='" + tag.className + "'");
			if (tag.hasImage())
				out.print(" hasImage='true' ");
			if (tag.hasCharID())
				//out.print (" Has idref ");
				out.print(" idref='" + idRef(tag.ref) + "'");
			if (tag.hasName())
				out.print(" name='" + tag.name + "'");
			out.print(" depth='" + tag.depth + "'");
			if (tag.hasClipDepth())
				out.print(" clipDepth='" + tag.clipDepth + "'");
			if (tag.hasCacheAsBitmap())
				out.print(" cacheAsBitmap='true'");
			if (tag.hasRatio())
				out.print(" ratio='" + tag.ratio + "'");
			if (tag.hasCxform())
				out.print(" cxform='" + tag.colorTransform + "'");
			if (tag.hasMatrix())
				out.print(" matrix='" + tag.matrix + "'");
			if (tag.hasBlendMode())
				out.print(" blendmode='" + tag.blendMode + "'");
			if (tag.hasFilterList())
			{
				// todo - pretty print this once we actually care
				out.print(" filters='");
				for each (var f:Filter in tag.filters)
				{
					out.print( f.getID() + " ");
				}
				out.print("'");
			}
			
			if (tag.hasClipAction())
			{
				end();
				
				openCDATA();
				for each (var record:ClipActionRecord in tag.clipActions.clipActionRecords)
				{
					indent();
					out.print("onClipEvent(" + printClipEventFlags(record.eventFlags) +
						(record.hasKeyPress() ? "<" + record.keyCode + ">" : "") +
						") {\r");
					indentLength++;
					if (showActions)
					{
						printActions(record.actionList);
					}
					else
					{
						indent();
						out.print("// " + record.actionList.size() + " action(s) elided\r");
					}
					indentLength--;
					indent();
					out.print("}\r");
				}
				closeCDATA();
				closeTag(tag);
			}
			else
			{
				close();
			}
		}
		
		public override function removeObject2(tag:RemoveObject):void
		{
			open(tag);
			out.print(" depth='" + tag.depth + "'");
			close();
		}
		
		public override function defineShape3(tag:DefineShape):void
		{
			printDefineShape(tag, true);
		}
		
		public override function defineShape4(tag:DefineShape):void
		{
			printDefineShape(tag, true);
		}
		
		private function printShapeWithStyles(shapes:ShapeWithStyle, alpha:Boolean):void
		{
			printFillStyles(shapes.fillstyles, alpha);
			printLineStyles(shapes.linestyles, alpha);
			printShape(shapes, alpha);
		}
		
		private function printMorphLineStyles(lineStyles:Vector.<MorphLineStyle>):void
		{
			for (var i:int = 0; i < lineStyles.length; i++)
			{
				var lineStyle:MorphLineStyle = lineStyles[i];
				indent();
				out.print("<linestyle ");
				out.print("startColor='" + printRGBA(lineStyle.startColor) + "' ");
				out.print("endColor='" + printRGBA(lineStyle.startColor) + "' ");
				out.print("startWidth='" + lineStyle.startWidth + "' ");
				out.print("endWidth='" + lineStyle.endWidth + "' ");
				out.print("/>\r");
			}
		}
		
		private function printLineStyles(linestyles:Vector.<LineStyle>, alpha:Boolean):void
		{
			//Iterator it = linestyles.iterator();
			//while (it.hasNext())
			for (var i:int = 0; i < linestyles.length; i++)
			{
				var lineStyle:LineStyle = linestyles[i]; //(LineStyle)it.next();
				indent();
				out.print("<linestyle ");
				var color:String = alpha ? printRGBA(lineStyle.color) : printRGB(lineStyle.color);
				out.print("color='" + color + "' ");
				out.print("width='" + lineStyle.width + "' ");
				if (lineStyle.flags != 0)
					out.print("flags='" + lineStyle.flags + "' ");
				if (lineStyle.hasMiterJoint())
				{
					out.print("miterLimit='" + lineStyle.miterLimit + "' ");
				}
				if (lineStyle.hasFillStyle())
				{
					out.print(">\r");
					indent();
					//ArrayList<FillStyle> fillStyles = new ArrayList<FillStyle>(1);
					var fillStyles:Vector.<FillStyle> = new Vector.<FillStyle>(1);
					fillStyles.push(lineStyle.fillStyle);
					printFillStyles(fillStyles, alpha);
					indent();
					out.print("</linestyle>\r");
				}
				else
				{
					out.print("/>\r");
				}
			}
		}
		
		private function printFillStyles(fillstyles:Vector.<FillStyle>, alpha:Boolean):void
		{
			//Iterator it = fillstyles.iterator();
			//while (it.hasNext())
			for (var i:int = 0; i < fillstyles.length; i++)
			{
				var fillStyle:FillStyle = fillstyles[i];
				indent();
				out.print("<fillstyle");
				out.print(" type='" + fillStyle.getType() + "'");
				if (fillStyle.getType() == FillStyle.FILL_SOLID)
				{
					out.print(" color='" + (alpha ? printRGBA(fillStyle.color) : printRGB(fillStyle.color)) + "'");
				}
				if ((fillStyle.getType() & FillStyle.FILL_LINEAR_GRADIENT) != 0)
				{
					if (fillStyle.getType() == FillStyle.FILL_RADIAL_GRADIENT)
						out.print( " typeName='radial'");
					else if (fillStyle.getType() == FillStyle.FILL_FOCAL_RADIAL_GRADIENT)
						out.print( " typeName='focal' focalPoint='" + (fillStyle.gradient as FocalGradient).focalPoint + "'");
					// todo print linear or radial or focal
					out.print(" gradient='" + formatGradient(fillStyle.gradient.records, alpha) + "'");
					out.print(" matrix='" + fillStyle.matrix + "'");
				}
				if ((fillStyle.getType() & FillStyle.FILL_BITS) != 0)
				{
					// todo print tiled or clipped
					out.print(" idref='" + idRef(fillStyle.bitmap) + "'");
					out.print(" matrix='" + fillStyle.matrix + "'");
				}
				out.print(" />\r");
			}
		}
		
		private function printMorphFillStyles(fillStyles:Vector.<MorphFillStyle>):void
		{
			for (var i:int = 0; i < fillStyles.length; i++)
			{
				var fillStyle:MorphFillStyle = fillStyles[i];
				indent();
				out.print("<fillstyle");
				out.print(" type='" + fillStyle.type + "'");
				if (fillStyle.type == FillStyle.FILL_SOLID)
				{
					out.print(" startColor='" + printRGBA(fillStyle.startColor) + "'");
					out.print(" endColor='" + printRGBA(fillStyle.endColor) + "'");
				}
				if ((fillStyle.type & FillStyle.FILL_LINEAR_GRADIENT) != 0)
				{
					// todo print linear or radial
					out.print(" gradient='" + formatMorphGradient(fillStyle.gradRecords) + "'");
					out.print(" startMatrix='" + fillStyle.startGradientMatrix + "'");
					out.print(" endMatrix='" + fillStyle.endGradientMatrix + "'");
				}
				if ((fillStyle.type & FillStyle.FILL_BITS) != 0)
				{
					// todo print tiled or clipped
					out.print(" idref='" + idRef(fillStyle.bitmap) + "'");
					out.print(" startMatrix='" + fillStyle.startBitmapMatrix + "'");
					out.print(" endMatrix='" + fillStyle.endBitmapMatrix + "'");
				}
				out.print(" />\r");
			}
		}
		
		private function formatGradient(records:Vector.<GradRecord>, alpha:Boolean):String
		{
			//StringBuilder b = new StringBuilder();
			var b:String = new String();
			for (var i:int = 0; i < records.length; i++)
			{
				b += records[i].ratio;
				b += ' ';
				b += (alpha ? printRGBA(records[i].color) : printRGB(records[i].color));
				if (i + 1 < records.length)
					b += ' ';
			}
			return b;
		}
		
		private function formatMorphGradient(records:Vector.<MorphGradRecord>):String
		{
			//StringBuilder b = new StringBuilder();
			var b:String = new String();
			for (var i:int = 0; i < records.length; i++)
			{
				b += records[i].startRatio;
				b += ',';
				b += records[i].endRatio;
				b += ' ';
				b += printRGBA(records[i].startColor);
				b += ',';
				b += printRGBA(records[i].endColor);
				if (i + 1 < records.length)
					b += ' ';
			}
			return b;
		}
		
		private function printShape(shapes:Shape, alpha:Boolean):void
		{
			if (shapes == null)
				return;
			
			//Iterator it = shapes.shapeRecords.iterator();
			//while (it.hasNext())
			for (var i:int = 0; i < shapes.shapeRecords.length; i++)
			{
				indent();
				var shape:ShapeRecord = shapes.shapeRecords[i];
				if (shape is StyleChangeRecord)
				{
					var styleChange:StyleChangeRecord = shape as StyleChangeRecord;
					out.print("<styleChange ");
					if (styleChange.stateMoveTo)
					{
						out.print("dx='" + styleChange.moveDeltaX + "' dy='" + styleChange.moveDeltaY + "' ");
					}
					if (styleChange.stateFillStyle0)
					{
						out.print("fillStyle0='" + styleChange.fillstyle0 + "' ");
					}
					if (styleChange.stateFillStyle1)
					{
						out.print("fillStyle1='" + styleChange.fillstyle1 + "' ");
					}
					if (styleChange.stateLineStyle)
					{
						out.print("lineStyle='" + styleChange.linestyle + "' ");
					}
					if (styleChange.stateNewStyles)
					{
						out.print(">\r");
						indentLength++;
						printFillStyles(styleChange.fillstyles, alpha);
						printLineStyles(styleChange.linestyles, alpha);
						indentLength--;
						indent();
						out.print("</styleChange>\r");
					}
					else
					{
						out.print("/>\r");
					}
				}
				else
				{
					var edge:EdgeRecord = shape as EdgeRecord;
					if (edge is StraightEdgeRecord)
					{
						var straightEdge:StraightEdgeRecord = edge as StraightEdgeRecord;
						out.print("<line dx='" + straightEdge.deltaX + "' dy='" + straightEdge.deltaY + "' />\r");
					}
					else
					{
						var curvedEdge:CurvedEdgeRecord = edge as CurvedEdgeRecord;
						out.print("<curve ");
						out.print("cdx='" + curvedEdge.controlDeltaX + "' cdy='" + curvedEdge.controlDeltaY + "' ");
						out.print("dx='" + curvedEdge.anchorDeltaX + "' dy='" + curvedEdge.anchorDeltaY + "' ");
						out.print("/>\r");
					}
				}
			}
		}
		
		private function printShapeWithTabs(shapes:Shape):void
		{
			if (shapes == null)
				return;
			
			//Iterator it = shapes.shapeRecords.iterator();
			var startX:int = 0;
			var startY:int = 0;
			
			var x:int = 0;
			var y:int = 0;
			
			//while (it.hasNext())
			for (var n:int = 0; n < shapes.shapeRecords.length; n++)
			{
				indent();
				var shape:ShapeRecord = shapes.shapeRecords[n]; //(ShapeRecord)it.next();
				if (shape is StyleChangeRecord)
				{
					var styleChange:StyleChangeRecord = shape as StyleChangeRecord;
					out.print("SSCR" + styleChange.nMoveBits() + "\t");
					if (styleChange.stateMoveTo)
					{
						out.print(styleChange.moveDeltaX + "\t" + styleChange.moveDeltaY);
						
						if (startX == 0 && startY == 0)
						{
							startX = styleChange.moveDeltaX;
							startY = styleChange.moveDeltaY;
						}
						
						x = styleChange.moveDeltaX;
						y = styleChange.moveDeltaY;
						
						out.print("\t\t");
					}
				}
				else
				{
					var edge:EdgeRecord = shape as EdgeRecord;
					if (edge is StraightEdgeRecord)
					{
						var straightEdge:StraightEdgeRecord = edge as StraightEdgeRecord;
						out.print("SER" + "\t");
						out.print(straightEdge.deltaX + "\t" + straightEdge.deltaY);
						x += straightEdge.deltaX;
						y += straightEdge.deltaY;
						out.print("\t\t");
					}
					else
					{
						var curvedEdge:CurvedEdgeRecord = edge as CurvedEdgeRecord;
						out.print("CER" + "\t");
						out.print(curvedEdge.controlDeltaX + "\t" + curvedEdge.controlDeltaY + "\t");
						out.print(curvedEdge.anchorDeltaX + "\t" + curvedEdge.anchorDeltaY);
						x += (curvedEdge.controlDeltaX + curvedEdge.anchorDeltaX);
						y += (curvedEdge.controlDeltaY + curvedEdge.anchorDeltaY);
					}
				}
				
				out.print("\t\t" + x + "\t" + y + "\r");
			}
		}
		
		public static function printClipEventFlags(flags:int):String
		{
			var b:String = new String();
			
			if ((flags & ClipActionRecord.unused31) != 0) b += "res31,";
			if ((flags & ClipActionRecord.unused30) != 0) b += "res30,";
			if ((flags & ClipActionRecord.unused29) != 0) b += "res29,";
			if ((flags & ClipActionRecord.unused28) != 0) b += "res28,";
			if ((flags & ClipActionRecord.unused27) != 0) b += "res27,";
			if ((flags & ClipActionRecord.unused26) != 0) b += "res26,";
			if ((flags & ClipActionRecord.unused25) != 0) b += "res25,";
			if ((flags & ClipActionRecord.unused24) != 0) b += "res24,";
			
			if ((flags & ClipActionRecord.unused23) != 0) b += "res23,";
			if ((flags & ClipActionRecord.unused22) != 0) b += "res22,";
			if ((flags & ClipActionRecord.unused21) != 0) b += "res21,";
			if ((flags & ClipActionRecord.unused20) != 0) b += "res20,";
			if ((flags & ClipActionRecord.unused19) != 0) b += "res19,";
			if ((flags & ClipActionRecord.construct) != 0) b += "construct,";
			if ((flags & ClipActionRecord.keyPress) != 0) b += "keyPress,";
			if ((flags & ClipActionRecord.dragOut) != 0) b += "dragOut,";
			
			if ((flags & ClipActionRecord.dragOver) != 0) b += "dragOver,";
			if ((flags & ClipActionRecord.rollOut) != 0) b += "rollOut,";
			if ((flags & ClipActionRecord.rollOver) != 0) b += "rollOver,";
			if ((flags & ClipActionRecord.releaseOutside) != 0) b += "releaseOutside,";
			if ((flags & ClipActionRecord.release) != 0) b += "release,";
			if ((flags & ClipActionRecord.press) != 0) b += "press,";
			if ((flags & ClipActionRecord.initialize) != 0) b += "initialize,";
			if ((flags & ClipActionRecord.data) != 0) b += "data,";
			
			if ((flags & ClipActionRecord.keyUp) != 0) b += "keyUp,";
			if ((flags & ClipActionRecord.keyDown) != 0) b += "keyDown,";
			if ((flags & ClipActionRecord.mouseUp) != 0) b += "mouseUp,";
			if ((flags & ClipActionRecord.mouseDown) != 0) b += "mouseDown,";
			if ((flags & ClipActionRecord.mouseMove) != 0) b += "moseMove,";
			if ((flags & ClipActionRecord.unload) != 0) b += "unload,";
			if ((flags & ClipActionRecord.enterFrame) != 0) b += "enterFrame,";
			if ((flags & ClipActionRecord.load) != 0) b += "load,";
			
			if (b.length > 1)
			{
				b = b.substr(0,b.length - 1);
			}
			
			return b;
		}
		
		public override function defineText2(tag:DefineText):void
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			end();
			
			//Iterator it = tag.records.iterator();
			
			//while (it.hasNext())
			for (var i:int = 0; i < tag.records.length; i++)
			{
				var tr:TextRecord = tag.records[i]; //(TextRecord)it.next();
				printTextRecord(tr, tag.code);
			}
			
			closeTag(tag);
		}
		
		public function printTextRecord(tr:TextRecord, tagCode:int):void
		{
			indent();
			out.print("<textRecord ");
			if (tr.hasFont())
				out.print(" font='" + tr.font.getFontName() + "'");
			
			if (tr.hasHeight())
				out.print(" height='" + tr.height + "'");
			
			if (tr.hasX())
				out.print(" xOffset='" + tr.xOffset + "'");
			
			if (tr.hasY())
				out.print(" yOffset='" + tr.yOffset + "'");
			
			if (tr.hasColor())
				out.print(" color='" +
					(tagCode == TagValues.stagDefineEditText ? printRGB(tr.color) : printRGBA(tr.color)) +
					"'");
			out.print(">\r");
			
			indentLength++;
			printGlyphEntries(tr);
			indentLength--;
			indent();
			out.print("</textRecord>\r");
			
		}
		
		private function printGlyphEntries(tr:TextRecord):void
		{
			indent();
			for (var i:int = 0; i < tr.entries.length; i++)
			{
				var ge:GlyphEntry = tr.entries[i];
				out.print(ge.getIndex());
				if (ge.advance >= 0)
					out.print('+');
				out.print(ge.advance);
				out.print(' ');
				if ((i + 1) % 10 == 0)
				{
					out.print('\r');
					indent();
				}
			}
			if (tr.entries.length % 10 != 0)
				out.print('\r');
		}
		
		public override function defineButton2(tag:DefineButton):void
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			out.print(" trackAsMenu='" + tag.trackAsMenu + "'");
			end();
			
			var i:int;
			
			for (i = 0; i < tag.buttonRecords.length; i++)
			{
				var record:ButtonRecord = tag.buttonRecords[i];
				indent();
				out.print("<buttonRecord " +
					"idref='" + idRef(record.characterRef) + "' " +
					"depth='" + record.placeDepth + "' " +
					"matrix='" + record.placeMatrix + "' " +
					"states='" + record.getFlags() + "'/>\r");
				// todo print optional cxforma
			}
			
			// print conditional actions
			if (tag.condActions.length > 0 && showActions)
			{
				indent();
				out.print("<buttonCondAction>\r");
				openCDATA();
				for (i = 0; i < tag.condActions.length; i++)
				{
					var cond:ButtonCondAction = tag.condActions[i];
					indent();
					out.print("on(" + cond + ") {\r");
					indentLength++;
					printActions(cond.actionList);
					indentLength--;
					indent();
					out.print("}\r");
				}
				closeCDATA();
				indent();
				out.print("</buttonCondAction>\r");
			}
			
			closeTag(tag);
		}
		
		public override function defineBitsJPEG3(tag:DefineBitsJPEG3):void
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			
			if (external)
			{
				/**
			 	String path = externalDirectory
			 	+ externalPrefix
			 	+ "image"
			 	+ dict.getId(tag)
			 	+ ".jpg";
			 
			 	out.println(" src='" + path + "' />");
			 
			 	try
			 	{
			 		FileOutputStream image = new FileOutputStream(path, false);
			 		SwfImageUtils.JPEG jpeg = null;
			 
			 		if (tag.jpegTables != null)
			 		{
			 			jpeg = new SwfImageUtils.JPEG(tag.jpegTables.data, tag.data);
			 		}
			 		else
			 		{
			 			jpeg = new SwfImageUtils.JPEG(null,null,tag.data, true);
			 		}
			 
			 		jpeg.write(image);
			 		image.close();
			 	}
			 	catch (IOException e)
			 	{
			 		out.println("<!-- error: unable to write external asset file " + path + "-->");
			 	}
				 */
				var fileName:String = this.externalPrefix + "-" + dict.getId(tag) + ".jpg";
				var fileRef:FileReference = new FileReference();
				var outData:ByteArray = new ByteArray();
				var jpeg:JPEG;
				if (tag.jpegTables != null) {
					jpeg = new JPEG(tag.jpegTables.data, tag.data);
				} else {
					jpeg = new JPEG(null,null,tag.data,true);
				}
				jpeg.write(outData);
				//fileRef.save(tag.data,fileName);
				fileRef.save(outData,fileName);
				this.external = false;
			 }
			 //else
			 //{
			out.print(" encoding='base64'");
			end();
			outputBase64(tag.data);
			closeTag(tag);
			//}
		}

		public override function defineBitsLossless2(tag:DefineBitsLossless):void
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			
			if (external)
			{
			    /**
				String path = externalDirectory
					+ externalPrefix
					+ "image"
					+ dict.getId(tag)
					+ ".bitmap";
				
				out.print(" src='" + path + "' />\r");
				try
				{
					FileOutputStream image = new FileOutputStream(path, false);
					image.write(tag.data);
					image.close();
				}
				catch (IOException e)
				{
					out.print("<!-- error: unable to write external asset file " + path + "-->\r");
				}
				 */
				var fileName:String = this.externalPrefix + "-" + dict.getId(tag) + ".bmp";
				var fileRef:FileReference = new FileReference();
				fileRef.save(tag.data,fileName);
				this.external = false;
			}
			//else
			//{
				out.print(" encoding='base64'");
				end();
				outputBase64(tag.data);
				closeTag(tag);
			//}
		}
		
		public override function defineEditText(tag:DefineEditText):void
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			
			if (tag.hasText)
				out.print(" text='" + escape(tag.initialText) + "'");
			
			if (tag.hasFont)
			{
				out.print(" fontId='" + id(tag.font) + "'");
				out.print(" fontName='" + tag.font.getFontName() + "'");
				out.print(" fontHeight='" + tag.height + "'");
			}
			else if (tag.hasFontClass)
			{
				out.print(" fontClass='" + tag.fontClass + "'");
				out.print(" fontHeight='" + tag.height + "'");
			}
			
			out.print(" bounds='" + tag.bounds + "'");
			
			if (tag.hasTextColor)
				out.print(" color='" + printRGBA(tag.color) + "'");
			
			out.print(" html='" + tag.html + "'");
			out.print(" autoSize='" + tag.autoSize + "'");
			out.print(" border='" + tag.border + "'");
			
			if (tag.hasMaxLength)
				out.print(" maxLength='" + tag.maxLength + "'");
			
			out.print(" multiline='" + tag.multiline + "'");
			out.print(" noSelect='" + tag.noSelect + "'");
			out.print(" password='" + tag.password + "'");
			out.print(" readOnly='" + tag.readOnly + "'");
			out.print(" useOutlines='" + tag.useOutlines + "'");
			out.print(" varName='" + tag.varName + "'");
			out.print(" wordWrap='" + tag.wordWrap + "'");
			
			if (tag.hasLayout)
			{
				out.print(" align='" + tag.align + "'");
				out.print(" indent='" + tag.ident + "'");
				out.print(" leading='" + tag.leading + "'");
				out.print(" leftMargin='" + tag.leftMargin + "'");
				out.print(" rightMargin='" + tag.rightMargin + "'");
			}
			close();
		}
		
		public override function defineSprite(tag:DefineSprite):void
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			end();
			indent();
			out.print("<!-- sprite framecount=" + tag.framecount + " -->\r");
			
			tag.tagList.visitTags(this);
			
			closeTag(tag);
		}
		
		public override function frameLabel(tag:FrameLabel):void
		{
			open(tag);
			out.print(" label='" + tag.label + "'");
			if (tag.anchor)
				out.print(" anchor='" + "true" + "'");
			close();
		}
		
		public override function soundStreamHead2(tag:SoundStreamHead):void
		{
			open(tag);
			out.print(" playbackRate='" + tag.playbackRate + "'");
			out.print(" playbackSize='" + tag.playbackSize + "'");
			out.print(" playbackType='" + tag.playbackType + "'");
			out.print(" compression='" + tag.compression + "'");
			out.print(" streamRate='" + tag.streamRate + "'");
			out.print(" streamSize='" + tag.streamSize + "'");
			out.print(" streamType='" + tag.streamType + "'");
			out.print(" streamSampleCount='" + tag.streamSampleCount + "'");
			
			if (tag.compression == 2)
			{
				out.print(" latencySeek='" + tag.latencySeek + "'");
			}
			close();
		}

		public override function defineScalingGrid(tag:DefineScalingGrid):void
		{
			open(tag);
			out.print(" idref='" + id(tag.scalingTarget) + "'");
			out.print( " grid='" + tag.rect + "'" );
			close();
		}
		
		public override function defineMorphShape(tag:DefineMorphShape):void
		{
			defineMorphShape2(tag);
		}
		
		public override function defineMorphShape2(tag:DefineMorphShape):void
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			out.print(" startBounds='" + tag.startBounds + "'");
			out.print(" endBounds='" + tag.endBounds + "'");
			if (tag.code == TagValues.stagDefineMorphShape2)
			{
				out.print(" startEdgeBounds='" + tag.startEdgeBounds + "'");
				out.print(" endEdgeBounds='" + tag.endEdgeBounds + "'");
				out.print(" usesNonScalingStrokes='" + tag.usesNonScalingStrokes + "'");
				out.print(" usesScalingStrokes='" + tag.usesScalingStrokes + "'");
			}
			end();
			printMorphLineStyles(tag.lineStyles);
			printMorphFillStyles(tag.fillStyles);
			
			indent();
			out.print("<start>\r");
			indentLength++;
			printShape(tag.startEdges, true);
			indentLength--;
			indent();
			out.print("</start>\r");
			
			indent();
			out.print("<end>\r");
			indentLength++;
			printShape(tag.endEdges, true);
			indentLength--;
			indent();
			out.print("</end>\r");
			
			closeTag(tag);
		}
		
		public override function defineFont2(tag:DefineFont2):void
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			out.print(" font='" + tag.fontName + "'");
			out.print(" numGlyphs='" + tag.glyphShapeTable.length + "'");
			out.print(" italic='" + tag.italic + "'");
			out.print(" bold='" + tag.bold + "'");
			out.print(" ansi='" + tag.ansi + "'");
			out.print(" wideOffsets='" + tag.wideOffsets + "'");
			out.print(" wideCodes='" + tag.wideCodes + "'");
			out.print(" shiftJIS='" + tag.shiftJIS + "'");
			out.print(" langCode='" + tag.langCode + "'");
			out.print(" hasLayout='" + tag.hasLayout + "'");
			out.print(" ascent='" + tag.ascent + "'");
			out.print(" descent='" + tag.descent + "'");
			out.print(" leading='" + tag.leading + "'");
			out.print(" kerningCount='" + tag.kerningCount + "'");
			
			out.print(" codepointCount='" + tag.codeTable.length + "'");
			
			if (tag.hasLayout)
			{
				out.print(" advanceCount='" + tag.advanceTable.length + "'");
				out.print(" boundsCount='" + tag.boundsTable.length + "'");
			}
			end();
			
			if (glyphs)
			{
				var i:int;
				for (i=0; i < tag.kerningCount; i++)
				{
					var rec:KerningRecord = tag.kerningTable[i];
					indent();
					out.print("<kerningRecord adjustment='" + rec.adjustment + "' code1='" + rec.code1 + "' code2='" + rec.code2 + "' />\r");
				}
				
				for (i = 0; i < tag.glyphShapeTable.length; i++)
				{
					indent();
					out.print("<glyph");
					out.print(" codepoint='" + (tag.codeTable.charCodeAt(i)) + (isPrintable(tag.codeTable.charAt(i)) ? ("(" + tag.codeTable.charAt(i) + ")") : "(?)") + "'");
					if (tag.hasLayout)
					{
						out.print(" advance='" + tag.advanceTable[i] + "'");
						out.print(" bounds='" + tag.boundsTable[i] + "'");
					}
					out.print(">\r");
					
					var shape:Shape = tag.glyphShapeTable[i];
					indentLength++;
					if (tabbedGlyphs)
						printShapeWithTabs(shape);
					else
						printShape(shape, true);
					indentLength--;
					indent();
					out.print("</glyph>\r");
				}
			}
			
			closeTag(tag);
		}
		
		public override function defineFont3(tag:DefineFont3):void
		{
			defineFont2(tag);
		}
		
		public override function defineFont4(tag:DefineFont4):void
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			out.print(" font='" + tag.fontName + "'");
			out.print(" hasFontData='" + tag.hasFontData + "'");
			out.print(" smallText='" + tag.smallText + "'");
			out.print(" italic='" + tag.italic + "'");
			out.print(" bold='" + tag.bold + "'");
			out.print(" langCode='" + tag.langCode + "'");
			end();
			
			if (glyphs && tag.hasFontData)
			{
				outputBase64(tag.data);
			}
			
			closeTag(tag);
		}
		
		public override function defineFontAlignZones(tag:DefineFontAlignZones):void
		{
			open(tag);
			if (tag.name != null)
				out.print(" id='" + id(tag) + "'");
			out.print(" fontID='" + id(tag.font) + "'");
			out.print(" CSMTableHint='" + tag.csmTableHint + "'");
			out.print(">\r");
			indentLength++;
			indent();
			out.print("<ZoneTable length='" + tag.zoneTable.length + "'>\r");
			indentLength++;
			if (glyphs)
			{
				for (var i:int = 0; i < tag.zoneTable.length; i++)
				{
					var record:ZoneRecord = tag.zoneTable[i];
					indent();
					out.print("<ZoneRecord num='" + record.numZoneData + "' mask='" + record.zoneMask + "'>");
					for (var j:int = 0; j < record.zoneData.length; j++)
					{
						out.print(record.zoneData[j] + " ");
					}
					out.print("</ZoneRecord>\r");
				}
			}
			indentLength--;
			indent();
			out.print("</ZoneTable>\r");
			closeTag(tag);
		}
		
		public override function csmTextSettings(tag:CSMTextSettings):void
		{
			open(tag);
			if (tag.name != null)
				out.print(" id='" + id(tag) + "'");
			
			var textID:String = tag.textReference == null ? "0" : id(tag.textReference);
			out.print(" textID='" + textID + "'");
			out.print(" styleFlagsUseSaffron='" + tag.styleFlagsUseSaffron + "'");
			out.print(" gridFitType='" + tag.gridFitType + "'");
			out.print(" thickness='" + tag.thickness + "'");
			out.print(" sharpness='" + tag.sharpness + "'");
			close();
		}
		
		public override function defineFontName(tag:DefineFontName):void
		{
			open(tag);
			if (tag.name != null)
				out.print(" id='" + id(tag) + "'");
			out.print(" fontID='" + id(tag.font) + "'");
			if (tag.fontName != null)
			{
				out.print(" name='" + tag.fontName + "'");
			}
			if (tag.copyright != null)
			{
				out.print(" copyright='" + tag.copyright + "'");
			}
			
			close();
		}
		
		private function isPrintable(c:String):Boolean
		{
			//var i:int = parseInt(c) & 0xFFFF;
			if (c.charCodeAt(0) < 32 || c == '<' || c == '&' || c == '\'')
				return false;
			else
				return true;
		}
		
		public override function exportAssets(tag:ExportAssets):void
		{
			open(tag);
			end();
			
			//Iterator it = tag.exports.iterator();
			//while (it.hasNext())
			for (var i:int=0; i< tag.exports.length; i++)
			{
				//DefineTag ref = (DefineTag)it.next();
				var ref:DefineTag = tag.exports[i] as DefineTag;
				indent();
				out.print("<Export idref='" + dict.getId(ref) + "' name='" + ref.name + "' />\r");
			}
			
			closeTag(tag);
		}
		
		public override function symbolClass(tag:SymbolClass):void
		{
			open(tag);
			end();
			
			//Iterator it = tag.class2tag.entrySet().iterator();
			//while (it.hasNext())
			for (var e:* in tag.class2tag)
			{
				//Map.Entry e = (Map.Entry)it.next();
				var className:String = e;
				var ref:DefineTag = tag.class2tag[e];
				if (ref == null) {
					//Added by SWF Investigator
					//Try looking it up a second time...
					ref = dict.getTagByID(tag.class2idref[e]);
				}
				indent();
				out.print("<Symbol idref='" + dict.getId(ref) + "' className='" + className + "' />\r");
			}
			
			if (tag.topLevelClass != null)
			{
				indent();
				out.print("<Symbol idref='0' className='" + tag.topLevelClass + "' />\r");
			}
				
			closeTag(tag);
		}
		
		public override function importAssets(tag:ImportAssets):void
		{
			open(tag);
			out.print(" url='" + tag.url + "'");
			end();
			
			//Iterator it = tag.importRecords.iterator();
			//while (it.hasNext())
			for (var i:int = 0; i < tag.importRecords.length; i++)
			{
				//ImportRecord record = (ImportRecord)it.next();
				var record:ImportRecord = tag.importRecords[i];
				indent();
				out.print("<Import name='" + record.name + "' id='" + dict.getId(record) + "' />\r");
			}
			
			closeTag(tag);
		}
		
		public override function importAssets2(tag:ImportAssets):void
		{
			// TODO: add support for tag.downloadNow and SHA1...
			importAssets(tag);
		}
		
		public override function enableDebugger(tag:EnableDebugger):void
		{
			open(tag);
			out.print(" password='" + tag.password + "'");
			close();
		}
		
		public override function doInitAction(tag:DoInitAction):void
		{
			if (tag.sprite != null && tag.sprite.name != null)
			{
				indent();
				out.print("<!-- init " + tag.sprite.name + " " + idRef(tag.sprite) + " -->\r");
			}
			
			open(tag);
			if (tag.sprite != null)
				out.print(" idref='" + idRef(tag.sprite) + "'");
			end();
			
			if (showActions)
			{
				openCDATA();
				printActions(tag.actionList);
				closeCDATA();
			}
			else
			{
				indent();
				out.print("<!-- " + tag.actionList.size() + " action(s) elided -->\r");
			}
			closeTag(tag);
		}
		
		private function idRef(tag:DefineTag):String
		{
			if (tag == null)
			{
				// if tag is null then it isn't in the dict -- the SWF is invalid.
				// lets be lax and print something; Matador generates invalid SWF sometimes.
				return "-1";
			}
			else if (tag.name == null || tag.name.length == 0)
			{
				var id:uint = dict.getId(tag);
				var s:String = dict.getName(id);
				if (s == null || s.length == 0) {
					// just print the character id since no name was exported
					return id.toString();
				} else {
					return (id.toString() + "' symbolName='" + s);
				}
				//tag.getID().toString();
			}
			else
			{
				return (dict.getId(tag).toString() + "' idrefName='" + tag.name);
			}
			return ("");
		}
		
		public override function defineVideoStream(tag:DefineVideoStream):void
		{
			open(tag);
			out.print(" id='" + id(tag) + "'");
			close();
		}
		
		public override function videoFrame(tag:VideoFrame):void
		{
			open(tag);
			out.print(" streamId='" + idRef(tag.stream) + "'");
			out.print(" frame='" + tag.frameNum + "'");
			close();
		}
		
		public override function defineFontInfo2(tag:DefineFontInfo):void
		{
			defineFontInfo(tag);
		}
		
		public override function enableDebugger2(tag:EnableDebugger):void
		{
			open(tag);
			out.print(" password='" + tag.password + "'");
			out.print(" reserved='0x" )
			var hex:String = "0123456789abcdef";
			out.print(hex.charAt((tag.reserved & 0xF0) >> 4));
			out.print(hex.charAt(tag.reserved & 0x0F) + "'");
			close();
		}
		
		public override function debugID(tag:DebugID):void
		{
			open(tag);
			out.print(" uuid='" + tag.uuid + "'");
			close();
		}
		
		public override function scriptLimits(tag:ScriptLimits):void
		{
			open(tag);
			out.print(" scriptRecursionLimit='" + tag.scriptRecursionLimit + "'" +
				" scriptTimeLimit='" + tag.scriptTimeLimit + "'");
			close();
		}
		
		public override function setTabIndex(tag:SetTabIndex):void
		{
			open(tag);
			out.print(" depth='" + tag.depth + "'");
			out.print(" index='" + tag.index + "'");
			close();
		}
		
		public override function defineSceneAndFrameLabelData(tag:DefineSceneAndFrameLabelData):void
		{
			open(tag);
			out.print(">\r");
			out.print("  <scenes count='" + tag.sceneCount + "'>\r");
			var i:int;
			for (i=0; i < tag.sceneCount; i++) {
				out.print ("    <scene offset='" + tag.sceneInfo[i].offset + "' name='" + tag.sceneInfo[i].name + "'/>\r");
			}
			out.print("  </scenes>\r");
			out.print("  <frameLabel count='" + tag.frameLabelCount + "'>\r");
			for (i=0; i < tag.frameLabelCount; i++) {
				out.print ("    <frameLabel number='" + tag.frameInfo[i].number + "' label='" + tag.frameInfo[i].label + "'>\r");
			}
			out.print ("  </frameLabel>\r");
			
			closeTag(tag);
		}
		
		public override function defineBitsJPEG4(tag:DefineBitsJPEG4):void
		{
			open(tag);
			out.print(" id='" + id(tag) + "' deblockParam='" + tag.deblockParam + "'");
			
			if (external)
			{
				var fileName:String = this.externalPrefix + "-" + dict.getId(tag) + ".jpg";
				var fileRef:FileReference = new FileReference();
				var outData:ByteArray = new ByteArray();
				var jpeg:JPEG;
				if (tag.jpegTables != null) {
					jpeg = new JPEG(tag.jpegTables.data, tag.data);
				} else {
					jpeg = new JPEG(null,null,tag.data,true);
				}
				jpeg.write(outData);
				fileRef.save(outData,fileName);
				this.external = false;
			}
			out.print(" encoding='base64'");
			end();
			outputBase64(tag.data);
			closeTag(tag);

		}

	}
}