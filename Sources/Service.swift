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
  let invokeUri: String

  public init(connection: ZosConnect, serviceName: String, invokeUri: String) {
    self.connection = connection
    self.serviceName = serviceName
    self.invokeUri = invokeUri
  }
  
  func invoke(data: NSData, callback: (NSData?) -> Void){
    
  }
  
  public func getRequestSchema(callback: (NSData?) -> Void){
    var uri = connection.hostName + ":" + String(connection.port)
    uri += "/zosConnect/services/" + serviceName + "?action=getRequestSchema"
    print(uri)
    Http.get(uri) { (response) in
      let data = NSMutableData()
      do {
        try response?.readAllData(data)
        callback(data)
      } catch let error {
        print("got an error creating the request: \(error)")
        callback(nil)
      }
    }
  }
  
  public func getResponseSchema(callback: (NSData?) -> Void){
    var uri = connection.hostName + ":" + String(connection.port)
    uri += "/zosConnect/services/" + serviceName + "?action=getResponseSchema"
    print(uri)
    Http.get(uri) { (response) in
      let data = NSMutableData()
      do {
        try response?.readAllData(data)
        callback(data)
      } catch let error {
        print("got an error creating the request: \(error)")
        callback(nil)
      }
    }
  }
  
  public func getStatus(callback: (ServiceStatus) -> Void){
    var uri = connection.hostName + ":" + String(connection.port)
    uri += "/zosConnect/services/" + serviceName + "?action=status"
    print(uri)
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
