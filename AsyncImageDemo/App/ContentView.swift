//
//  ContentView.swift
//  AsyncImageDemo
//
//  Created by Marc Biosca on 9/29/22.
//

import SwiftUI
import AsyncImage

struct ContentView: View {
    @State private var showSlide = false
    
    private let imageCache: ImageCache
    private let publisherCache: PublisherCache
    private let images: [ImageItem] = (1...100).map { _ in ImageItem() }
    
    init(imageCache: ImageCache) {
        self.imageCache = imageCache
        self.publisherCache = PublisherCacheFactory.makeTemporaryCache()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    Button("Show slide") { self.showSlide.toggle() }
                    
                    ForEach(self.images) { item in
                        NavigationLink(
                            destination: DetailView(
                                imageCache: self.imageCache,
                                publisherCache: self.publisherCache,
                                item: item
                            )) {
                                HStack(alignment: .center) {
                                    Spacer(minLength: 0)
                                    
                                    AsyncImage(
                                        request: item.image.urlRequest,
                                        imageCache: self.imageCache,
                                        publisherCache: self.publisherCache
                                    )
                                    .frame(width: 200)
                                    .cornerRadius(10)
                                    
                                    Spacer(minLength: 0)
                                }
                                .frame(height: 300)
                        }
                    }
                }
                
                Group {
                    if self.showSlide {
                        VStack {
                            Spacer(minLength: 90)
                            
                            HStack {
                                AsyncImage(
                                    request: self.images[self.images.count - 1].image.urlRequest,
                                    imageCache: self.imageCache,
                                    publisherCache: self.publisherCache
                                )
                                .frame(width: 200)
                                .clipShape(Circle())
                                
                                AsyncImage(
                                    request: self.images[self.images.count - 2].image.urlRequest,
                                    imageCache: self.imageCache,
                                    publisherCache: self.publisherCache
                                )
                                .frame(width: 200)
                                .clipShape(Circle())
                            }
                        }
                    }
                }
                .animation(.linear, value: self.showSlide)
                .transition(.move(edge: .bottom))
                .zIndex(99)
            }
            .navigationBarTitle("AsyncImage", displayMode: .large)
        }
    }
}

struct DetailView: View {
    private let imageCache: ImageCache
    private let publisherCache: PublisherCache
    private let item: ImageItem
    
    init(imageCache: ImageCache, publisherCache: PublisherCache, item: ImageItem) {
        self.imageCache = imageCache
        self.publisherCache = publisherCache
        self.item = item
    }
    
    var body: some View {
        AsyncImage(
            request: self.item.image.urlRequest,
            imageCache: self.imageCache,
            publisherCache: self.publisherCache
        )
        .aspectRatio(contentMode: .fit)
    }
}

struct ImageItem: Identifiable {
    let id: String
    let image: String
    
    init() {
        self.id = UUID().uuidString
        self.image = "https://picsum.photos/200/300?id=\(UUID().uuidString)"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(imageCache: ImageCacheFactory.makeTemporaryCache())
    }
}
