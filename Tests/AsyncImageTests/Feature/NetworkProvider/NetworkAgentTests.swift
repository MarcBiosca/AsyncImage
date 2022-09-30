import XCTest
import Combine
import Foundation
@testable import AsyncImage

final class NetworkAgentTests: XCTestCase {
    private final let returnedData = "{\"test\":\"value\"}".data(using: .utf8)!
    private final let expectedObject = DecodableObject(test: "value")
    private final let request = URLRequest(url: URL(string: "url")!)
    
    private var urlSession = URLSession.shared
    private var completedExpectation: XCTestExpectation?
    private var completedExpectation2: XCTestExpectation?
    private var valueReceived: DecodableObject?
    private var cancellable: AnyCancellable?
    
    override func setUp() {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        self.urlSession = URLSession(configuration: config)
        
        URLProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion:nil, headerFields:nil)!
            return (response, self.returnedData)
        }
        
        self.completedExpectation = self.expectation(description: "publisher completed")
        self.valueReceived = nil
        URLProtocolMock.requestCount = 0
    }
    
    func test_run_toInvalidUrl() throws {
        let agent = NetworkAgent(with: NetworkConfiguration(session: self.urlSession))
        
        URLProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion:nil, headerFields:nil)!
            return (response, self.returnedData)
        }
        
        // WHEN
        self.cancellable = agent
            .run(self.request, decode: DecodableObject.self)
            .sink { _ in self.completedExpectation!.fulfill() }
            receiveValue: { self.valueReceived = $0 }
        
        // VERIFY
        self.waitForExpectations(timeout: 1)
        XCTAssertNil(self.valueReceived, "Value should not be received")
        XCTAssertEqual(URLProtocolMock.requestCount, 3, "Request should be retried twice when failed")
    }
    
    func test_run_toInvalidUrl_withCustomRetryCount() throws {
        let agent = NetworkAgent(with: NetworkConfiguration(session: self.urlSession, retries: 3))
        
        URLProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion:nil, headerFields:nil)!
            return (response, self.returnedData)
        }
        
        // WHEN
        self.cancellable = agent
            .run(self.request, decode: DecodableObject.self)
            .sink { _ in self.completedExpectation!.fulfill() }
            receiveValue: { self.valueReceived = $0 }
        
        // VERIFY
        self.waitForExpectations(timeout: 1)
        XCTAssertNil(self.valueReceived, "Value should not be received")
        XCTAssertEqual(URLProtocolMock.requestCount, 4, "Request should be retried 3 times when failed")
    }
    
    func test_run_toNilRequest() throws {
        let agent = NetworkAgent(with: NetworkConfiguration(session: self.urlSession))
        
        // WHEN
        self.cancellable = agent
            .run(nil, decode: DecodableObject.self)
            .sink { _ in self.completedExpectation!.fulfill() }
            receiveValue: { self.valueReceived = $0 }
        
        // VERIFY
        self.waitForExpectations(timeout: 1)
        XCTAssertNil(self.valueReceived, "Value should not be received")
        XCTAssertEqual(URLProtocolMock.requestCount, 0, "Request should not be executed with a nil UrlRequest")
    }
    
    func test_run_toValidUrlReturningWrongData() throws {
        let agent = NetworkAgent(with: NetworkConfiguration(session: self.urlSession))
        
        URLProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion:nil, headerFields:nil)!
            return (response, "wrongData".data(using: .utf8)!)
        }
        
        // WHEN
        self.cancellable = agent
            .run(self.request, decode: DecodableObject.self)
            .sink { _ in self.completedExpectation!.fulfill() }
            receiveValue: { self.valueReceived = $0 }
        
        // VERIFY
        self.waitForExpectations(timeout: 1)
        XCTAssertNil(self.valueReceived, "Value should not be received")
        XCTAssertEqual(URLProtocolMock.requestCount, 1, "Request should only be executed once on success")
    }
    
    func test_run_toValidUrlReturningOKData_ReturningInBackgroundThread() throws {
        let agent = NetworkAgent(with: NetworkConfiguration(session: self.urlSession))
        var isMainThread = false
        
        URLProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion:nil, headerFields:nil)!
            return (response, self.returnedData)
        }
        
        // WHEN
        self.cancellable = agent
            .run(self.request, decode: DecodableObject.self)
            .sink { _ in
                isMainThread = Thread.isMainThread
                self.completedExpectation!.fulfill()
            }
            receiveValue: { self.valueReceived = $0 }
        
        // VERIFY
        self.waitForExpectations(timeout: 1)
        XCTAssertEqual(self.valueReceived, self.expectedObject)
        XCTAssertEqual(URLProtocolMock.requestCount, 1, "Request should only be executed once on success")
        XCTAssertFalse(isMainThread, "Returning thread should be background if not specified")
    }
    
    func test_run_toValidUrlReturningOKData_ReturningInMain() throws {
        let agent = NetworkAgent(with: NetworkConfiguration(session: self.urlSession))
        var isMainThread = false
        
        URLProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion:nil, headerFields:nil)!
            return (response, self.returnedData)
        }
        
        // WHEN
        self.cancellable = agent
            .run(self.request, decode: DecodableObject.self)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                isMainThread = Thread.isMainThread
                self.completedExpectation!.fulfill()
            }
            receiveValue: { self.valueReceived = $0 }
        
        // VERIFY
        self.waitForExpectations(timeout: 1)
        XCTAssertEqual(self.valueReceived, self.expectedObject)
        XCTAssertEqual(URLProtocolMock.requestCount, 1, "Request should only be executed once on success")
        XCTAssertTrue(isMainThread, "Returning thread should be main")
    }
    
    func test_download_toValidUrlReturningOKData() throws {
        let agent = NetworkAgent(with: NetworkConfiguration(session: self.urlSession))
        var image: UIImage?
        
        URLProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion:nil, headerFields:nil)!
            return (response, UIImage(systemName: "camera")!.pngData()!)
        }
        
        // WHEN
        self.cancellable = agent
            .download(from: self.request)
            .sink { _ in self.completedExpectation!.fulfill() }
            receiveValue: { image = $0 }
        
        // VERIFY
        self.waitForExpectations(timeout: 1)
        XCTAssertNotNil(image)
        XCTAssertEqual(URLProtocolMock.requestCount, 1, "Request should only be executed once on success")
    }
    
    func test_download_toValidUrlReturningWrongData() throws {
        let agent = NetworkAgent(with: NetworkConfiguration(session: self.urlSession))
        var image: UIImage?
        
        URLProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion:nil, headerFields:nil)!
            return (response, "wrongData".data(using: .utf8)!)
        }
        
        // WHEN
        self.cancellable = agent
            .download(from: self.request)
            .sink { _ in self.completedExpectation!.fulfill() }
            receiveValue: { image = $0 }
        
        // VERIFY
        self.waitForExpectations(timeout: 1)
        XCTAssertNil(image)
        XCTAssertEqual(URLProtocolMock.requestCount, 1, "Request should only be executed once on success")
    }
    
    func test_download_toInvalidUrl() throws {
        let agent = NetworkAgent(with: NetworkConfiguration(session: self.urlSession))
        var image: UIImage?
        
        URLProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion:nil, headerFields:nil)!
            return (response, self.returnedData)
        }
        
        // WHEN
        self.cancellable = agent
            .download(from: self.request)
            .sink { _ in self.completedExpectation!.fulfill() }
            receiveValue: { image = $0 }
        
        // VERIFY
        self.waitForExpectations(timeout: 1)
        XCTAssertNil(image)
        XCTAssertEqual(URLProtocolMock.requestCount, 3, "Request should be retried twice when failed")
    }

    private struct DecodableObject: Decodable, Equatable {
        let test: String
    }
}
