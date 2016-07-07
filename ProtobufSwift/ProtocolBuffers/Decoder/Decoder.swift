//
//  Decoder.swift
//  ProtobufSwift
//
//  Created by Antwan van Houdt on 07/07/16.
//  Copyright © 2016 Antwan van Houdt. All rights reserved.
//

import Foundation

class Decoder
{
    static let shared: Decoder = Decoder()
    
    init()
    {
        
    }
    
    func decode(data: NSData) -> [UInt32: Value]
    {
        var result = [UInt32: Value]()
        let buffer = NSMutableData(data: data)
        while( buffer.length > 0 ) {
            let varint = readVarInt(buffer)
            let key    = Key(value: UInt32(varint.value))
            buffer.removeBytes(varint.length)
            let value = Value(key: key, data: buffer)
            buffer.removeBytes(value.length)
            result[key.fieldNumber] = value
        }
        return result
    }
}

// MARK: - Decoding functions

func readVarInt(data: NSData) -> (value: UInt64, length: Int)
{
    let bytes = UnsafePointer<UInt8>(data.bytes)
    
    var len: Int = 0
    var n: UInt64 = 0
    
    for i in (0..<data.length) {
        let m: UInt32 = UInt32(bytes.advancedBy(i).memory)
        n = n + UInt64((m & 0x7F) * UInt32(pow(2.0, Double(7*i))))
        if( m < 128 ) {
            len += 1
            break
        }
        len += 1
    }
    return (n, len)
}