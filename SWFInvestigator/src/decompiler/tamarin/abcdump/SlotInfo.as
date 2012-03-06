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
	
	import decompiler.tamarin.abcdump.MemberInfo;
	
	//Used by Abc.as
	internal class SlotInfo extends MemberInfo
	{
		include "ABC_Constants.as";

		/**
		 * inherited from MemberInfo
		 * 		public var id:int;
		 *		public var kind:int;
		 *		public var name:String;
		 *		public var metadata:Array;
		 */
		
		public var type:*;
		public var value:*;
		
		public function format():String
		{
			return traitKinds[kind] + " " + name + ":" + type + 
				(value !== undefined ? (" = " + (value is String ? ('"'+value+'"') : value)) : "") + 
				"\t/* slot_id " + id + " */";
		}
		
		internal function dump(abc:Abc, indent:String, attr:String=""):void
		{
			//refactor by SWF Investigator
			var md:MetaData;
			
			if (kind == TRAIT_Const || kind == TRAIT_Slot)
			{
				if (this.metadata) {
					for each (md in this.metadata)
						abc.log.print(indent+md + "\r");
				}
				abc.log.print(indent+attr+format() + "\r");
				return
			}
			
			// else, class
			
			var ct:Traits = value;
			var it:Traits = ct.itraits;
			abc.log.print('\r');
			if (this.metadata) {
				for each (md in this.metadata)
					abc.log.print(indent+md + "\r");
			}
			var def:String;
			if (it.flags & CLASS_FLAG_interface)
				def = "interface"
			else {
				def = "class";
				if (!(it.flags & CLASS_FLAG_sealed))
					def = "dynamic " + def;
				if (it.flags & CLASS_FLAG_final)
					def = "final " + def;
				
			}
			abc.log.print(indent+attr+def+" "+name+" extends "+it.base + "\r");
			
			var oldindent:String = indent;
			indent += TAB;
			
			if (it.interfaces.length > 0)
				abc.log.print(indent+"implements "+it.interfaces + "\r");
			
			abc.log.print(oldindent+"{\r");
			
			it.init.dump(abc,indent);
			it.dump(abc,indent);
			
			ct.dump(abc,indent,"static ");
			ct.init.dump(abc,indent,"static ");
			
			abc.log.print(oldindent+"}\r");
		}
	}
}