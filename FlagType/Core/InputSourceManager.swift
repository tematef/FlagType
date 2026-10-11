import Foundation
import Carbon
import AppKit

struct InputSource: Equatable {
    let id: String
    let localizedName: String
    let iconURL: URL?
    let rawSource: TISInputSource
    
    static func == (lhs: InputSource, rhs: InputSource) -> Bool {
        return lhs.id == rhs.id
    }
}

final class InputSourceManager {
    static let shared = InputSourceManager()
    
    var onInputSourceChanged: ((InputSource) -> Void)?
    
    private(set) var currentInputSource: InputSource?
    
    private init() {
        refreshCurrentInputSource()
        setupObserver()
    }
    
    func refreshCurrentInputSource() {
        guard let source = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue() else {
            return
        }
        
        let info = makeInputSource(from: source)
        if currentInputSource != info {
            currentInputSource = info
            onInputSourceChanged?(info)
        }
    }
    
    func availableInputSources() -> [InputSource] {
        let properties = [
            kTISPropertyInputSourceCategory: kTISCategoryKeyboardInputSource as CFString,
            kTISPropertyInputSourceIsSelectCapable: true as CFBoolean
        ] as CFDictionary
        
        guard let list = TISCreateInputSourceList(properties, false)?.takeRetainedValue() as? [TISInputSource] else {
            return []
        }
        
        return list.map { makeInputSource(from: $0) }
    }
    
    func select(inputSource: InputSource) {
        TISSelectInputSource(inputSource.rawSource)
        refreshCurrentInputSource()
    }
    
    private func setupObserver() {
        let notificationName = kTISNotifySelectedKeyboardInputSourceChanged as CFString as String
        DistributedNotificationCenter.default().addObserver(
            forName: NSNotification.Name(notificationName),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refreshCurrentInputSource()
        }
    }
    
    private func makeInputSource(from raw: TISInputSource) -> InputSource {
        let id = getProperty(raw, kTISPropertyInputSourceID) as? String ?? "unknown"
        let name = getProperty(raw, kTISPropertyLocalizedName) as? String ?? id
        let iconURL = getProperty(raw, kTISPropertyIconImageURL) as? URL
        return InputSource(id: id, localizedName: name, iconURL: iconURL, rawSource: raw)
    }
    
    private func getProperty(_ source: TISInputSource, _ key: CFString) -> AnyObject? {
        guard let raw = TISGetInputSourceProperty(source, key) else { return nil }
        return Unmanaged<AnyObject>.fromOpaque(raw).takeUnretainedValue()
    }
}
