//
// BatteryMonitor.swift
//
// Created by Speedyfriend67 on 25.06.24
//
 
import Combine
import UIKit

class BatteryMonitor: ObservableObject {
    @Published var batteryLevel: Float
    @Published var batteryState: UIDevice.BatteryState

    init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        batteryLevel = UIDevice.current.batteryLevel
        batteryState = UIDevice.current.batteryState

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryLevelDidChange),
            name: UIDevice.batteryLevelDidChangeNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryStateDidChange),
            name: UIDevice.batteryStateDidChangeNotification,
            object: nil
        )
    }

    @objc private func batteryLevelDidChange() {
        batteryLevel = UIDevice.current.batteryLevel
    }

    @objc private func batteryStateDidChange() {
        batteryState = UIDevice.current.batteryState
    }
}