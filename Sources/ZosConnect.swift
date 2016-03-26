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

  public func getServices(callback: ([String]) -> Void) {
    Http.get(hostName + ":" + String(port) + "/zosConnect/services", callback:{(response)-> Void in
      let data = NSMutableData()
      do {
        try response?.readAllData(data)
        let json = JSON(data: data)
        var services = [String]()
        if let serviceList = json["zosConnectServices"].array {
          for service in serviceList {
            if let serviceName = service["ServiceName"].string {
              services.append(serviceName)
            }
          }
          callback(services)
        }
      } catch let error {
        print("got an error creating the request: \(error)")
        callback([])
      }
    })
  }

  public func getService(serviceName: String, callback: (Service?) -> Void) {
    Http.get(hostName + ":" + String(port) + "/zosConnect/services/" + serviceName, callback: {(response) -> Void in
      let data = NSMutableData()
      do {
        try response?.readAllData(data)
        let json = JSON(data: data)
        if let invokeUri = json["zosConnect"]["serviceInvokeURL"].string {
          callback(Service(connection:self, serviceName:serviceName, invokeUri:invokeUri))
        }
        
      } catch let error {
        print("got an error creating the request: \(error)")
        callback(nil)
      }
    })
  }

  // MARK: API calls

  public func getApis(callback: ([String]) -> Void) {
    Http.get(hostName + ":" + String(port) + "/zosConnect/apis", callback: {(response) -> Void in
      let data = NSMutableData()
      do {
        try response?.readAllData(data)
        let json = JSON(data: data)
        var apis = [String]()
        if let apiList = json["apis"].array {
          for api in apiList {
            if let apiName = api["name"].string {
              apis.append(apiName)
            }
          }
        }
        callback(apis)
      } catch let error {
        print("got an error creating the request: \(error)")
        callback([])
      }
    })
  }

  public func getApi(apiName: String, callback: (Api?) -> Void) {
    Http.get(hostName + ":" + String(port) + "/zosConnect/apis/" + apiName, callback: {(response) -> Void in
      let data = NSMutableData()
      do {
        try response?.readAllData(data)
        let json = JSON(data: data)
        if let basePath = json["apiUrl"].string {
          callback(Api(connection:self, apiName:apiName, basePath:basePath))
        }
      } catch let error {
        print("got an error creating the request: \(error)")
        callback(nil)
      }
    })
  }
}
