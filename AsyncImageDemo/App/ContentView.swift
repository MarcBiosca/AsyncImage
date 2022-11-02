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
    
    private let images: [ImageItem] = (1...100).map { _ in ImageItem() }
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    Button("Show slide") { self.showSlide.toggle() }
                    
                    ForEach(self.images) { item in
                        NavigationLink(
                            destination: DetailView(item: item)) {
                                HStack(alignment: .center) {
                                    Spacer(minLength: 0)
                                    
                                    AsyncImage(item.image.urlRequest)
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
                                AsyncImage(self.images[self.images.count - 1].image.urlRequest)
                                    .frame(width: 200)
                                    .clipShape(Circle())
                                
                                AsyncImage(self.images[self.images.count - 2].image.urlRequest)
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
    private let item: ImageItem
    
    init(item: ImageItem) {
        self.item = item
    }
    
    var body: some View {
        AsyncImage(self.item.image.urlRequest)
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
        ContentView()
    }
}
