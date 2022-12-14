//
//  KV.swift
//
//
//  Created by Pat Nakajima on 12/13/22.
//

import Foundation
import GRDB
import MessagePacker

struct KV {
	let id = UUID()
	public static var shared = KV()
	var queue: DatabaseQueue

	private let encoder = MessagePackEncoder()
	private let decoder = MessagePackDecoder()

	public static func initialize(db _: DatabaseQueue) throws {
		try shared.queue.close()

		shared = KV()
		try KVRecord.migrate()
	}

	init(queue: DatabaseQueue? = nil) {
		self.queue = queue ?? (try! DatabaseQueue())
	}

	public func set<T: Codable>(_ key: String, _ val: T) throws {
		let data = try encoder.encode(val)
		var record = KVRecord(key: key, val: data, setAt: Date())

		try queue.write { db in
			try record.insert(db, onConflict: .replace)
		}
	}

	public func get<T: Codable>(_ key: String) -> T? {
		let record = try! queue.read { db in
			try! KVRecord.filter(Column("key") == key).fetchOne(db)
		}

		guard let record else {
			return nil
		}

		return try? decoder.decode(T.self, from: record.val)
	}
}
