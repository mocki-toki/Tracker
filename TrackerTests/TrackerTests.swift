//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Simon Butenko on 05.12.2024.
//

import SnapshotTesting
import XCTest

@testable import Tracker

final class TrackerTests: XCTestCase {
    func testViewController() {
        for userInterfaceStyle in [UIUserInterfaceStyle.light, .dark] {
            let vc = MainViewController()
            vc.overrideUserInterfaceStyle = userInterfaceStyle
            assertSnapshot(of: vc, as: .image)
        }
    }
}
