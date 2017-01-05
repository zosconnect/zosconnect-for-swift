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
  
  /// Invoke the service.
  ///
  /// - Parameters:
  ///   - data: JSON Object to be sent to the service
  ///   - callback: Callback function which takes a `ZosConnectResult<Data>` parameter
  open func invoke(_ data: Data?, callback: @escaping DataCallback){
    var options = [ClientRequest.Options.schema(invokeUri.schema! + "://"),
                   ClientRequest.Options.hostname(invokeUri.host!),
                   ClientRequest.Options.path(invokeUri.path! + "?action=invoke"),
                   ClientRequest.Options.method("PUT")]
    if let port = invokeUri.port {
      options.append(ClientRequest.Options.port(Int16(port)))
    } else {
      if invokeUri.schema == "https" {
        options.append(ClientRequest.Options.port(Int16(443)))
      } else {
        options.append(ClientRequest.Options.port(Int16(80)))
      }
    }
    if let user = connection.userId {
      options.append(ClientRequest.Options.username(user))
    }
    if let pass = connection.password {
      options.append(ClientRequest.Options.password(pass))
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
  
  /// Get the JSON schema that describes the request payload for the service
  ///
  /// - Parameter callback: Callback function which takes a `ZosConnectResult<Data>` parameter.
  open func getRequestSchema(_ callback: @escaping DataCallback){
    let req = HTTP.request(connection.getOptions("/zosConnect/services/" + serviceName + "?action=getRequestSchema")) { (response) in
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
  
  /// Get the JSON schema that describes the response payload for the service
  ///
  /// - Parameter callback: Callback function which takes a `ZosConnectResult<Data>` parameter.
  open func getResponseSchema(_ callback: @escaping DataCallback){
    let req = HTTP.request(connection.getOptions("/zosConnect/services/" + serviceName + "?action=getResponseSchema")) { (response) in
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
  
  private func callUriWithStatus(_ path: String, verb: String, callback: @escaping StatusCallback){
    let req = HTTP.request(connection.getOptions(path, verb: verb)) { (response) in
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
  
  /// Get the status of the service
  ///
  /// - Parameter callback: Callback function which takes a `ZosConnectResult<ServiceStatus>` parameter
  open func getStatus(_ callback: @escaping StatusCallback){
    let path = "/zosConnect/services/" + serviceName + "?action=status"
    callUriWithStatus(path, verb: "GET", callback: callback)
  }
  
  /// Request to set the status of the service as started
  ///
  /// - Parameter callback: Callback function which takes a `ZosConnectResult<ServiceStatus>` parameter
  open func start(_ callback: @escaping StatusCallback){
    let path = "/zosConnect/services/" + serviceName + "?action=start"
    callUriWithStatus(path, verb: "PUT", callback: callback)
  }
  
  /// Request to set the status of the service as stopped
  ///
  /// - Parameter callback: Callback function which takes a `ZosConnectResult<ServiceStatus>` parameter
  open func stop(_ callback: @escaping StatusCallback){
    let path = "/zosConnect/services/" + serviceName + "?action=stop"
    callUriWithStatus(path, verb: "PUT", callback: callback)
  }
}

/// Alias for a Callback function which takes `ZosConnectResult<ServiceStatus> as a parameter.
public typealias StatusCallback = (_ response: ZosConnectResult<ServiceStatus>) -> Void

// MARK: ServiceStatus enum

/// Enumeration of the status a Service can have.
///
/// - STARTED: The Service is started
/// - STOPPED: The Service is stopped
/// - UNAVAILABLE: The status of the service is unavailable
public enum ServiceStatus: String {
  case STARTED = "STARTED", STOPPED = "STOPPED", UNAVAILABLE = "UNAVAILABLE"
}
