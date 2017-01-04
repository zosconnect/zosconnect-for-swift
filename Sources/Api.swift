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

open class Api {
  let connection: ZosConnect
  let apiName: String
  let basePath: URLParser
  let documentation: JSON
  
  public init(connection: ZosConnect, apiName: String, basePath: String, documentation: JSON) {
    self.connection = connection
    self.apiName = apiName
    self.basePath = URLParser(url: basePath.data(using: String.Encoding.utf8)!, isConnect: false)
    self.documentation = documentation
  }
    
  /// Invoke the API
  ///
  /// - Parameters:
  ///   - verb: The HTTP verb to use
  ///   - resource: The resource path to call
  ///   - data: The request payload
  ///   - callback: Callback function which takes a `ZosConnectResult<Data>` parameter
  public func invoke(_ verb: String, resource: String, data: Data?, callback: @escaping DataCallback){
    var hostPort:Int16
    if let port = basePath.port {
      hostPort = Int16(port);
    } else {
      if basePath.schema == "https" {
        hostPort = Int16(443);
      } else {
        hostPort = Int16(80);
      }
    }
    let req = HTTP.request([ClientRequest.Options.schema(basePath.schema! + "://"),
                            ClientRequest.Options.hostname(basePath.host!),
                            ClientRequest.Options.port(hostPort),
                            ClientRequest.Options.path(basePath.path! + resource),
                            ClientRequest.Options.method(verb)]) { (response) in
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
      req.end()
    }
  }
  
  /// Retrieve the API documentation for the API
  ///
  /// - Parameters:
  ///   - documentationType: The type of API documentation to retrieve (e.g. Swagger)
  ///   - callback: Callback function which takes a `ZosConnectResult<Data>` parameter
  public func getApiDoc(_ documentationType: String, callback: @escaping DataCallback) {
    if let documentUri = documentation[documentationType].string {
      let req = HTTP.get(documentUri) { (response) in
        var data = Data()
        let resultObj = ZosConnectResult<Data>()
        do {
          try response?.readAllData(into: &data)
          resultObj.result = data
        } catch let error {
          resultObj.error = error;
        }
        callback(resultObj)
      }
      req.end()
    }
  }
}
