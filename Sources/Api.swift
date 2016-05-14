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

public class Api {
  let connection: ZosConnect
  let apiName: String
  let basePath: URLParser
  let documentation: JSON
  
  public init(connection: ZosConnect, apiName: String, basePath: String, documentation: JSON) {
    self.connection = connection
    self.apiName = apiName
    self.basePath = URLParser(url: basePath.data(using: NSUTF8StringEncoding)!, isConnect: false)
    self.documentation = documentation
  }
    
  func invoke(verb: String, resource: String, data: NSData?, callback: DataCallback){
    var hostPort = Int16(80)
    if let port = basePath.port {
      hostPort = Int16(port);
    }
    let req = HTTP.request([ClientRequestOptions.schema(basePath.schema!),
                            ClientRequestOptions.hostname("://" + basePath.host!),
                            ClientRequestOptions.port(hostPort),
                            ClientRequestOptions.path(basePath.path! + resource),
                            ClientRequestOptions.method(verb)]) { (response) in
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
      req.end()
    }
  }
  
  func getApiDoc(documentationType: String, callback: (NSData?) -> Void) {
    if let documentUri = documentation[documentationType].string {
      HTTP.get(documentUri) { (response) in
        let data = NSMutableData()
        do {
          try response?.readAllData(into: data)
          callback(data)
        } catch let error {
          print("got an error creating the request: \(error)")
          callback(nil)
        }
      }
    }
  }
}
