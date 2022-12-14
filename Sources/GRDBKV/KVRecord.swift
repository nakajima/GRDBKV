//
//  KV+DB.swift
//
//
//  Created by Pat Nakajima on 12/13/22.
//

import Foundation
import GRDB

internal struct KVRecord: Codable, FetchableRecord, MutablePersistableRecord {
	static func migrate(force: Bool = false) throws {
		try KV.shared.queue.write { db in
			try db.create(table: "kvrecord", ifNotExists: !force) { t in
				t.autoIncrementedPrimaryKey("id")
				t.column("key", .text).notNull().indexed().unique(onConflict: .replace)
				t.column("val", .blob).notNull()
				t.column("setAt", .datetime).notNull()
			}
		}
	}

	var id: Int?
	var key: String
	var val: Data
	var setAt: Date

	mutating func didInsert(_ inserted: InsertionSuccess) {
		id = Int(inserted.rowID)
	}
}
