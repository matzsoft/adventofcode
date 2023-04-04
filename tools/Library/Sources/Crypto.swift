//
//  Crypto.swift
//  day05
//
//  Created by Mark Johnson on 3/25/21.
//

import Foundation
import CommonCrypto


func md5Hash( str: String ) -> String {
    guard let string = str.data( using: .utf8 ) else { return "" }
    
    var digest = [UInt8]( repeating: 0, count: Int( CC_MD5_DIGEST_LENGTH ) )
    
    _ = string.withUnsafeBytes { CC_MD5( $0.baseAddress, UInt32( string.count ), &digest ) }

    return digest.map { String( format: "%02x", UInt8( $0 ) ) }.joined()
}


func md5Fast( str: String ) -> [UInt8] {
    guard let string = str.data( using: .utf8 ) else { return [] }
    
    var digest = [UInt8]( repeating: 0, count: Int( CC_MD5_DIGEST_LENGTH ) )
    
    _ = string.withUnsafeBytes { CC_MD5( $0.baseAddress, UInt32( string.count ), &digest ) }

    return digest
}
