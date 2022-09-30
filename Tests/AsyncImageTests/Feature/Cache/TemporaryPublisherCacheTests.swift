import XCTest
@testable import AsyncImage
import Combine

final class TemporaryPublisherCacheTests: XCTestCase {
    func test_threadSafe() async throws {
        let cache = TemporaryPublisherCache()
        let key = "any"
        let publisher = self.publisher
        
        // WHEN
        for _ in 0..<100 {
            DispatchQueue.global().async {
                cache.set(publisher, for:key)
            }
        }
        
        for _ in 0..<100 {
            DispatchQueue.global().async {
                _ = cache.get(key)
            }
        }

        // VERIFY
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    func test_getAndSet() async throws {
        let cache = TemporaryPublisherCache()
        let key = "any"
        let publisher = self.publisher
        
        // WHEN
        cache.set(publisher, for:key)
        let result = cache.get(key)
        
        // VERIFY
        XCTAssertNotNil(result)
    }
    
    private var publisher: UIImageErrorPublisher {
        Just(UIImage())
            .tryMap { $0 }
            .eraseToAnyPublisher()
    }
}
