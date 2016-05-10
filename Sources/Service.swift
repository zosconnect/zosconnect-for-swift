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
  let invokeUri: UrlParser

  public init(connection: ZosConnect, serviceName: String, invokeUri: String) {
    self.connection = connection
    self.serviceName = serviceName
    self.invokeUri = UrlParser(url: invokeUri.dataUsingEncoding(NSUTF8StringEncoding)!, isConnect: false)
  }
  
  public func invoke(data: NSData, callback: DataCallback){
    var hostPort = Int16(80)
    if let port = invokeUri.port {
      hostPort = Int16(port);
    }
    Http.request([ClientRequestOptions.Schema(invokeUri.schema!),
                  ClientRequestOptions.Hostname(invokeUri.host!),
                  ClientRequestOptions.Port(hostPort),
                  ClientRequestOptions.Path(invokeUri.path!),
                  ClientRequestOptions.Method("POST")]) { (response) in
      let data = NSMutableData()
      let resultObj = ZosConnectResult<NSData>()
      do {
        if let localresponse = response {
          resultObj.statusCode = localresponse.status
          try localresponse.readData(data)
          resultObj.result = data
        }
      } catch let error {
        resultObj.error = ZosConnectErrors.CONNECTIONERROR(error)
      }
      callback(response: resultObj)
    }
    
  }
  
  public func getRequestSchema(callback: DataCallback){
    var uri = connection.hostName + ":" + String(connection.port)
    uri += "/zosConnect/services/" + serviceName + "?action=getRequestSchema"
    Http.get(uri) { (response) in
      let resultObj = ZosConnectResult<NSData>()
      let data = NSMutableData()
      do {
        if let localresponse = response {
          if localresponse.statusCode == HttpStatusCode.OK {
            try localresponse.readAllData(data)
            resultObj.result = data
          } else if localresponse.statusCode == HttpStatusCode.NOT_FOUND {
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
    Http.get(uri) { (response) in
      let resultObj = ZosConnectResult<NSData>()
      let data = NSMutableData()
      do {
        if let localresponse = response {
          if localresponse.statusCode == HttpStatusCode.OK {
            try localresponse.readAllData(data)
            resultObj.result = data
          } else if localresponse.statusCode == HttpStatusCode.NOT_FOUND {
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
  
  public func getStatus(callback: (ServiceStatus) -> Void){
    var uri = connection.hostName + ":" + String(connection.port)
    uri += "/zosConnect/services/" + serviceName + "?action=status"
    Http.get(uri) { (response) in
      let data = NSMutableData()
      do {
        try response?.readAllData(data)
        let json = JSON(data: data)
        var serviceStatus = ServiceStatus.UNAVAILABLE
        if let status = json["zosConnect"]["serviceStatus"].string {
          if status == "Started" {
            serviceStatus = ServiceStatus.STARTED
          } else if status == "Stopped" {
            serviceStatus = ServiceStatus.STOPPED
          }
        }
        callback(serviceStatus)
      } catch let error {
        print("got an error creating the request: \(error)")
        callback(ServiceStatus.UNAVAILABLE)
      }
    }
  }
}

public enum ServiceStatus: String {
  case STARTED = "STARTED", STOPPED = "STOPPED", UNAVAILABLE = "UNAVAILABLE"
}
