//
//  AsyncImageVM.swift
//
//
//  Created by Marc Biosca on 9/29/22.
//

import Combine
import UIKit
import Network
import SwiftUI

final class AsyncImageVM: ObservableObject {
    @Published var imageState = ImageState.empty
    
    private let imageProcessingQueue = DispatchQueue(label: "async-imageVm")
    private let request: URLRequest?
    private let networkAgent: NetworkAgentProtocol
    
    private var images: ImageCache?
    private var publishers: PublisherCache
    private var imagePublisher: AnyCancellable?
    private var networkPublisher: AnyCancellable?
    private var isLoading = false
    
    init(
        request: URLRequest?,
        networkAgent: NetworkAgentProtocol = NetworkAgent(),
        imageCache: ImageCache?,
        publisherCache: PublisherCache
    ) {
        self.request = request
        self.networkAgent = networkAgent
        self.images = imageCache
        self.publishers = publisherCache
        
        self.load()
    }
    
    func load() {
        guard !self.isLoading, let url = self.request?.url else { return }

        if let image = self.images?[url] {
            self.imageState = .success(image)
            return
        }
        
        self.onStart()
        
        self.publisher(for: url)
            .catch { [weak self] in
                self?.onError($0) ?? Empty().eraseToAnyPublisher()
            }
            .sink { [weak self] _ in
                self?.onComplete()
            }
            receiveValue: { [weak self] in
                self?.onOutput(url: url, image: $0)
            }
            .keep(in: &self.imagePublisher)
    }
    
    func disappear() {
        self.imagePublisher = nil
        self.networkPublisher = nil
    }
    
    func reload() {
        self.set(.empty)
        self.load()
    }
}

private extension AsyncImageVM {
    typealias UIImagePublisher = AnyPublisher<UIImage, Never>
    
    func publisher(for url: URL) -> UIImageErrorPublisher {
        if let publisher = self.publishers.get(url.absoluteString) {
            return publisher
        }

        let publisher = self.networkAgent.download(from: self.request)
            .subscribe(on: self.imageProcessingQueue)
            .handleEvents(receiveCompletion: { [weak self] _ in
                self?.onCancel(url: url)
            }, receiveCancel: { [weak self] in
                self?.onCancel(url: url)
            })
            .share()
            .eraseToAnyPublisher()
        
        self.publishers.set(publisher, for: url.absoluteString)
        
        return publisher
    }

    func onStart() {
        self.isLoading = true
    }
    
    func onError(_ error: Swift.Error) -> UIImagePublisher {
        if self.networkPublisher == nil {
            NWPathMonitor().publisher
                .filter { [weak self] in
                    $0 == .satisfied
                    && self?.imageState.image == nil
                }
                .sink { [weak self] _ in
                    self?.load()
                }
                .keep(in: &self.networkPublisher)
        }
        
        self.set(.failure(error))
        
        return Empty().eraseToAnyPublisher()
    }
    
    func onCancel(url: URL) {
        self.publishers.set(nil, for: url.absoluteString)
        self.isLoading = false
    }
    
    func onOutput(url: URL, image: UIImage) {
        self.images?[url] = image
        self.set(.success(image))
        
        self.networkPublisher = nil
    }
    
    func onComplete() {
        self.imagePublisher = nil
        self.isLoading = false
    }
    
    func set(_ imageState: ImageState) {
        DispatchQueue.main.async {
            self.imageState = imageState
        }
    }
}
