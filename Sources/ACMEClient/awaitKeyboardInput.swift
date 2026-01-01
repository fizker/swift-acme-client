@discardableResult
func awaitKeyboardInput(message: String? = nil) -> String {
	if let message {
		print(message)
	}
	print("Press enter to continue")
	return readLine() ?? ""
}
