import GRDB
@testable import GRDBKV
import XCTest

struct TestModel {
	@KVBacked("foo") var foo: String = "bar"
	@KVBacked("sup") var sup = "not much"
}

final class GRDBKVTests: XCTestCase {
	override func setUp() {
		try! KV.initialize(db: DatabaseQueue())
	}

	func testExists() throws {
		_ = KV.shared
	}

	func testSetGetString() throws {
		try KV.shared.set("hello", "world")

		XCTAssertEqual("world", KV.shared.get("hello"))
	}

	func testSetGetBool() throws {
		try KV.shared.set("huh", true)

		XCTAssertEqual(true, KV.shared.get("huh"))
	}

	func testCanBackProperty() throws {
		try KV.shared.set("foo", "bar")

		XCTAssertEqual("bar", KV.shared.get("foo"))

		let model = TestModel()
		XCTAssertEqual("bar", model.foo)

		try KV.shared.set("foo", "fizz")
		XCTAssertEqual("fizz", KV.shared.get("foo"))
		let model2 = TestModel()

		XCTAssertEqual("fizz", model.foo)
		XCTAssertEqual("fizz", model2.foo)
	}

	func testCanBackPropertyWithDefaultValue() throws {
		let model = TestModel()
		XCTAssertEqual("not much", model.sup)

		try KV.shared.set("sup", "tons")
		XCTAssertEqual("tons", model.sup)
	}

	func testDoesnotOverride() throws {
		// make sure we're fresh
		let count = try KV.shared.queue.read { db in
			try KVRecord.fetchCount(db)
		}

		XCTAssertEqual(0, count)

		try KV.shared.set("sup", "tons")
		XCTAssertEqual("tons", TestModel().sup)
	}
}
