//
//  ZosConnectTests.swift
//  zosconnect-for-swift
//
//  Created by Andrew Smithson on 28/03/2016.
//
//

import Foundation

import XCTest

@testable import zosconnectforswift

class ZosConnectTests: XCTestCase {
    
    let zosConnect = ZosConnect(hostName: "http://zosconnectmock.mybluemix.net", port: 80)

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGetServices() {
        zosConnect.getServices { (services) in
            XCTAssert(services[0] == "dateTimeService")
        }
    }
    
    func testGetService() {
        zosConnect.getService("dateTimeService") { (service) in
            XCTAssertNotNil(service)
        }
    }
    
    func testGetApis() {
        zosConnect.getApis { (apis) in
            XCTAssert(apis[0] == "healthApi")
        }
    }
    
    func testGetApi() {
        zosConnect.getApi("healthApi") { (api) in
            XCTAssertNotNil(api)
        }
    }

}
