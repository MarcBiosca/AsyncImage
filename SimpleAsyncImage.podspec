Pod::Spec.new do |s|
  s.platform                    = :ios, "13.0"
  s.swift_version 		= '5.0'
  s.name                        = "SimpleAsyncImage"
  s.version                     = "1.0.3"
  s.summary                     = "Simple iOS 13 AsyncImage"
  s.description                 = <<-DESC
    iOS >= 13 AsyncImage with the following characteristics:

	- Loads the image when te view appears in the screen
	- Cancel download request when it disappears
	- (optional) in-memory cache to avoid too many URLRequest
	- Thread safe
	- Concurrency handling to avoid duplicate URLRequest
	- Automatically reload when connectivity is regained
	- Automatic retry when URLRequest fails
DESC
  s.homepage                    = "https://github.com/MarcBiosca/AsyncImage.git"
  s.license                     = { :type => "MIT", :file => "LICENSE" }
  s.author                      = { "MarcBiosca" => "marc@dostresdos.com" }
  s.source                      = { :git => "https://github.com/MarcBiosca/AsyncImage.git", :tag => "#{s.version}" }
  s.source_files                = 'Sources/AsyncImage/**/*'
end
