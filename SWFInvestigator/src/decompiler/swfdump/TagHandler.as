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
	//NEEDED FOR SWF DISASSEMBLY
	import decompiler.swfdump.Header;
	import decompiler.swfdump.tags.*;
	import decompiler.tamarin.abcdump.Tag;
	//import decompiler.swfdump.DecoderDictionary;
	
	public class TagHandler
	{
		public function setOffsetAndSize(offset:int, size:int):void
		{
		}
		
		public function productInfo(tag:ProductInfo):void
		{
		}
		
		public function header(h:Header):void
		{
		}
				
		public function fileAttributes(tag:FileAttributes):void
		{
		}
		
		public function metadata(tag:Metadata):void
		{
		}
		
		public function showFrame(tag:ShowFrame):void
		{
		}
		
		public function defineShape(tag:DefineShape):void
		{
		}
		
		public function placeObject(tag:PlaceObject):void
		{
		}
		
		public function removeObject(tag:RemoveObject):void
		{
		}
		
		public function defineBinaryData(tag:DefineBinaryData):void
		{
		}
		
		public function defineFontName(tag:DefineFontName):void
		{
		}
		
		public function defineBits(tag:DefineBits):void
		{
		}
		
		public function defineButton(tag:DefineButton):void
		{
		}
		
		public function jpegTables(tag:GenericTag):void
		{
		}
		
		public function setBackgroundColor(tag:SetBackgroundColor):void
		{
		}

		public function defineFont(tag:DefineFont1):void
		{
		}
		
		public function defineFontAlignZones(tag:DefineFontAlignZones):void
		{
		}
		
		public function csmTextSettings(tag:CSMTextSettings):void
		{
		}
		
		public function defineText(tag:DefineText):void
		{
		}
		
		public function defineSceneAndFrameLabelData(tag:DefineSceneAndFrameLabelData):void
		{
		}
		
		public function doAction(tag:DoAction):void
		{
		}
		
		public function defineFontInfo(tag:DefineFontInfo):void
		{
		}
		
		public function defineSound(tag:DefineSound):void
		{
		}
		
		public function startSound(tag:StartSound):void
		{
		}

		public function defineButtonSound(tag:DefineButtonSound):void
		{
		}
		
		public function soundStreamHead(tag:SoundStreamHead):void
		{
		}
		
		public function soundStreamBlock(tag:GenericTag):void
		{
		}
		
		public function defineBitsLossless(tag:DefineBitsLossless):void
		{
		}
		
		public function defineBitsJPEG2(tag:DefineBits):void
		{
		}
		
		public function defineShape2(tag:DefineShape):void
		{
		}
		
		public function defineButtonCxform(tag:DefineButtonCxform):void
		{
		}
		
		public function protect(tag:GenericTag):void
		{
		}
		
		public function placeObject2(tag:PlaceObject):void
		{
		}
		
		public function placeObject3(tag:PlaceObject):void
		{
		}
		
		public function removeObject2(tag:RemoveObject):void
		{
		}
		
		public function defineShape3(tag:DefineShape):void
		{
		}
		
		public function defineShape4(tag:DefineShape):void
		{
		}
		
		public function defineText2(tag:DefineText):void
		{
		}
		
		public function defineButton2(tag:DefineButton):void
		{
		}
		
		public function defineBitsJPEG3(tag:DefineBitsJPEG3):void
		{
		}
		
		public function defineBitsLossless2(tag:DefineBitsLossless):void
		{
		}
		
		public function defineEditText(tag:DefineEditText):void
		{
		}
		
		public function defineSprite(tag:DefineSprite):void
		{
		}
		
		public function defineScalingGrid(tag:DefineScalingGrid):void
		{
		}
		
		public function frameLabel(tag:FrameLabel):void
		{
		}
		
		public function soundStreamHead2(tag:SoundStreamHead):void
		{
		}
		
		public function defineMorphShape(tag:DefineMorphShape):void
		{
		}
		
		public function defineMorphShape2(tag:DefineMorphShape):void
		{
		}
		
		public function defineFont2(tag:DefineFont2):void
		{
		}
		
		public function defineFont3(tag:DefineFont3):void
		{
		}
		
		public function defineFont4(tag:DefineFont4):void
		{
		}
		
		public function exportAssets(tag:ExportAssets):void
		{
		}
		
		public function symbolClass(tag:SymbolClass):void
		{
		}
		
		public function importAssets(tag:ImportAssets):void
		{
		}
		
		public function importAssets2(tag:ImportAssets):void
		{
		}
		
		public function enableDebugger(tag:EnableDebugger):void
		{
		}
		
		public function doInitAction(tag:DoInitAction):void
		{
		}
		
		public function defineVideoStream(tag:DefineVideoStream):void
		{
		}
		
		public function videoFrame(tag:VideoFrame):void
		{
		}
		
		public function defineFontInfo2(tag:DefineFontInfo):void
		{
		}
		
		public function enableDebugger2(tag:EnableDebugger):void
		{
		}
		
		public function debugID(tag:DebugID):void
		{
		}
		
		public function enableTelemetry(tag:EnableTelemetry):void
		{
		}
		
		public function startSound2(tag:StartSound2):void
		{
		}
		
		public function unknown(tag:GenericTag):void
		{
		}
		
		public function any( tag:Tag ):void
		{
		}
		
		
		/**
		 * called when we are done, no more tags coming
		 */
		public function finish():void
		{
		}
		
		public function setDecoderDictionary(dict:SWFDictionary):void
		{
		}
		
		//Modified by SWF Investigator
		public function error(tag:Tag, s:String):void
		{
			if (tag != null) {
				if (tag.SIErrorMessage != null) {
					tag.SIErrorMessage += "\r" + s;
				} else {
					tag.SIErrorMessage = s;
				}
			}
		}
		
		public function scriptLimits(tag:ScriptLimits):void
		{
		}
		
		public function setTabIndex(tag:SetTabIndex):void
		{
		}
		
		//Added by SWF Investigator
		public function defineBitsJPEG4(tag:DefineBitsJPEG4):void
		{
		}
		
		/**
		public function doABC(tag:DoABC):void
		{
		}
		 */
	}
}