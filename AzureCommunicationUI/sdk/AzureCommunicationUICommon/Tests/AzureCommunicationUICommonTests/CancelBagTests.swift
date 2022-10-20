
import XCTest
@testable import AzureCommunicationUICommon

final class AzureCommunicationUICommonTests: XCTestCase {
    func testCancelBag() throws {
        let cancelBag = CancelBag()
        
        XCTAssertNotNil(cancelBag)
    }
}
