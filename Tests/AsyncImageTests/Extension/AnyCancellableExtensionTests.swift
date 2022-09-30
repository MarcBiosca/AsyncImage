import XCTest
@testable import AsyncImage
import Combine

final class AnyCancellableExtensionTests: XCTestCase {
    func test_keep() throws {
        var cancellable: AnyCancellable?
        
        // WHEN
        Just(())
            .sink {}
            .keep(in: &cancellable)
        
        // VERIFY
        XCTAssertNotNil(cancellable)
    }
}
