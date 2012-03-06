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
	import decompiler.Logging.ILog;
	import decompiler.tamarin.abcdump.Multiname;
	import decompiler.tamarin.abcdump.Traits;
	import decompiler.tamarin.abcdump.TypeName;
	
	import flash.utils.ByteArray;
	
	//Used by Swf.as
	//Used by MethodInfo.as
	public class Abc
	{
		include "ABC_Constants.as";
		
		private var data:ByteArray
		
		public var major:int;
		public var minor:int;
		
		public var ints:Array;
		public var uints:Array;
		public var doubles:Array;
		public var strings:Array;
		public var namespaces:Array;
		public var nssets:Array;
		public var names:Array;
		
		public var defaults:Array = new Array(constantKinds.length);
		
		public var methods:Array;
		public var instances:Array;
		public var classes:Array;
		public var scripts:Array;
		private var metadata:Array;
		
		public var publicNs:Namespace = new Namespace("");
		public var anyNs:Namespace = new Namespace("*");
		
		private var magic:int;
		
		//Added by SWF Investigator
		public var totalSize:int;
		public var opSizes:Array = new Array(256);
		public var log:ILog;
		public var verboseOut:Boolean = false;
		
		private var infoIndent:String;
		
		public function Abc(data:ByteArray, logger:ILog, verboseFlag:Boolean = false, infoSpace:String = "")
		{
			
			//Added by SWF Investigator
			this.log = logger;
			this.verboseOut = verboseFlag;
			this.infoIndent = infoSpace;
			
			data.position = 0;
			this.data = data;
			this.magic = data.readInt();
			
			if (this.verboseOut) {
				verbose(data.position-4, "ABC MAGIC. Version="+(magic>>16)+"."+(magic%65536));
			}
			
			this.log.print(infoIndent + "magic " + magic.toString(16) + "\r")
			
			switch (magic) {
				case (46<<16|14):
				case (46<<16|15):
				case (46<<16|16):
				case (47<<16|12):
				case (47<<16|13):
				case (47<<16|14):
				case (47<<16|15):
				case (47<<16|16):
				case (47<<16|17):
				case (47<<16|18):
				case (47<<16|19):
				case (47<<16|20):
					break;
				default:
					throw new Error("not an abc file.  magic=" + magic.toString(16))
			}
			
			parseCpool();
			
			defaults[CONSTANT_Utf8] = strings;
			defaults[CONSTANT_Int] = ints;
			defaults[CONSTANT_UInt] = uints;
			defaults[CONSTANT_Double] = doubles;
			defaults[CONSTANT_Int] = ints;
			defaults[CONSTANT_False] = { 10:false };
			defaults[CONSTANT_True] = { 11:true };
			defaults[CONSTANT_Namespace] = namespaces;
			defaults[CONSTANT_PrivateNs] = namespaces;
			defaults[CONSTANT_PackageNs] = namespaces;
			defaults[CONSTANT_PackageInternalNs] = namespaces;
			defaults[CONSTANT_ProtectedNs] = namespaces;
			defaults[CONSTANT_StaticProtectedNs] = namespaces;
			defaults[CONSTANT_StaticProtectedNs2] = namespaces;
			defaults[CONSTANT_Null] = { 12: null };
			
			parseMethodInfos();
			parseMetadataInfos();
			parseInstanceInfos();
			parseClassInfos();
			parseScriptInfos();
			parseMethodBodies();
			
			//if (doExtractAbc==true)
			//	data.writeFile(nextAbcFname());
		}
		
		//Taken from EvalES4UI
		private function verbose(start:uint, comment:String):void {
			var b:ByteArray = data;
			var s:String =("000000"+start.toString(16)).substr(-6,6)+"  ";
			for (var i:int=start;i<b.position;i++) {
				var c:int = b[i];
				s+= ("0"+c.toString(16)).substr(-2,2)+" ";
			}
			s+=" // "+comment;
			this.log.print(s + "\r");
		}
		
		private function readU32():int
		{
			var result:int = data.readUnsignedByte();
			if (!(result & 0x00000080))
				return result;
			result = result & 0x0000007f | data.readUnsignedByte()<<7;
			if (!(result & 0x00004000))
				return result;
			result = result & 0x00003fff | data.readUnsignedByte()<<14;
			if (!(result & 0x00200000))
				return result;
			result = result & 0x001fffff | data.readUnsignedByte()<<21;
			if (!(result & 0x10000000))
				return result;
			return   result & 0x0fffffff | data.readUnsignedByte()<<28;
		}
		
		private function parseCpool():void
		{
			var i:int, j:int;
			var n:int;
			var kind:int;
			
			var start:int = data.position;
			var p:uint = start;
			
			// ints
			n = readU32();
			if (this.verboseOut) {verbose(p, "Pool of "+(n-1)+" int");}
			ints = [0];
			for (i=1; i < n; i++) {
				p = data.position;
				ints[i] = readU32();
				if (this.verboseOut) {verbose(p, "int["+i+"] = "+ints[i]);}
			}
			
			// uints
			p = data.position
			n = readU32();
			uints = [0];
			if (this.verboseOut) {verbose(p, "Pool of "+(n-1)+" int");}
			for (i=1; i < n; i++) {
				p = data.position;
				uints[i] = uint(readU32());
				if (this.verboseOut) {verbose(p, "uint["+i+"] = "+uints[i]);}
			}
			
			// doubles
			p = data.position;
			n = readU32();
			if (this.verboseOut) {verbose(p, "Pool of "+(n-1)+" Number");}
			doubles = [NaN];
			for (i=1; i < n; i++) {
				p = data.position;
				doubles[i] = data.readDouble();
				if (this.verboseOut) {verbose(p, "double["+i+"] = "+doubles[i]);}
			}
			
			this.log.print(this.infoIndent + "Cpool numbers size "+(data.position-start)+" "+int(100*(data.position-start)/data.length)+" %\r")
			start = data.position
			
			// strings
			p = data.position;
			n = readU32();
			if (this.verboseOut) {verbose(p, "Pool of "+(n-1)+" String");}
			strings = [""];
			for (i=1; i < n; i++) {
				p = data.position;
				strings[i] = data.readUTFBytes(readU32());
				if (this.verboseOut) {verbose(p, "String["+i+"] = \""+strings[i]+'"');}
			}
			
			this.log.print(this.infoIndent + "Cpool strings count "+ n +" size "+(data.position-start)+" "+int(100*(data.position-start)/data.length)+" %\r");
			start = data.position;
			
			// namespaces
			p = data.position;
			n = readU32();
			if (this.verboseOut) {verbose(p, "Pool of "+(n-1)+" Namespace");}
			namespaces = [publicNs];
			for (i=1; i < n; i++) {
				p = data.position;
				switch (data.readByte())
				{
					case CONSTANT_Namespace:
					case CONSTANT_PackageNs:
					case CONSTANT_PackageInternalNs:
					case CONSTANT_ProtectedNs:
					case CONSTANT_StaticProtectedNs:
					case CONSTANT_StaticProtectedNs2:
					{
						namespaces[i] = new Namespace(strings[readU32()])
						// todo mark kind of namespace.
						
						var s:String="";
						switch(t) {
							case CONSTANT_Namespace: s="Namespace"; break;
							case CONSTANT_PackageNs: s="Package"; break;
							case CONSTANT_PackageInternalNs: s="Internal Package"; break;
							case CONSTANT_ProtectedNs: s="protected"; break;
							case CONSTANT_StaticProtectedNs: s="static protected"; break;
							case CONSTANT_StaticProtectedNs2: s="static protected(v2)"; break;
						}
						if (this.verboseOut) {verbose(p, "Namespace["+i+"] = "+s+" \""+namespaces[i]+'"');}
						break;
					}
					case CONSTANT_PrivateNs:
						readU32();
						namespaces[i] = new Namespace(null, "private");
						if (this.verboseOut) {verbose(p, "Namespace["+i+"] = \""+namespaces[i]+'"');}
						break;
				}
			}
			
			this.log.print(this.infoIndent + "Cpool namespaces count "+ n +" size "+(data.position-start)+" "+int(100*(data.position-start)/data.length)+" %\r")
			start = data.position;
			
			//SWF Investigator refactor
			var count:uint;
			
			// namespace sets
			p = data.position;
			n = readU32();
			if (this.verboseOut) {verbose(p, "Pool of "+(n-1)+" namespace sets");}
			nssets = [null];
			for (i=1; i < n; i++)
			{
				p = data.position;
				count = readU32();
				if (this.verboseOut) {verbose(p, "nsset["+i+"] has "+count+" namespaces");}
				var nsset:Array = nssets[i] = [];
				for (j=0; j < count; j++) {
					p = data.position;
					nsset[j] = namespaces[readU32()];
					if (this.verboseOut) {verbose(p, "nsset["+i+"]["+j+"] = \""+nsset[j]+"\"");}
				}
			}
			
			this.log.print(this.infoIndent + "Cpool nssets count "+ n +" size "+(data.position-start)+" "+int(100*(data.position-start)/data.length)+" %\r");
			start = data.position;
			
			// multinames
			p = data.position;
			n = readU32();
			if (this.verboseOut) {verbose(p, "Pool of "+(n-1)+" multinames");}
			names = [null];
			namespaces[0] = anyNs;
			strings[0] = "*"; // any name
			for (i=1; i < n; i++) {
				p = data.position;
				switch (data.readByte())
				{
					case CONSTANT_Qname:
					case CONSTANT_QnameA:
						names[i] = new QName(namespaces[readU32()], strings[readU32()]);
						break;
					
					case CONSTANT_RTQname:
					case CONSTANT_RTQnameA:
						names[i] = new QName(strings[readU32()]);
						break;
					
					case CONSTANT_RTQnameL:
					case CONSTANT_RTQnameLA:
						names[i] = null;
						break;
					
					case CONSTANT_NameL:
					case CONSTANT_NameLA:
						names[i] = new QName(new Namespace(""), null);
						break;
					
					case CONSTANT_Multiname:
					case CONSTANT_MultinameA:
						var sName:String = strings[readU32()];
						names[i] = new Multiname(nssets[readU32()], sName);
						break;
					
					case CONSTANT_MultinameL:
					case CONSTANT_MultinameLA:
						names[i] = new Multiname(nssets[readU32()], null);
						break;
					
					case CONSTANT_TypeName:
						var name:* = names[readU32()];
						count = readU32();
						var types:Array = [];
						for( var t:int=0; t < count; ++t )
							types.push(names[readU32()]);
						names[i] = new TypeName(name, types);
						break;
					
					default:
						throw new Error("invalid kind " + data[data.position-1])
				}
				if (this.verboseOut) {verbose(p, "name["+i+"] = "+names[i]);}
			}
			
			this.log.print(this.infoIndent + "Cpool names count "+ n +" size "+(data.position-start)+" "+int(100*(data.position-start)/data.length)+" %\r");
			start = data.position;
			
			namespaces[0] = publicNs;
			strings[0] = "*";
		}
		
		private function parseMethodInfos():void
		{
			var start:int = data.position;
			var p:uint = data.position;
			names[0] = new QName(publicNs,"*");
			var method_count:int = readU32();
			if (this.verboseOut) {verbose(p, "Pool of "+method_count+" methods");}
			methods = [];
			for (var i:int=0; i < method_count; i++)
			{
				p = data.position;
				var m:MethodInfo = methods[i] = new MethodInfo();
				//Added by SWF Investigator
				m.mDefPosition = this.data.position;
				var k:int;
				
				m.method_id = i;
				var param_count:int = readU32();
				m.returnType = names[readU32()];
				m.paramTypes = [];
				for (var j:int=0; j < param_count; j++)
					m.paramTypes[j] = names[readU32()];
				m.debugName = strings[readU32()];
				m.flags = data.readByte();
				if (m.flags & HAS_OPTIONAL)
				{
					// has_optional
					var optional_count:int = readU32();
					m.optionalValues = [];
					for( k = param_count-optional_count; k < param_count; ++k)
					{
						var index:uint = readU32();    // optional value index
						var kind:int = data.readByte(); // kind byte for each default value
						if (index == 0)
						{
							// kind is ignored, default value is based on type
							m.optionalValues[k] = undefined;
						}
						else
						{
							if (!defaults[kind])
								this.log.errorPrint("ERROR kind="+kind+" method_id " + i + "\r");
							else
								m.optionalValues[k] = defaults[kind][index];
						}
					}
				}
				if (m.flags & HAS_ParamNames)
				{
					// has_paramnames
					for( k = 0; k < param_count; ++k)
					{
						readU32();
					}
				}
				if (this.verboseOut) {verbose(p, "method["+i+"] = "+m);}
			}
			this.log.print(this.infoIndent + "MethodInfo count " +method_count+ " size "+(data.position-start)+" "+int(100*(data.position-start)/data.length)+" %\r")
		}
		
		private function parseMetadataInfos():void
		{
			var p:uint = data.position;
			var count:int = readU32();
			if (this.verboseOut) {verbose(p, "Pool of "+count+" metadata");}
			metadata= [];
			for (var i:int=0; i < count; i++)
			{
				// MetadataInfo
				p = data.position;
				var m:MetaData = metadata[i] = new MetaData();
				m.name = strings[readU32()];
				var values_count:int = readU32();
				var names:Array = [];
				//Refactor by SWF Investigator
				var q:int;
				
				for(q = 0; q < values_count; ++q)
					names[q] = strings[readU32()] // name 
				for(q = 0; q < values_count; ++q)
					m[names[q]] = strings[readU32()] // value
				if (this.verboseOut) {verbose(p, "metadata["+i+"] = "+m);}
			}
		}
		
		//Instances extend classes
		private function parseInstanceInfos():void
		{
			var start:int = this.data.position;
			var p:uint = this.data.position;
			var count:int = readU32();
			if (this.verboseOut) {verbose(p, "Pool of "+count+" instance info");}
			instances = [];
			for (var i:int=0; i < count; i++)
			{
				p = data.position;
				var t:Traits = instances[i] = new Traits();
				//Added by SWF Investigator
				t.start = this.data.position;
				var nIndex:uint = readU32();
				
				t.name = names[nIndex];
				t.base = names[readU32()];
				t.flags = this.data.readByte();
				if (t.flags & 8)
					t.protectedNs = namespaces[readU32()];
				var interface_count:uint = readU32();
				for (var j:int=0; j < interface_count; j++)
					t.interfaces[j] = names[readU32()];
				var m:MethodInfo = t.init = methods[readU32()];
				m.name = t.name;
				m.nIndex = nIndex;
				m.kind = TRAIT_Method;
				m.id = -1;
				parseTraits(t);
				if (this.verboseOut) {verbose(p, "instance["+i+"] = "+t);}
			}
			this.log.print(this.infoIndent + "InstanceInfo count " + count + " size "+(data.position-start)+" "+int(100*(data.position-start)/data.length)+" %\r");
		}
		
		private function parseTraits(t:Traits):void
		{
			var namecount:uint = readU32();
			for (var i:int=0; i < namecount; i++)
			{
				//Added by Si
				var nIndex:uint = readU32();
				var name:* = names[nIndex];
				var tag:int = data.readByte();
				var kind:uint = tag & 0xf;
				var member:*;
				switch(kind) {
					case TRAIT_Slot:
					case TRAIT_Const:
					case TRAIT_Class:
						var slot:SlotInfo = member = new SlotInfo();
						slot.id = readU32();
						t.slots[slot.id] = slot;
						if (kind==TRAIT_Slot || kind==TRAIT_Const)
						{
							slot.type = names[readU32()];
							var index:uint=readU32();
							if (index)
								slot.value = defaults[data.readByte()][index];
						}
						else // (kind == TRAIT_Class)
						{
							slot.value = classes[readU32()];
						}
						break;
					case TRAIT_Method:
					case TRAIT_Getter:
					case TRAIT_Setter:
						var disp_id:uint = readU32();
						var method:MethodInfo = member = methods[readU32()];
						t.methods[disp_id] = method;
						method.id = disp_id;
						//print("\t",traitKinds[kind],name,disp_id,method,"// disp_id", disp_id)
						break;
				}
				if (!member)
					this.log.errorPrint("error trait kind "+kind + "\r");
				member.kind = kind;
				member.name = name;
				member.nIndex = nIndex;
				t.names[String(name)] = t.members[i] = member;
				
				if ( (tag >> 4) & ATTR_metadata ) {
					member.metadata = [];
					for(var j:int=0, mdCount:int=readU32(); j < mdCount; ++j)
						member.metadata[j] = metadata[readU32()];
				}
			}
		}
		
		private function parseClassInfos():void
		{
			var start:int = data.position;
			var count:int = instances.length;
			classes = [];
			for (var i:int=0; i < count; i++)
			{
				var t:Traits = classes[i] = new Traits();
				//Added by SWF Investigator
				t.start = start;
				var p:uint = data.position;
				
				t.init = methods[readU32()];
				t.base = "Class";
				t.itraits = instances[i];
				//SWF Investigator change
				t.name = t.itraits.name + "$";
				t.init.name = t.itraits.name + "$cinit";
				t.init.kind = TRAIT_Method;
				parseTraits(t);
				if (this.verboseOut) {verbose(p, "class["+i+"] = "+t);}
			}           
			this.log.print(this.infoIndent + "ClassInfo count " + count + " size "+(data.position-start)+" "+int(100*(data.position-start)/data.length)+"%\r");
		}
		
		private function parseScriptInfos():void
		{
			var start:int = data.position;
			var p:uint = data.position;
			var count:int = readU32();
			if (this.verboseOut) {verbose(p, "Pool of "+count+" script");}
			scripts = [];
			for (var i:int=0; i < count; i++)
			{
				p = data.position;
				var t:Traits = new Traits();
				scripts[i] = t;
				t.name = "script" + i;
				t.base = names[0]; // Object
				t.init = methods[readU32()];
				t.init.name = t.name + "$init";
				t.init.kind = TRAIT_Method;      
				parseTraits(t);
				if (this.verboseOut) {verbose(p, "script["+i+"] = "+t);}
			}
			this.log.print(this.infoIndent + "ScriptInfo size "+(data.position-start)+" "+int(100*(data.position-start)/data.length)+" %\r");
		}
		
		private function parseMethodBodies():void
		{
			var start:uint = data.position;
			var p:uint = data.position;
			var count:uint = readU32();
			if (this.verboseOut) {verbose(p, "Pool of "+count+" method body");}
			for (var i:int=0; i < count; i++)
			{
				p = data.position;
				var m:MethodInfo = methods[readU32()];				
				m.max_stack = readU32();
				m.local_count = readU32();
				var initScopeDepth:uint = readU32();
				var maxScopeDepth:uint = readU32();
				m.max_scope = maxScopeDepth - initScopeDepth;
				m.codePosition = data.position;
				var code_length:uint = readU32();
				m.code = new ByteArray();
				m.code.endian = "littleEndian";
				if (code_length > 0)
					data.readBytes(m.code, 0, code_length);
				var ex_count:uint = readU32();
				for (var j:int = 0; j < ex_count; j++)
				{
					var from:uint = readU32();
					var to:uint = readU32();
					var target:uint = readU32();
					var type:* = names[readU32()];
					//print("magic " + magic.toString(16))
					//if (magic >= (46<<16|16))
					var name:* = names[readU32()];
				}
				parseTraits(m.activation = new Traits);
				if (this.verboseOut) {verbose(p, "method "+i);}
			}
			this.log.print(this.infoIndent + "MethodBodies count " + count + " size "+(data.position-start)+" "+int(100*(data.position-start)/data.length)+" %\r");
		}
		
		public function dump(indent:String=""):void
		{
			
			//Same
			for each (var t:Traits in scripts)
			{
				this.log.print("\r\r" + indent + "// " + indent+t.name + "\r");
				t.dump(this,indent);
				t.init.dump(this,indent);
			}
			
			//Classes & instances
			for each (var m:MethodInfo in methods)
			{
				if (!m.dumped) {
					m.dump(this,indent);
				}
			}
			
			if (this.verboseOut) {
				this.log.print("OPCODE\tSIZE\t% OF "+ this.totalSize + "\r");
				var done:Array = [];
				for (;;)
				{
					var max:int = -1;
					var maxsize:int = 0;
					for (var i:int=0; i < 256; i++)
					{
						if (opSizes[i] > maxsize && !done[i])
						{
							max = i;
							maxsize = opSizes[i];
						}
					}
					if (max == -1)
						break;
					done[max] = 1;
					this.log.print(opNames[max]+"\t"+int(opSizes[max])+"\t"+int(100*opSizes[max]/this.totalSize)+"%\r")
				}
			}			
		}
	}
}