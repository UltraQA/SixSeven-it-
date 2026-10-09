import Foundation
import XCTest
@testable import SixSevenCore

final class SettingsStoreTests: XCTestCase {
    func testUserDefaultsSettingsRoundTrip() async throws {
        let suiteName = "SixSevenTests.\(UUID().uuidString)"
        let store = UserDefaultsSettingsStore(suiteName: suiteName)
        let expected = AppSettings(
            soundEffectsEnabled: false,
            motionControlEnabled: true,
            theme: .dark
        )

        try await store.save(expected)
        let actual = try await store.load()

        XCTAssertEqual(actual, expected)
        try XCTUnwrap(UserDefaults(suiteName: suiteName)).removePersistentDomain(forName: suiteName)
    }

    func testEmptySettingsStoreReturnsDefaults() async throws {
        let suiteName = "SixSevenTests.\(UUID().uuidString)"
        let store = UserDefaultsSettingsStore(suiteName: suiteName)

        let actual = try await store.load()

        XCTAssertEqual(actual, .defaults)
        try XCTUnwrap(UserDefaults(suiteName: suiteName)).removePersistentDomain(forName: suiteName)
    }
}
