// ActionScript file
// Used by SWF.as

internal const stagDoABC:int = 72;   // embedded .abc (AVM+) bytecode
internal const stagSymbolClass:int = 76;
internal const stagDoABC2:int = 82;   // revised ABC version with a name

internal var tagNames:Array = [
	"End",                  // 00
	"ShowFrame",            // 01
	"DefineShape",          // 02
	"FreeCharacter",        // 03
	"PlaceObject",          // 04
	"RemoveObject",         // 05
	"DefineBits",           // 06
	"DefineButton",         // 07
	"JPEGTables",           // 08
	"SetBackgroundColor",   // 09
	
	"DefineFont",           // 10
	"DefineText",           // 11
	"DoAction",             // 12
	"DefineFontInfo",       // 13
	
	"DefineSound",          // 14
	"StartSound",           // 15
	"StopSound",            // 16
	
	"DefineButtonSound",    // 17
	
	"SoundStreamHead",      // 18
	"SoundStreamBlock",     // 19
	
	"DefineBitsLossless",   // 20
	"DefineBitsJPEG2",      // 21
	
	"DefineShape2",         // 22
	"DefineButtonCxform",   // 23
	
	"Protect",              // 24
	
	"PathsArePostScript",   // 25
	
	"PlaceObject2",         // 26
	"27 (invalid)",         // 27
	"RemoveObject2",        // 28
	
	"SyncFrame",            // 29
	"30 (invalid)",         // 30
	"FreeAll",              // 31
	
	"DefineShape3",         // 32
	"DefineText2",          // 33
	"DefineButton2",        // 34
	"DefineBitsJPEG3",      // 35
	"DefineBitsLossless2",  // 36
	"DefineEditText",       // 37
	
	"DefineVideo",          // 38
	
	"DefineSprite",         // 39
	"NameCharacter",        // 40
	"ProductInfo",          // 41
	"DefineTextFormat",     // 42
	"FrameLabel",           // 43
	"DefineBehavior",       // 44
	"SoundStreamHead2",     // 45
	"DefineMorphShape",     // 46
	"FrameTag",             // 47
	"DefineFont2",          // 48
	"GenCommand",           // 49
	"DefineCommandObj",     // 50
	"CharacterSet",         // 51
	"FontRef",              // 52
	
	"DefineFunction",       // 53
	"PlaceFunction",        // 54
	
	"GenTagObject",         // 55
	
	"ExportAssets",         // 56
	"ImportAssets",         // 57
	
	"EnableDebugger",       // 58
	
	"DoInitAction",         // 59
	"DefineVideoStream",    // 60
	"VideoFrame",           // 61
	
	"DefineFontInfo2",      // 62
	"DebugID",              // 63
	"EnableDebugger2",      // 64
	"ScriptLimits",         // 65
	
	"SetTabIndex",          // 66
	
	"DefineShape4",         // 67
	"DefineMorphShape2",    // 68
	
	"FileAttributes",       // 69
	
	"PlaceObject3",         // 70
	"ImportAssets2",        // 71
	
	"DoABC",                // 72
	"DefineFontAlignZones", // 73
	"CSMTextSettings",      // 74
	"DefineFont3",          // 75
	"SymbolClass",          // 76
	"Metadata", 	        // 77
	"DefineScalingGrid",    // 78
	"79 (invalid)",         // 79
	"80 (invalid)",         // 80
	"81 (invalid)",         // 81
	"DoABC2",               // 82
	"DefineShape4",         // 83
	"DefineMorphShape3",	// 84
	"85 (invalid)",			// 85
	"DefineSceneAndFrameLabelData",			// 86
	"DefineBinaryData",		// 87
	"DefineFontName",		// 88
	"89 (invalid)",			// 89
	"90 (invalid)",			// 90
	"DefineFont4",			// 91
	"(invalid)"				// 92
]