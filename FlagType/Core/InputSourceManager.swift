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
    
    static let inputSourceChangedNotification = Notification.Name("FlagTypeInputSourceChangedNotification")
    
    private(set) var currentInputSource: InputSource?
    
    private var keyMonitor: Any?
    private var pollTimer: Timer?
    
    private init() {
        refreshCurrentInputSource()
        setupObservers()
    }
    
    func refreshCurrentInputSource() {
        guard let source = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue() else {
            return
        }
        
        let info = makeInputSource(from: source)
        if currentInputSource != info {
            currentInputSource = info
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: InputSourceManager.inputSourceChangedNotification,
                    object: info
                )
            }
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
    
    private func setupObservers() {
        // 1. CFNotificationCenter with deliverImmediately
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDistributedCenter(),
            Unmanaged.passUnretained(self).toOpaque(),
            { (_, observer, name, _, _) in
                guard let observer = observer else { return }
                let manager = Unmanaged<InputSourceManager>.fromOpaque(observer).takeUnretainedValue()
                DispatchQueue.main.async {
                    manager.refreshCurrentInputSource()
                }
            },
            kTISNotifySelectedKeyboardInputSourceChanged,
            nil,
            .deliverImmediately
        )
        
        // 2. DistributedNotificationCenter with deliverImmediately
        let notifName = kTISNotifySelectedKeyboardInputSourceChanged as CFString as String
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(handleNotification),
            name: NSNotification.Name(notifName),
            object: nil,
            suspensionBehavior: .deliverImmediately
        )
        
        // 3. Global key press & modifier flags monitor (Cmd+Space, Ctrl+Space, Globe, CapsLock)
        keyMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.flagsChanged, .keyDown]) { [weak self] _ in
            self?.refreshCurrentInputSource()
        }
        
        // 4. Fallback lightweight polling timer (0.2s)
        pollTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            self?.refreshCurrentInputSource()
        }
    }
    
    @objc private func handleNotification() {
        refreshCurrentInputSource()
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
