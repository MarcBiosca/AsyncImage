# AsyncImage
iOS >= 13 AsyncImage with the following characteristics:
- Loads the image when te view appears in the screen
- Cancel download request when it disappears
- (optional) in-memory cache to avoid too many URLRequest
- Thread safe
- Concurrency handling to avoid duplicate URLRequest
- Automatically reload when connectivity is regained
- Automatic retry when URLRequest fails

## Getting started
You can clone this repository and run the `AsyncImageDemo` App.

```swift
AsyncImage("https://picsum.photos/200/300".urlRequest)
    .frame(width: 200, height: 200)
```

You can optionally use the `configuration` to apply modifiers to the Image rather than directly to the View returned by AsyncImage.
If not specified, default ones applied are: `resizable().renderingMode(.original)`

### Controlling the cache
> Warning: Make sure to create an ImageCache and PublisherCache object somewhere in your app/module and injected to the AsyncImage object. Do not create a new one per each image, otherwise it will not work as intended.

```swift
let imageCache = PublisherCacheFactory.makeTemporaryCache()
let publisherCache = ImageCacheFactory.makeTemporaryCache()

AsyncImage(
    request: "https://picsum.photos/200/300".urlRequest,
    imageCache: imageCache,
    publisherCache: publisherCache
)
.frame(width: 200, height: 200)
```

## Install
### Swift Package Manager
In Xcode, right click your project and `Add Packages`, then enter the repository URL.
```
https://github.com/MarcBiosca/AsyncImage
```

If you are working with a package, add the repository URL in your `Package.swift`:
```swift
.package(url: "https://github.com/MarcBiosca/AsyncImage.git", from: "1.0.0")
```

### CocoaPods
Add the following line in your `Podfile`:
```
pod 'SimpleAsyncImage'
```
