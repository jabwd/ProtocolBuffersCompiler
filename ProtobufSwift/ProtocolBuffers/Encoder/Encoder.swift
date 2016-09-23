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
    
    func encode(_ storage: [Value]) -> Data
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
                    print("[\(type(of: self))] Unable to encode \(value)")
                    continue
                }
                encodeVarInt(rawValue, buffer: buffer)
                break
                
            case .packed:
                if let dataRep = value.value as? Data {
                    encodeData(dataRep, buffer: buffer)
                } else if let strRep = value.value as? String {
                    encodeString(strRep, buffer: buffer)
                } else {
                    print("[\(type(of: self))] Unable to encode \(value)")
                }
                break
                
            case .fixed32:
                guard let fixed = value.value as? UInt32 else {
                    print("[\(type(of: self))] Unable to encode \(value)")
                    continue
                }
                encodeFixed32(fixed, buffer: buffer)
                break
                
            case .fixed64:
                guard let fixed = value.value as? UInt64 else {
                    print("[\(type(of: self))] Unable to encode \(value)")
                    continue
                }
                encodeFixed64(fixed, buffer: buffer)
                break
                
            default:
                print("[\(type(of: self))] Does not yet encode values of type: \(value.key.type)")
                break
            }
        }
        
        return buffer as Data
    }
}

func encodeVarInt(_ value: UInt64, buffer: NSMutableData)
{
    var n: UInt64 = value
    repeat {
        var tmp: UInt8 = UInt8(n % 0x80)
        let next: UInt64 = UInt64(floor(Double(n/0x80)))
        if( next != 0 ) {
            tmp = tmp + 0x80;
        }
        buffer.append(&tmp, length: 1)
        n = next;
    } while( n != 0 )
}

func encodeFixed64(_ value: UInt64, buffer: NSMutableData)
{
    var v = value
    buffer.append(&v, length: MemoryLayout<UInt64>.size)
}

func encodeFixed32(_ value: UInt32, buffer: NSMutableData)
{
    var v = value
    buffer.append(&v, length: MemoryLayout<UInt32>.size)
}

func encodeString(_ value: String, buffer: NSMutableData)
{
    guard let strData = value.data(using: String.Encoding.utf8) else {
        return
    }
    encodeVarInt(UInt64(strData.count), buffer: buffer)
    buffer.append(strData)
}

func encodeData(_ data: Data, buffer: NSMutableData)
{
    encodeVarInt(UInt64(data.count), buffer: buffer)
    buffer.append(data)
}
