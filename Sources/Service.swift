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
  
  func getRequestSchema(callback: (NSData?) -> Void){
    
  }
  
  func getResponseSchema(callback: (NSData?) -> Void){
    
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
