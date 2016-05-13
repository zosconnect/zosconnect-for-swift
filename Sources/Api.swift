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
  let basePath: String
  let documentation: JSON
  
  public init(connection: ZosConnect, apiName: String, basePath: String, documentation: JSON) {
    self.connection = connection
    self.apiName = apiName
    self.basePath = basePath
    self.documentation = documentation
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
