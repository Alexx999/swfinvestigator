package alchemy.samples {
	public class as3_crypto_wrapper {
		import cmodule.as3_crypto_wrapper.CLibInit;
		import flash.utils.ByteArray;
		protected static const _lib_init:cmodule.as3_crypto_wrapper.CLibInit = new cmodule.as3_crypto_wrapper.CLibInit();
		protected static const _lib:* = _lib_init.init();
		static public function prng_seed(seed:ByteArray):void {
			_lib.prng_seed(seed);
		}
		static public function prng_random(numBytes:uint):ByteArray {
			return _lib.prng_random(numBytes);
		}
		static public function md5_begin():uint {
			return _lib.md5_begin();
		}
		static public function md5_update(hdl:uint, data:ByteArray):void {
			_lib.md5_update(hdl, data);
		}
		static public function md5_finish(hdl:uint):ByteArray {
			return _lib.md5_finish(hdl);
		}
		static public function sha1_begin():uint {
			return _lib.sha1_begin();
		}
		static public function sha1_update(hdl:uint, data:ByteArray):void {
			_lib.sha1_update(hdl, data);
		}
		static public function sha1_finish(hdl:uint):ByteArray {
			return _lib.sha1_finish(hdl);
		}
		static public function sha256_begin():uint {
			return _lib.sha256_begin();
		}
		static public function sha256_update(hdl:uint, data:ByteArray):void {
			_lib.sha256_update(hdl, data);
		}
		static public function sha256_finish(hdl:uint):ByteArray {
			return _lib.sha256_finish(hdl);
		}
		static public function sha384_begin():uint {
			return _lib.sha384_begin();
		}
		static public function sha384_update(hdl:uint, data:ByteArray):void {
			_lib.sha384_update(hdl, data);
		}
		static public function sha384_finish(hdl:uint):ByteArray {
			return _lib.sha384_finish(hdl);
		}
		static public function pkcs12_acquire(inP12:ByteArray, pwd:String, outContents:Object):uint {
			return _lib.pkcs12_acquire(inP12, pwd, outContents);
		}
		static public function pkcs12_sign(hdl:uint, algID:String, digest:ByteArray):ByteArray {
			return _lib.pkcs12_sign(hdl, algID, digest);
		}
		static public function pkcs12_decrypt(hdl:uint, paddingName:String, encrypted:ByteArray):ByteArray {
			return _lib.pkcs12_decrypt(hdl, paddingName, encrypted);
		}
		static public function pkcs12_release(hdl:uint):void {
			_lib.pkcs12_release(hdl);
		}
		static public function aes128_cbc_encrypt_begin(key:ByteArray, iv:ByteArray):uint {
			return _lib.aes128_cbc_encrypt_begin(key, iv);
		}
		static public function aes128_cbc_decrypt_begin(key:ByteArray, iv:ByteArray):uint {
			return _lib.aes128_cbc_decrypt_begin(key, iv);
		}
		static public function symmetric_encrypt_update(hdl:uint, data:ByteArray):ByteArray {
			return _lib.symmetric_encrypt_update(hdl, data);
		}
		static public function symmetric_encrypt_finish(hdl:uint):ByteArray {
			return _lib.symmetric_encrypt_finish(hdl);
		}
		static public function symmetric_decrypt_update(hdl:uint, data:ByteArray):ByteArray {
			return _lib.symmetric_decrypt_update(hdl, data);
		}
		static public function symmetric_decrypt_finish(hdl:uint):ByteArray {
			return _lib.symmetric_decrypt_finish(hdl);
		}
	}
}
