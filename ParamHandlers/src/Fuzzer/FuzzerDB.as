/****************************************************************************
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2012 Adobe Systems Incorporated and it’s licensors
 * All Rights Reserved.
 *  
 * NOTICE: Adobe permits you to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 * ****************************************************************************/

package Fuzzer
{
	import flash.utils.getDefinitionByName;

	public class FuzzerDB
	{
		private var intMin:int = int.MIN_VALUE;
		private var intMax:int = int.MAX_VALUE;
		private var uintMin:uint = uint.MIN_VALUE;
		private var uintMax:uint = uint.MAX_VALUE;
		private var numMin:Number = Number.MIN_VALUE;
		private var numMax:Number = Number.MAX_VALUE;
		private var byteMin:uint = 0;
		private var byteMax:uint = 255;
		private var emptyObject:Object = new Object();
		
		private var attackInts:Vector.<int>;
		private var attackUInts:Vector.<uint>;
		private var attackStrings:Vector.<String>;
		private var attackNums:Vector.<Number>;
		private var attackObjects:Vector.<Object>;
		private var attackXMLs:Vector.<XML>;
		private var attackClasses:Array;
		private var bytes:Vector.<uint>;
		
		private var currentPos:uint = 0;
		
		public function FuzzerDB(xmlFile:XML = null)
		{
			if (xmlFile == null) {
				setDefaults();
			} else {
				clearDefaults();
				populateVectors(xmlFile);
			}
		}
		
		public function setDefaults():void {
			attackInts = new <int>[intMin,-1,0,intMax];
			attackUInts = new <uint>[uintMin,uintMax/2, uintMax];
			attackStrings = new <String>[null,"","' or 1=1;--","&%!@#$^&*()[]{}:|/?-_+=><.,\\;`~","\"","'"];
			attackStrings.push(String.fromCharCode(00));
			attackNums = new <Number>[numMin,-1,0,numMax];
			attackObjects = new <Object>[null,emptyObject];
			attackXMLs = new <XML>[null,<foo/>];
			attackClasses = [null,emptyObject];
			bytes = new <uint>[byteMin,byteMax];
		}
		
		public function clearDefaults():void {
			attackInts = new <int>[];
			attackUInts = new <uint>[];
			attackStrings = new <String>[];
			attackNums = new <Number>[];
			attackObjects = new <Object>[];
			attackXMLs = new <XML>[];
			attackClasses = new Array();
		}
		
		private function populateVectors(xmlFile:XML):void {
			var types:Vector.<String> = new <String>["int","uint","Number","Object","XML","Class"];
			for (var i:int = 0; i < types.length; i++) {
				var node:XMLList = xmlFile.type.(@name == types[i]);
				for each (var item:XML in node) {
				  var list:XMLList = item.value;
				  var val:XML;
				  	for each (val in list) {
						addValue(types[i], val.toString());
				  	}
				}
			}
		}
		
		public function addValue(type:String, value:*):void {
			var objXML:XML;
			var objList:XMLList;
			var param:XML;
			
			switch (type) {
				case "int":
					attackInts.push(int(value));
					break;
				case "uint":
					attackUInts.push(uint(value));
					break;
				case "String":
					attackStrings.push(value);
					break;
				case "Number":
					attackNums.push(Number(value));
					break;
				case "XML":
					attackXMLs.push(new XML(value));
					break;
				case "Object":
					var temp:Object = new Object();
					objXML = new XML(value);
					objList = objXML.param;
					for each (param in objList) {
						assignObjectVal(temp,param.@name,param.@type,param.toString());
					}
					attackObjects.push(temp);
					break;
				case "Class":
					objXML = new XML(value);
					var classReference:Class = getDefinitionByName(objXML.@name) as Class;
					var cObject:* = new classReference();
					objList = objXML.param;
					for each (param in objList) {
						assignObjectVal(cObject,param.@name,param.@type,param.toString());
					}
					attackObjects.push(cObject);
					break;
				default :
			}
		}
		
		private function assignObjectVal(obj:*,name:String,type:String,val:*):void {
			var objXML:XML;
			var objList:XMLList;
			var param:XML;
			
			switch (type) {
				case "int":
					obj[name] = int(val);
					break;
				case "uint":
					obj[name] = uint(val);
					break;
				case "Number":
					obj[name] = Number(val);
					break;
				case "String":
					obj[name] = val.toString();
					break;
				case "XML":
					obj[name] = new XML(val);
					break;
				case "Object":
					var temp:Object = new Object();
					objXML = new XML(val);
					objList = objXML.param;
					for each (param in objList) {
						assignObjectVal(temp,param.@name,param.@type,param.toString());
					}
					obj[name] = temp;
					break;
				case "Class":
					objXML = new XML(val);
					var classReference:Class = getDefinitionByName(objXML.@name) as Class;
					var cObject:* = new classReference();
					objList = objXML.param;
					for each (param in objList) {
						assignObjectVal(cObject,param.@name,param.@type,param.toString());
					}
					obj[name] = cObject;
					break;
				default :
			}
		}
		
		public function getNextAttackArgs(paramType:String, pos:uint, defaults:Array):Array {
			var newParams:Array = new Array();
			newParams = newParams.concat(defaults);
			var j:uint = 0;
			
			switch (paramType) {
				case "int":
					if (currentPos < attackInts.length) {
						newParams[pos] = attackInts[currentPos];
						currentPos++;
						return (newParams);
					} else {
						currentPos = 0;
						return (null);
					}
					break;
				case "uint":
					if (currentPos < attackUInts.length) {
						newParams[pos] = attackUInts[currentPos];
						currentPos++;
						return (newParams);
					} else {
						currentPos = 0;
						return (null);
					}
					break;
				case "String":
					if (currentPos < attackStrings.length) {
						newParams[pos] = attackStrings[currentPos];
						currentPos++;
						return (newParams);
					} else {
						currentPos = 0;
						return (null);
					}
					break;
				case "Number":
					if (currentPos < attackNums.length) {
						newParams[pos] = attackNums[currentPos];
						currentPos++;
						return (newParams);
					} else {
						currentPos = 0;
						return (null);
					}
					break;
				case "Boolean":
					if (currentPos == 0) {
						newParams[pos] = false;
						currentPos++;
					} else if (currentPos == 1) {
						newParams[pos] = true;
						currentPos++;
					} else {
						currentPos = 0;
						return (null)
					}
					break;
				case "null":
					if (currentPos == 0) {
						newParams[pos] = new Object();
						currentPos++;
					} else if (currentPos > 0) {
						currentPos = 0;
						return (null)
					}
					break;
				case "XML":
					if (currentPos < attackXMLs.length) {
						newParams[pos] = attackXMLs[currentPos];
						currentPos++;
						return (newParams);
					} else {
						currentPos = 0;
						return (null);
					}
					break;
				case "Object":
					if (currentPos < attackObjects.length) {
						newParams[pos] = attackObjects[currentPos];
						currentPos++;
						return (newParams);
					} else {
						currentPos = 0;
						return (null);
					}
					break;
				case "Class":
					if (currentPos < attackClasses.length) {
						newParams[pos] = attackClasses[currentPos];
						currentPos++;
						return (newParams);
					} else {
						currentPos = 0;
						return (null);
					}
					break
				default :
			}
			return (null);
		}
	}
}