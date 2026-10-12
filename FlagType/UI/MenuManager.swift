import AppKit

final class MenuManager: NSObject {
    static let shared = MenuManager()
    
    private var statusItem: NSStatusItem?
    private let menu = NSMenu()
    
    private override init() {
        super.init()
        setupStatusItem()
        setupInputSourceObserver()
    }
    
    func setup() {
        updateStatusItem()
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.menu = menu
        menu.delegate = self
        updateStatusItem()
    }
    
    private func setupInputSourceObserver() {
        NotificationCenter.default.addObserver(
            forName: InputSourceManager.inputSourceChangedNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateStatusItem()
        }
    }
    
    func updateStatusItem() {
        guard let button = statusItem?.button,
              let current = InputSourceManager.shared.currentInputSource else { return }
        
        let flag = FlagProvider.shared.flagImage(for: current, size: CGSize(width: 22, height: 16))
        button.image = flag
        button.imagePosition = .imageLeft
        
        if Settings.shared.showMenuLayoutName {
            button.title = " \(current.localizedName)"
        } else {
            button.title = ""
        }
    }
    
    private func rebuildMenu() {
        menu.removeAllItems()
        
        let currentSource = InputSourceManager.shared.currentInputSource
        
        // Header
        let headerItem = NSMenuItem(
            title: currentSource?.localizedName ?? "FlagType",
            action: nil,
            keyEquivalent: ""
        )
        headerItem.isEnabled = false
        menu.addItem(headerItem)
        menu.addItem(NSMenuItem.separator())
        
        // Input Sources list
        let sources = InputSourceManager.shared.availableInputSources()
        for source in sources {
            let item = NSMenuItem(
                title: source.localizedName,
                action: #selector(didSelectInputSource(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = source
            item.image = FlagProvider.shared.flagImage(for: source, size: CGSize(width: 18, height: 13))
            
            if source == currentSource {
                item.state = .on
            } else {
                item.state = .off
            }
            menu.addItem(item)
        }
        
        menu.addItem(NSMenuItem.separator())
        
        // Settings Section
        let cursorItem = NSMenuItem(
            title: "Show Flag at Cursor on Layout Change",
            action: #selector(toggleShowCursorIndicator),
            keyEquivalent: ""
        )
        cursorItem.target = self
        cursorItem.state = Settings.shared.showCursorIndicator ? .on : .off
        menu.addItem(cursorItem)
        
        let nameItem = NSMenuItem(
            title: "Show Layout Name in Menu Bar",
            action: #selector(toggleShowMenuLayoutName),
            keyEquivalent: ""
        )
        nameItem.target = self
        nameItem.state = Settings.shared.showMenuLayoutName ? .on : .off
        menu.addItem(nameItem)
        
        let loginItem = NSMenuItem(
            title: "Launch at Login",
            action: #selector(toggleLaunchAtLogin),
            keyEquivalent: ""
        )
        loginItem.target = self
        loginItem.state = Settings.shared.launchAtLogin ? .on : .off
        menu.addItem(loginItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // About & Quit
        let aboutItem = NSMenuItem(
            title: "About FlagType",
            action: #selector(showAbout),
            keyEquivalent: ""
        )
        aboutItem.target = self
        menu.addItem(aboutItem)
        
        let quitItem = NSMenuItem(
            title: "Quit FlagType",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)
    }
    
    @objc private func didSelectInputSource(_ sender: NSMenuItem) {
        guard let source = sender.representedObject as? InputSource else { return }
        InputSourceManager.shared.select(inputSource: source)
        updateStatusItem()
    }
    
    @objc private func toggleShowCursorIndicator() {
        Settings.shared.showCursorIndicator.toggle()
        updateStatusItem()
    }
    
    @objc private func toggleHideWhileTyping() {
        Settings.shared.hideWhileTyping.toggle()
    }
    
    @objc private func toggleShowMenuLayoutName() {
        Settings.shared.showMenuLayoutName.toggle()
        updateStatusItem()
    }
    
    @objc private func toggleLaunchAtLogin() {
        Settings.shared.launchAtLogin.toggle()
    }
    
    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "FlagType v0.1.0"
        alert.informativeText = "A lightweight macOS menu bar utility that displays your active keyboard layout flag in the menu bar and at the cursor on layout change.\n\nCreated with AppKit."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}

extension MenuManager: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        rebuildMenu()
    }
}
