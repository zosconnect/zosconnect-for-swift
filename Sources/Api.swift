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
      Http.get(documentUri) { (response) in
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
}
