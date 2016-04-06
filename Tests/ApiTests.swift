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

import XCTest

@testable import zosconnectforswift

class Api: XCTestCase {
  
  let zosConnect = ZosConnect(hostName: "http://zosconnectmock.mybluemix.net", port: 80)
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testGetApiDoc() {
    zosConnect.getApi("healthApi") { (inner) in
      do {
        try inner().getApiDoc("swagger") { (swagger) in
          XCTAssertNotNil(swagger)
        }
      }catch let error {
        XCTFail(String(error))
      }
    }
  }
  
  func testGetUnknownApiDoc() {
    zosConnect.getApi("healthApi") { (inner) in
      do {
        try inner().getApiDoc("raml", callback: { (doc) in
          XCTAssertNil(doc)
        })
      } catch let error {
        XCTFail(String(error))
      }
    }
  }
  
}
