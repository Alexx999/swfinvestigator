package decompiler.swfdump.util
{
	public class IntMap
	{
		private var keys:Vector.<int>;
		private var values:Array;
		private var mapSize:int;
		
		public function IntMap(capacity:int = 10)
		{
			keys = new Vector.<int>(capacity);
			values = new Array(capacity);
		}
		
		/**
		 * An approximation of Java's System.arraycopy
		 */
		private function arrayCopy (a1:*, s1:int, a2:*, s2:int, size:int):void {
			var temp:Array;
			var i:int;
			
			for (i=s1; i< s1 + size; i++) {
				temp[i-s1] = a1[i];
			}
			
			for (i=0; i < size; i++) {
				a2[s2 + i] = temp[i];
			}
		} 
		
		public function capacity():int
		{
			return keys.length;
		}
		
		private function find(k:int):int
		{
			var lo:int = 0;
			var hi:int = this.mapSize-1;
			
			while (lo <= hi)
			{
				var i:int = (lo + hi)/2;
				var m:int = keys[i];
				if (k > m)
					lo = i + 1;
				else if (k < m)
					hi = i - 1;
				else
					return i; // key found
			}
			return -(lo + 1);  // key not found, low is the insertion point
		}
		
		public function remove(k:int):*
		{
			var old:* = null;
			var i:int = find(k);
			if (i >= 0)
			{
				old = values[i];
				arrayCopy(keys, i+1, keys, i, this.mapSize-i-1);
				arrayCopy(values, i+1, values, i, this.mapSize-i-1);
				this.mapSize--;
			}
			return old;
		}
		
		public function clear():void
		{
			this.mapSize = 0;
		}
		
		public function put(k:int, v:*):*
		{
			if (this.mapSize == 0 || k > keys[this.mapSize-1])
			{
				if (this.mapSize == keys.length)
					grow();
				keys[this.mapSize] = k;
				values[this.mapSize] = v;
				this.mapSize++;
				return null;
			}
			else
			{
				var i:int = find(k);
				if (i >= 0)
				{
					var old:* = values[i];
					values[i] = v;
					return old;
				}
				else
				{
					i = -i - 1; // recover the insertion point
					if (this.mapSize == keys.length)
						grow();
					arrayCopy(keys,i,keys,i+1,this.mapSize-i);
					arrayCopy(values,i,values,i+1,this.mapSize-i);
					keys[i] = k;
					values[i] = v;
					this.mapSize++;
					return null;
				}
			}
		}
		
		private function grow():void
		{
			var newkeys:Vector.<int> = new Vector.<int>(this.mapSize*2);
			arrayCopy(keys,0,newkeys,0,this.mapSize);
			keys = newkeys;
			
			var newvalues:Array = new Array(this.mapSize*2);
			arrayCopy(values,0,newvalues,0,this.mapSize);
			values = newvalues;
		}
		
		public function get(k:int):*
		{
			var i:int = find(k);
			return i >= 0 ? values[i] : null;
		}
		
		public function contains(k:int):Boolean
		{
			return find(k) >= 0;
		}
		
		/** 
		 * A bit of an aberration from an academic point of view,
		 * but since this is an ordered Map, why not!
		 * 
		 * @return the element immediately following element k.
		 */
		public function getNextAdjacent(k:int):*
		{
			var i:int = find(k);
			return ( (i >= 0) && (i+1 < this.mapSize) ) ? values[i+1] : null;
		}
		
		/**
		public Iterator iterator()
		{
			return new Iterator()
			{
				private int i = 0;
				public boolean hasNext()
				{
					return i < size;
				}
				
				public Object next()
				{
					if (i >= size)
					{
						throw new NoSuchElementException();
					}
					final int j = i++;
					return new Map.Entry()
					{
						public Object getKey()
						{
							return new Integer(keys[j]);
						}
						
						public Object getValue()
						{
							return values[j];
						}
						
						public Object setValue(Object value)
						{
							Object old = values[j];
							values[j] = value;
							return old;
						}
					};
				}
				
				public void remove()
				{
					arrayCopy(keys, i, keys, i-1, size-i);
					arrayCopy(values, i, values, i-1, size-i);
					size--;
				}
			};
		}
		 */
		
		public function size():int
		{
			return this.mapSize;
		}
		
		/** 
		 * @param ar must be of size size().
		 */
		public function valuesToArray(ar:Vector.<Object>):Vector.<Object>
		{
			arrayCopy(values, 0, ar, 0, this.mapSize);
			return ar;
		}
		
		public function keySetToArray():Vector.<int>
		{
			var ar:Vector.<int> = new Vector.<int>(this.size());
			arrayCopy(keys, 0, ar, 0, this.mapSize);
			return ar;
		}
	}
}