import Foundation
import Dispatch

print("About to create ZosConnect")
let zosconnect = ZosConnect(hostName:"http://192.168.99.100", port:9080)
print("About to getServices")
var semaphore = dispatch_semaphore_create(0)
zosconnect.getServices({(services) -> Void in
    print(services)
    dispatch_semaphore_signal(semaphore)
})
dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
print("About to getService")
var semaphore1 = dispatch_semaphore_create(0)
zosconnect.getService("dateTimeService", callback: {(service) -> Void in
    print(service)
    dispatch_semaphore_signal(semaphore1)
})
dispatch_semaphore_wait(semaphore1, DISPATCH_TIME_FOREVER)
print("About to getApis")
var semaphore2 = dispatch_semaphore_create(0)
zosconnect.getApis({(api) -> Void in
    print(api)
    dispatch_semaphore_signal(semaphore2)
})
dispatch_semaphore_wait(semaphore2, DISPATCH_TIME_FOREVER)
print("About to getApi")
var semaphore3 = dispatch_semaphore_create(0)
zosconnect.getApi("healthApi", callback: {(api) -> Void in
    print(api)
    dispatch_semaphore_signal(semaphore3)
})
dispatch_semaphore_wait(semaphore3, DISPATCH_TIME_FOREVER)
