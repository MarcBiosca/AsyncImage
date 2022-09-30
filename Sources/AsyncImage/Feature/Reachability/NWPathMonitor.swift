//
//  NWPathMonitor.swift
//  
//
//  Created by Marc Biosca on 9/29/22.
//

import Network
import Combine

extension NWPathMonitor {
    var publisher: NetworkStatusPublisher {
        NetworkStatusPublisher(monitor: self)
    }
}

struct NetworkStatusPublisher: Publisher {
    public typealias Output = NWPath.Status
    public typealias Failure = Never
    
    private let monitor: NWPathMonitor
    private let queue: DispatchQueue
    
    init(monitor: NWPathMonitor, queue: DispatchQueue = DispatchQueue(label: "network-monitor")) {
        self.monitor = monitor
        self.queue = queue
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, NWPath.Status == S.Input {
        let subscription = NetworkStatusSubscription(
            subscriber: subscriber,
            monitor: self.monitor,
            queue: self.queue
        )
        
        subscriber.receive(subscription: subscription)
    }
}

private class NetworkStatusSubscription<S: Subscriber>: Subscription where S.Input == NWPath.Status {
    private let subscriber: S?
    private let monitor: NWPathMonitor
    private let queue: DispatchQueue
    
    private var currentStatus: NWPath.Status?
    
    init(subscriber: S, monitor: NWPathMonitor, queue: DispatchQueue) {
        self.subscriber = subscriber
        self.monitor = monitor
        self.queue = queue
    }
    
    func request(_ demand: Subscribers.Demand) {
        self.monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }

            guard let current = self.currentStatus, current != path.status else {
                self.currentStatus = path.status
                return
            }

            self.currentStatus = path.status
            _ = self.subscriber?.receive(path.status)
        }

        self.monitor.start(queue: self.queue)
    }
    
    func cancel() {
        self.monitor.cancel()
    }
}
