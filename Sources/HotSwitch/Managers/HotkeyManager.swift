import AppKit
import Carbon
import os.log

private let logger = Logger(subsystem: "com.hotswitch.app", category: "HotkeyManager")

class HotkeyManager {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var isSwitcherVisible = false
    private var isOptionHeld = false

    let onSwitcherShow: () -> Void
    let onSwitcherHide: () -> Void
    let onNextApp: () -> Void
    let onPreviousApp: () -> Void

    // Key codes
    private let tabKeyCode: CGKeyCode = 48
    private let leftArrowKeyCode: CGKeyCode = 123
    private let rightArrowKeyCode: CGKeyCode = 124

    init(
        onSwitcherShow: @escaping () -> Void,
        onSwitcherHide: @escaping () -> Void,
        onNextApp: @escaping () -> Void,
        onPreviousApp: @escaping () -> Void
    ) {
        self.onSwitcherShow = onSwitcherShow
        self.onSwitcherHide = onSwitcherHide
        self.onNextApp = onNextApp
        self.onPreviousApp = onPreviousApp
    }

    @discardableResult
    func start() -> Bool {
        guard eventTap == nil else { return true }

        let eventMask: CGEventMask =
            (1 << CGEventType.keyDown.rawValue) |
            (1 << CGEventType.keyUp.rawValue) |
            (1 << CGEventType.flagsChanged.rawValue)

        // Create a mutable self pointer to pass to the callback
        let selfPointer = Unmanaged.passUnretained(self).toOpaque()

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else {
                    return Unmanaged.passUnretained(event)
                }
                let manager = Unmanaged<HotkeyManager>.fromOpaque(refcon).takeUnretainedValue()
                return manager.handleEvent(proxy: proxy, type: type, event: event)
            },
            userInfo: selfPointer
        ) else {
            logger.error("Failed to create event tap. Make sure Accessibility permissions are granted.")
            return false
        }

        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)

        if let source = runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
            logger.info("Event tap created and enabled successfully")
            return true
        }
        return false
    }

    func stop() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
        }
        eventTap = nil
        runLoopSource = nil
    }

    private func handleEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        // Handle tap disabled events (re-enable the tap)
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let tap = eventTap {
                CGEvent.tapEnable(tap: tap, enable: true)
            }
            return Unmanaged.passUnretained(event)
        }

        let flags = event.flags
        let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))

        // Handle flags changed (Option key press/release)
        if type == .flagsChanged {
            let optionPressed = flags.contains(.maskAlternate)

            if optionPressed && !isOptionHeld {
                // Option just pressed
                isOptionHeld = true
            } else if !optionPressed && isOptionHeld {
                // Option just released
                isOptionHeld = false
                if isSwitcherVisible {
                    DispatchQueue.main.async { [weak self] in
                        self?.onSwitcherHide()
                    }
                    isSwitcherVisible = false
                }
            }
            return Unmanaged.passUnretained(event)
        }

        // Handle key down
        if type == .keyDown {
            // Check for Option+Tab
            if flags.contains(.maskAlternate) && keyCode == tabKeyCode {
                logger.info("Option+Tab detected!")
                let shiftHeld = flags.contains(.maskShift)

                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }

                    if !self.isSwitcherVisible {
                        self.onSwitcherShow()
                        self.isSwitcherVisible = true
                        // Don't cycle on first show - start at first app
                    } else {
                        // Only cycle on subsequent Tab presses
                        if shiftHeld {
                            self.onPreviousApp()
                        } else {
                            self.onNextApp()
                        }
                    }
                }

                // Consume the event (don't pass it to other apps)
                return nil
            }

            // Check for Escape while switcher is visible
            if isSwitcherVisible && keyCode == 53 { // Escape key
                DispatchQueue.main.async { [weak self] in
                    self?.isSwitcherVisible = false
                    // Hide without activating (cancel)
                    if let window = NSApp.windows.first(where: { $0 is NSPanel }) {
                        window.orderOut(nil)
                    }
                }
                return nil
            }

            // Arrow key navigation while switcher is visible
            if isSwitcherVisible {
                if keyCode == rightArrowKeyCode {
                    DispatchQueue.main.async { [weak self] in
                        self?.onNextApp()
                    }
                    return nil
                } else if keyCode == leftArrowKeyCode {
                    DispatchQueue.main.async { [weak self] in
                        self?.onPreviousApp()
                    }
                    return nil
                }
            }
        }

        return Unmanaged.passUnretained(event)
    }
}
