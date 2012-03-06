#include "AS3.h"
AS3_Val gg_lib = NULL;

#line 1 "as3_crypto_wrapper.gg"
 // start of pass-thru C section
/*
** This is the generated file produced from as3_crypto_wrapper.gg
** This source is an example of how you can use the OpenSSL crypto library from Flash or AIR.
**
** This product includes software developed by the OpenSSL Project
** for use in the OpenSSL Toolkit (http://www.openssl.org/)
**
** ADOBE SYSTEMS INCORPORATED
** Copyright 2008 Adobe Systems Incorporated. All Rights Reserved.
**
** NOTICE:  Adobe permits you to use, modify, and distribute this file in
** accordance with the terms of the Adobe license agreement accompanying it.
** If you have received this file from a source other than Adobe, then your use,
** modification, or distribution of it requires the prior written permission of Adobe.
**
*/

#include <stdlib.h>
#include <string.h>
#include <malloc.h>

#include <openssl/evp.h>
#include <openssl/err.h>
#include <openssl/rand.h>
#include <openssl/md5.h>
#include <openssl/sha.h>
#include <openssl/pkcs12.h>
#include <openssl/rsa.h>
#include <openssl/dsa.h>
#include <openssl/aes.h>

/* AS3.h is included automatically by gluegen */

void sztrace(char*);

AS3_Val no_params = NULL;
AS3_Val zero_param = NULL;
AS3_Val ByteArray_class = NULL;
AS3_Val getTimer_method = NULL;

/* This function will be called at the top of the generated main(). The GGINIT_DEFINED macro is required. */
#define GGINIT_DEFINED true
static void ggInit()
{
	sztrace("setting up as3_crypto_wrapper library");

	/* setup some useful constants */
	no_params = AS3_Array("");
	zero_param = AS3_Int(0);
	AS3_Val flash_utils_namespace = AS3_String("flash.utils");
	ByteArray_class = AS3_NSGetS(flash_utils_namespace, "ByteArray");
	getTimer_method = AS3_NSGetS(flash_utils_namespace, "getTimer");
	AS3_Release(flash_utils_namespace);

	/* initialize */
	SSLeay_add_all_algorithms();
	ERR_load_crypto_strings();
}

/* Copy the byteArray data into a malloc'd buffer */
static void* newMallocFromByteArray(AS3_Val byteArray, unsigned int* size)
{
	AS3_Val byteArraySize = AS3_GetS(byteArray, "length");
	*size = AS3_IntValue(byteArraySize);
	AS3_Release(byteArraySize);
	void* bytes = malloc(*size);
	AS3_SetS(byteArray, "position", zero_param);
	AS3_ByteArray_readBytes((char*)bytes, byteArray, (int)*size);
	return bytes;
}

/* Make a new ByteArray containing the data passed */
static AS3_Val newByteArrayFromMalloc(void *data, unsigned int size)
{
	AS3_Val byteArray = AS3_New(ByteArray_class, no_params);
	AS3_ByteArray_writeBytes(byteArray, data, size);
	return byteArray;
}

#if 0 // use for profiling
/* get a timestamp from Flash */
static int getTimestamp()
{
	AS3_Val ts = AS3_Call(getTimer_method, NULL, no_params);
	int result = AS3_IntValue(ts);
	AS3_Release(ts);
	return result;
}
#endif

/* convert the padding name to an OpenSSL define */
static int getPadding(const char *name)
{
	const char PKCS1[] = "pkcs1-padding";
	if(strncmp(name, PKCS1, sizeof(PKCS1)-1) == 0)
		return RSA_PKCS1_PADDING;

	const char PKCS1_OAEP[] = "pkcs1-oaep-padding";
	if(strncmp(name, PKCS1_OAEP, sizeof(PKCS1_OAEP)-1) == 0)
		return RSA_PKCS1_OAEP_PADDING;

	const char SSLV23[] = "sslv23-padding";
	if(strncmp(name, SSLV23, sizeof(SSLV23)-1) == 0)
		return RSA_SSLV23_PADDING;

	const char NONE[] = "no-padding";
	if(strncmp(name, NONE, sizeof(NONE)-1) == 0)
		return RSA_NO_PADDING;
		
	return -1;
}

/* Convert OID in dotted notation to an NID_* value */
static int getNID(const char *oid)
{
	const char sha1[] = "1.3.14.3.2.26";
	if(strncmp(oid, sha1, sizeof(sha1)-1) == 0)
		return NID_sha1;
	
	const char sha256[] = "2.16.840.1.101.2.4.2.1";
	if(strncmp(oid, sha256, sizeof(sha256)-1) == 0)
		return NID_sha256;
	
	const char sha384[] = "2.16.840.1.101.2.4.2.2";
	if(strncmp(oid, sha384, sizeof(sha384)-1) == 0)
		return NID_sha384;
	
	const char sha512[] = "2.16.840.1.101.2.4.2.3";
	if(strncmp(oid, sha512, sizeof(sha512)-1) == 0)
		return NID_sha512;
	
	const char md5[] = "1.2.840.113549.2.5";
	if(strncmp(oid, md5, sizeof(md5)-1) == 0)
		return NID_md5;
	
	return -1;
}

static void prng_seed_impl(AS3_Val seed)
{
  /* This is not thread-safe. However Flash is currently single-threaded. */
  static int seeded = 0;
  if(0 == seeded) {
	sztrace("seeding PRNG");
    
	/* use entropy passed if any */
	unsigned int seedSize = 4092;
    if(seed) {
	  unsigned int callerSeedSize = 0;
	  unsigned char * callerSeedBytes = newMallocFromByteArray(seed, &callerSeedSize);
      RAND_add(callerSeedBytes, callerSeedSize, callerSeedSize);
      seedSize -= (callerSeedSize * 8);
	}	  
	  
    /* get <seedSize> bits of entropy from Flash (1/32 .. using 1/2 double each time) */
    AS3_Val mathClass = AS3_NSGetS(NULL, "Math");
    AS3_Val mathRandom = AS3_GetS(mathClass, "random");
	const unsigned int numDoubles = seedSize/32;
	unsigned int i;
    for(i = 0; i < numDoubles; i++) {
      AS3_Val num = AS3_Call(mathRandom, NULL, no_params);
      double e = AS3_NumberValue(num);
      RAND_add(&e, sizeof(e), 4); /* range is 0-1 so just use 4 bytes */
      AS3_Release(num);
    }		
    AS3_Release(mathRandom);
    AS3_Release(mathClass);

    seeded = 1;
  }
}

/* end of passthru C section */

#line 178 "as3_crypto_wrapper.gg"
static void impl_prng_seed(AS3_Val seed) {

#line 179 "as3_crypto_wrapper.gg"

	prng_seed_impl(seed);
}
static AS3_Val thunk_prng_seed(void *gg_clientData, AS3_Val gg_args) {
	AS3_Val seed;
	AS3_ArrayValue(gg_args, "AS3ValType",  &seed);
	impl_prng_seed(
#line 178 "as3_crypto_wrapper.gg"
 seed);
	return NULL;
}

#line 184 "as3_crypto_wrapper.gg"
static AS3_Val impl_prng_random(unsigned numBytes) {

#line 185 "as3_crypto_wrapper.gg"

	unsigned char * bytes = malloc(numBytes);
	RAND_bytes(bytes, numBytes);
	AS3_Val ba = newByteArrayFromMalloc(bytes, numBytes);
	free(bytes);
	return ba;
}
static AS3_Val thunk_prng_random(void *gg_clientData, AS3_Val gg_args) {
	unsigned numBytes;
	AS3_ArrayValue(gg_args, "IntType",  &numBytes);
	
#line 184 "as3_crypto_wrapper.gg"
return (
#line 184 "as3_crypto_wrapper.gg"
impl_prng_random(
#line 184 "as3_crypto_wrapper.gg"
 numBytes));
}

#line 194 "as3_crypto_wrapper.gg"
static unsigned impl_md5_begin() {

#line 195 "as3_crypto_wrapper.gg"

	MD5_CTX * hdl = malloc(sizeof(MD5_CTX));
	MD5_Init(hdl);
	return (uint)hdl;
}
static AS3_Val thunk_md5_begin(void *gg_clientData, AS3_Val gg_args) {
	AS3_ArrayValue(gg_args, "", NULL);
	
#line 194 "as3_crypto_wrapper.gg"
return AS3_Int(
#line 194 "as3_crypto_wrapper.gg"
impl_md5_begin());
}

#line 202 "as3_crypto_wrapper.gg"
static void impl_md5_update(MD5_CTX* hdl, AS3_Val data) {

#line 203 "as3_crypto_wrapper.gg"

	unsigned int size = 0;
	unsigned char* bytes = newMallocFromByteArray(data, &size);
	MD5_Update(hdl, bytes, size);
	free(bytes);
}
static AS3_Val thunk_md5_update(void *gg_clientData, AS3_Val gg_args) {
	unsigned hdl;
	AS3_Val data;
	AS3_ArrayValue(gg_args, "IntType, AS3ValType",  &hdl,  &data);
	impl_md5_update(
#line 202 "as3_crypto_wrapper.gg"
(MD5_CTX*) hdl, 
#line 202 "as3_crypto_wrapper.gg"
 data);
	return NULL;
}

#line 211 "as3_crypto_wrapper.gg"
static AS3_Val impl_md5_finish(MD5_CTX* hdl) {

#line 212 "as3_crypto_wrapper.gg"

	unsigned char * buffer = malloc(MD5_DIGEST_LENGTH);
	MD5_Final(buffer, hdl);
	AS3_Val ba = newByteArrayFromMalloc(buffer, MD5_DIGEST_LENGTH);
	free(buffer);
	return ba;
}
static AS3_Val thunk_md5_finish(void *gg_clientData, AS3_Val gg_args) {
	unsigned hdl;
	AS3_ArrayValue(gg_args, "IntType",  &hdl);
	
#line 211 "as3_crypto_wrapper.gg"
return (
#line 211 "as3_crypto_wrapper.gg"
impl_md5_finish(
#line 211 "as3_crypto_wrapper.gg"
(MD5_CTX*) hdl));
}

#line 221 "as3_crypto_wrapper.gg"
static unsigned impl_sha1_begin() {

#line 222 "as3_crypto_wrapper.gg"

	SHA_CTX * hdl = malloc(sizeof(SHA_CTX));
	SHA1_Init(hdl);
	return (uint)hdl;
}
static AS3_Val thunk_sha1_begin(void *gg_clientData, AS3_Val gg_args) {
	AS3_ArrayValue(gg_args, "", NULL);
	
#line 221 "as3_crypto_wrapper.gg"
return AS3_Int(
#line 221 "as3_crypto_wrapper.gg"
impl_sha1_begin());
}

#line 229 "as3_crypto_wrapper.gg"
static void impl_sha1_update(SHA_CTX* hdl, AS3_Val data) {

#line 230 "as3_crypto_wrapper.gg"

	unsigned int size = 0;
	unsigned char* bytes = newMallocFromByteArray(data, &size);
	SHA1_Update(hdl, bytes, size);
	free(bytes);
}
static AS3_Val thunk_sha1_update(void *gg_clientData, AS3_Val gg_args) {
	unsigned hdl;
	AS3_Val data;
	AS3_ArrayValue(gg_args, "IntType, AS3ValType",  &hdl,  &data);
	impl_sha1_update(
#line 229 "as3_crypto_wrapper.gg"
(SHA_CTX*) hdl, 
#line 229 "as3_crypto_wrapper.gg"
 data);
	return NULL;
}

#line 238 "as3_crypto_wrapper.gg"
static AS3_Val impl_sha1_finish(SHA_CTX* hdl) {

#line 239 "as3_crypto_wrapper.gg"

	unsigned char * buffer = malloc(SHA_DIGEST_LENGTH);
	SHA1_Final(buffer, hdl);
	AS3_Val ba = newByteArrayFromMalloc(buffer, SHA_DIGEST_LENGTH);
	free(buffer);
	return ba;
}
static AS3_Val thunk_sha1_finish(void *gg_clientData, AS3_Val gg_args) {
	unsigned hdl;
	AS3_ArrayValue(gg_args, "IntType",  &hdl);
	
#line 238 "as3_crypto_wrapper.gg"
return (
#line 238 "as3_crypto_wrapper.gg"
impl_sha1_finish(
#line 238 "as3_crypto_wrapper.gg"
(SHA_CTX*) hdl));
}

#line 248 "as3_crypto_wrapper.gg"
static unsigned impl_sha256_begin() {

#line 249 "as3_crypto_wrapper.gg"

	SHA256_CTX * hdl = malloc(sizeof(SHA256_CTX));
	SHA256_Init(hdl);
	return (uint)hdl;
}
static AS3_Val thunk_sha256_begin(void *gg_clientData, AS3_Val gg_args) {
	AS3_ArrayValue(gg_args, "", NULL);
	
#line 248 "as3_crypto_wrapper.gg"
return AS3_Int(
#line 248 "as3_crypto_wrapper.gg"
impl_sha256_begin());
}

#line 256 "as3_crypto_wrapper.gg"
static void impl_sha256_update(SHA256_CTX* hdl, AS3_Val data) {

#line 257 "as3_crypto_wrapper.gg"

	unsigned int size = 0;
	unsigned char* bytes = newMallocFromByteArray(data, &size);
	SHA256_Update(hdl, bytes, size);
	free(bytes);
}
static AS3_Val thunk_sha256_update(void *gg_clientData, AS3_Val gg_args) {
	unsigned hdl;
	AS3_Val data;
	AS3_ArrayValue(gg_args, "IntType, AS3ValType",  &hdl,  &data);
	impl_sha256_update(
#line 256 "as3_crypto_wrapper.gg"
(SHA256_CTX*) hdl, 
#line 256 "as3_crypto_wrapper.gg"
 data);
	return NULL;
}

#line 265 "as3_crypto_wrapper.gg"
static AS3_Val impl_sha256_finish(SHA256_CTX* hdl) {

#line 266 "as3_crypto_wrapper.gg"

	unsigned char * buffer = malloc(SHA256_DIGEST_LENGTH);
	SHA256_Final(buffer, hdl);
	AS3_Val ba = newByteArrayFromMalloc(buffer, SHA256_DIGEST_LENGTH);
	free(buffer);
	return ba;
}
static AS3_Val thunk_sha256_finish(void *gg_clientData, AS3_Val gg_args) {
	unsigned hdl;
	AS3_ArrayValue(gg_args, "IntType",  &hdl);
	
#line 265 "as3_crypto_wrapper.gg"
return (
#line 265 "as3_crypto_wrapper.gg"
impl_sha256_finish(
#line 265 "as3_crypto_wrapper.gg"
(SHA256_CTX*) hdl));
}

#line 275 "as3_crypto_wrapper.gg"
static unsigned impl_sha384_begin() {

#line 276 "as3_crypto_wrapper.gg"

	SHA512_CTX * hdl = malloc(sizeof(SHA512_CTX));
	SHA384_Init(hdl);
	return (uint)hdl;
}
static AS3_Val thunk_sha384_begin(void *gg_clientData, AS3_Val gg_args) {
	AS3_ArrayValue(gg_args, "", NULL);
	
#line 275 "as3_crypto_wrapper.gg"
return AS3_Int(
#line 275 "as3_crypto_wrapper.gg"
impl_sha384_begin());
}

#line 283 "as3_crypto_wrapper.gg"
static void impl_sha384_update(SHA512_CTX* hdl, AS3_Val data) {

#line 284 "as3_crypto_wrapper.gg"

	unsigned int size = 0;
	unsigned char* bytes = newMallocFromByteArray(data, &size);
	SHA384_Update(hdl, bytes, size);
	free(bytes);
}
static AS3_Val thunk_sha384_update(void *gg_clientData, AS3_Val gg_args) {
	unsigned hdl;
	AS3_Val data;
	AS3_ArrayValue(gg_args, "IntType, AS3ValType",  &hdl,  &data);
	impl_sha384_update(
#line 283 "as3_crypto_wrapper.gg"
(SHA512_CTX*) hdl, 
#line 283 "as3_crypto_wrapper.gg"
 data);
	return NULL;
}

#line 292 "as3_crypto_wrapper.gg"
static AS3_Val impl_sha384_finish(SHA512_CTX* hdl) {

#line 293 "as3_crypto_wrapper.gg"

	unsigned char * buffer = malloc(SHA384_DIGEST_LENGTH);
	SHA384_Final(buffer, hdl);
	AS3_Val ba = newByteArrayFromMalloc(buffer, SHA384_DIGEST_LENGTH);
	free(buffer);
	return ba;
}
static AS3_Val thunk_sha384_finish(void *gg_clientData, AS3_Val gg_args) {
	unsigned hdl;
	AS3_ArrayValue(gg_args, "IntType",  &hdl);
	
#line 292 "as3_crypto_wrapper.gg"
return (
#line 292 "as3_crypto_wrapper.gg"
impl_sha384_finish(
#line 292 "as3_crypto_wrapper.gg"
(SHA512_CTX*) hdl));
}

#line 302 "as3_crypto_wrapper.gg"
static unsigned impl_pkcs12_acquire(AS3_Val inP12, const char * pwd, AS3_Val outContents) {

#line 303 "as3_crypto_wrapper.gg"

	sztrace("pkcs12_acquire");

	/* make something OpenSSL can use */
	unsigned int p12size = 0;
	unsigned char * p12data = newMallocFromByteArray(inP12, &p12size);
	BIO * bio = BIO_new_mem_buf(p12data, p12size);

	/* open and parse the P12 */
	X509 *cert;
	EVP_PKEY *hdl;
	STACK_OF(X509) *ca;
	PKCS12 * p12 = d2i_PKCS12_bio(bio, NULL);
	if(NULL == p12 || !PKCS12_parse(p12, pwd, &hdl, &cert, &ca)) {
		ERR_print_errors_fp(stderr);
		PKCS12_free(p12);
		BIO_free_all(bio);
		free(p12data);
		return 0;
	}
	sztrace("pkcs12_acquire - parsed p12");

	/* add the certificate to the output */
	unsigned int certSize = i2d_X509(cert, NULL);
	unsigned char *certData = malloc(certSize);
	i2d_X509(cert, &certData);
	certData -= certSize; /* i2d_* moves the ptr ahead -- ugh */
	AS3_SetS(outContents, "certificate", newByteArrayFromMalloc(certData, certSize));
	free(certData);
	X509_free(cert);
	sztrace("pkcs12_acquire - extracted certificate");
	
	/* add the key size */
	AS3_SetS(outContents, "keySize", AS3_Int(EVP_PKEY_bits(hdl)));
	
	/* add the key algorithm */
	switch(EVP_PKEY_type(hdl->type)) {
	case EVP_PKEY_RSA:
		AS3_SetS(outContents, "keyAlgorithm", AS3_String("1.2.840.113549.1.1.1")); // OID.kRSAEncryptionOID
		break;
	case EVP_PKEY_DSA:
		AS3_SetS(outContents, "keyAlgorithm", AS3_String("1.2.840.10040.4.1")); // OID.kDSASignatureKeyOID
		break;
	case EVP_PKEY_DH:
		AS3_SetS(outContents, "keyAlgorithm", AS3_String("1.2.840.113549.1.3.1")); // OID.kRSADHKeyAgreement
		break;
	case EVP_PKEY_EC:
		AS3_SetS(outContents, "keyAlgorithm", AS3_String("2.23.42.9.11.4.1")); // OID.kECDSADigitalSignatureAlgorithmOID
		break;
	default:
		AS3_SetS(outContents, "keyAlgorithm", AS3_String("Unsupported!"));
		break;
	}
	sztrace("pkcs12_acquire - set key algorithm");

	/*XXX extract the CA certs */

	/* return the key handle */
	return (uint)hdl;
}
static AS3_Val thunk_pkcs12_acquire(void *gg_clientData, AS3_Val gg_args) {
	AS3_Val inP12;
	const char * pwd;
	AS3_Val outContents;
	AS3_ArrayValue(gg_args, "AS3ValType, StrType, AS3ValType",  &inP12,  &pwd,  &outContents);
	
#line 302 "as3_crypto_wrapper.gg"
return AS3_Int(
#line 302 "as3_crypto_wrapper.gg"
impl_pkcs12_acquire(
#line 302 "as3_crypto_wrapper.gg"
 inP12, 
#line 302 "as3_crypto_wrapper.gg"
 pwd, 
#line 302 "as3_crypto_wrapper.gg"
 outContents));
}

#line 365 "as3_crypto_wrapper.gg"
static AS3_Val impl_pkcs12_sign(EVP_PKEY* hdl, const char * algID, AS3_Val digest) {

#line 366 "as3_crypto_wrapper.gg"

	sztrace("pkcs12_sign");

	/* convert algID to an NID_* value */
	int nid = getNID(algID);
	if(-1 == nid) {
		sztrace("pkcs12_sign - unsupported algorithm");
		return NULL;
	}
 	
	/* malloc a buffer for the digest data */
	unsigned int digestLen = 0;
	unsigned char * digestData = newMallocFromByteArray(digest, &digestLen);
	AS3_Release(digest);

	/* seed the PRNG as needed */
	prng_seed_impl(NULL);

	/* do the signing using <p12obj> */
	AS3_Val sig = NULL;
	int result = 0;
	unsigned int sigLen = 0;
	unsigned char * sigData = NULL;
	switch(EVP_PKEY_type(hdl->type)) {
	case EVP_PKEY_RSA: {
		RSA *rsa = EVP_PKEY_get1_RSA(hdl);
		sigLen = RSA_size(rsa);
		sigData = malloc(sigLen);
		result = RSA_sign(nid, digestData, digestLen, sigData, &sigLen, rsa);
		} 
		break;
		
	case EVP_PKEY_DSA: {
		DSA *dsa = EVP_PKEY_get1_DSA(hdl);
		sigLen = DSA_size(dsa);
		sigData = malloc(sigLen);
		result = DSA_sign(nid, digestData, digestLen, sigData, &sigLen, dsa);
		} 
		break;
		
	case EVP_PKEY_DH: /* DH *dh = EVP_PKEY_get1_DH(hdl); */
	case EVP_PKEY_EC: /* EC_KEY *ec = EVP_PKEY_get1_EC_KEY(hdl); */
	default:
		sztrace("pkcs12_sign - unsupported key type"); 
		break;
	}
	
	/* check for errors */
	if(0 == result) 
		ERR_print_errors_fp(stderr);

	free(digestData);
	free(sigData);
	return sig;
}
static AS3_Val thunk_pkcs12_sign(void *gg_clientData, AS3_Val gg_args) {
	unsigned hdl;
	const char * algID;
	AS3_Val digest;
	AS3_ArrayValue(gg_args, "IntType, StrType, AS3ValType",  &hdl,  &algID,  &digest);
	
#line 365 "as3_crypto_wrapper.gg"
return (
#line 365 "as3_crypto_wrapper.gg"
impl_pkcs12_sign(
#line 365 "as3_crypto_wrapper.gg"
(EVP_PKEY*) hdl, 
#line 365 "as3_crypto_wrapper.gg"
 algID, 
#line 365 "as3_crypto_wrapper.gg"
 digest));
}

#line 423 "as3_crypto_wrapper.gg"
static AS3_Val impl_pkcs12_decrypt(EVP_PKEY* hdl, const char * paddingName, AS3_Val encrypted) {

#line 424 "as3_crypto_wrapper.gg"

	sztrace("pkcs12_decrypt");

	/* get the padding */
	int padding = getPadding(paddingName);
	if(-1 == padding) {
		sztrace("pkcs12_decrypt - padding not supported");
		return NULL;
	}

	/* seed the PRNG as needed */
	prng_seed_impl(NULL);
	
	/* malloc a buffer for the encrypted data */
	unsigned int encryptedLen = 0;
	unsigned char * encryptedData = newMallocFromByteArray(encrypted, &encryptedLen);
	AS3_Release(encrypted);
	
	/* do the decryption using <key> */
	AS3_Val decrypted = NULL;
	unsigned int decryptedLen = 0;
	unsigned char * decryptedData = NULL;
	switch(EVP_PKEY_type(hdl->type)) {
	case EVP_PKEY_RSA: {
		RSA *rsa = EVP_PKEY_get1_RSA(hdl);
		const int maxBufferSize = RSA_size(rsa);
		decryptedData = malloc(maxBufferSize);
		decryptedLen = RSA_private_decrypt(encryptedLen, encryptedData, decryptedData, rsa, padding);
		decrypted = newByteArrayFromMalloc(decryptedData, decryptedLen);	
		} 
		break;
	case EVP_PKEY_DSA:	/* no such thing as DSA decryption */
	case EVP_PKEY_DH:	/* DH *EVP_PKEY_get1_DH(EVP_PKEY *pkey); */
	case EVP_PKEY_EC:	/* EC_KEY *EVP_PKEY_get1_EC_KEY(EVP_PKEY *pkey); */
	default:
		break;
	}

	/* check for errors */
	if(-1 == decryptedLen)
		ERR_print_errors_fp(stderr);

	free(encryptedData);
	free(decryptedData);
	return decrypted;	
}
static AS3_Val thunk_pkcs12_decrypt(void *gg_clientData, AS3_Val gg_args) {
	unsigned hdl;
	const char * paddingName;
	AS3_Val encrypted;
	AS3_ArrayValue(gg_args, "IntType, StrType, AS3ValType",  &hdl,  &paddingName,  &encrypted);
	
#line 423 "as3_crypto_wrapper.gg"
return (
#line 423 "as3_crypto_wrapper.gg"
impl_pkcs12_decrypt(
#line 423 "as3_crypto_wrapper.gg"
(EVP_PKEY*) hdl, 
#line 423 "as3_crypto_wrapper.gg"
 paddingName, 
#line 423 "as3_crypto_wrapper.gg"
 encrypted));
}

#line 472 "as3_crypto_wrapper.gg"
static void impl_pkcs12_release(EVP_PKEY* hdl) {

#line 473 "as3_crypto_wrapper.gg"

	sztrace("pkcs12_release");
	EVP_PKEY_free(hdl);
}
static AS3_Val thunk_pkcs12_release(void *gg_clientData, AS3_Val gg_args) {
	unsigned hdl;
	AS3_ArrayValue(gg_args, "IntType",  &hdl);
	impl_pkcs12_release(
#line 472 "as3_crypto_wrapper.gg"
(EVP_PKEY*) hdl);
	return NULL;
}

#line 478 "as3_crypto_wrapper.gg"
static unsigned impl_aes128_cbc_encrypt_begin(AS3_Val key, AS3_Val iv) {

#line 479 "as3_crypto_wrapper.gg"

	sztrace("aes128_cbc_encrypt_begin");

	EVP_CIPHER_CTX * ctx = malloc(sizeof(EVP_CIPHER_CTX));
	EVP_CIPHER_CTX_init(ctx);
	const EVP_CIPHER * cipherType = EVP_aes_128_cbc();
	unsigned int keySize = 0;
	unsigned char * keyBytes = newMallocFromByteArray(key, &keySize);
	unsigned int ivSize = 0;
	unsigned char * ivBytes = newMallocFromByteArray(iv, &ivSize);	
	if(!EVP_EncryptInit(ctx, cipherType, keyBytes, ivBytes))
		ERR_print_errors_fp(stderr);

	free(ivBytes);
	free(keyBytes);
	return (uint)ctx;	
}
static AS3_Val thunk_aes128_cbc_encrypt_begin(void *gg_clientData, AS3_Val gg_args) {
	AS3_Val key;
	AS3_Val iv;
	AS3_ArrayValue(gg_args, "AS3ValType, AS3ValType",  &key,  &iv);
	
#line 478 "as3_crypto_wrapper.gg"
return AS3_Int(
#line 478 "as3_crypto_wrapper.gg"
impl_aes128_cbc_encrypt_begin(
#line 478 "as3_crypto_wrapper.gg"
 key, 
#line 478 "as3_crypto_wrapper.gg"
 iv));
}

#line 497 "as3_crypto_wrapper.gg"
static unsigned impl_aes128_cbc_decrypt_begin(AS3_Val key, AS3_Val iv) {

#line 498 "as3_crypto_wrapper.gg"

	sztrace("aes128_cbc_decrypt_begin");

	EVP_CIPHER_CTX * ctx = malloc(sizeof(EVP_CIPHER_CTX));
	EVP_CIPHER_CTX_init(ctx);
	const EVP_CIPHER * cipherType = EVP_aes_128_cbc();
	unsigned int keySize = 0;
	unsigned char * keyBytes = newMallocFromByteArray(key, &keySize);
	unsigned int ivSize = 0;
	unsigned char * ivBytes = newMallocFromByteArray(iv, &ivSize);	
	if(!EVP_DecryptInit(ctx, cipherType, keyBytes, ivBytes))
		ERR_print_errors_fp(stderr);

	free(ivBytes);
	free(keyBytes);
	return (uint)ctx;	
}
static AS3_Val thunk_aes128_cbc_decrypt_begin(void *gg_clientData, AS3_Val gg_args) {
	AS3_Val key;
	AS3_Val iv;
	AS3_ArrayValue(gg_args, "AS3ValType, AS3ValType",  &key,  &iv);
	
#line 497 "as3_crypto_wrapper.gg"
return AS3_Int(
#line 497 "as3_crypto_wrapper.gg"
impl_aes128_cbc_decrypt_begin(
#line 497 "as3_crypto_wrapper.gg"
 key, 
#line 497 "as3_crypto_wrapper.gg"
 iv));
}

#line 516 "as3_crypto_wrapper.gg"
static AS3_Val impl_symmetric_encrypt_update(EVP_CIPHER_CTX* hdl, AS3_Val data) {

#line 517 "as3_crypto_wrapper.gg"

	sztrace("symmetric_encrypt_update");

	unsigned int inSize = 0;
	unsigned char * inData = newMallocFromByteArray(data, &inSize);

	char msg[512];
	sprintf(msg, "encrypting: %s", inData);
	sztrace(msg);
	
	unsigned int outSize = inSize + EVP_CIPHER_CTX_block_size(hdl) ;
	unsigned char * outData = malloc(outSize);

	sprintf(msg, "inSize=%d, block_size=%d", inSize, EVP_CIPHER_CTX_block_size(hdl));
	sztrace(msg);
	
	if(!EVP_EncryptUpdate(hdl, outData, (int*)&outSize, inData, inSize))
		ERR_print_errors_fp(stderr);
		
	sprintf(msg, "outputsize=%d", outSize);
	sztrace(msg);

	free(inData);
	AS3_Val out = newByteArrayFromMalloc(outData, outSize);
	free(outData);
	return out;
}
static AS3_Val thunk_symmetric_encrypt_update(void *gg_clientData, AS3_Val gg_args) {
	unsigned hdl;
	AS3_Val data;
	AS3_ArrayValue(gg_args, "IntType, AS3ValType",  &hdl,  &data);
	
#line 516 "as3_crypto_wrapper.gg"
return (
#line 516 "as3_crypto_wrapper.gg"
impl_symmetric_encrypt_update(
#line 516 "as3_crypto_wrapper.gg"
(EVP_CIPHER_CTX*) hdl, 
#line 516 "as3_crypto_wrapper.gg"
 data));
}

#line 545 "as3_crypto_wrapper.gg"
static AS3_Val impl_symmetric_encrypt_finish(EVP_CIPHER_CTX* hdl) {

#line 546 "as3_crypto_wrapper.gg"

	sztrace("symmetric_encrypt_finish");

	unsigned int outSize = EVP_CIPHER_CTX_block_size(hdl);
	unsigned char * outData = malloc(outSize);
	
	if(!EVP_EncryptFinal(hdl, outData, (int*)&outSize))
		ERR_print_errors_fp(stderr);

	char msg[512];
	sprintf(msg, "outputsize=%d", outSize);
	sztrace(msg);

	AS3_Val out = newByteArrayFromMalloc(outData, outSize);
	free(outData);
	return out;
}
static AS3_Val thunk_symmetric_encrypt_finish(void *gg_clientData, AS3_Val gg_args) {
	unsigned hdl;
	AS3_ArrayValue(gg_args, "IntType",  &hdl);
	
#line 545 "as3_crypto_wrapper.gg"
return (
#line 545 "as3_crypto_wrapper.gg"
impl_symmetric_encrypt_finish(
#line 545 "as3_crypto_wrapper.gg"
(EVP_CIPHER_CTX*) hdl));
}

#line 564 "as3_crypto_wrapper.gg"
static AS3_Val impl_symmetric_decrypt_update(EVP_CIPHER_CTX* hdl, AS3_Val data) {

#line 565 "as3_crypto_wrapper.gg"

	sztrace("symmetric_decrypt_update");

	unsigned int inSize = 0;
	unsigned char * inData = newMallocFromByteArray(data, &inSize);
	
	char msg[512];
	sprintf(msg, "inSize=%d, block_size=%d", inSize, EVP_CIPHER_CTX_block_size(hdl));
	sztrace(msg);
	
	unsigned int outSize = inSize + EVP_CIPHER_CTX_block_size(hdl);
	unsigned char * outData = malloc(outSize);

	if(!EVP_DecryptUpdate(hdl, outData, (int*)&outSize, inData, inSize))
		ERR_print_errors_fp(stderr);

	sprintf(msg, "outSize=%d", outSize);
	sztrace(msg);

	free(inData);
	AS3_Val out = newByteArrayFromMalloc(outData, outSize);
	free(outData);
	return out;
}
static AS3_Val thunk_symmetric_decrypt_update(void *gg_clientData, AS3_Val gg_args) {
	unsigned hdl;
	AS3_Val data;
	AS3_ArrayValue(gg_args, "IntType, AS3ValType",  &hdl,  &data);
	
#line 564 "as3_crypto_wrapper.gg"
return (
#line 564 "as3_crypto_wrapper.gg"
impl_symmetric_decrypt_update(
#line 564 "as3_crypto_wrapper.gg"
(EVP_CIPHER_CTX*) hdl, 
#line 564 "as3_crypto_wrapper.gg"
 data));
}

#line 590 "as3_crypto_wrapper.gg"
static AS3_Val impl_symmetric_decrypt_finish(EVP_CIPHER_CTX* hdl) {

#line 591 "as3_crypto_wrapper.gg"

	unsigned int outSize = 0; //EVP_CIPHER_CTX_block_size(hdl);
	
	int result = EVP_DecryptFinal(hdl, NULL, (int*)&outSize);
	if(!result)
		ERR_print_errors_fp(stderr);

	char msg[512];
	sprintf(msg, "outSize=%d, rc=%d", outSize, result);
	sztrace(msg);
	
	outSize = 64000;//XXX testing
	unsigned char * outData = malloc(outSize);

	if(!EVP_DecryptFinal(hdl, outData, (int*)&outSize))
		ERR_print_errors_fp(stderr);

	sprintf(msg, "outSize=%d, outData=%s", outSize, outData);
	sztrace(msg);

	AS3_Val out = newByteArrayFromMalloc(outData, outSize);
	free(outData);
	return out;
}
static AS3_Val thunk_symmetric_decrypt_finish(void *gg_clientData, AS3_Val gg_args) {
	unsigned hdl;
	AS3_ArrayValue(gg_args, "IntType",  &hdl);
	
#line 590 "as3_crypto_wrapper.gg"
return (
#line 590 "as3_crypto_wrapper.gg"
impl_symmetric_decrypt_finish(
#line 590 "as3_crypto_wrapper.gg"
(EVP_CIPHER_CTX*) hdl));
}
AS3_Val gg_string(const char *str) {
	AS3_Val result = AS3_String(str);
	free((void *)str);
	return result;
}
void gg_reg(AS3_Val lib, const char *name, AS3_ThunkProc p) {
	AS3_Val fun = AS3_Function(NULL, p);
	AS3_SetS(lib, name, fun);
	AS3_Release(fun);
}
void gg_reg_async(AS3_Val lib, const char *name, AS3_ThunkProc p) {
	AS3_Val fun = AS3_FunctionAsync(NULL, p);
	AS3_SetS(lib, name, fun);
	AS3_Release(fun);
}
int main(int argc, char **argv) {
#if defined(GGINIT_DEFINED)
	ggInit();
#endif
	gg_lib = AS3_Object("");
	gg_reg(gg_lib, "prng_seed", thunk_prng_seed);
	gg_reg(gg_lib, "prng_random", thunk_prng_random);
	gg_reg(gg_lib, "md5_begin", thunk_md5_begin);
	gg_reg(gg_lib, "md5_update", thunk_md5_update);
	gg_reg(gg_lib, "md5_finish", thunk_md5_finish);
	gg_reg(gg_lib, "sha1_begin", thunk_sha1_begin);
	gg_reg(gg_lib, "sha1_update", thunk_sha1_update);
	gg_reg(gg_lib, "sha1_finish", thunk_sha1_finish);
	gg_reg(gg_lib, "sha256_begin", thunk_sha256_begin);
	gg_reg(gg_lib, "sha256_update", thunk_sha256_update);
	gg_reg(gg_lib, "sha256_finish", thunk_sha256_finish);
	gg_reg(gg_lib, "sha384_begin", thunk_sha384_begin);
	gg_reg(gg_lib, "sha384_update", thunk_sha384_update);
	gg_reg(gg_lib, "sha384_finish", thunk_sha384_finish);
	gg_reg(gg_lib, "pkcs12_acquire", thunk_pkcs12_acquire);
	gg_reg(gg_lib, "pkcs12_sign", thunk_pkcs12_sign);
	gg_reg(gg_lib, "pkcs12_decrypt", thunk_pkcs12_decrypt);
	gg_reg(gg_lib, "pkcs12_release", thunk_pkcs12_release);
	gg_reg(gg_lib, "aes128_cbc_encrypt_begin", thunk_aes128_cbc_encrypt_begin);
	gg_reg(gg_lib, "aes128_cbc_decrypt_begin", thunk_aes128_cbc_decrypt_begin);
	gg_reg(gg_lib, "symmetric_encrypt_update", thunk_symmetric_encrypt_update);
	gg_reg(gg_lib, "symmetric_encrypt_finish", thunk_symmetric_encrypt_finish);
	gg_reg(gg_lib, "symmetric_decrypt_update", thunk_symmetric_decrypt_update);
	gg_reg(gg_lib, "symmetric_decrypt_finish", thunk_symmetric_decrypt_finish);
	AS3_LibInit(gg_lib);
	return 1;
}
