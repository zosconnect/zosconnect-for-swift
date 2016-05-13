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

public class ZosConnect {
  let hostName: String
  let port: Int32
  let userId: String?
  let password: String?

  public init(hostName: String, port: Int32, userId: String? = nil, password: String? = nil) {
    self.hostName = hostName
    self.port = port
    self.userId = userId
    self.password = password
  }

  // MARK: Service calls

  public func getServices(result: ListCallback) {
    HTTP.get(hostName + ":" + String(port) + "/zosConnect/services", callback:{(response)-> Void in
      let resultObj = ZosConnectResult<[String]>()
      let data = NSMutableData()
      do {
        try response?.readAllData(into: data)
        let json = JSON(data: data)
        var services = [String]()
        if let serviceList = json["zosConnectServices"].array {
          for service in serviceList {
            if let serviceName = service["ServiceName"].string {
              services.append(serviceName)
            }
          }
        }
        resultObj.result = services
      } catch let error {
        resultObj.error = ZosConnectErrors.CONNECTIONERROR(error)
      }
      result(response: resultObj)
    })
  }

  public func getService(serviceName: String, result: ServiceCallback) {
    HTTP.get(hostName + ":" + String(port) + "/zosConnect/services/" + serviceName, callback: {(response) -> Void in
      let resultObj = ZosConnectResult<Service>()
      let data = NSMutableData()
      do {
        if let localResponse = response {
          if localResponse.statusCode == HTTPStatusCode.OK {
            try localResponse.readAllData(into: data)
            let json = JSON(data: data)
            if let invokeUri = json["zosConnect"]["serviceInvokeURL"].string {
              resultObj.result = Service(connection:self, serviceName:serviceName, invokeUri:invokeUri)
            }
          } else if localResponse.statusCode == HTTPStatusCode.notFound {
            resultObj.error = ZosConnectErrors.UNKNOWNSERVICE
          } else {
            resultObj.error = ZosConnectErrors.SERVERERROR(localResponse.status)
          }
        }
      } catch let error {
        resultObj.error = ZosConnectErrors.CONNECTIONERROR(error)
      }
      result(response: resultObj)
    })
  }

  // MARK: API calls

  public func getApis(result: ListCallback) {
    HTTP.get(hostName + ":" + String(port) + "/zosConnect/apis", callback: {(response) -> Void in
      let resultObj = ZosConnectResult<[String]>()
      let data = NSMutableData()
      do {
        try response?.readAllData(into: data)
        let json = JSON(data: data)
        var apis = [String]()
        if let apiList = json["apis"].array {
          for api in apiList {
            if let apiName = api["name"].string {
              apis.append(apiName)
            }
          }
        }
        resultObj.result = apis;
      } catch let error {
        resultObj.error = ZosConnectErrors.CONNECTIONERROR(error)
      }
      result(response: resultObj)
    })
  }

  public func getApi(apiName: String, result: ApiCallback) {
    HTTP.get(hostName + ":" + String(port) + "/zosConnect/apis/" + apiName, callback: {(response) -> Void in
      let resultObj = ZosConnectResult<Api>()
      let data = NSMutableData()
      do {
        if let localResponse = response {
          if localResponse.statusCode == HTTPStatusCode.OK {
            try localResponse.readAllData(into: data)
            let json = JSON(data: data)
            if let basePath = json["apiUrl"].string {
              let documentation = json["documentation"]
              resultObj.result = Api(connection:self, apiName:apiName, basePath:basePath, documentation: documentation)
            }
          } else if localResponse.statusCode == HTTPStatusCode.notFound {
            resultObj.error = ZosConnectErrors.UNKNOWNAPI
          } else {
            resultObj.error = ZosConnectErrors.SERVERERROR(localResponse.status)
          }
        }
      } catch let error {
        resultObj.error = ZosConnectErrors.CONNECTIONERROR(error)
      }
    })
  }
}

// MARK: Error types

public enum ZosConnectErrors : ErrorProtocol {
  case UNKNOWNSERVICE, UNKNOWNAPI
  case CONNECTIONERROR(ErrorProtocol), SERVERERROR(Int)
}

// MARK: Response closure

public typealias DataCallback = (response: ZosConnectResult<NSData>) -> Void
public typealias ListCallback = (response: ZosConnectResult<[String]>) -> Void
public typealias ServiceCallback = (response: ZosConnectResult<Service>) -> Void
public typealias ApiCallback = (response: ZosConnectResult<Api>) -> Void
