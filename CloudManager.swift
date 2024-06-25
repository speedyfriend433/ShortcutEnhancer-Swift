//
// CloudManager.swift
//
// Created by Speedyfriend67 on 25.06.24
//
 
import CloudKit
import Combine

class CloudManager: ObservableObject {
    private var database: CKDatabase

    init() {
        let container = CKContainer.default()
        self.database = container.privateCloudDatabase
    }

    func saveShortcut(_ shortcut: Shortcut) {
        let record = CKRecord(recordType: "Shortcut")
        record["name"] = shortcut.name
        record["actions"] = try! JSONEncoder().encode(shortcut.actions)

        database.save(record) { record, error in
            if let error = error {
                print("Error saving in CloudKit: \(error.localizedDescription)")
            }
        }
    }

    func fetchShortcuts(completion: @escaping ([Shortcut]) -> Void) {
        let query = CKQuery(recordType: "Shortcut", predicate: NSPredicate(value: true))
        let operation = CKQueryOperation(query: query)
        
        var fetchedRecords: [CKRecord] = []
        
        operation.recordMatchedBlock = { recordID, recordResult in
            switch recordResult {
            case .success(let record):
                fetchedRecords.append(record)
            case .failure(let error):
                print("Error while importing records: \(error.localizedDescription)")
            }
        }
        
        operation.queryResultBlock = { result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                print("Error importing from CloudKit: \(error.localizedDescription)")
                completion([])
                return
            }
            
            let shortcuts = fetchedRecords.compactMap { record -> Shortcut? in
                guard let name = record["name"] as? String,
                      let actionsData = record["actions"] as? Data,
                      let actions = try? JSONDecoder().decode([Action].self, from: actionsData) else {
                    return nil
                }
                return Shortcut(name: name, actions: actions)
            }
            completion(shortcuts)
        }
        
        database.add(operation)
    }
}
