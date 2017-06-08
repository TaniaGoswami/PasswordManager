//  Copyright © 2017 Compass. All rights reserved.

import XCTest
@testable import PasswordManager

class PasswordManagerTests: XCTestCase {
    func testPasswordManagerIsAvailable() {
        XCTAssertFalse(PasswordManager.shared.isPasswordManagerAvailable)
    }
}
