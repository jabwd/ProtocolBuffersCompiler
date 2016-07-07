//
//  NSDataAdditions.swift
//  ProtobufSwift
//
//  Created by Antwan van Houdt on 07/07/16.
//  Copyright © 2016 Antwan van Houdt. All rights reserved.
//

import Foundation

extension NSMutableData
{
    func removeBytes(n: Int)
    {
        if length < n {
            replaceBytesInRange(NSMakeRange(0, length), withBytes: nil, length: 0)
            return
        }
        replaceBytesInRange(NSMakeRange(0, n), withBytes: nil, length: 0)
    }
}
