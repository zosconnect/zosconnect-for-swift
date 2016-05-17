/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation
import SwiftyJSON
import KituraNet

public class Service {
  let connection: ZosConnect
  let serviceName: String
  let invokeUri: URLParser

  public init(connection: ZosConnect, serviceName: String, invokeUri: String) {
    self.connection = connection
    self.serviceName = serviceName
    self.invokeUri = URLParser(url: invokeUri.data(using: NSUTF8StringEncoding)!, isConnect: false)
  }
  
  public func invoke(data: NSData?, callback: DataCallback){
    var options = [ClientRequestOptions.schema(invokeUri.schema! + "://"),
                   ClientRequestOptions.hostname(invokeUri.host!),
                   ClientRequestOptions.path(invokeUri.path! + "?action=invoke"),
                   ClientRequestOptions.method("POST")]
    if let port = invokeUri.port {
      options.append(ClientRequestOptions.port(Int16(port)))
    }
    let req = HTTP.request(options) { (response) in
      let data = NSMutableData()
      let resultObj = ZosConnectResult<NSData>()
      do {
        if let localresponse = response {
          resultObj.statusCode = localresponse.status
          try localresponse.readAllData(into: data)
          resultObj.result = data
        }
      } catch let error {
        resultObj.error = ZosConnectErrors.CONNECTIONERROR(error)
      }
      callback(response: resultObj)
    }
    if let requestData = data {
        req.end(requestData)
    } else {
        req.end("{}")
    }
  }
  
  public func getRequestSchema(callback: DataCallback){
    var uri = connection.hostName + ":" + String(connection.port)
    uri += "/zosConnect/services/" + serviceName + "?action=getRequestSchema"
    HTTP.get(uri) { (response) in
      let resultObj = ZosConnectResult<NSData>()
      let data = NSMutableData()
      do {
        if let localresponse = response {
          if localresponse.statusCode == HTTPStatusCode.OK {
            try localresponse.readAllData(into: data)
            resultObj.result = data
          } else if localresponse.statusCode == HTTPStatusCode.notFound {
            resultObj.error = ZosConnectErrors.UNKNOWNSERVICE
          } else {
            resultObj.error = ZosConnectErrors.SERVERERROR(localresponse.status)
          }
        }
      } catch let error {
        resultObj.error = ZosConnectErrors.CONNECTIONERROR(error)
      }
      callback(response: resultObj)
    }
  }
  
  public func getResponseSchema(callback: DataCallback){
    var uri = connection.hostName + ":" + String(connection.port)
    uri += "/zosConnect/services/" + serviceName + "?action=getResponseSchema"
    HTTP.get(uri) { (response) in
      let resultObj = ZosConnectResult<NSData>()
      let data = NSMutableData()
      do {
        if let localresponse = response {
          if localresponse.statusCode == HTTPStatusCode.OK {
            try localresponse.readAllData(into: data)
            resultObj.result = data
          } else if localresponse.statusCode == HTTPStatusCode.notFound {
            resultObj.error = ZosConnectErrors.UNKNOWNSERVICE
          } else {
            resultObj.error = ZosConnectErrors.SERVERERROR(localresponse.status)
          }
        }
      } catch let error {
        resultObj.error = ZosConnectErrors.CONNECTIONERROR(error)
      }
      callback(response: resultObj)
    }
  }
  
  public func getStatus(callback: StatusCallback){
    var uri = connection.hostName + ":" + String(connection.port)
    uri += "/zosConnect/services/" + serviceName + "?action=status"
    HTTP.get(uri) { (response) in
      let resultObj = ZosConnectResult<ServiceStatus>()
      let data = NSMutableData()
      do {
        try response?.readAllData(into: data)
        let json = JSON(data: data)
        if let status = json["zosConnect"]["serviceStatus"].string {
          if status == "Started" {
            resultObj.result = ServiceStatus.STARTED
          } else if status == "Stopped" {
            resultObj.result = ServiceStatus.STOPPED
          }
        }
      } catch let error {
        resultObj.error = error
      }
      callback(response: resultObj)  
    }
  }
}

public typealias StatusCallback = (response: ZosConnectResult<ServiceStatus>) -> Void

// MARK: ServiceStatus enum

public enum ServiceStatus: String {
  case STARTED = "STARTED", STOPPED = "STOPPED", UNAVAILABLE = "UNAVAILABLE"
}
