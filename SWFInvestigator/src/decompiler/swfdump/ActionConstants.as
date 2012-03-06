////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2002-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
//Copied from http://opensource.adobe.com/svn/opensource/flex/sdk/trunk/modules/swfutils/src/java/flash/swf/ActionConstants.java
package decompiler.swfdump
{

	public class ActionConstants {
	// Flash 1 and 2 actions
	    public static const sactionHasLength:int		= 0x80;
	    public static const sactionNone:int				= 0x00;
	    public static const sactionGotoFrame:int		= 0x81; // frame num (int)
	    public static const sactionGetURL:int			= 0x83; // url (STR), window (STR)
	    public static const sactionNextFrame:int		= 0x04;
	    public static const sactionPrevFrame:int		= 0x05;
	    public static const sactionPlay:int				= 0x06;
	    public static const sactionStop:int				= 0x07;
	    public static const sactionToggleQuality:int	= 0x08;
	    public static const sactionStopSounds:int		= 0x09;
	    public static const sactionWaitForFrame:int		= 0x8A; // frame needed (int), actions to skip (BYTE)
	
	// Flash 3 Actions
	    public static const sactionSetTarget:int		= 0x8B; // name (STR)
	    public static const sactionGotoLabel:int		= 0x8C; // name (STR)
	
	// Flash 4 Actions
	    public static const sactionAdd:int				= 0x0A; // Stack IN: number, number, OUT: number
	    public static const sactionSubtract:int			= 0x0B; // Stack IN: number, number, OUT: number
	    public static const sactionMultiply:int			= 0x0C; // Stack IN: number, number, OUT: number
	    public static const sactionDivide:int			= 0x0D; // Stack IN: dividend, divisor, OUT: number
	    public static const sactionEquals:int			= 0x0E; // Stack IN: number, number, OUT: bool
	    public static const sactionLess:int				= 0x0F; // Stack IN: number, number, OUT: bool
	    public static const sactionAnd:int				= 0x10; // Stack IN: bool, bool, OUT: bool
	    public static const sactionOr:int				= 0x11; // Stack IN: bool, bool, OUT: bool
	    public static const sactionNot:int				= 0x12; // Stack IN: bool, OUT: bool
	    public static const sactionStringEquals:int		= 0x13; // Stack IN: string, string, OUT: bool
	    public static const sactionStringLength:int		= 0x14; // Stack IN: string, OUT: number
	    public static const sactionStringAdd:int		= 0x21; // Stack IN: string, strng, OUT: string
	    public static const sactionStringExtract:int	= 0x15; // Stack IN: string, index, count, OUT: substring
	    public static const sactionPush:int				= 0x96; // type (BYTE), value (STRING or FLOAT)
	    public static const sactionPop:int				= 0x17; // no arguments
	    public static const sactionToInteger:int		= 0x18; // Stack IN: number, OUT: integer
	    public static const sactionJump:int				= 0x99; // offset (int)
	    public static const sactionIf:int				= 0x9D; // offset (int) Stack IN: bool
	    public static const sactionCall:int				= 0x9E; // Stack IN: name
	    public static const sactionGetVariable:int		= 0x1C; // Stack IN: name, OUT: value
	    public static const sactionSetVariable:int		= 0x1D; // Stack IN: name, value
	    public static const sactionGetURL2:int			= 0x9A; // method (BYTE) Stack IN: url, window
	    public static const sactionGotoFrame2:int		= 0x9F; // flags (BYTE) Stack IN: frame
	    public static const sactionSetTarget2:int		= 0x20; // Stack IN: target
	    public static const sactionGetProperty:int		= 0x22; // Stack IN: target, property, OUT: value
	    public static const sactionSetProperty:int		= 0x23; // Stack IN: target, property, value
	    public static const sactionCloneSprite:int		= 0x24; // Stack IN: source, target, depth
	    public static const sactionRemoveSprite:int		= 0x25; // Stack IN: target
	    public static const sactionTrace:int			= 0x26; // Stack IN: message
	    public static const sactionStartDrag:int		= 0x27; // Stack IN: no constraint: 0, center, target
	// constraint: x1, y1, x2, y2, 1, center, target
	    public static const sactionEndDrag:int			= 0x28; // no arguments
	    public static const sactionStringLess:int		= 0x29; // Stack IN: string, string, OUT: bool
	    public static const sactionWaitForFrame2:int	= 0x8D; // skipCount (BYTE) Stack IN: frame
	    public static const sactionRandomNumber:int		= 0x30; // Stack IN: maximum, OUT: result
	    public static const sactionMBStringLength:int	= 0x31; // Stack IN: string, OUT: length
	    public static const sactionCharToAscii:int		= 0x32; // Stack IN: character, OUT: ASCII code
	    public static const sactionAsciiToChar:int		= 0x33; // Stack IN: ASCII code, OUT: character
	    public static const sactionGetTime:int			= 0x34; // Stack OUT: milliseconds since Player start
	    public static const sactionMBStringExtract:int	= 0x35;// Stack IN: string, index, count, OUT: substring
	    public static const sactionMBCharToAscii:int	= 0x36;// Stack IN: character, OUT: ASCII code
	    public static const sactionMBAsciiToChar:int	= 0x37;// Stack IN: ASCII code, OUT: character
	
	// Flash 5 actions
	//unused OK to reuse --> public static final     public static const sactionGetLastKeyCode= 0x38; // Stack OUT: code for last key pressed
	    public static const sactionDelete:int			= 0x3A; // Stack IN: name of object to delete
	    public static const sactionDefineFunction:int	= 0x9B; // name (STRING), body (BYTES)
	    public static const sactionDelete2:int			= 0x3B; // Stack IN: name
	    public static const sactionDefineLocal:int		= 0x3C; // Stack IN: name, value
	    public static const sactionCallFunction:int		= 0x3D; // Stack IN: function, numargs, arg1, arg2, ... argn
	    public static const sactionReturn:int			= 0x3E; // Stack IN: value to return
	    public static const sactionModulo:int			= 0x3F; // Stack IN: x, y Stack OUT: x % y
	    public static const sactionNewObject:int		= 0x40; // like CallFunction but constructs object
	    public static const sactionDefineLocal2:int		= 0x41; // Stack IN: name
	    public static const sactionInitArray:int		= 0x42; // Stack IN: //# of elems, arg1, arg2, ... argn
	    public static const sactionInitObject:int		= 0x43; // Stack IN: //# of elems, arg1, name1, ...
	    public static const sactionTypeOf:int			= 0x44; // Stack IN: object, Stack OUT: type of object
	    public static const sactionTargetPath:int		= 0x45; // Stack IN: object, Stack OUT: target path
	    public static const sactionEnumerate:int		= 0x46; // Stack IN: name, Stack OUT: children ended by null
	    public static const sactionStoreRegister:int	= 0x87; // register number (BYTE, 0-31)
	    public static const sactionAdd2:int				= 0x47; // Like sactionAdd, but knows about types
	    public static const sactionLess2:int			= 0x48; // Like sactionLess, but knows about types
	    public static const sactionEquals2:int			= 0x49; // Like sactionEquals, but knows about types
	    public static const sactionToNumber:int			= 0x4A; // Stack IN: object Stack OUT: number
	    public static const sactionToString:int			= 0x4B; // Stack IN: object Stack OUT: string
	    public static const sactionPushDuplicate:int	= 0x4C; // pushes duplicate of top of stack
	    public static const sactionStackSwap:int		= 0x4D; // swaps top two items on stack
	    public static const sactionGetMember:int		= 0x4E; // Stack IN: object, name, Stack OUT: value
	    public static const sactionSetMember:int		= 0x4F; // Stack IN: object, name, value
	    public static const sactionIncrement:int		= 0x50; // Stack IN: value, Stack OUT: value+1
	    public static const sactionDecrement:int		= 0x51; // Stack IN: value, Stack OUT: value-1
	    public static const sactionCallMethod:int		= 0x52; // Stack IN: object, name, numargs, arg1, arg2, ... argn
	    public static const sactionNewMethod:int		= 0x53; // Like sactionCallMethod but constructs object
	    public static const sactionWith:int				= 0x94; // body length: int, Stack IN: object
	    public static const sactionConstantPool:int		= 0x88; // Attaches constant pool
	    public static const sactionStrictMode:int		= 0x89; // Activate/deactivate strict mode
	
	    public static const sactionBitAnd:int			= 0x60; // Stack IN: number, number, OUT: number
	    public static const sactionBitOr:int 			= 0x61; // Stack IN: number, number, OUT: number
	    public static const sactionBitXor:int			= 0x62; // Stack IN: number, number, OUT: number
	    public static const sactionBitLShift:int		= 0x63; // Stack IN: number, number, OUT: number
	    public static const sactionBitRShift:int		= 0x64; // Stack IN: number, number, OUT: number
	    public static const sactionBitURShift:int		= 0x65; // Stack IN: number, number, OUT: number
	
	// Flash 6 actions
	    public static const sactionInstanceOf:int		= 0x54; // Stack IN: object, class OUT: boolean
	    public static const sactionEnumerate2:int		= 0x55; // Stack IN: object, Stack OUT: children ended by null
	    public static const sactionStrictEquals:int		= 0x66; // Stack IN: something, something, OUT: bool
	    public static const sactionGreater:int			= 0x67; // Stack IN: something, something, OUT: bool
	    public static const sactionStringGreater:int	= 0x68; // Stack IN: something, something, OUT: bool
	
	// Flash 7 actions
	    public static const sactionDefineFunction2:int	= 0x8E; // name (STRING), numParams (WORD), registerCount (BYTE)
	    public static const sactionTry:int				= 0x8F;
	    public static const sactionThrow:int			= 0x2A;
	    public static const sactionCastOp:int			= 0x2B;
	    public static const sactionImplementsOp:int		= 0x2C;
	
	    public static const sactionExtends:int			= 0x69; // stack in: baseclass, classname, constructor
	
	    public static const sactionNop:int				= 0x77;  // nop
	    public static const sactionHalt:int				= 0x5F;  // halt script execution
	
	// Reserved for Quicktime
	    public static const sactionQuickTime:int		= 0xAA; // I think this is what they are using...
	
	    public static const kPushStringType:int			= 0;
	    public static const kPushFloatType:int			= 1;
	    public static const kPushNullType:int			= 2;
	    public static const kPushUndefinedType:int		= 3;
	    public static const kPushRegisterType:int		= 4;
	    public static const kPushBooleanType:int		= 5;
	    public static const kPushDoubleType:int			= 6;
	    public static const kPushIntegerType:int		= 7;
	    public static const kPushConstant8Type:int		= 8;
	    public static const kPushConstant16Type:int		= 9;
	
	// GetURL2 methods
	
	    public static const kHttpDontSend:int			= 0x0000;
	    public static const kHttpSendUseGet:int			= 0x0001;
	    public static const kHttpSendUsePost:int		= 0x0002;
	    public static const kHttpMethodMask:int			= 0x0003;
	    public static const kHttpLoadTarget:int			= 0x0040;
	    public static const kHttpLoadVariables:int		= 0x0080;
	//    //#ifdef FAP
	//        public static const kHttpIsFAP = 0x0200;
	//#endif
	
	    public static const kClipEventLoad:int			= 0x0001;
	    public static const kClipEventEnterFrame:int	= 0x0002;
	    public static const kClipEventUnload:int		= 0x0004;
	    public static const kClipEventMouseMove:int		= 0x0008;
	    public static const kClipEventMouseDown:int		= 0x0010;
	    public static const kClipEventMouseUp:int		= 0x0020;
	    public static const kClipEventKeyDown:int		= 0x0040;
	    public static const kClipEventKeyUp:int			= 0x0080;
	    public static const kClipEventData:int			= 0x0100;
	    public static const kClipEventInitialize:int	= 0x00200;
	    public static const kClipEventPress:int			= 0x00400;
	    public static const kClipEventRelease:int		= 0x00800;
	    public static const kClipEventReleaseOutside:int = 0x01000;
	    public static const kClipEventRollOver:int		= 0x02000;
	    public static const kClipEventRollOut:int		= 0x04000;
	    public static const kClipEventDragOver:int		= 0x08000;
	    public static const kClipEventDragOut:int		= 0x10000;
	    public static const kClipEventKeyPress:int		= 0x20000;
	    public static const kClipEventConstruct:int		= 0x40000;
	    public static const kTryHasCatchFlag:int		= 1;
	    public static const kTryHasFinallyFlag:int	= 2;
	    public static const kTryCatchRegisterFlag:int	= 4;
	}
}