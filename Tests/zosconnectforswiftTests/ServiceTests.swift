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

#if os(Linux)
    extension ServiceTests {
        static var allTests = {
            return [
                       ("testGetStatus", testGetStatus),
                       ("testGetRequestSchema", testGetRequestSchema),
                       ("testGetResponseSchema", testGetResponseSchema),
                       ("testInvoke", testInvoke)
            ]
        }()
    }
#endif

class ServiceTests: XCTestCase {
  
  let zosConnect = ZosConnect(hostName: "http://zosconnectmock.mybluemix.net", port: 80)
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testGetStatus() {
    zosConnect.getService("dateTimeService") { result in
      result.result!.getStatus({ (result) in
        XCTAssertEqual(result.result, ServiceStatus.STARTED)
      })
    }
  }
  
  func testStart() {
    zosConnect.getService("dateTimeService") { result in
      result.result!.start { result in
        XCTAssertEqual(result.result, ServiceStatus.STARTED)
      }
    }
  }
  
  func testStop() {
    zosConnect.getService("dateTimeService") { result in
      result.result!.stop { result in
        XCTAssertEqual(result.result, ServiceStatus.STOPPED)
      }
    }
  }
  
  func testGetRequestSchema() {
    zosConnect.getService("dateTimeService") { result in
      result.result!.getRequestSchema { result in
        XCTAssertNotNil(result.result)
      }
    }
  }
  
  func testGetResponseSchema() {
    zosConnect.getService("dateTimeService") { result in
      result.result!.getResponseSchema { result in
        XCTAssertNotNil(result.result)
      }
    }
  }
  
  func testInvoke() {
    zosConnect.getService("dateTimeService") { result in
        result.result!.invoke(nil, callback: { result in
        XCTAssertEqual(result.statusCode, 200)
        XCTAssertNotNil(result.result)
      })
    }
  }
}
