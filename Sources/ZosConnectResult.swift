//
//  ZosConnectResult.swift
//  zosconnectforswift
//
//  Created by Andrew Smithson on 09/05/2016.
//
//

import Foundation
import Swift
import KituraNet

open class ZosConnectResult<T> {
    var error: Swift.Error?
    var result: T?
    var statusCode: Int?
    
    public init(){
        error = nil;
        result = nil;
        statusCode = nil;
    }
}
