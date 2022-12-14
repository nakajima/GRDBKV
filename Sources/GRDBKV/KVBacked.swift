//
//  KVBacked.swift
//
//
//  Created by Pat Nakajima on 12/13/22.
//

@propertyWrapper public struct KVBacked<T: Codable> {
	public var wrappedValue: T {
		get {
			return KV.shared.get(key) ?? defaultValue
		}
		set {
			try! KV.shared.set(key, newValue)
		}
	}

	public let key: String
	var defaultValue: T

	init(wrappedValue: T, _ key: String) {
		let existing: T? = KV.shared.get(key)
		self.defaultValue = wrappedValue

		if existing == nil {
			try! KV.shared.set(key, wrappedValue)
		}

		self.key = key
	}
}
