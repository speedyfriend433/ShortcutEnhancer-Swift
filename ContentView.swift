//
// ContentView.swift
//
// Created by Speedyfriend67 on 25.06.24
//
 
import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var viewModel = ShortcutViewModel()
    @State private var showAddShortcutView = false
    @State private var selectedShortcut: Shortcut?
    @StateObject private var locationManager = LocationManager()
    @StateObject private var batteryMonitor = BatteryMonitor()
    @StateObject private var cloudManager = CloudManager()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.shortcuts) { shortcut in
                    VStack(alignment: .leading) {
                        Text(shortcut.name)
                            .font(.headline)
                        ForEach(shortcut.actions) { action in
                            Text(action.type.rawValue)
                                .font(.subheadline)
                        }
                    }
                    .contextMenu {
                        Button(action: {
                            selectedShortcut = shortcut
                            showAddShortcutView = true
                        }) {
                            Text("Edit")
                            Image(systemName: "pencil")
                        }
                        Button(action: {
                            viewModel.deleteShortcut(shortcut)
                        }) {
                            Text("Delete")
                            Image(systemName: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Shortcuts")
            .navigationBarItems(trailing: HStack {
                Button(action: {
                    cloudManager.fetchShortcuts { shortcuts in
                        viewModel.shortcuts = shortcuts
                    }
                }) {
                    Image(systemName: "icloud.and.arrow.down")
                }
                Button(action: {
                    selectedShortcut = nil
                    showAddShortcutView.toggle()
                }) {
                    Image(systemName: "plus")
                }
            })
            .sheet(isPresented: $showAddShortcutView) {
                AddShortcutView(viewModel: viewModel, shortcut: $selectedShortcut)
            }
            .onAppear {
                checkTriggers()
            }
        }
    }
    
    func checkTriggers() {
        // 위치 기반 트리거
        if let location = locationManager.currentLocation {
            // 예시: 특정 위치에 도달했을 때 단축어 실행
            if location.distance(from: CLLocation(latitude: 37.7749, longitude: -122.4194)) < 100 {
                // 특정 단축어 실행
                if let shortcut = viewModel.shortcuts.first(where: { $0.name == "Location Trigger" }) {
                    viewModel.executeShortcut(shortcut)
                }
            }
        }

        // 배터리 상태 기반 트리거
        if batteryMonitor.batteryState == .unplugged && batteryMonitor.batteryLevel < 0.2 {
            // 예시: 배터리 잔량이 20% 미만일 때 단축어 실행
            if let shortcut = viewModel.shortcuts.first(where: { $0.name == "Low Battery Trigger" }) {
                viewModel.executeShortcut(shortcut)
            }
        }
    }
}