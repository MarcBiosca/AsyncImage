import XCTest
@testable import AsyncImage

final class StringExtensionTests: XCTestCase {
    func test_urlRequest_validUrl() throws {
        // WHEN
        let request = "test".urlRequest
        
        // VERIFY
        XCTAssertNotNil(request)
    }
    
    func test_urlRequest_invalidUrl() throws {
        // WHEN
        let request = "".urlRequest
        
        // VERIFY
        XCTAssertNil(request)
    }
}
