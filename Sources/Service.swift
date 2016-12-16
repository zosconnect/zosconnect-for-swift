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

open class Service {
  let connection: ZosConnect
  let serviceName: String
  let invokeUri: URLParser

  public init(connection: ZosConnect, serviceName: String, invokeUri: String) {
    self.connection = connection
    self.serviceName = serviceName
    self.invokeUri = URLParser(url: invokeUri.data(using: String.Encoding.utf8)!, isConnect: false)
  }
  
  open func invoke(_ data: Data?, callback: @escaping DataCallback){
    var hostPort:Int16
    if let port = invokeUri.port {
      hostPort = Int16(port);
    } else {
      if invokeUri.schema == "https" {
        hostPort = Int16(443);
      } else {
        hostPort = Int16(80);
      }
    }
    var options = [ClientRequest.Options.schema(invokeUri.schema! + "://"),
                   ClientRequest.Options.hostname(invokeUri.host!),
                   ClientRequest.Options.port(hostPort),
                   ClientRequest.Options.path(invokeUri.path! + "?action=invoke"),
                   ClientRequest.Options.method("PUT")]
    if let port = invokeUri.port {
      options.append(ClientRequest.Options.port(Int16(port)))
    }
    let req = HTTP.request(options) { (response) in
      var data = Data()
      let resultObj = ZosConnectResult<Data>()
      do {
        if let localresponse = response {
          resultObj.statusCode = localresponse.status
          try localresponse.readAllData(into: &data)
          resultObj.result = data
        }
      } catch let error {
        resultObj.error = ZosConnectErrors.connectionerror(error)
      }
      callback(resultObj)
    }
    if let requestData = data {
        req.end(requestData)
    } else {
        req.end("{}")
    }
  }
  
  open func getRequestSchema(_ callback: @escaping DataCallback){
    var uri = connection.hostName + ":" + String(connection.port)
    uri += "/zosConnect/services/" + serviceName + "?action=getRequestSchema"
    let req = HTTP.get(uri) { (response) in
      let resultObj = ZosConnectResult<Data>()
      var data = Data()
      do {
        if let localresponse = response {
          if localresponse.statusCode == HTTPStatusCode.OK {
            try localresponse.readAllData(into: &data)
            resultObj.result = data
          } else if localresponse.statusCode == HTTPStatusCode.notFound {
            resultObj.error = ZosConnectErrors.unknownservice
          } else {
            resultObj.error = ZosConnectErrors.servererror(localresponse.status)
          }
        }
      } catch let error {
        resultObj.error = ZosConnectErrors.connectionerror(error)
      }
      callback(resultObj)
    }
    req.end()
  }
  
  open func getResponseSchema(_ callback: @escaping DataCallback){
    var uri = connection.hostName + ":" + String(connection.port)
    uri += "/zosConnect/services/" + serviceName + "?action=getResponseSchema"
    let req = HTTP.get(uri) { (response) in
      let resultObj = ZosConnectResult<Data>()
      var data = Data()
      do {
        if let localresponse = response {
          if localresponse.statusCode == HTTPStatusCode.OK {
            try localresponse.readAllData(into: &data)
            resultObj.result = data
          } else if localresponse.statusCode == HTTPStatusCode.notFound {
            resultObj.error = ZosConnectErrors.unknownservice
          } else {
            resultObj.error = ZosConnectErrors.servererror(localresponse.status)
          }
        }
      } catch let error {
        resultObj.error = ZosConnectErrors.connectionerror(error)
      }
      callback(resultObj)
    }
    req.end()
  }
  
  private func callUriWithStatus(_ uri: String, verb: String, callback: @escaping StatusCallback){
    let parsedUri = URLParser(url: uri.data(using: String.Encoding.utf8)!, isConnect: false)
    var hostPort:Int16
    if let port = parsedUri.port {
      hostPort = Int16(port);
    } else {
      if parsedUri.schema == "https" {
        hostPort = Int16(443);
      } else {
        hostPort = Int16(80);
      }
    }
    let req = HTTP.request([ClientRequest.Options.schema(parsedUri.schema! + "://"),
                            ClientRequest.Options.hostname(parsedUri.host!),
                            ClientRequest.Options.port(hostPort),
                            ClientRequest.Options.path(parsedUri.path! + "?" + parsedUri.query!),
                            ClientRequest.Options.method(verb)]) { (response) in
      let resultObj = ZosConnectResult<ServiceStatus>()
      var data = Data()
      do {
        try response?.readAllData(into: &data)
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
      callback(resultObj)
    }
    req.end()
  }
  
  open func getStatus(_ callback: @escaping StatusCallback){
    var uri = connection.hostName + ":" + String(connection.port)
    uri += "/zosConnect/services/" + serviceName + "?action=status"
    callUriWithStatus(uri, verb: "GET", callback: callback)
  }
  
  open func start(_ callback: @escaping StatusCallback){
    var uri = connection.hostName + ":" + String(connection.port)
    uri += "/zosConnect/services/" + serviceName + "?action=start"
    callUriWithStatus(uri, verb: "PUT", callback: callback)
  }
  
  open func stop(_ callback: @escaping StatusCallback){
    var uri = connection.hostName + ":" + String(connection.port)
    uri += "/zosConnect/services/" + serviceName + "?action=stop"
    callUriWithStatus(uri, verb: "PUT", callback: callback)
  }
}

public typealias StatusCallback = (_ response: ZosConnectResult<ServiceStatus>) -> Void

// MARK: ServiceStatus enum

public enum ServiceStatus: String {
  case STARTED = "STARTED", STOPPED = "STOPPED", UNAVAILABLE = "UNAVAILABLE"
}
