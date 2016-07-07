//
//  Encoder.swift
//  ProtobufSwift
//
//  Created by Antwan van Houdt on 07/07/16.
//  Copyright © 2016 Antwan van Houdt. All rights reserved.
//

import Foundation

class Encoder
{
    static let shared: Encoder = Encoder()
    
    init()
    {
        
    }
    
    func encode(storage: [Value]) -> NSData
    {
        let buffer = NSMutableData(length: 0)!
        
        for (value) in storage {
            
            // Encode the field number and type
            var byte = value.key.type.rawValue
            byte |= UInt8(value.key.fieldNumber << 3)
            encodeVarInt(UInt64(byte), buffer: buffer)
            
            switch(value.key.type) {
            case .varint:
                guard let rawValue = value.value as? UInt64 else {
                    print("[\(self.dynamicType)] Unable to encode \(value)")
                    continue
                }
                encodeVarInt(rawValue, buffer: buffer)
                break
                
            case .packed:
                if let dataRep = value.value as? NSData {
                    encodeData(dataRep, buffer: buffer)
                } else if let strRep = value.value as? String {
                    encodeString(strRep, buffer: buffer)
                } else {
                    print("[\(self.dynamicType)] Unable to encode \(value)")
                }
                break
                
            case .fixed32:
                guard let fixed = value.value as? UInt32 else {
                    print("[\(self.dynamicType)] Unable to encode \(value)")
                    continue
                }
                encodeFixed32(fixed, buffer: buffer)
                break
                
            case .fixed64:
                guard let fixed = value.value as? UInt64 else {
                    print("[\(self.dynamicType)] Unable to encode \(value)")
                    continue
                }
                encodeFixed64(fixed, buffer: buffer)
                break
                
            default:
                print("[\(self.dynamicType)] Does not yet encode values of type: \(value.key.type)")
                break
            }
        }
        
        return buffer
    }
}

func encodeVarInt(value: UInt64, buffer: NSMutableData)
{
    var n: UInt64 = value
    repeat {
        var tmp: UInt8 = UInt8(n % 0x80)
        let next: UInt64 = UInt64(floor(Double(n/0x80)))
        if( next != 0 ) {
            tmp = tmp + 0x80;
        }
        buffer.appendBytes(&tmp, length: 1)
        n = next;
    } while( n != 0 )
}

func encodeFixed64(value: UInt64, buffer: NSMutableData)
{
    var v = value
    buffer.appendBytes(&v, length: sizeof(UInt64))
}

func encodeFixed32(value: UInt32, buffer: NSMutableData)
{
    var v = value
    buffer.appendBytes(&v, length: sizeof(UInt32))
}

func encodeString(value: String, buffer: NSMutableData)
{
    guard let strData = value.dataUsingEncoding(NSUTF8StringEncoding) else {
        return
    }
    encodeVarInt(UInt64(strData.length), buffer: buffer)
    buffer.appendData(strData)
}

func encodeData(data: NSData, buffer: NSMutableData)
{
    encodeVarInt(UInt64(data.length), buffer: buffer)
    buffer.appendData(data)
}
