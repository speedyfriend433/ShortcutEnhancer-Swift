//
// TriggerNotif.swift
//
// Created by Speedyfriend67 on 25.06.24
//
 
import UserNotifications

extension ShortcutViewModel {
    func scheduleTimeTriggerShortcut(shortcut: Shortcut, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Shortcut Trigger"
        content.body = "Your shortcut is ready to run"
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}