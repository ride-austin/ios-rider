import Foundation

func executeInRelease(_ block: () -> Void) {
    #if DEBUG
    #else
    block()
    #endif
}

func executeInRealDevice(_ block: () -> Void) {
    #if targetEnvironment(simulator)
    #else
    block()
    #endif
}
