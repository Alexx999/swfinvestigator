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

package decompiler.swfdump.util.SwfImageUtils
{
	import flash.utils.ByteArray;
	import decompiler.swfdump.SWFFormatError;
	
	/**
	 * A variety of utilities for dealing with the image formats that are
	 * part of the SWF spec.
	 *
	 * @author Roger Gonzalez
	 */
	
	public class JPEG
	{
		public var table:ByteArray;
		public var data:ByteArray;
		
		private var width:int;
		private var height:int;
		
		/**
		 public function JPEG(table:ByteArray, data:ByteArray )
		 {
		 this.table = table;
		 this.data = data;
		 
		 validate();
		 }
		 */
		
		public function JPEG(table:ByteArray = null, data:ByteArray = null, jpeg:ByteArray = null, doSplit:Boolean = false )
		{
			if (jpeg != null) {
				if (doSplit)
					split( jpeg );
				else
					data = jpeg;
			} else {
				this.table = table;
				this.data = data;
			}
			
			validate();
		}
		
		public function getWidth():int
		{
			return width;
		}
		
		public function getHeight():int
		{
			return height;
		}
		
		static public function markerIsSOF( code:uint ):Boolean
		{
			return ((code >= 0xc0)
				&& (code <= 0xcf)
				&& (code != 0xc4)
				&& (code != 0xcc));
		}
		
		public function validate():Boolean
		{
			if (table != null)
			{
				// Confirm that there are only db and c4 markers...
				
				var it:JPEGIterator = new JPEGIterator( table );
				
				if ( !it.getValid() )  // constructor does an SOI/EOI check...
					return false;
				it.next();
				
				while (it.getValid() && (it.getCode() != 0xd9))
				{
					if ((it.getCode() != 0xc4) && (it.getCode() != 0xdb))
						return false;
					it.next();
				}
				
				if (it.getOffset() != table.length-2)
					return false;
			}
			
			if (data == null)
				return false;
			
			it = new JPEGIterator( data );
			
			if ( !it.getValid() )
				return false;
			
			var foundSOS:Boolean = false;
			var foundSOF:Boolean = false;
			
			while (it.getValid())
			{
				if (it.getCode() == 0xda)
					foundSOS = true;
				
				if (!foundSOF && markerIsSOF(it.getCode()))
				{
					foundSOF = true;
					height = (((data[it.getOffset()+5]&0xff)<<8)
						|(data[it.getOffset()+6]&0xff));
					
					width = (((data[it.getOffset()+7]&0xff)<<8)
						|(data[it.getOffset()+8]&0xff));
					
					if ((width == 0) || (height == 0))
						return false;
				}
				it.next();
			}
			return ( foundSOS && foundSOF && (it.getOffset() == data.length));
		}
		
		private function split( jpeg:ByteArray ):void //throws IllegalStateException
		{
			var it:JPEGIterator = new JPEGIterator( jpeg );
			var tablesize:int = 4;
			
			while (it.getValid())
			{
				if ((it.getCode() == 0xdb) || (it.getCode() == 0xc4))
					tablesize += it.getLength() + 2;
				it.next();
			}
			
			//table = new byte[tablesize];
			table = new ByteArray();
			table.length = tablesize;
			table.position = 0;
			var tableoffset:int = 0;
			table[tableoffset++] = 0xff;
			table[tableoffset++] = 0xd8;
			
			var datasize:int = 4 + (jpeg.length - tablesize);
			var dataoffset:int = 0;
			//data = new byte[datasize];
			data = new ByteArray();
			data.length = datasize;
			data.position = 0;
			
			it.reset();
			while (it.getValid())
			{
				if ((it.getCode() == 0xdb) || (it.getCode() == 0xc4))
				{
					/**java.lang.System.arraycopy( jpeg,
					 it.offset(),
					 table,
					 tableoffset,
					 it.size() );*/
					table.writeBytes(jpeg, it.getOffset(),it.size());
					tableoffset += it.size();
				}
				else
				{
					/**
					 java.lang.System.arraycopy( jpeg,
					 it.offset(),
					 data,
					 dataoffset,
					 it.size() );
					 */
					data.writeBytes(jpeg, it.getOffset(),it.size());
					dataoffset += it.size();
				}
				it.next();
			}
			table[tableoffset++] =  0xff;
			table[tableoffset++] =  0xd9;
			
			if ( (tableoffset < table.length) || (dataoffset < data.length) )
				throw new SWFFormatError( "JPEG data is corrupt!" );
		}
		
		public function write( out:ByteArray ):void  //throws IOException
		{
			// Simple case: non-split JPEG
			if (table == null)
			{
				out.writeBytes( data );
				return;
			}
			
			// Harder case... emit the tables just before the SOS marker.
			var i:uint = 0;
			while (i < data.length)
			{
				if ( data[i] !=  0xff )
				{
					++i;
					continue;
				}
				if (i + 1 >= data.length)
					return;
				
				
				var marker:uint = data[i+1];
				
				if (marker == 0xff)
				{
					++i;
					continue;
				}
				
				if ((marker == 0x00)
					|| (marker == 0x01)
					|| ((marker >= 0xd0) && (marker <= 0xd9 )))
				{
					i += 2;
					continue;
				}
				if (marker == 0xda)    // Start of Scan, aka SOS
				{
					out.writeBytes( data, 0, i );
					out.writeBytes( table, 2, table.length - 4 );
					out.writeBytes( data, i, data.length - i );
					return;
				}
				else
				{
					if (i + 3 >= data.length)
						return;
					
					var length:int =  ((data[i+2]&0xff)<<8) + (data[i+3]&0xff);
					i += length;
				}
			}
		}
		
	}
	
	// You don't care about this.  Move along.
	/**
	 public static function jpegDebugSegments( data:ByteArray ):void
	 {
	 var it:JPEGIterator = new JPEGIterator( data );
	 
	 while (it.valid())
	 {
	 System.out.print( "offset " + it.offset() + ": " );
	 
	 System.out.print( Integer.toHexString(it.code() & 0xff) + " (");
	 
	 switch( it.code() )
	 {
	 case 0xc0: System.out.print( "SOF0"); break;
	 case 0xc1: System.out.print( "SOF1"); break;
	 case 0xc2: System.out.print( "SOF2"); break;
	 case 0xc3: System.out.print( "SOF3"); break;
	 case 0xc4: System.out.print( "DHT"); break;
	 case 0xc5: System.out.print( "SOF5"); break;
	 case 0xc6: System.out.print( "SOF6"); break;
	 case 0xc7: System.out.print( "SOF7"); break;
	 case 0xc8: System.out.print( "JPGext"); break;
	 case 0xc9: System.out.print( "SOF9"); break;
	 case 0xca: System.out.print( "SOF10"); break;
	 case 0xcb: System.out.print( "SOF11"); break;
	 case 0xcc: System.out.print( "DAC"); break;
	 case 0xcd: System.out.print( "SOF13"); break;
	 case 0xce: System.out.print( "SOF14"); break;
	 case 0xcf: System.out.print( "SOF15"); break;
	 
	 case 0xd0: System.out.print( "RST0"); break;
	 case 0xd1: System.out.print( "RST1"); break;
	 case 0xd2: System.out.print( "RST2"); break;
	 case 0xd3: System.out.print( "RST3"); break;
	 case 0xd4: System.out.print( "RST4"); break;
	 case 0xd5: System.out.print( "RST5"); break;
	 case 0xd6: System.out.print( "RST6"); break;
	 case 0xd7: System.out.print( "RST7"); break;
	 
	 case 0xd8: System.out.print( "SOI"); break;
	 case 0xd9: System.out.print( "EOI"); break;
	 
	 case 0xda: System.out.print( "SOS"); break;
	 case 0xdb: System.out.print( "DQT"); break;
	 case 0xdc: System.out.print( "DNL"); break;
	 case 0xdd: System.out.print( "DRI"); break;
	 case 0xde: System.out.print( "DHP"); break;
	 case 0xdf: System.out.print( "EXP"); break;
	 
	 case 0xe0: System.out.print( "APP0"); break;
	 case 0xe1: System.out.print( "APP1"); break;
	 case 0xe2: System.out.print( "APP2"); break;
	 case 0xe3: System.out.print( "APP3"); break;
	 case 0xe4: System.out.print( "APP4"); break;
	 case 0xe5: System.out.print( "APP5"); break;
	 case 0xe6: System.out.print( "APP6"); break;
	 case 0xe7: System.out.print( "APP7"); break;
	 case 0xe8: System.out.print( "APP8"); break;
	 case 0xe9: System.out.print( "APP9"); break;
	 case 0xea: System.out.print( "APP10"); break;
	 case 0xeb: System.out.print( "APP11"); break;
	 case 0xec: System.out.print( "APP12"); break;
	 case 0xed: System.out.print( "APP13"); break;
	 case 0xee: System.out.print( "APP14"); break;
	 case 0xef: System.out.print( "APP15"); break;
	 
	 case 0xf0: System.out.print( "JPG0"); break;
	 case 0xf1: System.out.print( "JPG1"); break;
	 case 0xf2: System.out.print( "JPG2"); break;
	 case 0xf3: System.out.print( "JPG3"); break;
	 case 0xf4: System.out.print( "JPG4"); break;
	 case 0xf5: System.out.print( "JPG5"); break;
	 case 0xf6: System.out.print( "JPG6"); break;
	 case 0xf7: System.out.print( "JPG7"); break;
	 case 0xf8: System.out.print( "JPG8"); break;
	 case 0xf9: System.out.print( "JPG9"); break;
	 case 0xfa: System.out.print( "JPG10"); break;
	 case 0xfb: System.out.print( "JPG11"); break;
	 case 0xfc: System.out.print( "JPG12"); break;
	 case 0xfd: System.out.print( "JPG13"); break;
	 case 0xfe: System.out.print( "COM"); break;
	 
	 case 0x00: System.out.print( "00?"); break;
	 case 0x01: System.out.print( "TEM"); break;
	 default: System.out.print("???"); break;
	 }
	 System.out.print( ") ");
	 
	 if ((it.code() == 0x00)
	 || (it.code() == 0x01)
	 || ((it.code() >= 0xd0) && (it.code() <= 0xd9 )))
	 System.out.print( "len=0");
	 else
	 System.out.print( "len=" + it.length() );
	 
	 System.out.print( " size=" + it.size() );
	 
	 var i:int = it.offset();
	 
	 if ( it.code() == (byte)0xfe)
	 {
	 var comment:ByteArray = new ByteArray();
	 comment.length = it.length() + 1; //new byte[it.length() + 1];
	 for (var c:uint = 0; c < it.length(); ++c )
	 comment[c] = data[i+2+c];
	 
	 System.out.print( " COMMENT='" + comment + "'");
	 }
	 
	 if ( it.code() == 0xe0)
	 {
	 if (( data[i+4] == 'J')
	 && (data[i+5] == 'F')
	 && (data[i+6] == 'I')
	 && (data[i+7] == 'F')
	 && (data[i+8] == 0))
	 System.out.print(" JFIF");
	 }
	 
	 if ( (it.code() == (byte)0xc0)
	 || (it.code() == (byte)0xc1)
	 || (it.code() == (byte)0xc2)
	 || (it.code() == (byte)0xc3)
	 || (it.code() == (byte)0xc5)
	 || (it.code() == (byte)0xc6)
	 || (it.code() == (byte)0xc7)
	 || (it.code() == (byte)0xc8)
	 || (it.code() == (byte)0xc9)
	 || (it.code() == (byte)0xca)
	 || (it.code() == (byte)0xcb)
	 || (it.code() == (byte)0xcd)
	 || (it.code() == (byte)0xce)
	 || (it.code() == (byte)0xcf))
	 {
	 System.out.print( " precision = " + data[i+4]);
	 var y:int = ((data[i+5]&0xff)<<8) | (data[i+6]&0xff);
	 var x:int = ((data[i+7]&0xff)<<8) | (data[i+8]&0xff);
	 System.out.print( " dimensions = " + x + "," + y );
	 }
	 
	 
	 System.out.println(".");
	 it.next();
	 }
	 }*/
}