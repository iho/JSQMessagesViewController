Pod::Spec.new do |s|
	s.name = 'JSQMessagesViewController'
	s.version = '8.0.0'
	s.summary = 'An elegant messages UI library for iOS.'
	s.license = 'MIT'
	s.platform = :ios, '13.0'
	s.author = 'Jesse Squires'
	s.source = { :git => 'https://github.com/jessesquires/JSQMessagesViewController.git', :tag => s.version }
	s.source_files = 'JSQMessagesViewController/**/*.{h,m,swift}'
	s.resources = ['JSQMessagesViewController/Assets/JSQMessagesAssets.bundle', 'JSQMessagesViewController/**/*.{xib}']
	s.frameworks = 'QuartzCore', 'CoreGraphics', 'CoreLocation', 'MapKit', 'MobileCoreServices', 'AVFoundation'
	s.requires_arc = true
    s.swift_version = '5.0'
end
