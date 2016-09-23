//
//  Types.swift
//  ProtobufSwift
//
//  Created by Antwan van Houdt on 07/07/16.
//  Copyright © 2016 Antwan van Houdt. All rights reserved.
//

import Foundation

enum WireType: UInt8
{
    case varint        = 0
    case fixed32       = 5 // yes... this is actually true Why 5? Coz Weed I guess
    case fixed64       = 1
    case packed        = 2
    case beginGrouping = 3
    case endGrouping   = 4
    case invalid       = 100 // Bit kludgey, but allows us to keep key a non-nil object
}

struct Key
{
    let value: UInt32
    let fieldNumber: UInt32
    let type: WireType
    
    init(value: UInt32)
    {
        print("Key value: \(value)")
        self.value = value
        fieldNumber = ((value) ^ 0x00000007) >> 3
        if let newType = WireType(rawValue: UInt8((value & 0x00000007))) {
            type = newType
        } else {
            type = .invalid
        }
    }
    
    init(type: WireType, number: UInt32)
    {
        self.value = 0
        self.type = type
        self.fieldNumber = number
    }
}

struct Value: CustomStringConvertible
{
    let key: Key
    var value: Any?
    var length: Int
    
    init(value: Any?, Type: WireType, fieldNumber: UInt32)
    {
        self.key = Key(type: Type, number: fieldNumber)
        self.value = value
        self.length = 0
    }
    
    init(key: Key, data: Data)
    {
        self.key = key
        self.length = 0
        guard key.type != .invalid else {
            self.value = nil
            return
        }
        switch(key.type)
        {
        case .varint:
            let result = readVarInt(data)
            self.length = result.length
            value = result.value
            break
            
        case .fixed64:
            var result: UInt64 = 0
            (data as NSData).getBytes(&result, length: 8)
            value = UInt64(result)
            length = 8
            break
            
        case .fixed32:
            var result: UInt32 = 0
            (data as NSData).getBytes(&result, length: 4)
            value = UInt32(result)
            length = 4
            break
            
        case .packed:
            let result = readVarInt(data)
            let dataLen = Int(result.value)
            if( dataLen > 0 && data.count >= dataLen ) {
                let range = Range(uncheckedBounds: (lower: result.length, upper: dataLen))
                let packedData = data.subdata(in: range)
                let stringValue = String(data: packedData, encoding: String.Encoding.utf8)
                length = dataLen+result.length
                if( stringValue != nil ) {
                    value = stringValue
                } else {
                    value = packedData
                }
            } else {
                value = "" // Same reason as above
                length = result.length
            }
            break
            
        default:
            print("[\(type(of: self))] Unhandled WireType: \(key.type) ( Probably a deprecated value )")
            break
        }
    }
    
    var description: String {
        return "[ProtoValue type:\(key.type) value:\(value)]"
    }
}
