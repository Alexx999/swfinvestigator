/****************************************************************************
 * ADOBE SYSTEMS INCORPORATED
 *  Copyright 2012 Adobe Systems Incorporated and it’s licensors
 *  All Rights Reserved.
 *  
 * NOTICE: Adobe permits you to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 * ****************************************************************************/

package decompiler
{
	import decompiler.Logging.StringWriter;
	import decompiler.Swf;
	import decompiler.swfdump.SWFFormatError;
	import decompiler.swfdump.TagDecoder;
	import decompiler.tamarin.abcdump.Abc;
	import decompiler.tamarin.abcdump.Tag;
	import decompiler.tamarin.abcdump.Traits;
	
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	import flash.utils.Endian;

	
	/**
	 * The ASDecompiler is the class that wraps the swfutils library for decompiling AS2 and AS3 SWFs.
	 * 
	 * This is the core class that maintains all information regarding the SWF's decompilation for all of SWF Investigator
	 */
	public class ASDecompiler
	{
		
		private var swfFile:Swf;
		
		private var swfInfo:String;
		
		private var fileTagsArray:Array;
		
		private var logger:StringWriter = new StringWriter("Array");
		
		public var swfData:Object = {};
		
		public var fileName:String;
		
		
		/**
		 * @public
		 * Constructor
		 * 
		 * @param bytes The ByteArray from loader.loadBytes
		 */
		public function ASDecompiler(bytes:ByteArray)
		{
			this.swfFile = new Swf(bytes,this.logger);
			this.swfData.size = this.swfFile.length;
			this.swfData.version = this.swfFile.version;
			this.swfData.compressed = this.swfFile.compressed;
		}
		
		/**
		 * @public
		 * Once the constructor is initialized, this will get additional info for the class and the main SWF Investigator tab.
		 * 
		 * @return A string containing a basic summary of the SWF
		 */ 
		public function getInfo():String {
		        this.swfData.avm2 = this.swfFile.avm2;
				this.swfData.hasMetadata = this.swfFile.hasMetadata;
				this.swfData.useGPU = this.swfFile.useGPU;
				this.swfData.useDirectBlit = this.swfFile.useDirectBlit;
				this.swfData.swfRelativeURLs = this.swfFile.swfRelativeURLs;
				this.swfData.suppressCrossDomainCaching = this.swfFile.suppressXDomainCaching;
				this.swfData.useNetwork = this.swfFile.useNetwork;
		        this.swfData.frameRate = this.swfFile.frameRate;
		        this.swfData.frameCount = this.swfFile.frameCount;
		        this.swfData.movieRect = this.swfFile.rect.toString();
				this.swfData.compressionType = this.swfFile.compressionType;
		    	
		    	this.fileTagsArray = this.swfFile.tags;
				this.swfInfo = this.logger.outArray[0];
				this.swfFile.log.clear();
		    	var outputString:String = "";
		    					
				outputString += "Total # of File Tags: " + this.fileTagsArray.length + "\r";
				var swfTag:Tag;
		    	for (var s:String in this.fileTagsArray) {
		    		swfTag = this.fileTagsArray[s][0];
		    		outputString += " * "  + this.swfFile.getTagName(swfTag.type) + " (" + swfTag.type +") -- total: " + this.fileTagsArray[s].length +  "\r";
		    	}
		    	
		    	this.swfData.fileTags = outputString;
		    	outputString = "";
				
				try {
					if (this.swfFile.avm2) {
						this.swfFile.dumpABC();
					} else if (this.swfFile.hasActions) {
						this.swfFile.dumpAllActions();
					}
					this.swfData.byteCode = this.logger.outArray;
				} catch (e:SWFFormatError) {
					this.logger.print("\rError during processing! - pos=" + this.swfFile.data.position + "\r");
					this.logger.print(e.message + "\r");
					this.swfData.byteCode = this.logger.outArray;
					return (e.message);
				} catch (e:Error) {
					this.logger.print("\rError during processing! - pos=" + this.swfFile.data.position + "\r");
					this.logger.print(e.message + "\r");
					this.swfData.byteCode = this.logger.outArray;
					return (e.message);
				}
		    	
		    	if (this.swfFile.avm2 && this.swfFile.abc.length > 0 && this.swfFile.abc[0].classes != null && this.swfFile.abc[0].classes.length > 0) {
					for (var i:int = 0; i < this.swfFile.abc.length; i++) {
					  outputString += "ABC Block " + i + " Classes\r";
					  for (var j:String in this.swfFile.abc[i].classes) {
						outputString += " - " + this.swfFile.abc[i].classes[j] + "\r";
					  }
					}
		    	} else {
					outputString += "No exports\r";
		    	}
					
				this.swfData.exportClasses = outputString;
		    	
		    	if (swfFile.hasActions) {
		    		this.swfData.hasActions = true;
		    	} else {
		    		this.swfData.hasActions = false;
		    	}
								
		    	return this.logger.errorOutput;
		}
		
		
		    /**
		     * @private 
		     * Used to collect the instance information for a specific class when called by the dumpABCClasses function
		     * 
		     * This collects information such as whether the class is dynamic or final, its interfaces, its traits, etc.
		     * 
			 * @param abc An ABC class object
		     * @param inst An instance of the Traits found in the SWF
		     * @param sWriter The StringWriter object where the output is written
		     */ 
		    private function dumpInstances(abc:Abc, inst:Traits, sWriter:StringWriter):void {
				var line:String;
				if (inst.flags & abc.CLASS_FLAG_interface)
					line = "interface"
				else {
					line  = "class";
					if ( !(inst.flags & abc.CLASS_FLAG_sealed) )
						line = "dynamic " + line;
					if ( inst.flags & abc.CLASS_FLAG_final )
						line = "final " + line;
						
				};
			
				line += " " + inst.name + " extends " + inst.base;
				
				if ( inst.interfaces )
				{
					line += " implements " + inst.interfaces[0];
					for ( var i:int = 1; i < inst.interfaces.length; i += 1)
					 		line += ", " + inst.interfaces[i];
				};
			
				sWriter.print( " " + line + " { " );
					
				if ( (inst.flags & 0x08 ) ) sWriter.print("  /* protected namespace : "+ inst.protectedNs + " */" );
				
				if (inst.init) {
					inst.init.dump(abc," ");
				} else {
					sWriter.print("/* no constructor code */");
				}
				
				inst.dump(abc, " ");
							
		    }
		    
		    /**
			 * @public
		     * Used by the AS3Navigator function to obtain an ABCXML description of the SWF for the tree navigator
		     * 
		     * @return An ABCXML description of the packages and classes, null if error
		     */
		    public function dumpABCClasses():ABCXML {
		    	var swfXML:ABCXML = new ABCXML();
				var tr:Traits;
				var sw:StringWriter = new StringWriter("String");
				
				if (this.swfFile.abc == null || this.swfFile.abc.length == 0) {
					return (null);
				}
				
				var abc:Abc;
				var pckgName:String;
				var className:String;

				for (var i:int = 0; i < this.swfFile.abc.length; i++) {
				 abc = this.swfFile.abc[i];
		    	 for (var c:* in abc.classes) {
					sw.clear();
					abc.log = sw;
					 
		    		pckgName = "(default)";
		    		className = abc.classes[c].name;
		    		
		    		if (abc.classes[c].name.indexOf("::") > 0) {
		    			var info:Array = className.split("::");
		    			pckgName = info[0];
		    			className = info[1];
		    			swfXML.addPackage(pckgName);
		    		}
		    		
					dumpInstances(abc, abc.instances[c],sw);

					abc.classes[c].dump(abc, " ");
					
					abc.classes[c].init.dump(abc, " ");
					
					sw.print(" }");

					swfXML.addClass(pckgName,className,sw.output);
				 }
		    	}
		    	swfXML.createCollection();
		    	return (swfXML);
		    }
		    
			/**
			 * @private
			 * Used (via proxy) by the Decompiler Tab to dump the source code for an AS3 SWF.
			 * 
			 * An array is returned because the dump decompilation can be rather lengthy.
			 * 
			 * @param i An int describing which ABC Block it is currently disassesmbling.
			 * @return An Array of strings with the dumped source code.
			 */
		    private function dumpABC (i:int):Array {
		    	var logger:StringWriter = new StringWriter("Array");
		    	var outputString:String =  "-------- Dumping ABC Block #" + i + " --------\r";
				var position:int = this.swfFile.tags[82][i].position;
		    	swfFile.data.position = position;
		    	outputString += "position: " + position + "\r";
				var abc:Abc = this.swfFile.abc[i];
				abc.log = logger;
				abc.dump();
		    	
		    	logger.outArray[0] = outputString + logger.outArray[0];
		    	return (logger.outArray);
		    }

		    
		    /**
		     * Return the strings array for the String Viewer tab
		     * 
		     * @return The Array of each string within the SWF
		     */
		    public function dumpStrings():Array {
				if (this.swfFile.abc == null || this.swfFile.abc.length == 0) {
					var empty:Array = new Array();
					return (empty);
				}
				
				var masterStr:Array = new Array();
				var abc:Abc;
				for (var i:int = 0; i < this.swfFile.abc.length; i++) {
					abc = this.swfFile.abc[i];
					if (abc.strings != null) {
						masterStr = masterStr.concat(abc.strings);
					}
				}
				return (masterStr);
		    }

			/**
			 * @public
			 * Return a decompressed version of the SWF bytes for the Hex Viewer
			 * 
			 * @param bytes The bytes of the SWF to be cast as a SWFFile
			 * @return A ByteArray of the decompressed SWF
			 */
		    public function decompressSWF(bytes:ByteArray):ByteArray {
		    	//Get Header info
		    	var header:ByteArray = new ByteArray();
		    	bytes.readBytes(header,0,8);
				bytes.endian = Endian.LITTLE_ENDIAN;
	
		    	var dataArray:ByteArray = new ByteArray();
				dataArray.endian = Endian.LITTLE_ENDIAN;
				if (header[0] == 67) {
					bytes.readBytes(dataArray);
					dataArray.position = 0;
					dataArray.uncompress();
				} else {
					var csize:uint = bytes.readUnsignedInt();
					bytes.readBytes(dataArray,0,5);
					dataArray.position = 5;
					header.position = 4;
					header.endian = Endian.LITTLE_ENDIAN;
					var size:uint = header.readUnsignedInt();
					dataArray.writeUnsignedInt(size-8);
					dataArray.writeUnsignedInt(0);
					bytes.readBytes(dataArray,13,csize);
					dataArray.position = 0;
					dataArray.uncompress(CompressionAlgorithm.LZMA);
				}
				dataArray.position = 0;
		    	
		    	//Put together in pretty package
				header[0] = 70; // Reset to non-compressed :-)
		    	var tmpArray:ByteArray = new ByteArray();
		    	tmpArray.writeBytes(header);
		    	tmpArray.writeBytes(dataArray);
		    	return (tmpArray);
			}
			
			
		    /**
			 * @public
		     * Return an Array of the File Tags from the SWF for the Hex Viewer Tab
		     * 
		     * @return An array of the File Tags from the SWF
		     */
		    public function getFileTagArray():Array {
		    	var tmpArray:Array = new Array;
				
		    	var swfTag:Tag;
				var tmpObject:Object;
		    	
				for (var j:String in this.fileTagsArray) {
		    		swfTag = this.fileTagsArray[j][0];
		    		tmpObject = new Object;
		    		tmpObject.label = this.swfFile.getTagName(swfTag.type);
		    		tmpObject.data = swfTag.type;
		    		tmpArray.push(tmpObject);
		    	}
		    	
		    	return (tmpArray);
		    }
		    
		    /**
			 * @public
		     * Find the position of the next file tag based on the current position for the HexViewer Tab
		     * 
		     * @param tagType A String representing the tag type
		     * @param position An unsigned int representing the current position
		     * @return A uint of the next position within the SWF of the current file tag.
		     */ 
		    public function getNextFileTag(tagType:String, position:uint):Tag {
				var tmpArray:Array;
				var swfTag:Tag;
				
		    	for (var j:String in this.fileTagsArray) {
		    		if (j == tagType) {
		    			tmpArray = this.fileTagsArray[j];
		    			if (tmpArray.length == 1) {
		    				return (Tag(tmpArray[0]));
		    			}
		    			for (var str:String in this.fileTagsArray[j]) {
		    				swfTag = this.fileTagsArray[j][str];
							if (swfTag.position > position) {
								return (swfTag);
							}
		    			}
		    			//Search Wrapped
		    			return (Tag(tmpArray[0]));
		    		}
		    	}
		    	return (null);
		    }
			
			/**
			 * @private
			 * Used to sort the Tags array
			 * 
			 * @param a The first tag for the comparison
			 * @param b The second tag for the comparison
			 */
			private function sortOnPosition(a:Tag, b:Tag):Number {
				if(a.position > b.position) {
					return 1;
				} else if(a.position < b.position) {
					return -1;
				} else  {
					//aPrice == bPrice
					return 0;
				}
			}
			
			/**
			 * @private
			 * Converts a byte into a hex string
			 * 
			 * @param byte An unsigned int of the byte that will be converted to a hex String
			 * @return A string representation of the hex value of the supplied byte.
			 */
			private function convertToHex(byte:uint):String {
				var hex:String = byte.toString(16);
				if (hex.length == 1) {
					hex = "0" + hex;
				}
				return (hex)
			}
			
			/**
			 * @public
			 * Used by the TagPanel to generate the XML
			 * 
			 * @return The TagXML representing the Tag
			 */
			public function produceTagXML():TagXML {
				var tagXML:TagXML = new TagXML();
				
				var tmpArray:Array = new Array();
				for each (var arr:Array in this.fileTagsArray) {
					for (var j:int=0; j < arr.length; j++) {
						tmpArray.push(arr[j]);
					}
				}

				tmpArray.sort(sortOnPosition);
				
				for (var i:int=0; i < tmpArray.length; i++) {
					var t:* = tmpArray[i];
					tagXML.addTag(t);
					
					/**
					if (t.type == 4 || t.type == 26 || t.type == 70) {
						tagXML.addField(t.position);
					}
					 */
				}
				
				tagXML.createCollection();
				return (tagXML);
			}
			
			/**
			 * @public
			 * Used by TagPanel to get the hex for the selected tag
			 * 
			 * @param pos The start position in the SWF file
			 * @param size The size of the tag
			 * @return The hex encoded section of the SWF file as a String
			 */
			public function getTagHex(pos:uint, size:uint):String {
				var hex:String = new String();
				var str:String = new String();
				str = "\t\t| ";
				for (var i:int=0; i < size; i++) {
					if (i > 0 && i % 16 == 0) {
						hex += str + " |\r";
						str = "\t\t| ";
					}
					hex += convertToHex(this.swfFile.data[pos + i]) + " ";
					if (this.swfFile.data[pos + i] > 31 && this.swfFile.data[pos + i] < 128) {
						str += String.fromCharCode(this.swfFile.data[pos + i].toString());
					} else {
						str += "*";
					}
				}
				hex += str + " |\r";
				return (hex);
			}
			
			/**
			 * @public
			 * Returns the string representation of a Tag
			 * 
			 * @param type The type of the tag to print
			 * @param pos The position of the tag in the SWF
			 * @param dumpFile Used to indicate that binary data in the tag will be saved to a file
			 * @return The string representing the tag
			 */
			public function printTagInfo(type:uint, pos:uint, dumpFile:Boolean=false):String {
				var t:Tag;
				for each (t in this.swfFile.tags[type]) {
					if (t.position == pos) {
						break;
					}
				}
				
				return (this.swfFile.printTag(t,dumpFile,this.fileName));
			}
			
			/**
			 * @public
			 * Used to retrive tag list sorted by position
			 * 
			 * @param The Function for sending the data.
			 * @param returnChar the character to use for carriage returns
			 */
			public function printSortedFileTagArray(fStream:FileStream, returnChar:String="\r\n"):void {				
				var tmpVector:Vector.<Tag> = new Vector.<Tag>;
				for each (var arr:Array in this.fileTagsArray) {
					for (var j:int=0; j < arr.length; j++) {
						tmpVector.push(arr[j]);
					}
				}
				
				tmpVector.sort(sortOnPosition);
				
				var myPattern:RegExp = /[\r]/g;
				var tmpString:String;
				for (var i:int = 0; i < tmpVector.length; i++) {
					tmpString = printTagInfo(tmpVector[i].type, tmpVector[i].position);
					fStream.writeUTFBytes(tmpString.replace(myPattern,returnChar));
				}
				
				return;
			}
	}
}