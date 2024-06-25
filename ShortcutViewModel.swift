//
// ViewModel.swift
//
// Created by Speedyfriend67 on 25.06.24
//
 
import SwiftUI
import Combine

class ShortcutViewModel: ObservableObject {
    @Published var shortcuts: [Shortcut] = []
    private var cloudManager = CloudManager()

    init() {
        loadShortcuts()
    }
    
    func addShortcut(name: String, actions: [Action]) {
        let newShortcut = Shortcut(name: name, actions: actions)
        shortcuts.append(newShortcut)
        saveShortcuts()
        cloudManager.saveShortcut(newShortcut)
    }
    
    func saveShortcuts() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(shortcuts) {
            UserDefaults.standard.set(encoded, forKey: "shortcuts")
        }
    }
    
    func loadShortcuts() {
        let decoder = JSONDecoder()
        if let savedShortcuts = UserDefaults.standard.object(forKey: "shortcuts") as? Data {
            if let loadedShortcuts = try? decoder.decode([Shortcut].self, from: savedShortcuts) {
                shortcuts = loadedShortcuts
            }
        }
    }
    
    func deleteShortcut(_ shortcut: Shortcut) {
        shortcuts.removeAll { $0.id == shortcut.id }
        saveShortcuts()
    }

    func executeShortcut(_ shortcut: Shortcut) {
        for action in shortcut.actions {
            switch action.type {
            case .apiCall:
                if let url = action.parameters["url"] {
                    performAPICall(urlString: url) { result in
                        switch result {
                        case .success(let data):
                            print("API call success: \(data)")
                        case .failure(let error):
                            print("API call error: \(error)")
                        }
                    }
                }
            case .showAlert:
                if let message = action.parameters["message"] {
                    showAlert(message: message)
                }
            case .custom:
                // 커스텀 액션 처리
                break
            }
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            window.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func performAPICall(urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                completion(.success(data))
            }
        }
        
        task.resume()
    }
}