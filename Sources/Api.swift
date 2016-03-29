import Foundation
import SwiftyJSON
import KituraNet

public class Api {
  let connection: ZosConnect
  let apiName: String
  let basePath: String

  public init(connection: ZosConnect, apiName: String, basePath: String) {
    self.connection = connection
    self.apiName = apiName
    self.basePath = basePath
  }
  
  func getApiDoc(callback: (NSData?) -> Void) {
    Http.get(basePath + "/api-docs") { (response) in
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
}
