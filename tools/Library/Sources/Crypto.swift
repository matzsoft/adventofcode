//
//  Crypto.swift
//  day05
//
//  Created by Mark Johnson on 3/25/21.
//

import Foundation
import CommonCrypto


/// Computes the MD5 hash of its input.
///
/// This function is the same as md5Fast for legacy reasons.
///
/// - Parameter str: The string to be hashed.
/// - Returns: The hexadecimal string of the resulting hash.
public func md5Hash( str: String ) -> String {
    guard let string = str.data( using: .utf8 ) else { return "" }
    
    var digest = [UInt8]( repeating: 0, count: Int( CC_MD5_DIGEST_LENGTH ) )
    
    _ = string.withUnsafeBytes { CC_MD5( $0.baseAddress, UInt32( string.count ), &digest ) }

    return digest.map { String( format: "%02x", UInt8( $0 ) ) }.joined()
}


/// Computes the MD5 hash of its input.
///
/// This function is the same as md5Hash for legacy reasons.
///
/// - Parameter str: The string to be hashed.
/// - Returns: The hexadecimal string of the resulting hash.
public func md5Fast( str: String ) -> [UInt8] {
    guard let string = str.data( using: .utf8 ) else { return [] }
    
    var digest = [UInt8]( repeating: 0, count: Int( CC_MD5_DIGEST_LENGTH ) )
    
    _ = string.withUnsafeBytes { CC_MD5( $0.baseAddress, UInt32( string.count ), &digest ) }

    return digest
}
