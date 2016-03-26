import Foundation
import SwiftyJSON

public class Service {
  let connection: ZosConnect
  let serviceName: String
  let invokeUri: String

  public init(connection: ZosConnect, serviceName: String, invokeUri: String) {
    self.connection = connection
    self.serviceName = serviceName
    self.invokeUri = invokeUri
  }
}
