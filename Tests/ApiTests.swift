//
//  Api.swift
//  zosconnectforswift
//
//  Created by Andrew Smithson on 28/03/2016.
//
//

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
    zosConnect.getApi("healthApi") { (api) in
      api?.getApiDoc({ (swagger) in
        XCTAssertNotNil(swagger)
      })
    }
  }
  
}
