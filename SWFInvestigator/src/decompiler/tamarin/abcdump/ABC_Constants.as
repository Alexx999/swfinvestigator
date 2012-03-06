/* -*- tab-width: 4 -*- */
/* vi: set ts=4 sw=4 expandtab: (add to ~/.vimrc: set modeline modelines=5) */
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

// This file is to be included in its clients

internal const TAB:String = "  ";

// method flags
internal const NEED_ARGUMENTS:int = 		0x01
internal const NEED_ACTIVATION:int = 	0x02
internal const NEED_REST:int = 			0x04
internal const HAS_OPTIONAL:int = 		0x08
internal const IGNORE_REST:int = 		0x10
internal const NATIVE:int =				0x20
internal const HAS_ParamNames:int =      0x80

internal const CONSTANT_Utf8					:int = 0x01
internal const CONSTANT_Int					:int = 0x03
internal const CONSTANT_UInt					:int = 0x04
internal const CONSTANT_PrivateNs			:int = 0x05 // non-shared namespace
internal const CONSTANT_Double				:int = 0x06
internal const CONSTANT_Qname				:int = 0x07 // o.ns::name, ct ns, ct name
internal const CONSTANT_Namespace			:int = 0x08
internal const CONSTANT_Multiname			:int = 0x09 // o.name, ct nsset, ct name
internal const CONSTANT_False				:int = 0x0A
internal const CONSTANT_True					:int = 0x0B
internal const CONSTANT_Null					:int = 0x0C
internal const CONSTANT_QnameA				:int = 0x0D // o.@ns::name, ct ns, ct attr-name
internal const CONSTANT_MultinameA			:int = 0x0E // o.@name, ct attr-name
internal const CONSTANT_RTQname				:int = 0x0F // o.ns::name, rt ns, ct name
internal const CONSTANT_RTQnameA				:int = 0x10 // o.@ns::name, rt ns, ct attr-name
internal const CONSTANT_RTQnameL				:int = 0x11 // o.ns::[name], rt ns, rt name
internal const CONSTANT_RTQnameLA			:int = 0x12 // o.@ns::[name], rt ns, rt attr-name
internal const CONSTANT_NameL				:int = 0x13	// o.[], ns=public implied, rt name
internal const CONSTANT_NameLA				:int = 0x14 // o.@[], ns=public implied, rt attr-name
internal const CONSTANT_NamespaceSet			:int = 0x15
internal const CONSTANT_PackageNs			:int = 0x16
internal const CONSTANT_PackageInternalNs	:int = 0x17
internal const CONSTANT_ProtectedNs			:int = 0x18
internal const CONSTANT_StaticProtectedNs	:int = 0x19
internal const CONSTANT_StaticProtectedNs2	:int = 0x1a
internal const CONSTANT_MultinameL           :int = 0x1B
internal const CONSTANT_MultinameLA          :int = 0x1C
internal const CONSTANT_TypeName             :int = 0x1D

internal const constantKinds:Array = [ "0", "utf8", "2",
	"int", "uint", "private", "double", "qname", "namespace",
	"multiname", "false", "true", "null", "@qname", "@multiname", "rtqname",
	"@rtqname", "[qname]", "@[qname]", "[name]", "@[name]", "nsset", "packagens",
	"packageinternalns", "protectedns", "staticprotectedns", "staticprotectedns2",
	"multiname", "multiname2", "typename"

]

internal const TRAIT_Slot		:int = 0x00
internal const TRAIT_Method		:int = 0x01
internal const TRAIT_Getter		:int = 0x02
internal const TRAIT_Setter		:int = 0x03
internal const TRAIT_Class		:int = 0x04
internal const TRAIT_Function	:int = 0x05
internal const TRAIT_Const		:int = 0x06

internal const traitKinds:Array = [
	"var", "function", "function get", "function set", "class", "function", "internal const"
]
	

internal const ATTR_final:int = 0x01; // 1=final, 0=virtual
internal const ATTR_override:int = 0x02; // 1=override, 0=new
internal const ATTR_metadata:int = 0x04; // 1=has metadata, 0=no metadata
internal const ATTR_public:int = 0x08; // 1=add public namespace

public const CLASS_FLAG_sealed:int = 0x01;
public const CLASS_FLAG_final:int = 0x02;
public const CLASS_FLAG_interface:int = 0x04;

//--------------------------------------------
//End abc-constants.as
//---------------------------------------------

//----------------------------------------------
//Start opcode-table.as / swfdump code
//----------------------------------------------

internal const OP_bkpt:int = 0x01
internal const OP_nop:int = 0x02
internal const OP_throw:int = 0x03
internal const OP_getsuper:int = 0x04
internal const OP_setsuper:int = 0x05
internal const OP_dxns:int = 0x06
internal const OP_dxnslate:int = 0x07
internal const OP_kill:int = 0x08
internal const OP_label:int = 0x09
internal const OP_ifnlt:int = 0x0C
internal const OP_ifnle:int = 0x0D
internal const OP_ifngt:int = 0x0E
internal const OP_ifnge:int = 0x0F
internal const OP_jump:int = 0x10
internal const OP_iftrue:int = 0x11
internal const OP_iffalse:int = 0x12
internal const OP_ifeq:int = 0x13
internal const OP_ifne:int = 0x14
internal const OP_iflt:int = 0x15
internal const OP_ifle:int = 0x16
internal const OP_ifgt:int = 0x17
internal const OP_ifge:int = 0x18
internal const OP_ifstricteq:int = 0x19
internal const OP_ifstrictne:int = 0x1A
internal const OP_lookupswitch:int = 0x1B
internal const OP_pushwith:int = 0x1C
internal const OP_popscope:int = 0x1D
internal const OP_nextname:int = 0x1E
internal const OP_hasnext:int = 0x1F
internal const OP_pushnull:int = 0x20
internal const OP_pushundefined:int = 0x21
internal const OP_pushconstant:int = 0x22
internal const OP_nextvalue:int = 0x23
internal const OP_pushbyte:int = 0x24
internal const OP_pushshort:int = 0x25
internal const OP_pushtrue:int = 0x26
internal const OP_pushfalse:int = 0x27
internal const OP_pushnan:int = 0x28
internal const OP_pop:int = 0x29
internal const OP_dup:int = 0x2A
internal const OP_swap:int = 0x2B
internal const OP_pushstring:int = 0x2C
internal const OP_pushint:int = 0x2D
internal const OP_pushuint:int = 0x2E
internal const OP_pushdouble:int = 0x2F
internal const OP_pushscope:int = 0x30
internal const OP_pushnamespace:int = 0x31
internal const OP_hasnext2:int = 0x32
internal const OP_li8:int = 0x35
internal const OP_li16:int = 0x36
internal const OP_li32:int = 0x37
internal const OP_lf32:int = 0x38
internal const OP_lf64:int = 0x39
internal const OP_si8:int = 0x3A
internal const OP_si16:int = 0x3B
internal const OP_si32:int = 0x3C
internal const OP_sf32:int = 0x3D
internal const OP_sf64:int = 0x3E
internal const OP_newfunction:int = 0x40
internal const OP_call:int = 0x41
internal const OP_construct:int = 0x42
internal const OP_callmethod:int = 0x43
internal const OP_callstatic:int = 0x44
internal const OP_callsuper:int = 0x45
internal const OP_callproperty:int = 0x46
internal const OP_returnvoid:int = 0x47
internal const OP_returnvalue:int = 0x48
internal const OP_constructsuper:int = 0x49
internal const OP_constructprop:int = 0x4A
internal const OP_callsuperid:int = 0x4B
internal const OP_callproplex:int = 0x4C
internal const OP_callinterface:int = 0x4D
internal const OP_callsupervoid:int = 0x4E
internal const OP_callpropvoid:int = 0x4F
internal const OP_sxi1:int = 0x50
internal const OP_sxi8:int = 0x51
internal const OP_sxi16:int = 0x52
internal const OP_applytype:int = 0x53
internal const OP_newobject:int = 0x55
internal const OP_newarray:int = 0x56
internal const OP_newactivation:int = 0x57
internal const OP_newclass:int = 0x58
internal const OP_getdescendants:int = 0x59
internal const OP_newcatch:int = 0x5A
internal const OP_findpropstrict:int = 0x5D
internal const OP_findproperty:int = 0x5E
internal const OP_finddef:int = 0x5F
internal const OP_getlex:int = 0x60
internal const OP_setproperty:int = 0x61
internal const OP_getlocal:int = 0x62
internal const OP_setlocal:int = 0x63
internal const OP_getglobalscope:int = 0x64
internal const OP_getscopeobject:int = 0x65
internal const OP_getproperty:int = 0x66
internal const OP_getouterscope:int = 0x67
internal const OP_initproperty:int = 0x68
internal const OP_setpropertylate:int = 0x69
internal const OP_deleteproperty:int = 0x6A
internal const OP_deletepropertylate:int = 0x6B
internal const OP_getslot:int = 0x6C
internal const OP_setslot:int = 0x6D
internal const OP_getglobalslot:int = 0x6E
internal const OP_setglobalslot:int = 0x6F
internal const OP_convert_s:int = 0x70
internal const OP_esc_xelem:int = 0x71
internal const OP_esc_xattr:int = 0x72
internal const OP_convert_i:int = 0x73
internal const OP_convert_u:int = 0x74
internal const OP_convert_d:int = 0x75
internal const OP_convert_b:int = 0x76
internal const OP_convert_o:int = 0x77
internal const OP_checkfilter:int = 0x78;
internal const OP_coerce:int = 0x80
internal const OP_coerce_b:int = 0x81
internal const OP_coerce_a:int = 0x82
internal const OP_coerce_i:int = 0x83
internal const OP_coerce_d:int = 0x84
internal const OP_coerce_s:int = 0x85
internal const OP_astype:int = 0x86
internal const OP_astypelate:int = 0x87
internal const OP_coerce_u:int = 0x88
internal const OP_coerce_o:int = 0x89
internal const OP_negate:int = 0x90
internal const OP_increment:int = 0x91
internal const OP_inclocal:int = 0x92
internal const OP_decrement:int = 0x93
internal const OP_declocal:int = 0x94
internal const OP_typeof:int = 0x95
internal const OP_not:int = 0x96
internal const OP_bitnot:int = 0x97
internal const OP_concat:int = 0x9A;
internal const OP_add_d:int = 0x9B
internal const OP_add:int = 0xA0
internal const OP_subtract:int = 0xA1
internal const OP_multiply:int = 0xA2
internal const OP_divide:int = 0xA3
internal const OP_modulo:int = 0xA4
internal const OP_lshift:int = 0xA5
internal const OP_rshift:int = 0xA6
internal const OP_urshift:int = 0xA7
internal const OP_bitand:int = 0xA8
internal const OP_bitor:int = 0xA9
internal const OP_bitxor:int = 0xAA
internal const OP_equals:int = 0xAB
internal const OP_strictequals:int = 0xAC
internal const OP_lessthan:int = 0xAD
internal const OP_lessequals:int = 0xAE
internal const OP_greaterthan:int = 0xAF
internal const OP_greaterequals:int = 0xB0
internal const OP_instanceof:int = 0xB1
internal const OP_istype:int = 0xB2
internal const OP_istypelate:int = 0xB3
internal const OP_in:int = 0xB4
internal const OP_increment_i:int = 0xC0
internal const OP_decrement_i:int = 0xC1
internal const OP_inclocal_i:int = 0xC2
internal const OP_declocal_i:int = 0xC3
internal const OP_negate_i:int = 0xC4
internal const OP_add_i:int = 0xC5
internal const OP_subtract_i:int = 0xC6
internal const OP_multiply_i:int = 0xC7
internal const OP_getlocal0:int = 0xD0
internal const OP_getlocal1:int = 0xD1
internal const OP_getlocal2:int = 0xD2
internal const OP_getlocal3:int = 0xD3
internal const OP_setlocal0:int = 0xD4
internal const OP_setlocal1:int = 0xD5
internal const OP_setlocal2:int = 0xD6
internal const OP_setlocal3:int = 0xD7
internal const OP_debug:int = 0xEF
internal const OP_debugline:int = 0xF0
internal const OP_debugfile:int = 0xF1
internal const OP_bkptline:int = 0xF2
internal const OP_timestamp:int = 0xF3;
internal const OP_verifypass:int = 0xF5;
internal const OP_alloc:int = 0xF6;
internal const OP_mark:int = 0xF7;
internal const OP_wb:int = 0xF8;
internal const OP_prologue:int = 0xF9;
internal const OP_sendenter:int = 0xFA;
internal const OP_doubletoatom:int = 0xFB;
internal const OP_sweep:int = 0xFC;
internal const OP_codegenop:int = 0xFD;
internal const OP_verifyop:int = 0xFE;
internal const OP_decode:int = 0xFF;

internal const opNames:Array = [
	"OP_0x00       ",
	"bkpt          ",
	"nop           ",
	"throw         ",
	"getsuper      ",
	"setsuper      ",
	"dxns          ",
	"dxnslate      ",
	"kill          ",
	"label         ",
	"OP_0x0A       ",
	"OP_0x0B       ",
	"ifnlt         ",
	"ifnle         ",
	"ifngt         ",
	"ifnge         ",
	"jump          ",
	"iftrue        ",
	"iffalse       ",
	"ifeq          ",
	"ifne          ",
	"iflt          ",
	"ifle          ",
	"ifgt          ",
	"ifge          ",
	"ifstricteq    ",
	"ifstrictne    ",
	"lookupswitch  ",
	"pushwith      ",
	"popscope      ",
	"nextname      ",
	"hasnext       ",
	"pushnull      ",
	"pushundefined ",
	"pushconstant  ",
	"nextvalue     ",
	"pushbyte      ",
	"pushshort     ",
	"pushtrue      ",
	"pushfalse     ",
	"pushnan       ",
	"pop           ",
	"dup           ",
	"swap          ",
	"pushstring    ",
	"pushint       ",
	"pushuint      ",
	"pushdouble    ",
	"pushscope     ",
	"pushnamespace ",
	"hasnext2      ",
	"OP_0x33       ", // lix8 (internal)
	"OP_0x34       ", // lix16 (internal)
	"li8           ",
	"li16          ",
	"li32          ",
	"lf32          ",
	"lf64          ",
	"si8           ",
	"si16          ",
	"si32          ",
	"sf32          ",
	"sf64          ",
	"OP_0x3F       ",
	"newfunction   ",
	"call          ",
	"construct     ",
	"callmethod    ",
	"callstatic    ",
	"callsuper     ",
	"callproperty  ",
	"returnvoid    ",
	"returnvalue   ",
	"constructsuper",
	"constructprop ",
	"callsuperid   ",
	"callproplex   ",
	"callinterface ",
	"callsupervoid ",
	"callpropvoid  ",
	"sxi1          ",
	"sxi8          ",
	"sxi16         ",
	"applytype     ",
	"OP_0x54       ",
	"newobject     ",
	"newarray      ",
	"newactivation ",
	"newclass      ",
	"getdescendants",
	"newcatch      ",
	"OP_0x5B       ", // findpropglobalstrict (internal)
	"OP_0x5C       ", // findpropglobal (internal)
	"findpropstrict",
	"findproperty  ",
	"finddef       ",
	"getlex        ",
	"setproperty   ",
	"getlocal      ",
	"setlocal      ",
	"getglobalscope",
	"getscopeobject",
	"getproperty   ",
	"getouterscope ",
	"initproperty  ",
	"OP_0x69       ",
	"deleteproperty",
	"OP_0x6B       ",
	"getslot       ",
	"setslot       ",
	"getglobalslot ",
	"setglobalslot ",
	"convert_s     ",
	"esc_xelem     ",
	"esc_xattr     ",
	"convert_i     ",
	"convert_u     ",
	"convert_d     ",
	"convert_b     ",
	"convert_o     ",
	"checkfilter   ",
	"OP_0x79       ",
	"OP_0x7A       ",
	"OP_0x7B       ",
	"OP_0x7C       ",
	"OP_0x7D       ",
	"OP_0x7E       ",
	"OP_0x7F       ",
	"coerce        ",
	"coerce_b      ",
	"coerce_a      ",
	"coerce_i      ",
	"coerce_d      ",
	"coerce_s      ",
	"astype        ",
	"astypelate    ",
	"coerce_u      ",
	"coerce_o      ",
	"OP_0x8A       ",
	"OP_0x8B       ",
	"OP_0x8C       ",
	"OP_0x8D       ",
	"OP_0x8E       ",
	"OP_0x8F       ",
	"negate        ",
	"increment     ",
	"inclocal      ",
	"decrement     ",
	"declocal      ",
	"typeof        ",
	"not           ",
	"bitnot        ",
	"OP_0x98       ",
	"OP_0x99       ",
	"concat        ",
	"add_d         ",
	"OP_0x9C       ",
	"OP_0x9D       ",
	"OP_0x9E       ",
	"OP_0x9F       ",
	"add           ",
	"subtract      ",
	"multiply      ",
	"divide        ",
	"modulo        ",
	"lshift        ",
	"rshift        ",
	"urshift       ",
	"bitand        ",
	"bitor         ",
	"bitxor        ",
	"equals        ",
	"strictequals  ",
	"lessthan      ",
	"lessequals    ",
	"greaterthan   ",
	"greaterequals ",
	"instanceof    ",
	"istype        ",
	"istypelate    ",
	"in            ",
	"OP_0xB5       ",
	"OP_0xB6       ",
	"OP_0xB7       ",
	"OP_0xB8       ",
	"OP_0xB9       ",
	"OP_0xBA       ",
	"OP_0xBB       ",
	"OP_0xBC       ",
	"OP_0xBD       ",
	"OP_0xBE       ",
	"OP_0xBF       ",
	"increment_i   ",
	"decrement_i   ",
	"inclocal_i    ",
	"declocal_i    ",
	"negate_i      ",
	"add_i         ",
	"subtract_i    ",
	"multiply_i    ",
	"OP_0xC8       ",
	"OP_0xC9       ",
	"OP_0xCA       ",
	"OP_0xCB       ",
	"OP_0xCC       ",
	"OP_0xCD       ",
	"OP_0xCE       ",
	"OP_0xCF       ",
	"getlocal0     ",
	"getlocal1     ",
	"getlocal2     ",
	"getlocal3     ",
	"setlocal0     ",
	"setlocal1     ",
	"setlocal2     ",
	"setlocal3     ",
	"OP_0xD8       ",
	"OP_0xD9       ",
	"OP_0xDA       ",
	"OP_0xDB       ",
	"OP_0xDC       ",
	"OP_0xDD       ",
	"OP_0xDE       ",
	"OP_0xDF       ",
	"OP_0xE0       ",
	"OP_0xE1       ",
	"OP_0xE2       ",
	"OP_0xE3       ",
	"OP_0xE4       ",
	"OP_0xE5       ",
	"OP_0xE6       ",
	"OP_0xE7       ",
	"OP_0xE8       ",
	"OP_0xE9       ",
	"OP_0xEA       ",
	"OP_0xEB       ",
	"OP_0xEC       ",
	"OP_0xED       ",
	"OP_0xEE       ",
	"debug         ",
	"debugline     ",
	"debugfile     ",
	"bkptline      ",
	"timestamp     ",
	"OP_0xF4       ",
	"verifypass    ",
	"alloc         ",
	"mark          ",
	"wb            ",
	"prologue      ",
	"sendenter     ",
	"doubletoatom  ",
	"sweep         ",
	"codegenop     ",
	"verifyop      ",
	"decode        "
];