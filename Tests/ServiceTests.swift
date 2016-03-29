//
//  ServiceTests.swift
//  zosconnectforswift
//
//  Created by Andrew Smithson on 29/03/2016.
//
//
import Foundation

import XCTest

@testable import zosconnectforswift

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
        zosConnect.getService("dateTimeService") { (service) in
            service?.getStatus({ (status) in
                XCTAssertEqual(status, ServiceStatus.STARTED)
            })
        }
    }

}
