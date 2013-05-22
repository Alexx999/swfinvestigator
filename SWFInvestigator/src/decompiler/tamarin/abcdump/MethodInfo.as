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

package decompiler.tamarin.abcdump
{
	import decompiler.tamarin.abcdump.Abc;
	import decompiler.tamarin.abcdump.LabelInfo;
	import decompiler.tamarin.abcdump.MemberInfo;
	
	import flash.utils.ByteArray;
	
	internal class MethodInfo extends MemberInfo
	{
		include "ABC_Constants.as";
		
		/**
		 * Inherited from MemberInfo
		 * public var id:int;
		 * public var kind:int;
		 * public var name:String;
		 * public var metadata:Array;
		 * public var nIndex:uint
		 */
		
		public var method_id:int;
		public var dumped:Boolean;
		public var flags:int;
		public var debugName:String;
		public var paramTypes:Array;
		public var optionalValues:Array;
		//Some SWFs break when TypeName assigned to QName
		//public var returnType:QName;
		public var returnType:String;
		public var local_count:int;
		public var max_scope:int;
		public var max_stack:int;
		private var code_length:uint;
		public var code:ByteArray;
		public var activation:Traits;
		
		//Added by SWF Investigator
		public var mDefPosition:uint;
		public var codePosition:uint;
		
		public function toString():String
		{
			return format();
		}
		
		public function format():String
		{
			var name:String = this.name ? this.name : "function";
			
			return name + "(" + paramTypes + "):" + returnType + "\t/* disp_id=" + id + " method_id=" + method_id + " nameIndex = " + this.nIndex + " */";
		}
		
		public function dump(abc:Abc, indent:String, attr:String=""):void
		{
			//refactor by SWF Investigator
			var target:uint;
			var i:int;
			
			dumped = true;
			abc.log.print("\r");
			
			if (this.metadata) {
				for each (var md:MetaData in this.metadata)
				abc.log.print(indent+md + "\r");
			}
			
			var s:String = "";
			if (flags & NATIVE)
				s = "native ";
			s += traitKinds[kind] + " ";
			
			abc.log.print(indent+attr+s+format() + "\r");
			
			if (code)
			{
				abc.log.print(indent+"{\r");
				var oldindent:String = indent;
				indent += TAB;
				
				if (flags & NEED_ACTIVATION) {
					abc.log.print(indent+"activation {\r");
					activation.dump(abc, indent+TAB, "");
					abc.log.print(indent+"}\r");
				}
				
				abc.log.print(indent+"// local_count="+local_count+
					" max_scope=" + max_scope +
					" max_stack=" + max_stack +
					" code_len=" + code.length + "\r");
				
				abc.log.print(indent+"// method position=" + this.mDefPosition + " code position=" + this.codePosition + "\r");
				
				code.position = 0;
				var labels:LabelInfo = new LabelInfo();
				
				while (code.bytesAvailable > 0)
				{
					var start:int = code.position;
					s = indent + start;
					while (s.length < 12) s += ' ';
					
					var opcode:uint = code.readUnsignedByte();
					
					if (opcode == OP_label || ((code.position-1) in labels)) {
						abc.log.print(indent + "\r");
						abc.log.print(indent + labels.labelFor(code.position-1) + ": \r");
					}
					
					s += opNames[opcode];
					s += opNames[opcode].length < 8 ? "\t\t" : "\t";
					
					//Si Change
					var nameIndex:uint;
					
					switch(opcode)
					{
						case OP_debugfile:
						case OP_pushstring:
							nameIndex = readU32();
							s += '"' + abc.strings[nameIndex].replace(/\n/g,"\\n").replace(/\t/g,"\\t") + '"  //stringIndex = ' + nameIndex;
							break
						case OP_pushnamespace:
							s += abc.namespaces[readU32()];
							break
						case OP_pushint:
							i = abc.ints[readU32()];
							s += i + "\t// 0x" + i.toString(16);
							break
						case OP_pushuint:
							var u:uint = abc.uints[readU32()];
							s += u + "\t// 0x" + u.toString(16);
							break;
						case OP_pushdouble:
							s += abc.doubles[readU32()];
							break;
						case OP_getsuper: 
						case OP_setsuper: 
						case OP_getproperty: 
						case OP_initproperty: 
						case OP_setproperty: 
						case OP_getlex: 
						case OP_findpropstrict: 
						case OP_findproperty:
						case OP_finddef:
						case OP_deleteproperty: 
						case OP_istype: 
						case OP_coerce: 
						case OP_astype: 
						case OP_getdescendants:
							nameIndex = readU32();
							s += abc.names[nameIndex] + " //nameIndex = " + nameIndex;
							break;
						case OP_constructprop:
						case OP_callproperty:
						case OP_callproplex:
						case OP_callsuper:
						case OP_callsupervoid:
						case OP_callpropvoid:
							nameIndex = readU32();
							s += abc.names[nameIndex];
							s += " (" + readU32() + ") //nameIndex = " + nameIndex;
							break;
						case OP_newfunction: {
							var method_id:uint = readU32();
							s += abc.methods[method_id];
							break;
						}
						case OP_callstatic:
							s += abc.methods[readU32()];
							s += " (" + readU32() + ")";
							break;
						case OP_newclass: 
							s += abc.instances[readU32()]
							break;
						case OP_lookupswitch:
							var pos:uint = code.position-1;
							target = pos + readS24();
							var maxindex:uint = readU32();
							s += "default:" + labels.labelFor(target); // target + "("+(target-pos)+")"
							s += " maxcase:" + maxindex;
							for (i=0; i <= maxindex; i++) {
								target = pos + readS24();
								s += " " + labels.labelFor(target); // target + "("+(target-pos)+")"
							}
							break;
						case OP_jump:
						case OP_iftrue:     case OP_iffalse:
						case OP_ifeq:       case OP_ifne:
						case OP_ifge:       case OP_ifnge:
						case OP_ifgt:       case OP_ifngt:
						case OP_ifle:       case OP_ifnle:
						case OP_iflt:       case OP_ifnlt:
						case OP_ifstricteq: case OP_ifstrictne:
							var offset:int = readS24();
							target = code.position+offset;
							//s += target + " ("+offset+")"
							s += labels.labelFor(target);
							if (!((code.position) in labels))
								s += "\n";
							break;
						case OP_inclocal:
						case OP_declocal:
						case OP_inclocal_i:
						case OP_declocal_i:
						case OP_getlocal:
						case OP_kill:
						case OP_setlocal:
						case OP_debugline:
						case OP_getglobalslot:
						case OP_getslot:
						case OP_setglobalslot:
						case OP_setslot:
						case OP_pushshort:
						case OP_newcatch:
							s += readU32()
							break
						case OP_debug:
							s += code.readUnsignedByte(); 
							s += " " + readU32();
							s += " " + code.readUnsignedByte();
							s += " " + readU32();
							break;
						case OP_newobject:
							s += "{" + readU32() + "}";
							break;
						case OP_newarray:
							s += "[" + readU32() + "]";
							break;
						case OP_call:
						case OP_construct:
						case OP_constructsuper:
						case OP_applytype:
							s += "(" + readU32() + ")";
							break;
						case OP_pushbyte:
						case OP_getscopeobject:
							s += code.readByte();
							break;
						case OP_hasnext2:
							s += readU32() + " " + readU32();
						default:
							if (opNames[opcode] == ("0x"+opcode.toString(16).toUpperCase()))
							   s += " UNKNOWN OPCODE";
							break
					}
					var size:int = code.position - start;
					abc.totalSize += size;
					abc.opSizes[opcode] = int(abc.opSizes[opcode]) + size;
					abc.log.print(s + "\r");
				}
				abc.log.print(oldindent+"}\r");
			}
		}
		
		//SWF Investigator changed to uint
		private function readU32():uint
		{
			var result:uint = code.readUnsignedByte();
			if (!(result & 0x00000080))
				return result;
			result = result & 0x0000007f | code.readUnsignedByte()<<7;
			if (!(result & 0x00004000))
				return result;
			result = result & 0x00003fff | code.readUnsignedByte()<<14;
			if (!(result & 0x00200000))
				return result;
			result = result & 0x001fffff | code.readUnsignedByte()<<21;
			if (!(result & 0x10000000))
				return result;
			return   result & 0x0fffffff | code.readUnsignedByte()<<28;
		}
		
		private function readS24():int
		{
			var b:int = code.readUnsignedByte();
			b |= code.readUnsignedByte()<<8;
			b |= code.readByte()<<16;
			return b;
		}
	}
}