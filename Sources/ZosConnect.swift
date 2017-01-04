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

/// Main class for connecting to z/OS Connect Enterprise Edition and getting information about the available APIs and Services.
open class ZosConnect {
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

  /// Get the names of all the services available in the z/OS Connect EE server
  ///
  /// - Parameter result: Callback function which takes a `ZosConnectResult<[String]>` parameter
  open func getServices(_ result: @escaping ListCallback) {
    let req = HTTP.get(hostName + ":" + String(port) + "/zosConnect/services", callback:{(response)-> Void in
      let resultObj = ZosConnectResult<[String]>()
      var data = Data()
      do {
        try response?.readAllData(into: &data)
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
        resultObj.error = ZosConnectErrors.connectionerror(error)
      }
      result(resultObj)
    })
    req.end()
  }

  /// Get the specified Service from the z/OS Connect EE server.
  ///
  /// - Parameters:
  ///   - serviceName: The name of the service
  ///   - result: Callback function which takes a `ZosConnectResult<Service>` paramter
  open func getService(_ serviceName: String, result: @escaping ServiceCallback) {
    let req = HTTP.get(hostName + ":" + String(port) + "/zosConnect/services/" + serviceName, callback: {(response) -> Void in
      let resultObj = ZosConnectResult<Service>()
      var data = Data()
      do {
        if let localResponse = response {
          if localResponse.statusCode == HTTPStatusCode.OK {
            try localResponse.readAllData(into: &data)
            let json = JSON(data: data)
            if let invokeUri = json["zosConnect"]["serviceInvokeURL"].string {
              resultObj.result = Service(connection:self, serviceName:serviceName, invokeUri:invokeUri)
            }
          } else if localResponse.statusCode == HTTPStatusCode.notFound {
            resultObj.error = ZosConnectErrors.unknownservice
          } else {
            resultObj.error = ZosConnectErrors.servererror(localResponse.status)
          }
        }
      } catch let error {
        resultObj.error = ZosConnectErrors.connectionerror(error)
      }
      result(resultObj)
    })
    req.end()
  }

  // MARK: API calls

  /// Get the names of all the APIs available in the z/OS Connect EE server.
  ///
  /// - Parameter result: Callback function which takes a `ZosConnectResult<[String]>` parameter.
  open func getApis(_ result: @escaping ListCallback) {
    let req = HTTP.get(hostName + ":" + String(port) + "/zosConnect/apis", callback: {(response) -> Void in
      let resultObj = ZosConnectResult<[String]>()
      var data = Data()
      do {
        try response?.readAllData(into: &data)
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
        resultObj.error = ZosConnectErrors.connectionerror(error)
      }
      result(resultObj)
    })
    req.end()
  }

  /// Get the specified API from the z/OS Connect EE server.
  ///
  /// - Parameters:
  ///   - apiName: The name of the API
  ///   - result: Callback function which takies a `ZosConnectResult<Api>` parameter.
  open func getApi(_ apiName: String, result: @escaping ApiCallback) {
    let req = HTTP.get(hostName + ":" + String(port) + "/zosConnect/apis/" + apiName, callback: {(response) -> Void in
      let resultObj = ZosConnectResult<Api>()
      var data = Data()
      do {
        if let localResponse = response {
          if localResponse.statusCode == HTTPStatusCode.OK {
            try localResponse.readAllData(into: &data)
            let json = JSON(data: data)
            if let basePath = json["apiUrl"].string {
              let documentation = json["documentation"]
              resultObj.result = Api(connection:self, apiName:apiName, basePath:basePath, documentation: documentation)
            }
          } else if localResponse.statusCode == HTTPStatusCode.notFound {
            resultObj.error = ZosConnectErrors.unknownapi
          } else {
            resultObj.error = ZosConnectErrors.servererror(localResponse.status)
          }
        }
      } catch let error {
        resultObj.error = ZosConnectErrors.connectionerror(error)
      }
      result(resultObj)
    })
    req.end();
  }
}

// MARK: Error types

/// Enumeration of the errors that can occur when calling the z/OS Connect EE server.
///
/// - unknownservice: The requested service is not available in the z/OS Connect EE server.
/// - unknownapi: The request API is not available in the z/OS Connect EE server.
/// - connectionerror: There was an error connecting to the z/OS Connect EE server, the cause is linked.
/// - servererror: There was a server error, the HTTP status code is linked.
public enum ZosConnectErrors : Swift.Error {
  case unknownservice, unknownapi
  case connectionerror(Swift.Error), servererror(Int)
}

// MARK: Response closure

/// Alias for a callback function taking a `ZosConnectResult<Data>` as parameter
public typealias DataCallback = (_ response: ZosConnectResult<Data>) -> Void
/// Alias for a callback function taking a `ZosConnectResult<[String]>` as parameter
public typealias ListCallback = (_ response: ZosConnectResult<[String]>) -> Void
/// Alias for a callback function taking a `ZosConnectResult<Service>` as parameter
public typealias ServiceCallback = (_ response: ZosConnectResult<Service>) -> Void
/// Alias for a callback function taking a `ZosConnectResult<Api>` as parameter
public typealias ApiCallback = (_ response: ZosConnectResult<Api>) -> Void
