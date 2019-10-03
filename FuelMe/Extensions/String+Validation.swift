public extension String {
    
    func isOnlyNumber() -> Bool {
        let regEx = "^[0-9]*$"
        let pred = NSPredicate(format: "SELF MATCHES %@", regEx)
        return pred.evaluate(with: self)
    }
}
