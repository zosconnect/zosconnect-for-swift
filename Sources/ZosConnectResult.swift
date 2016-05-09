//
//  ZosConnectResult.swift
//  zosconnectforswift
//
//  Created by Andrew Smithson on 09/05/2016.
//
//

import Foundation
import KituraNet

public class ZosConnectResult<T> {
    var error: ErrorType?
    var result: T?
    var statusCode: HttpStatusCode?
    
    public init(){
        error = nil;
        result = nil;
        statusCode = nil;
    }
}