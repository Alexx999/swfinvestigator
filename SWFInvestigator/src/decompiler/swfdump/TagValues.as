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
	public class TagValues
	{
		public function TagValues()
		{
		}
		
		
		// Flash 1 tags
		public static const stagEnd:int						= 0;
		public static const stagShowFrame:int				= 1;
		public static const stagDefineShape:int				= 2;
		public static const stagFreeCharacter:int			= 3;
		public static const stagPlaceObject:int				= 4;
		public static const stagRemoveObject:int			= 5;
		public static const stagDefineBits:int				= 6; // id,w,h,colorTab,bits - bitmap referenced by a fill(s)
		public static const stagDefineButton:int			= 7; // up obj, down obj, action (URL, Page, ???)
		public static const stagJPEGTables:int				= 8; // id,w,h,colorTab,bits - bitmap referenced by a fill(s)
		public static const stagSetBackgroundColor:int		= 9;
		
		public static const stagDefineFont:int				= 10;
		public static const stagDefineText:int				= 11;
		public static const stagDoAction:int				= 12;
		public static const stagDefineFontInfo:int			= 13;
		
		public static const stagDefineSound:int				= 14;	// Event sound tags.
		public static const stagStartSound:int				= 15;
		public static const stagStopSound:int			= 16; //Originally commented out - Si
		
		public static const stagDefineButtonSound:int		= 17;
		
		public static const stagSoundStreamHead:int			= 18;
		public static const stagSoundStreamBlock:int		= 19;
		
		// Flash 2 tags
		public static const stagDefineBitsLossless:int		= 20;	// A bitmap using lossless zlib compression.
		public static const stagDefineBitsJPEG2:int			= 21;	// A bitmap using an internal JPEG compression table.
		
		public static const stagDefineShape2:int			= 22;
		public static const stagDefineButtonCxform:int		= 23;
		
		public static const stagProtect:int					= 24;	// This file should not be importable for editing.
		
		public static const stagPathsArePostScript:int		= 25;	// assume shapes are filled as PostScript style paths
		
		// Flash 3 tags
		public static const stagPlaceObject2:int			= 26;	// The new style place w/ alpha color transform and name.
		public static const stagRemoveObject2:int			= 28;	// A more compact remove object that omits the character tag (just depth).
		
		// This tag is used for RealMedia only
		public static const stagSyncFrame:int			= 29; // OBSOLETE...Handle a synchronization of the display list
		public static const stagFreeAll:int				= 31; // OBSOLETE...Free all of the characters
		
		public static const stagDefineShape3:int			= 32;	// A shape V3 includes alpha values.
		public static const stagDefineText2:int				= 33;	// A text V2 includes alpha values.
		public static const stagDefineButton2:int			= 34;	// a Flash 3 button that contains color transform and sound info
		//public static const stagMoveObject:int			= 34;	// OBSOLETE
		public static const stagDefineBitsJPEG3:int			= 35;	// A JPEG bitmap with alpha info.
		public static const stagDefineBitsLossless2:int		= 36;	// A lossless bitmap with alpha info.
		//Commented out by SWF Investigator because spec formally defines 37 as DefineEditText defined below.
		//public static const stagDefineButtonCxform2:int	= 37;	// OBSOLETE...a button color transform with alpha info
		
		public static const stagDefineMouseTarget:int	= 38;	// define a sequence of tags that describe the behavior -- Originally commented out Si
		public static const stagDefineSprite:int			= 39;	// Define a sequence of tags that describe the behavior of a sprite.
		public static const stagNameCharacter:int		= 40;	// OBSOLETE...name a character definition, character id and a string, (used for buttons, bitmaps, sprites and sounds)
		public static const stagNameObject:int			= 41;	// OBSOLETE...name an object instance layer, layer number and a string, clear the name when no longer valid
		public static const stagProductInfo:int				= 41;	// a tag command for the Flash Generator customer serial id and cpu information.  [preilly] Repurposed for Flex Audit info.
		public static const stagDefineTextFormat:int		= 42;	// OBSOLETE...define the contents of a text block with formating information
		public static const stagFrameLabel:int				= 43;	// A string label for the current frame.
		//public static const stagDefineButton2:int		= 44;	// unused, this is defined as 34 above
		public static const stagSoundStreamHead2:int		= 45;	// For lossless streaming sound; should not have needed this...
		public static const stagDefineMorphShape:int		= 46;	// A morph shape definition
		public static const stagFrameTag:int				= 47;	// OBSOLETE...a tag command for the Flash Generator (WORD duration, STRING label)
		public static const stagDefineFont2:int				= 48;	// defines a font with extended information
		public static const stagGenCommand:int			= 49;	// OBSOLETE...a tag command for the Flash Generator intrinsic
		public static const stagDefineCommandObj:int		= 50;	// OBSOLETE...a tag command for the Flash Generator intrinsic Command
		public static const stagCharacterSet:int			= 51;	// OBSOLETE...defines the character set used to store strings
		public static const stagFontRef:int				= 52;   // OBSOLETE...defines a reference to an external font source
		
		// Flash 4 tags
		public static const stagDefineEditText:int			= 37;	// an edit text object (bounds; width; font, variable name)
		public static const stagDefineVideo:int			= 38;	// OBSOLETE...a reference to an external video stream
		
		// Flash 5 tags
		public static const stagDefineBehavior:int		= 44;   // OBSOLETE...a behavior which can be attached to a movie clip
		public static const stagDefineFunction:int		= 53;   // OBSOLETE...defines a refernece to internals of a function
		public static const stagPlaceFunction:int		= 54;   // OBSOLETE...creates an instance of a function in a thread
		
		public static const stagGenTagObject:int			= 55;	// OBSOLETE...a generator tag object written to the swf.
		
		public static const stagExportAssets:int			= 56; // export assets from this swf file
		public static const stagImportAssets:int			= 57; // import assets into this swf file
		
		public static const stagEnableDebugger:int			= 58; // OBSOLETE...this movie may be debugged
		
		// Flash 6 tags
		public static const stagDoInitAction:int			= 59;
		
		public static const stagDefineVideoStream:int		= 60;
		public static const stagVideoFrame:int				= 61;
		
		public static const stagDefineFontInfo2:int			= 62; // just like a font info except adds a language tag
		public static const stagDebugID:int					= 63;  // unique id to match up swf to swd
		public static const stagEnableDebugger2:int			= 64; //this movie may be debugged (see 59)
		public static const stagScriptLimits:int			= 65; // Allow authoring tool to override some AS limits
		
		// Flash 7 tags
		public static const stagSetTabIndex:int				= 66; // allows us to set .tabindex via tags, not actionscript
				
		// Flash 8 tags
		public static const stagDefineShape4Obsolete:int			= 67;	// OBSOLETE... use 83
			
		public static const stagFileAttributes:int			= 69;	// FileAttributes defines whole-SWF attributes
		// (must be the FIRST tag after the SWF header)
		
		public static const stagPlaceObject3:int			= 70;	// includes optional surface filter list for object
		public static const stagImportAssets2:int			= 71;   // import assets into this swf file using the SHA-1 digest to
		// enable cached cross domain RSL downloads.
		public static const stagDoABC:int					= 72;   // embedded .abc (AVM+) bytecode
		public static const stagDefineFontAlignZones:int	= 73;   // ADF alignment zones
		public static const stagCSMTextSettings:int     	= 74;
		
		public static const stagDefineFont3:int				= 75;	// defines a font with saffron information
		public static const stagSymbolClass:int				= 76;
		public static const stagMetadata:int                = 77;   // XML blob with comments, description, copyright, etc
		public static const stagDefineScalingGrid:int       = 78;   // Scale9 grid
		
		public static const stagDoABC2:int                  = 82;   // new in 9, revised ABC version with a name
		
		public static const stagDefineShape4:int            = 83;
		public static const stagDefineMorphShape2:int		= 84;	// includes enhanced line style abd gradient properties
		
		// Flash 9 tags
		public static const stagDefineSceneAndFrameLabelData:int = 86;  // new in 9, only works on root timeline
		public static const stagDefineBinaryData:int        = 87;
		public static const stagDefineFontName:int          = 88;   // adds name and copyright information for a font
	
		// Flash 10 tags
		public static const stagDefineFont4:int             = 91;   // new in 10, embedded cff fonts
		// NOTE: If tag values exceed 255 we need to expand SCharacter::tagCode from a BYTE to a WORD
		
		//Added by SWF Investigator
		public static const stagStartSound2:int			    = 89;   //StartSound2.
		
		public static const stagDefineBitsJPEG4:int			= 90;	// A JPEG bitmap with alpha info.
		
		public static const stagEnableTelemetry:int			= 93;	//Enable Telemetry. New in spec version 19
		
		public static const stagObfuscation:int				= 253;
		
		//Overlaps SWFConstants.as
		/**
		public static const names:Vector.<String> = new Vector.<String>([
			"End",					// 00
			"ShowFrame",			// 01
			"DefineShape",			// 02
			"FreeCharacter",		// 03
			"PlaceObject",			// 04
			"RemoveObject",			// 05
			"DefineBits",			// 06
			"DefineButton",			// 07
			"JPEGTables",			// 08
			"SetBackgroundColor",	// 09
			
			"DefineFont",			// 10
			"DefineText",			// 11
			"DoAction",				// 12
			"DefineFontInfo",		// 13
			
			"DefineSound",			// 14
			"StartSound",			// 15
			"StopSound",			// 16
			
			"DefineButtonSound",	// 17
		
			"SoundStreamHead",		// 18
			"SoundStreamBlock",		// 19
			
			"DefineBitsLossless",	// 20
			"DefineBitsJPEG2",		// 21
			
			"DefineShape2",			// 22
			"DefineButtonCxform",	// 23
			
			"Protect",				// 24
				
			"PathsArePostScript",	// 25
			
			"PlaceObject2",			// 26
			"27 (invalid)",			// 27
			"RemoveObject2",		// 28
					
			"SyncFrame",			// 29
			"30 (invalid)",			// 30
			"FreeAll",				// 31
					
			"DefineShape3",			// 32
			"DefineText2",			// 33
			"DefineButton2",		// 34
			"DefineBitsJPEG3",		// 35
			"DefineBitsLossless2",	// 36
			"DefineEditText",		// 37
			
			"DefineVideo",			// 38
					
			"DefineSprite",			// 39
			"NameCharacter",		// 40
			"ProductInfo",			// 41
			"DefineTextFormat",		// 42
			"FrameLabel",			// 43
			"DefineBehavior",		// 44
			"SoundStreamHead2",		// 45
			"DefineMorphShape",		// 46
			"FrameTag",				// 47
			"DefineFont2",			// 48
			"GenCommand",			// 49
			"DefineCommandObj",		// 50
			"CharacterSet",			// 51
			"FontRef",				// 52
			
			"DefineFunction",		// 53
			"PlaceFunction",		// 54
			
			"GenTagObject",			// 55
			
			"ExportAssets",			// 56
			"ImportAssets",			// 57
			
			"EnableDebugger",		// 58
	
			"DoInitAction",			// 59
			"DefineVideoStream",	// 60
			"VideoFrame",			// 61
			
			"DefineFontInfo2",		// 62
			"DebugID", 				// 63
			"EnableDebugger2", 		// 64
			"ScriptLimits", 		// 65
			
			"SetTabIndex", 			// 66
			
			"DefineShape4", 		// 67
			"DefineMorphShape2",	// 68
			
			"FileAttributes", 		// 69
			
			"PlaceObject3", 		// 70
			"ImportAssets2", 		// 71
			
			"DoABC", 				// 72
			"DefineFontAlignZones",	// 73
			"CSMTextSettings",		// 74
			"DefineFont3",			// 75
			"SymbolClass",			// 76
			"Metadata",             // 77
			"ScalingGrid",          // 78
			"79 (invalid)",         // 79
			"80 (invalid)",         // 80
			"81 (invalid)",         // 81
			"DoABC2",               // 82
			"DefineShape4",         // 83        
			"DefineMorphShape2",    // 84
			"85 (invalid)",         // 85
			"DefineSceneAndFrameLabelData",         // 86
			"DefineBinaryData",     // 87
			"DefineFontName",       // 88
			"89 (unknown)  ",       // 89
			"90 (unknown)  ",       // 90
			"DefineFont4",          // 91
			"(invalid)"             // end
		]);
	  	*/

	}
}