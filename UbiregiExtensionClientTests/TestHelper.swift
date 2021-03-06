import Foundation
import Swifter
import XCTest

func withSwifter(port: UInt16 = 8081, k: (HttpServer) throws -> ()) {
    let server = HttpServer()
    try! server.start(port)
    
    defer {
        server.stop()
    }
    
    try! k(server)
}

func returnJSON(object: [String: AnyObject]) -> HttpRequest -> HttpResponse {
    return { (response: HttpRequest) in
        HttpResponse.OK(HttpResponseBody.Json(object))
    }
}

func dictionary(pairs: [(String, String)]) -> [String: String] {
    var h: [String: String] = [:]
    
    for p in pairs {
        h[p.0] = p.1
    }
    
    return h
}

class NotificationTrace: NSObject {
    var notifications: [NSNotification]
    
    override init() {
        self.notifications = []
    }
    
    func didReceiveNotification(notification: NSNotification) {
        self.notifications.append(notification)
    }
    
    func notificationNames() -> [String] {
        return self.notifications.map { $0.name }
    }
    
    func observeNotification(name: String, object: AnyObject?) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveNotification:", name: name, object: object)
    }
}

func waitFor(timeout: NSTimeInterval, message: String? = nil, predicate: () -> Bool) {
    let endTime = NSDate().dateByAddingTimeInterval(timeout)
    
    while NSDate().compare(endTime) == NSComparisonResult.OrderedAscending {
        NSThread.sleepForTimeInterval(0.1)
        if predicate() {
            return
        }
    }

    XCTAssert(false, message ?? "Timeout exceeded for waitFor")
}

func globally(timeout: NSTimeInterval = 1, message: String? = nil, predicate: () -> Bool) {
    let endTime = NSDate().dateByAddingTimeInterval(timeout)
    
    while NSDate().compare(endTime) == NSComparisonResult.OrderedAscending {
        NSThread.sleepForTimeInterval(0.1)
        if !predicate() {
            XCTAssert(false, message ?? "predicate does not hold which expected to hold globally")
            return
        }
    }
}