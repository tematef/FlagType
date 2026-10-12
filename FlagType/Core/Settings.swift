import Foundation
import ServiceManagement

final class Settings {
    static let shared = Settings()
    
    private let defaults = UserDefaults.standard
    
    static let settingsChangedNotification = Notification.Name("FlagTypeSettingsChangedNotification")
    
    enum Keys {
        static let showCursorIndicator = "showCursorIndicator"
        static let hideWhileTyping = "hideWhileTyping"
        static let showMenuLayoutName = "showMenuLayoutName"
    }
    
    var showCursorIndicator: Bool {
        get { defaults.object(forKey: Keys.showCursorIndicator) as? Bool ?? true }
        set {
            defaults.set(newValue, forKey: Keys.showCursorIndicator)
            NotificationCenter.default.post(name: Settings.settingsChangedNotification, object: nil)
        }
    }
    
    var hideWhileTyping: Bool {
        get { defaults.object(forKey: Keys.hideWhileTyping) as? Bool ?? true }
        set {
            defaults.set(newValue, forKey: Keys.hideWhileTyping)
            NotificationCenter.default.post(name: Settings.settingsChangedNotification, object: nil)
        }
    }
    
    var showMenuLayoutName: Bool {
        get { defaults.object(forKey: Keys.showMenuLayoutName) as? Bool ?? false }
        set {
            defaults.set(newValue, forKey: Keys.showMenuLayoutName)
            NotificationCenter.default.post(name: Settings.settingsChangedNotification, object: nil)
        }
    }
    
    var launchAtLogin: Bool {
        get {
            if #available(macOS 13.0, *) {
                return SMAppService.mainApp.status == .enabled
            }
            return false
        }
        set {
            if #available(macOS 13.0, *) {
                do {
                    if newValue {
                        try SMAppService.mainApp.register()
                    } else {
                        try SMAppService.mainApp.unregister()
                    }
                } catch {
                    print("[Settings] Failed to set launch at login: \(error)")
                }
            }
        }
    }
}
