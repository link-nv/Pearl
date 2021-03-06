/**
 * Copyright Maarten Billemont (http://www.lhunath.com, lhunath@lyndir.com)
 *
 * See the enclosed file LICENSE for license information (LGPLv3). If you did
 * not receive this file, see http://www.gnu.org/licenses/lgpl-3.0.txt
 *
 * @author   Maarten Billemont <lhunath@lyndir.com>
 * @license  http://www.gnu.org/licenses/lgpl-3.0.txt
 */

//
//  PearlCodeUtils.m
//  Pearl
//
//  Created by Maarten Billemont on 05/11/09.
//  Copyright 2009, lhunath (Maarten Billemont). All rights reserved.
//
//  See http://www.cocoadev.com/index.pl?BaseSixtyFour

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

static const char CodeUtils_Base64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

PearlHash PearlHashFromNSString(NSString *hash) {

    hash = [hash stringByReplacingOccurrencesOfString:@"-" withString:@""];
    if ([hash caseInsensitiveCompare:@"None"] == NSOrderedSame)
        return PearlHashNone;
    if ([hash caseInsensitiveCompare:@"MD4"] == NSOrderedSame)
        return PearlHashMD4;
    if ([hash caseInsensitiveCompare:@"MD5"] == NSOrderedSame)
        return PearlHashMD5;
    if ([hash caseInsensitiveCompare:@"SHA1"] == NSOrderedSame)
        return PearlHashSHA1;
    if ([hash caseInsensitiveCompare:@"SHA224"] == NSOrderedSame)
        return PearlHashSHA224;
    if ([hash caseInsensitiveCompare:@"SHA256"] == NSOrderedSame)
        return PearlHashSHA256;
    if ([hash caseInsensitiveCompare:@"SHA384"] == NSOrderedSame)
        return PearlHashSHA384;
    if ([hash caseInsensitiveCompare:@"SHA512"] == NSOrderedSame)
        return PearlHashSHA512;

    err(@"Can't understand hash function string: %@", hash);
    return PearlHashNone;
}

uint64_t PearlSecureRandom() {

    uint64_t random = 0;
#if TARGET_OS_IPHONE
    SecRandomCopyBytes( kSecRandomDefault, sizeof(random) / sizeof(uint8_t), (uint8_t *)&random );
#else
    FILE *fp = fopen("/dev/random", "r");
    if (!fp) {
        err(@"Couldn't open /dev/random.");
        return YES;
    }
    
    for (size_t i=0; i < sizeof(random); ++i)
        random |= ((uint64_t)fgetc(fp) << (8 * i));
#endif

    return random;
}

@implementation NSString(PearlCodeUtils)

- (NSData *)hashWith:(PearlHash)hash {

    return [[self dataUsingEncoding:NSUTF8StringEncoding] hashWith:hash];
}

- (NSData *)decodeHex {

    NSMutableData *data = [NSMutableData dataWithLength:self.length / 2];
    for (NSUInteger i = 0; i < self.length; i += 2) {
        NSString *hex = [self substringWithRange:NSMakeRange( i, 2 )];
        NSScanner *scanner = [NSScanner scannerWithString:hex];
        unsigned intValue;

        if (![scanner scanHexInt:&intValue])
                // Not a HEX string.
            return nil;
        [data appendBytes:&intValue length:1];
    }

    return data;
}

- (NSData *)decodeBase64 {

    if (![self length])
        return [NSData data];

    static char *decodingTable = NULL;
    if (decodingTable == NULL) {
        decodingTable = malloc( 256 );
        if (decodingTable == NULL)
            return nil;

        memset(decodingTable, CHAR_MAX, 256);
        for (char i = 0; i < 64; i++)
            decodingTable[CodeUtils_Base64EncodingTable[i]] = i;
    }

    const char *characters = [self cStringUsingEncoding:NSASCIIStringEncoding];
    if (characters == NULL)
            //  Not an ASCII string!
        return nil;

    char *bytes = malloc( (([self length] + 3) / 4) * 3 );
    if (bytes == NULL)
        return nil;

    NSUInteger length = 0, i = 0;
    while (YES) {
        char buffer[4];
        short bufferLength;
        for (bufferLength = 0; bufferLength < 4; i++) {
            if (characters[i] == '\0')
                break;
            if (isspace( characters[i] ) || characters[i] == '=')
                continue;

            buffer[bufferLength] = decodingTable[(short)characters[i]];
            if (buffer[bufferLength++] == CHAR_MAX) {
                // Illegal character!
                free( bytes );
                return nil;
            }
        }

        if (bufferLength == 0)
            break;
        if (bufferLength == 1) {
            //  At least two characters are needed to produce one byte!
            free( bytes );
            return nil;
        }

        //  Decode the characters in the buffer to bytes.
        bytes[length++] = (char)(buffer[0] << 2) | (buffer[1] >> 4);
        if (bufferLength > 2)
            bytes[length++] = (char)(buffer[1] << 4) | (buffer[2] >> 2);
        if (bufferLength > 3)
            bytes[length++] = (char)(buffer[2] << 6) | buffer[3];
    }

    realloc( bytes, length );
    return [NSData dataWithBytesNoCopy:bytes length:length];
}

- (NSString *)encodeURL {

    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (__bridge CFStringRef)self, NULL,
            CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"),
            kCFStringEncodingUTF8 );
}

- (NSString *)inject:(NSString *)injection interval:(NSUInteger)interval {

    NSMutableString *injectedString = [self mutableCopy];
    for (NSUInteger i = interval; i < [injectedString length]; i += interval + 1)
        [injectedString insertString:injection atIndex:i];

    return injectedString;
}

- (NSString *)wrapAt:(NSUInteger)lineLength {

    return [self inject:@"\n" interval:lineLength];
}

- (NSString *)wrapForMIME {

    return [self wrapAt:76];
}

- (NSString *)wrapForPEM {

    return [self wrapAt:64];
}

@end

@implementation NSData(PearlCodeUtils)

+ (NSData *)dataByConcatenatingDatas:(NSData *)datas, ... {

    NSArray *datasArray = va_array(datas);
    NSUInteger capacity = 0;
    for (NSData *data in datasArray)
        capacity += data.length;

    NSMutableData *concatenated = [NSMutableData dataWithCapacity:capacity];
    for (NSData *data in datasArray)
        [concatenated appendData:data];

    return concatenated;
}

+ (NSData *)dataByConcatenatingWithDelimitor:(char)delimitor datas:(NSData *)datas, ... {

    NSArray *datasArray = va_array(datas);
    NSUInteger capacity = [datasArray count] - 1;
    for (NSData *data in datasArray)
        capacity += data.length;

    NSMutableData *concatenated = [NSMutableData dataWithCapacity:capacity];
    NSUInteger d = 0;
    for (NSData *data in datasArray) {
        [concatenated appendData:data];

        if (++d != [datasArray count])
            [concatenated appendBytes:&delimitor length:1];
    }

    return concatenated;
}

- (NSString *)encodeHex {

    NSMutableString *hex = [NSMutableString stringWithCapacity:self.length * 2];
    for (NSUInteger i = 0; i < self.length; ++i)
        [hex appendFormat:@"%02hhx", ((char *)self.bytes)[i]];

    return hex;
}

- (NSString *)encodeBase64 {

    if ([self length] == 0)
        return @"";

    char *characters = malloc( (([self length] + 2) / 3) * 4 );
    if (characters == NULL)
        return nil;

    NSUInteger length = 0, i = 0;
    while (i < [self length]) {
        char buffer[3] = { 0, 0, 0 };
        short bufferLength = 0;
        while (bufferLength < 3 && i < [self length])
            buffer[bufferLength++] = ((char *)[self bytes])[i++];

        //  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
        characters[length++] = CodeUtils_Base64EncodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = CodeUtils_Base64EncodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = CodeUtils_Base64EncodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else
            characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = CodeUtils_Base64EncodingTable[buffer[2] & 0x3F];
        else
            characters[length++] = '=';
    }

    return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

- (NSData *)hashWith:(PearlHash)hash {

    switch (hash) {
        case PearlHashNone:
            return self;
        case PearlHashMD4: {
            unsigned char result[CC_MD4_DIGEST_LENGTH];
            CC_MD4( self.bytes, (CC_LONG)self.length, result );

            return [NSData dataWithBytes:result length:sizeof(result)];
        }
        case PearlHashMD5: {
            unsigned char result[CC_MD5_DIGEST_LENGTH];
            CC_MD5( self.bytes, (CC_LONG)self.length, result );

            return [NSData dataWithBytes:result length:sizeof(result)];
        }
        case PearlHashSHA1: {
            unsigned char result[CC_SHA1_DIGEST_LENGTH];
            CC_SHA1( self.bytes, (CC_LONG)self.length, result );

            return [NSData dataWithBytes:result length:sizeof(result)];
        }
        case PearlHashSHA224: {
            unsigned char result[CC_SHA224_DIGEST_LENGTH];
            CC_SHA224( self.bytes, (CC_LONG)self.length, result );

            return [NSData dataWithBytes:result length:sizeof(result)];
        }
        case PearlHashSHA256: {
            unsigned char result[CC_SHA256_DIGEST_LENGTH];
            CC_SHA256( self.bytes, (CC_LONG)self.length, result );

            return [NSData dataWithBytes:result length:sizeof(result)];
        }
        case PearlHashSHA384: {
            unsigned char result[CC_SHA384_DIGEST_LENGTH];
            CC_SHA384( self.bytes, (CC_LONG)self.length, result );

            return [NSData dataWithBytes:result length:sizeof(result)];
        }
        case PearlHashSHA512: {
            unsigned char result[CC_SHA512_DIGEST_LENGTH];
            CC_SHA512( self.bytes, (CC_LONG)self.length, result );

            return [NSData dataWithBytes:result length:sizeof(result)];
        }
        case PearlHashCount:
            break;
    }

    err(@"Hash function not supported: %d", hash);
    return nil;
}

- (NSData *)hmacWith:(PearlHash)hash key:(NSData *)key {

    switch (hash) {
        case PearlHashNone:
            return self;
        case PearlHashMD4:
            break;
        case PearlHashMD5: {
            unsigned char result[CC_MD5_DIGEST_LENGTH];
            CCHmac( kCCHmacAlgMD5, key.bytes, key.length, self.bytes, self.length, result );

            return [NSData dataWithBytes:result length:sizeof(result)];
        }
        case PearlHashSHA1: {
            unsigned char result[CC_SHA1_DIGEST_LENGTH];
            CCHmac( kCCHmacAlgSHA1, key.bytes, key.length, self.bytes, self.length, result );

            return [NSData dataWithBytes:result length:sizeof(result)];
        }
        case PearlHashSHA224: {
            unsigned char result[CC_SHA224_DIGEST_LENGTH];
            CCHmac( kCCHmacAlgSHA224, key.bytes, key.length, self.bytes, self.length, result );

            return [NSData dataWithBytes:result length:sizeof(result)];
        }
        case PearlHashSHA256: {
            unsigned char result[CC_SHA256_DIGEST_LENGTH];
            CCHmac( kCCHmacAlgSHA256, key.bytes, key.length, self.bytes, self.length, result );

            return [NSData dataWithBytes:result length:sizeof(result)];
        }
        case PearlHashSHA384: {
            unsigned char result[CC_SHA384_DIGEST_LENGTH];
            CCHmac( kCCHmacAlgSHA384, key.bytes, key.length, self.bytes, self.length, result );

            return [NSData dataWithBytes:result length:sizeof(result)];
        }
        case PearlHashSHA512: {
            unsigned char result[CC_SHA512_DIGEST_LENGTH];
            CCHmac( kCCHmacAlgSHA512, key.bytes, key.length, self.bytes, self.length, result );

            return [NSData dataWithBytes:result length:sizeof(result)];
        }
        case PearlHashCount:
            break;
    }

    err(@"Hash function not supported: %d", hash);
    return nil;
}

- (NSData *)saltWith:(NSData *)salt delimitor:(char)delimitor {

    NSMutableData *saltedData = [self mutableCopy];
    [saltedData appendBytes:&delimitor length:1];
    [saltedData appendData:salt];

    return saltedData;
}

- (NSData *)xorWith:(NSData *)otherData {

    if (self.length != otherData.length) {
        err(@"Input data must have the same length for an XOR operation to work.");
        return nil;
    }

    NSData *xorData = [self copy];
    for (NSUInteger b = 0; b < xorData.length; ++b)
        ((char *)xorData.bytes)[b] ^= ((char *)otherData.bytes)[b];

    return xorData;
}

@end

@implementation PearlCodeUtils

+ (NSString *)randomUUID {

    CFUUIDRef uuid = CFUUIDCreate( kCFAllocatorDefault );
    @try {
        return (__bridge_transfer NSString *)CFUUIDCreateString( kCFAllocatorDefault, uuid );
    }
    @finally {
        CFRelease( uuid );
    }
}

@end
