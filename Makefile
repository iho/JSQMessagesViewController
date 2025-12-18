b:
	xcodegen generate && xcodebuild -project JSQMessages.xcodeproj -scheme JSQMessagesDemo -sdk iphonesimulator clean build
i:
	brew install xcodegen
