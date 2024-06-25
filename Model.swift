//
// Model.swift
//
// Created by Speedyfriend67 on 25.06.24
//
 
import Foundation

struct Shortcut: Identifiable, Codable {
    var id = UUID()
    var name: String
    var actions: [Action]
}

struct Action: Identifiable, Codable {
    var id = UUID()
    var type: ActionType
    var parameters: [String: String]
}

enum ActionType: String, Codable, CaseIterable, Identifiable {
    case apiCall
    case showAlert
    case custom
    
    var id: String { self.rawValue }
}