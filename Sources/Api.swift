import Foundation

public class Api {
  let connection: ZosConnect
  let apiName: String
  let basePath: String

  public init(connection: ZosConnect, apiName: String, basePath: String) {
    self.connection = connection
    self.apiName = apiName
    self.basePath = basePath
  }
}
