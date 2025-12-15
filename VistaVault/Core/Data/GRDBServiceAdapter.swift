import Foundation
import GRDB

/// Service adapter to bridge old model structure with new GRDB V2 structure
/// This allows gradual migration while maintaining compatibility
@MainActor
class GRDBServiceAdapter {
    static let shared = GRDBServiceAdapter()
    private let dataController = GRDBDataController.shared
    
    private init() {}
    
    // MARK: - Helper Methods
    
    /// Execute a read transaction
    func read<T>(_ block: @escaping (Database) throws -> T) throws -> T {
        try dataController.dbQueue.read(block)
    }
    
    /// Execute a write transaction
    func write<T>(_ block: @escaping (Database) throws -> T) throws -> T {
        try dataController.dbQueue.write(block)
    }
    
    /// Fetch all records of a type with optional filter
    func fetchAll<T: FetchableRecord & TableRecord>(
        _ type: T.Type,
        filter: ((QueryInterfaceRequest<T>) -> QueryInterfaceRequest<T>)? = nil
    ) throws -> [T] {
        try read { db in
            var request = type.all()
            if let filter = filter {
                request = filter(request)
            }
            return try request.fetchAll(db)
        }
    }
    
    /// Fetch one record by ID
    func fetchOne<T: FetchableRecord & TableRecord>(
        _ type: T.Type,
        id: some DatabaseValueConvertible
    ) throws -> T? {
        try read { db in
            try type.fetchOne(db, key: id)
        }
    }
    
    /// Insert a record
    @discardableResult
    func insert<T: MutablePersistableRecord>(_ record: T) throws -> T {
        var mutableRecord = record
        try write { db in
            try mutableRecord.insert(db)
        }
        return mutableRecord
    }
    
    /// Update a record
    @discardableResult
    func update<T: MutablePersistableRecord>(_ record: T) throws -> T {
        var mutableRecord = record
        try write { db in
            try mutableRecord.update(db)
        }
        return mutableRecord
    }
    
    /// Delete records matching a condition
    func delete<T: TableRecord>(
        _ type: T.Type,
        where condition: @escaping (Database) throws -> Bool
    ) throws {
        try write { db in
            try type.deleteAll(db)
        }
    }
}
