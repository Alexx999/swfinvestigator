/****************************************************************************
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2012 Adobe Systems Incorporated and it’s licensors
 * All Rights Reserved.
 *  
 * NOTICE: Adobe permits you to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 * ****************************************************************************/

package hexEditor
{
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	import flash.utils.Endian;
	
	import mx.collections.ArrayCollection;
	

	/**
	 * The HexViewer class provides utility functions for transitioning between the byte array and data grid.
	 */
	//[Bindable]
	public final class HexViewer extends Object
	{
		/**
		 * The bindable array used by the data grid
		 */
		public var hexArray:Array;
		
		[Bindable]
		public var initDG:ArrayCollection = new ArrayCollection();
		
		/**
		 * @public
		 * A local copy of the swfBytes array that represents the current data in the dataGrid
		 */
		public var swfBytes:ByteArray;
		
		/**
		 * @private
		 * Used to track the last position of a found string within the data grid
		 */
		public var currentPosition:Object = new Object;
		
		/**
		 * @private
		 * String value used to represent non-printable characters
		 */
		private const npChar:String = "*";
		
		/**
		 * @private
		 * Prepend String for offset
		 */
		private const prepend:String = "00000000";
		
		/**
		 * @public
		 * Used by the Editor Tab to track file the last position of a found File Tag
		 */
		public var lastFTagPos:uint;
		
		/**
		 * @public
		 * Indicates whether this HV supports drag and drop
		 */
		public var dndSupported:Boolean;
		
		/**
		 * Constructor
		 * 
		 * @param dndSupport Indicates whether drag and drop is supported for this HV
		 */
		public function HexViewer(dndSupport:Boolean = false)
		{
			super();
			this.dndSupported = dndSupport;
		}
		
		/**
		 * When a new SWF is loaded, we initialize the pointer to the swfBytes array.
		 * The HV class does not create its own copy. Instead it expects to receive a pointer
		 * to an existing ByteArray.
		 * 
		 * @param swf The ByteArray containing the raw bytes for the current SWF.
		 */
		public function initViewer (swf:ByteArray):void {
			this.swfBytes = swf;
		}
		
		/**
		 * Clear references for the GC
		 */
		public function clearRefs():void {
			this.swfBytes = null;
		}
		
		/**
		 * @private
		 * Converts a byte into a hex string
		 * 
		 * @param byte An unsigned int of the byte that will be converted to a hex String
		 * @return A string representation of the hex value of the supplied byte.
		 */
		/**
		private function convertToHex(byte:uint):String {
			var hex:String = byte.toString(16);
			return (hex)
		}
		 */
		
		/**
		 * This function converts the current strings in the DataGrid to a byteArray and then launches file.save to prompt the user
		 */
		public function saveToFile():void {
			var fileArray:ByteArray = new ByteArray;
			var file:FileReference = new FileReference();
			var colName:String;
			
			for (var i:int = 0; i < this.hexArray.length; i++) {
				for (var j:int = 0; j < 16; j++) {
					colName = "col" + j;
					if (this.hexArray[i][colName] != null && this.hexArray[i][colName].length > 0) {
						fileArray.writeByte(int("0x" +  this.hexArray[i][colName]));
					}
				}
			}
			
			file.save(fileArray,"foo.swf");
		}

		/**
		 * This function converts the current strings in the DataGrid to a byteArray, compresses it
		 * and then launches file.save to prompt the user.
		 */
		public function saveCompressed(compressionType:String = CompressionAlgorithm.ZLIB):void {
			var fileArray:ByteArray = new ByteArray;
			var file:FileReference = new FileReference();
			var colName:String;
			
			for (var i:int = 0; i < this.hexArray.length; i++) {
				for (var j:int = 0; j < 16; j++) {
					colName = "col" + j.toString();
					if (this.hexArray[i][colName] != null && this.hexArray[i][colName].length > 0) {
						fileArray.writeByte(int("0x" +  this.hexArray[i][colName]));
					}
				}
			}
			
			var header:ByteArray = new ByteArray;
			fileArray.position = 0;
		    fileArray.readBytes(header,0,8);
			
			var compressedStuff:ByteArray = new ByteArray;
			compressedStuff.endian = Endian.LITTLE_ENDIAN;
			fileArray.readBytes(compressedStuff,0,0);
			compressedStuff.position = 0;
			
			var tmpArray:ByteArray = new ByteArray;
			tmpArray.endian = Endian.LITTLE_ENDIAN;
			
			if (compressionType == CompressionAlgorithm.ZLIB) {
				header[0] = 67; // Reset to compressed :-)
				compressedStuff.compress();
				tmpArray.writeBytes(header);
				tmpArray.writeBytes(compressedStuff);
			} else {
				//LZMA Compress
				compressedStuff.compress(CompressionAlgorithm.LZMA);
				var csize:uint = compressedStuff.length;
				
				//Reset header to ZWS
				header[0] = 90;

				//Read header into tmpArray
				tmpArray.writeBytes(header);
				
				//Write csize into the header
				//Subtract for LZMA props (5 bytes) and compressed length (8 bytes)
				tmpArray.writeUnsignedInt(csize - 13);
				
				//Read in LZMA props
				compressedStuff.position = 0;
				compressedStuff.readBytes(tmpArray,12,5);

				//Read in compressed info skipping the 8 byte compressed size
				compressedStuff.position = 13;
				compressedStuff.readBytes(tmpArray,17,csize - 13);
			}
			
			file.save(tmpArray,"compressed_foo.swf");
		}
		
		/**
		 * @private
		 * Creates an individual line for the data grid using the global swfBytes variable.
		 * This is a tight loop and therefore can have a great impact on the performance of the application.
		 * 
		 * @param position An integer representing the current position in the swfBytes array
		 * @param end An integer represnting when to stop reading (typically 16 unless it is the end of the array)
		 * @return A HexTableRow that represents the current line.
		 */
		private function createArrayLine(position:uint,end:uint):HexTableRow {
			var hexRow:HexTableRow = new HexTableRow();
			var tmpString:String = "";
			var colName:String;
			var curByte:uint;
			
			for (var i:uint = 0; i <end; i++) {
				colName = "col" + i;
				curByte = this.swfBytes[position + i];
				
				if (curByte > 126) {
					tmpString += this.npChar;
					hexRow[colName] = curByte.toString(16);
				} else if (curByte > 31) {
					tmpString += String.fromCharCode(curByte);
					hexRow[colName] = curByte.toString(16);
				} else if (curByte < 16) {
					hexRow[colName] = "0" + curByte.toString(16);
					tmpString += this.npChar;
				} else {
					tmpString += this.npChar;
					hexRow[colName] = curByte.toString(16);
				}
				
			}
			
			//Set bookend information
			hexRow.string = tmpString;
			tmpString = position.toString(16);
			hexRow.offset = this.prepend.substring(0,8-tmpString.length) + tmpString;
			
			return(hexRow);
		}
		
		/**
		 * Called whenever the Hex Viewer comes into view to initialize the viewing pane
		 */
		public function updateHexArray():void {
			if (this.swfBytes == null) {return;}
			var len:uint = this.swfBytes.length;
			if (len == 0) {
				if (this.hexArray.length > 0) {
					this.hexArray = new Array();
					this.initDG.source = this.hexArray;
				}
				return;
			}
			
			//var startTime:Number = new Date().getTime();

			this.hexArray = new Array();
			
			for (var i:uint = 0; i < len; i+=16) {
				if (i + 16 < len) {
					this.hexArray.push(createArrayLine(i,16));
				} else {
					this.hexArray.push(createArrayLine(i,len-i));
				}
			}

			
			//var endTime:Number = new Date().getTime();
			//trace(endTime-startTime);
			
			this.initDG.source = this.hexArray;
		}
		
		/**
		 * @private
		 * This function compares the string with the data at the supplied row and column position
		 * 
		 * This function is called by findHexString.  It is a separate function because it deals
		 * with comparisons when there is wrap around at the end of the row.
		 * 
		 * @param colPosition The column of the current value
		 * @param rowPosition The row of the current value
		 * @param strArray An Array representing the string that is being searched for
		 * @return A Bookean that will return true if found
		 */
		private function compareHexString(colPosition:int,rowPosition:int,strArray:Array):Boolean {
			var tempRow:int = rowPosition;
			var tempColumn:int = colPosition;
			var colName:String;
			
			for (var i:int=0; i<strArray.length; i++) {
				colName = "col" + tempColumn.toString();
				if (this.hexArray[tempRow][colName] != null && this.hexArray[tempRow][colName].indexOf(strArray[i]) == 0) {
					if (tempColumn < 15) {
						tempColumn++;
					} else {
						tempColumn = 0;
						if (tempRow + 1 < this.hexArray.length) {
							tempRow++;
						} else {
							return (false);
						}
					}
				} else {
					return (false);
				}
			}
			
			return (true);
		}
		
		/**
		 * This function searches for Hex strings within the data grid
		 * 
		 * @param inStr The hex string to find within the data grid
		 * @param findNext A boolean indicating whether this is the first search for that string
		 * @return The integer representing the row where the string was found.
		 */
		public function findHexString(inStr:String,findNext:Boolean):int {
			if (findNext == false) {
				this.currentPosition.column = 0;
				this.currentPosition.row = 0;
			}
			
			if (this.hexArray == null) {
				return (-1);
			}
			
			//Switch to Lower Case
			var str:String = inStr.toLowerCase();
			
			var re:RegExp = /(.){1,2}/g;
  			var results:Array = str.match(re);
  			var j_index:int = this.currentPosition.column;
			var colName:String;
						
			for (var i:int = this.currentPosition.row; i < this.hexArray.length; i++) {
				if (i > this.currentPosition.row) {j_index = 0;}
				for (var j:int = j_index; j < 16; j++) {
					colName = "col" + j.toString();

					if (this.hexArray[i][colName] != null && this.hexArray[i][colName].indexOf(results[0].toLowerCase()) == 0) {
						if (compareHexString(j,i,results) == true) {
							if (j < 16) {
								this.currentPosition.column = j + 2;
								this.currentPosition.row = i;
							} else {
								this.currentPosition.column = 0;
								if (this.currentPosition.row + 1 < this.hexArray.length) {
									this.currentPosition.row = i + 1;
								} else {
									this.currentPosition.row = 0;
								}
							}
							return(i);
						}
					}
				} //end for j
			} //end for i
			
			this.currentPosition.row = 0;
			this.currentPosition.column = 0;
			return (-1);
		}
		

		/**
		 * This function searches for strings within the data grid
		 * 
		 * @param str The string to find within the data grid
		 * @param findNext A boolean indicating whether this is the first search for that string
		 * @return The integer representing the row where the string was found.
		 */		
		public function findString(str:String, findNext:Boolean):int {
			if (findNext == false) {
				this.currentPosition.column = 0;
				this.currentPosition.row = 0;
			}
			
			if (this.hexArray == null) {
				return (-1);
			}
			
			var j_index:int = this.currentPosition.column;
			var stringPart:String;
			
			for (var i:int = this.currentPosition.row; i < this.hexArray.length; i++) {
				if (i > this.currentPosition.row) {j_index = 0;}
				for (var j:int = j_index; j < 16; j++) {
					stringPart = this.hexArray[i].string.substring(j);
					if (stringPart.length >= str.length) {
						if (stringPart.indexOf(str) == 0) {
							if (str.length > 1) {
								this.currentPosition.row = i;
								this.currentPosition.column = j + 2;
							} else {
								this.currentPosition.column = 0;
								if (i + 1 < this.hexArray.length) {
									this.currentPosition.row = i + 1
								} else {
									this.currentPosition.row = 0;
								}
							}
							return(i);
						}
					} else if (i + 1 < this.hexArray.length) {
						if (stringPart.indexOf(str.substr(0,stringPart.length)) == 0 && this.hexArray[i+1].string.indexOf(str.substr(stringPart.length)) == 0) {
							if (j < 16) {
								this.currentPosition.row = i;
								this.currentPosition.column = j + 2;
							} else {
								this.currentPosition.column = 2;
								if (i + 1 < this.hexArray.length) {
									this.currentPosition.row = i + 1;
								} else {
									this.currentPosition.row = 0;
								}
							}
							return (i);
						}
					}
					if (j == 15) {this.currentPosition.column = 0;}
				} //end for j
			}//end for i
			
			return(-1);
		}
		
		/**
		 * Update the string column within the data grid for the given row
		 * 
		 * @param row The integer value of the row to update
		 */
		public function resetString (row:int):void {
			var tmpString:String = new String;
			var colName:String;
			
			for (var i:int = 0; i < 16; i++) {
				colName = "col" + i.toString();
				if (this.hexArray[row][colName] != null) {
					var charInt:int = int("0x" + this.hexArray[row][colName].toString());
					if (charInt > 31 && charInt < 128) {
						tmpString += String.fromCharCode(charInt.toString());
					} else {
						tmpString += this.npChar;
					}
				}
			}
			this.hexArray[row].string = tmpString;
		}
		
		/**
		 * A utility function to determine the row in the data grid for the given position in the byte array.
		 * It will update the values for currentPosition.row and currentPosition.column
		 * 
		 * @param pos The current position within the byte array
		 * @return The row number for that position
		 */
		public function getRowFromPosition(pos:uint):int {
			this.currentPosition.row = int(pos / 16);
			this.currentPosition.column = pos % 16;
			
			return (this.currentPosition.row);
		}
		
		/**
		 * Allows for paste capabilities into the swfBytes byteArray
		 * 
		 * @param pos The position in the ByteArray to insert the data
		 * @param data The bytes to insert into the ByteArray
		 */
		public function insertData (pos:uint, data:ByteArray):void {
			if (pos > this.swfBytes.length) {
				return;
			}
			
			var temp:ByteArray = new ByteArray();
			
			if (pos > 0) {
				temp.writeBytes(this.swfBytes, 0, pos);
			}
			temp.writeBytes(data);
			temp.writeBytes(this.swfBytes,pos);
			this.swfBytes = null;
			this.swfBytes = temp;
			this.swfBytes.position = 0;
			this.swfBytes.endian = Endian.LITTLE_ENDIAN;
		}
		
		/**
		 * Allows for the deletion of a range of bytes
		 * 
		 * @param start The first position in the ByteArray to delete
		 * @param end The last position in the ByteArray to delete
		 */
		public function deleteData (start:uint, end:uint):void {
			if (end + 1 > this.swfBytes.length) {return;}
			
			var temp:ByteArray = new ByteArray();
			if (start > 0) {
				temp.writeBytes(this.swfBytes, 0, start);
			}
			temp.writeBytes(this.swfBytes,end + 1);
			
			this.swfBytes = null;
			this.swfBytes = temp;
			this.swfBytes.position = 0;
			this.swfBytes.endian = Endian.LITTLE_ENDIAN;
		}
		
		/**
		 * @public
		 * Overwrite the swfBytes Array with the data current in HexArray.
		 * The HexArray can be modified independently of swfBytes.
		 */
		public function copyHexArrayToSwfBytes():void {
			var temp:ByteArray = new ByteArray();
			var colName:String;
			
			for (var i:int = 0; i < this.hexArray.length; i++) {
				for (var j:int = 0; j < 16; j++) {
					colName = "col" + j.toString();
					if (this.hexArray[i][colName] != null && this.hexArray[i][colName].length > 0) {
						temp.writeByte(int("0x" +  this.hexArray[i][colName]));
					}
				}
			}
			
			this.swfBytes = null;
			this.swfBytes = temp;
			temp.position = 0;
			temp.endian = Endian.LITTLE_ENDIAN;
		}
		
	}//end class
}//end Package