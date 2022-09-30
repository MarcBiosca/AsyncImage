import XCTest
@testable import AsyncImage
import Combine

final class AsyncImageTests: XCTestCase {
    func test_memoryLeak() throws {
        let imageCache = TemporaryImageCache()
        let networkAgent = NetworkAgentMock()
        let publisherCache = TemporaryPublisherCache()
        let vm = AsyncImageVM(request: "any".urlRequest, networkAgent: networkAgent, imageCache: imageCache, publisherCache: publisherCache)
        
        // WHEN
        vm.load()
        
        // VERIFY
        self.addTeardownBlock { [weak vm] in
            XCTAssertNil(vm, "`vm` should have been deallocated. Potential memory leak!")
        }
    }
    
    func test_load_fromInternet() async throws {
        let imageCache = TemporaryImageCache()
        let networkAgent = NetworkAgentMock()
        let publisherCache = TemporaryPublisherCache()
        let vm = AsyncImageVM(request: "any".urlRequest, networkAgent: networkAgent, imageCache: imageCache, publisherCache: publisherCache)
        
        // WHEN
        vm.load()
        
        // VERIFY
        try await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertNotNil(vm.imageState.image)
    }
    
    func test_load_fromCache() async throws {
        let request = "any".urlRequest
        let image = UIImage(systemName: "camera")
        let imageCache = TemporaryImageCacheMock()
        imageCache.cache[request!.url!] = image
        let networkAgent = NetworkAgentMock()
        networkAgent.image = UIImage()
        let publisherCache = TemporaryPublisherCache()
        let vm = AsyncImageVM(request: request, networkAgent: networkAgent, imageCache: imageCache, publisherCache: publisherCache)
        
        // WHEN
        vm.load()
        
        // VERIFY
        try await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertNotNil(vm.imageState.image)
        XCTAssertEqual(imageCache.cacheReturned, 2)
    }
    
    func test_load_twice() async throws {
        let imageCache = TemporaryImageCache()
        let networkAgent = NetworkAgentMock()
        let publisherCache = TemporaryPublisherCache()
        let vm = AsyncImageVM(request: "any".urlRequest, networkAgent: networkAgent, imageCache: imageCache, publisherCache: publisherCache)
        
        // WHEN
        vm.load()
        
        // VERIFY
        try await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertNotNil(vm.imageState.image)
        
        // WHEN
        vm.load()
        
        // VERIFY
        try await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertNotNil(vm.imageState.image)
        XCTAssertEqual(networkAgent.networkCalls, 1)
    }
    
    func test_load_twice_parallel() async throws {
        let imageCache = TemporaryImageCache()
        let networkAgent = NetworkAgentMock()
        let publisherCache = TemporaryPublisherCache()
        let vm = AsyncImageVM(request: "any".urlRequest, networkAgent: networkAgent, imageCache: imageCache, publisherCache: publisherCache)
        
        // WHEN
        DispatchQueue.global().async {
            vm.load()
        }
        
        vm.load()
        
        // VERIFY
        try await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertNotNil(vm.imageState.image)
        XCTAssertEqual(networkAgent.networkCalls, 1)
    }
}

private struct DecodableObject: Decodable {
    let test: String
}
