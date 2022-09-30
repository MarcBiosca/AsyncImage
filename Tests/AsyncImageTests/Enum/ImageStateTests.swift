import XCTest
@testable import AsyncImage

final class ImageStateTests: XCTestCase {
    func test_states() throws {
        var state = ImageState.empty
        
        // VERIFY
        XCTAssertNil(state.image)
        XCTAssertNil(state.error)
        
        state = .success(UIImage())
        
        // VERIFY
        XCTAssertNotNil(state.image)
        XCTAssertNil(state.error)
        
        state = .failure(CustomError())
        
        // VERIFY
        XCTAssertNil(state.image)
        XCTAssertNotNil(state.error)
    }
}

private struct CustomError: Error {}
