//
//  AsyncImage.swift
//
//
//  Created by Marc Biosca on 9/29/22.
//

import SwiftUI

public struct AsyncImage: View {
    @ObservedObject private var viewModel: AsyncImageVM
    
    private let configuration: (Image) -> Image
    
    public init(
        request: URLRequest?,
        imageCache: ImageCache?,
        publisherCache: PublisherCache,
        configuration: @escaping (Image) -> Image = {
            $0.resizable().renderingMode(.original)
        }
    ) {
        self._viewModel = ObservedObject(
            wrappedValue: AsyncImageVM(
                request: request,
                imageCache: imageCache,
                publisherCache: publisherCache
            )
        )
        self.configuration = configuration
    }
    
    public var body: some View {
        self.image
            .onAppear(perform: self.viewModel.load)
            .onDisappear(perform: self.viewModel.disappear)
    }
    
    private var image: some View {
        VStack {
            if self.viewModel.imageState.loading {
                Rectangle()
                    .fill(Color(.tertiarySystemGroupedBackground))
                    .overlay(
                        Spinner(animating: true, style: .medium, color: UIColor.label)
                    )
            }
            else if let image = self.viewModel.imageState.image {
                self.configuration(Image(uiImage: image))
            }
            else {
                Rectangle()
                    .fill(Color(.tertiarySystemGroupedBackground))
                    .overlay(self.reloadView)
                    .onTapGesture(perform: self.viewModel.reload)
            }
        }
    }
    
    private var reloadView: some View {
        ZStack {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.red)
            
            VStack (alignment: .trailing) {
                HStack {
                    Spacer(minLength: 0)
                    
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(Color(UIColor.label))
                }
                .padding(10)
                
                Spacer(minLength: 0)
            }
        }
    }
}

struct AsyncImage_Previews: PreviewProvider {
    static var previews: some View {
        AsyncImage(
            request: "https://picsum.photos/200/300".urlRequest,
            imageCache: ImageCacheFactory.makeTemporaryCache(),
            publisherCache: PublisherCacheFactory.makeTemporaryCache()
        )
    }
}
