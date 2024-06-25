//
// AddShortcutView.swift
//
// Created by Speedyfriend67 on 25.06.24
//
 
import SwiftUI

struct AddShortcutView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ShortcutViewModel
    @Binding var shortcut: Shortcut?
    
    @State private var shortcutName = ""
    @State private var actions: [Action] = []
    @State private var selectedActionType = ActionType.apiCall
    @State private var actionParameters = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Shortcut Details")) {
                    TextField("Shortcut Name", text: $shortcutName)
                }

                Section(header: Text("Actions")) {
                    Picker("Action Type", selection: $selectedActionType) {
                        ForEach(ActionType.allCases) { actionType in
                            Text(actionType.rawValue.capitalized).tag(actionType)
                        }
                    }
                    
                    TextField("Parameters (comma separated)", text: $actionParameters)

                    Button(action: addAction) {
                        Text("Add Action")
                    }

                    List {
                        ForEach(actions) { action in
                            VStack(alignment: .leading) {
                                Text(action.type.rawValue.capitalized)
                                    .font(.headline)
                                Text(action.parameters.description)
                                    .font(.subheadline)
                            }
                        }
                    }
                }

                Section {
                    Button(action: saveShortcut) {
                        Text("Save Shortcut")
                    }
                }
            }
            .navigationTitle(shortcut == nil ? "Add Shortcut" : "Edit Shortcut")
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Cancel")
            })
            .onAppear {
                if let shortcut = shortcut {
                    shortcutName = shortcut.name
                    actions = shortcut.actions
                }
            }
        }
    }
    
    func addAction() {
        let parameters = actionParameters.split(separator: ",").reduce(into: [String: String]()) { (dict, param) in
            let keyValue = param.split(separator: ":")
            if keyValue.count == 2 {
                dict[String(keyValue[0])] = String(keyValue[1])
            }
        }
        let newAction = Action(type: selectedActionType, parameters: parameters)
        actions.append(newAction)
        actionParameters = ""
    }
    
    func saveShortcut() {
        if var shortcut = shortcut {
            shortcut.name = shortcutName
            shortcut.actions = actions
            if let index = viewModel.shortcuts.firstIndex(where: { $0.id == shortcut.id }) {
                viewModel.shortcuts[index] = shortcut
            }
        } else {
            viewModel.addShortcut(name: shortcutName, actions: actions)
        }
        presentationMode.wrappedValue.dismiss()
    }
}