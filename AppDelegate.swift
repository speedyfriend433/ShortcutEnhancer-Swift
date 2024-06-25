import SwiftUI
import CloudKit

@main
struct SCEnhancerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var locationManager = LocationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    locationManager.requestAuthorization()
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        let container = CKContainer.default()
        
        container.accountStatus { status, error in
            if let error = error {
                print("Error occured while checking iCloud account status: \(error.localizedDescription)")
                return
            }
            
            switch status {
            case .available:
                print("iCloud account is available")
            case .noAccount:
                print("No iCloud account")
            case .restricted:
                print("iCloud account restricted")
            case .couldNotDetermine:
                print("Unable to check iCloud account status")
            case .temporarilyUnavailable:
                print("iCloud account temporarily disabled")
            @unknown default:
                print("Unknown iCloud account status")
            }
        }

        return true
    }
}
