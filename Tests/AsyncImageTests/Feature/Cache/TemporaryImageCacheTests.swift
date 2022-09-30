import XCTest
@testable import AsyncImage

final class TemporaryImageCacheTests: XCTestCase {
    func test_threadSafe() async throws {
        let cache = TemporaryImageCache()
        let url = URL(string: "any")!
        let image = UIImage(systemName: "camera")

        // WHEN
        for _ in 0..<100 {
            DispatchQueue.global().async {
                cache[url] = image
            }
        }
        
        for _ in 0..<100 {
            DispatchQueue.global().async {
                _ = cache[url]
            }
        }

        // VERIFY
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    func test_getAndSet() throws {
        let cache = TemporaryImageCache()
        let url = URL(string: "any")!
        let image = UIImage(systemName: "camera")
        
        // WHEN
        cache[url] = image
        let result = cache[url]
        
        // VERIFY
        XCTAssertEqual(result, image)
    }
}
