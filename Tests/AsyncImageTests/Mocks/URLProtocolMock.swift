import Foundation
import XCTest

class URLProtocolMock: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    static var requestCount = 0
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = Self.requestHandler else {
            XCTFail("You forgot to set the mock protocol request handler")
            return
        }
        
        do {
            let (response, data) = try handler(request)
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            self.client?.urlProtocol(self, didLoad: data)
            self.client?.urlProtocolDidFinishLoading(self)
            Self.requestCount += 1
        }
        catch {
            self.client?.urlProtocol(self, didFailWithError:error)
        }
    }
    
    override func stopLoading() {}
}
