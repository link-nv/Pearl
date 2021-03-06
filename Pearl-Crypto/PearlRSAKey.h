/**
 * Copyright Maarten Billemont (http://www.lhunath.com, lhunath@lyndir.com)
 *
 * See the enclosed file LICENSE for license information (LGPLv3). If you did
 * not receive this file, see http://www.gnu.org/licenses/lgpl-3.0.txt
 *
 * @author   Maarten Billemont <lhunath@lyndir.com>
 * @license  http://www.gnu.org/licenses/lgpl-3.0.txt
 */

#ifdef PEARL_WITH_OPENSSL
#import <Foundation/Foundation.h>

#import "PearlCodeUtils.h"


@interface PearlRSAKey : NSObject
{
    void                            *_key;
    BOOL                            _isPublicKey;
}

@property (readwrite, assign) BOOL  isPublicKey;

- (id)init;
- (id)initWithKeyLength:(NSUInteger)keyBitLength;
- (id)initWithHexModulus:(NSString *)hexModulus privateExponent:(NSString *)hexExponent;
- (id)initWithBinaryModulus:(NSData *)modulus privateExponent:(NSData *)exponent;
- (id)initWithHexModulus:(NSString *)hexModulus privateExponent:(NSString *)hexExponent
                            primeP:(NSString *)hexPrimeP primeQ:(NSString *)hexPrimeQ;
- (id)initWithBinaryModulus:(NSData *)modulus privateExponent:(NSData *)exponent
                               primeP:(NSData *)primeP primeQ:(NSData *)primeQ;
- (id)initWithHexModulus:(NSString *)hexModulus publicExponent:(NSString *)hexExponent;
- (id)initWithBinaryModulus:(NSData *)modulus publicExponent:(NSData *)exponent;
- (id)initWithDEREncodedASN1:(NSData *)derEncodedKey isPublic:(BOOL)isPublicKey;
- (id)initWithDEREncodedPKCS12:(NSData *)derEncodedKey keyPhrase:(NSString *)keyPhrase isPublic:(BOOL)isPublicKey;
- (id)initWithPEMEncodedPKCS12:(NSData *)pemEncodedKey keyPhrase:(NSString *)keyPhrase isPublic:(BOOL)isPublicKey;
- (id)initWithDictionary:(NSDictionary *)dictionary;

/**
 * Convert this key to its public equivalent, discarting any private factors.
 */
- (PearlRSAKey *)publicKey;
/**
 * Export this key to a DER-encoded ASN1 structure.
 */
- (NSData *)derExportASN1;
/**
 * Export this key to a DER-encoded PKCS#12 format, optionally encrypting it with a key phrase.
 */
- (NSData *)derExportPKCS12WithName:(NSString *)friendlyName encryptWithKeyPhrase:(NSString *)keyPhrase;
/**
 * Export this key to a PEM-encoded format, optionally encrypting it with a key phrase.
 */
- (NSData *)pemExport:(NSString *)friendlyName encryptWithKeyPhrase:(NSString *)keyPhrase;

/**
 * @return The modulus of the RSA key.  This is the same for matching public and private key.
 */
- (NSString *)modulus;
/**
 * @return The private exponent of the RSA key.
 */
- (NSString *)privateExponent;
/**
 * @return The public exponent of the RSA key.
 */
- (NSString *)publicExponent;
/**
 * @return A dictionary that provides all the known factors of the RSA key.
 */
- (NSDictionary *)dictionaryRepresentation;

/**
 * Encrypt the given plain-text with this key.  PKCS1 padding will be used.
 */
- (NSData *)encryptPlainData:(NSData *)data;
/**
 * Decrypt the given encrypted data with this key.  The data must have been encrypted with PKCS1 padding.
 */
- (NSData *)decryptCipherData:(NSData *)data;
/**
 * Sign the given data with this private key.
 * 
 * PKCS1 padding will be used.
 * If a hash other than PearlHashNone is given, the data will be hashed by the hash algorithm and wrapped in a DigestInfo structure
 * before RSA signing is applied to it.  If PearlHashNone is given, the data must be a DER-encoded DigestInfo structure.
 */
- (NSData *)signData:(NSData *)data hashWith:(PearlHash)hash;
/**
 * Verify that the given signature is the result of signing the given data with the private key equivalent of this public key.
 * 
 * The signature must have been created with PKCS1 padding.
 * If a hash other than PearlHashNone is given, the data will be hashed by the hash algorithm and wrapped in a DigestInfo structure
 * before RSA signing is applied to it.  If PearlHashNone is given, the data must be a DER-encoded DigestInfo structure.
 */
- (BOOL)verifySignature:(NSData *)signature ofData:(NSData *)data hashWith:(PearlHash)hash;
/**
 * Verify that the given signature is the result of signing certain data with the private key equivalent of this public key.
 * The hash of the signed data will be recovered if the signature is valid.
 * 
 * The signature must have been created with PKCS1 padding.
 * If a hash other than PearlHashNone is given, the data must have been hashed by the given hash algorithm before it was signed.
 * If PearlHashNone is given, the DigestInfo structure will be recovered.
 */
- (NSData *)verifySignature:(NSData *)signature recoverDataHashedWith:(PearlHash)hash;

/**
 * Generate a certificate signing request signed by this private key and return the ASN.1 structure in DER encoding.
 * 
 * The result can be used by a certificate authority to generate a certificate for use by the owner of this key.
 */
- (NSData *)derEncodedCSRForSubject:(NSDictionary *)x509Subject hashWith:(PearlHash)hash;

/**
 * Generate a certificate signing request signed by this private key and return it PEM-encoded.
 * 
 * The result can be used by a certificate authority to generate a certificate for use by the owner of this key.
 */
- (NSData *)pemEncodedCSRForSubject:(NSDictionary *)x509Subject hashWith:(PearlHash)hash;


@end
#endif
