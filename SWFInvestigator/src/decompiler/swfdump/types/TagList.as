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

package decompiler.swfdump.types
{
		
		import decompiler.swfdump.TagHandler;
		import decompiler.swfdump.tags.*;
		import decompiler.swfdump.types.TagList;
		import decompiler.tamarin.abcdump.Tag;

		
		/**
		 * This is a simple container for a list of tags.  It's the physical
		 * representation of a timeline too, although strictly speaking, only
		 * the control tags are interesting on the timeline (placeobject,
		 * removeobject, startsound, showframe, etc).
		 *
		 * @author Clement Wong
		 */
		public class TagList extends TagHandler
		{
			public function TagList()
			{
				this.tags = new Vector.<Tag>();
			}
			
			public var tags:Vector.<Tag>;
			
			public function equals(object:*):Boolean
			{
				var isEqual:Boolean = false;
				
				if (object is TagList)
				{
					var tagList:TagList = object as TagList;
					
					if ( ( (tagList.tags == null) && (this.tags == null) ) ||
						( (tagList.tags != null) && (this.tags != null) ) ) {
							isEqual = true;
						}
					if (tagList.tags.length != this.tags.length) {
						return (false);
					}
					
					for (var i:int=0; i <this.tags.length; i++) {
						if (this.tags[i] != tagList.tags[i]) {
							isEqual = false;
						}
					}
				}
				
				return isEqual;
			}    
			
			public function toString():String
			{
				var stringBuffer:String = new String();
				
				stringBuffer += "TagList:\n";
				
				for (var i:int = 0; i < tags.length; i++)
				{
					stringBuffer += "\t" + i + " = " + tags[i] + "\n";
				}
				
				return stringBuffer;
			}
			
			public function visitTags(handler:TagHandler):void
			{
				var size:int = tags.length;
				for (var i:int = 0; i < size; i++)
				{
					var t:Tag = tags[i];
					t.visit(handler);
				}
			}
			
			public override function debugID(tag:DebugID):void
			{
				tags.push(tag);
			}
			
			public override function setTabIndex(tag:SetTabIndex):void
			{
				tags.push(tag);
			}
			
			public override function scriptLimits(tag:ScriptLimits):void
			{
				tags.push(tag);
			}
			
			public override function showFrame(tag:ShowFrame):void
			{
				tags.push(tag);
			}
			
			public override function defineShape(tag:DefineShape):void
			{
				tags.push(tag);
			}
			
			public override function placeObject(tag:PlaceObject):void
			{
				tags.push(tag);
			}
			
			public override function removeObject(tag:RemoveObject):void
			{
				tags.push(tag);
			}
			
			public override function defineBits(tag:DefineBits):void
			{
				tags.push(tag);
			}
			
			public override function defineButton(tag:DefineButton):void
			{
				tags.push(tag);
			}
			
			public override function jpegTables(tag:GenericTag):void
			{
				tags.push(tag);
			}
			
			public override function setBackgroundColor(tag:SetBackgroundColor):void
			{
				tags.push(tag);
			}
			
			public override function defineFont(tag:DefineFont1):void
			{
				tags.push(tag);
			}
			
			public override function defineText(tag:DefineText):void
			{
				tags.push(tag);
			}
			
			public override function doAction(tag:DoAction):void
			{
				tags.push(tag);
			}
			
			public override function defineFontInfo(tag:DefineFontInfo):void
			{
				tags.push(tag);
			}
			
			public override function defineSound(tag:DefineSound):void
			{
				tags.push(tag);
			}
			
			public override function startSound(tag:StartSound):void
			{
				tags.push(tag);
			}
			
			public override function defineButtonSound(tag:DefineButtonSound):void
			{
				tags.push(tag);
			}
			
			public override function soundStreamHead(tag:SoundStreamHead):void
			{
				tags.push(tag);
			}
			
			public override function soundStreamBlock(tag:GenericTag):void
			{
				tags.push(tag);
			}
			
			public override function defineBitsLossless(tag:DefineBitsLossless):void
			{
				tags.push(tag);
			}
			
			public override function defineBitsJPEG2(tag:DefineBits):void
			{
				tags.push(tag);
			}
			
			public override function defineShape2(tag:DefineShape):void
			{
				tags.push(tag);
			}
			
			public override function defineButtonCxform(tag:DefineButtonCxform):void
			{
				tags.push(tag);
			}
			
			public override function protect(tag:GenericTag):void
			{
				tags.push(tag);
			}
			
			public override function placeObject2(tag:PlaceObject):void
			{
				tags.push(tag);
			}
			
			public override function placeObject3(tag:PlaceObject):void
			{
				tags.push(tag);
			}
			
			public override function removeObject2(tag:RemoveObject):void
			{
				tags.push(tag);
			}
			
			public override function defineShape3(tag:DefineShape):void
			{
				tags.push(tag);
			}
			
			public override function defineShape4(tag:DefineShape):void
			{
				tags.push(tag);
			}
			
			public override function defineText2(tag:DefineText):void
			{
				tags.push(tag);
			}
			
			public override function defineButton2(tag:DefineButton):void
			{
				tags.push(tag);
			}
			
			public override function defineBitsJPEG3(tag:DefineBitsJPEG3):void
			{
				tags.push(tag);
			}
			
			public override function defineBitsLossless2(tag:DefineBitsLossless):void
			{
				tags.push(tag);
			}
			
			public override function defineEditText(tag:DefineEditText):void
			{
				tags.push(tag);
			}
			
			public override function defineSprite(tag:DefineSprite):void
			{
				tags.push(tag);
			}
			
			public override function frameLabel(tag:FrameLabel):void
			{
				tags.push(tag);
			}
			
			public override function soundStreamHead2(tag:SoundStreamHead):void
			{
				tags.push(tag);
			}
			
			public override function defineMorphShape(tag:DefineMorphShape):void
			{
				tags.push(tag);
			}
			
			public override function defineMorphShape2(tag:DefineMorphShape):void
			{
				tags.push(tag);
			}
			
			public override function defineFont2(tag:DefineFont2):void
			{
				tags.push(tag);
			}
			
			public override function defineFont3(tag:DefineFont3):void
			{
				tags.push(tag);
			}
			
			public override function defineFontAlignZones(tag:DefineFontAlignZones):void
			{
				tags.push(tag);
			}
			
			public override function csmTextSettings(tag:CSMTextSettings):void
			{
				tags.push(tag);
			}
			
			public override function defineFontName(tag:DefineFontName):void
			{
				tags.push(tag);
			}
			
			public override function exportAssets(tag:ExportAssets):void
			{
				tags.push(tag);
			}
			
			public override function importAssets(tag:ImportAssets):void
			{
				tags.push(tag);
			}
			
			public override function importAssets2(tag:ImportAssets):void
			{
				tags.push(tag);
			}
			
			public override function enableDebugger(tag:EnableDebugger):void
			{
				tags.push(tag);
			}
			
			public override function doInitAction(tag:DoInitAction):void
			{
				tags.push(tag);
			}
			
			public override function defineScalingGrid(tag:DefineScalingGrid):void
			{
				tags.push(tag);
			}
			
			
			public override function defineVideoStream(tag:DefineVideoStream):void
			{
				tags.push(tag);
			}
			
			public override function videoFrame(tag:VideoFrame):void
			{
				tags.push(tag);
			}
			
			public override function defineFontInfo2(tag:DefineFontInfo):void
			{
				tags.push(tag);
			}
			
			public override function enableDebugger2(tag:EnableDebugger):void
			{
				tags.push(tag);
			}
			
			public override function unknown(tag:GenericTag):void
			{
				tags.push(tag);
			}
			
			public override function productInfo(tag:ProductInfo):void
			{
				tags.push(tag);
			}
			
			public override function fileAttributes(tag:FileAttributes):void
			{
				tags.push(tag);
			}
			
			public override function defineSceneAndFrameLabelData(tag:DefineSceneAndFrameLabelData):void
			{
				tags.push(tag);
			}
			
			//Added by SWF Investigator
			public override function defineBitsJPEG4(tag:DefineBitsJPEG4):void
			{
				tags.push(tag);
			}
			
		}

}