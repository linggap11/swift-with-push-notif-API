import UIKit
import WebKit
import UserNotifications

class ViewController: UIViewController, WKNavigationDelegate, UNUserNotificationCenterDelegate {
    
    let webView = WKWebView()
    let userNotificationCenter = UNUserNotificationCenter.current()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.userNotificationCenter.delegate = self
        self.requestNotificationAuthorization()
        self.sendNotification()
        
        webView.frame = view.bounds
        webView.navigationDelegate = self

        let url = URL(string: "https://swclient.site/mobile")!
        let urlRequest = URLRequest(url: url)

        webView.load(urlRequest)
        print(urlRequest)
        webView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        view.addSubview(webView)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated  {
            if let url = navigationAction.request.url,
                let host = url.host, !host.hasPrefix("swclient.site/mobile"),
                UIApplication.shared.canOpenURL(url) {
                if (!url.description.contains("swclient.site")) {
                    UIApplication.shared.open(url)
                } else {
                    let urlRequest = URLRequest(url: url)
                    webView.load(urlRequest)
                }
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
    
    func requestNotificationAuthorization() {
            // Code here
            let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
            self.userNotificationCenter.requestAuthorization(options: authOptions) { (success, error) in
                if let error = error {
                    print("Error: ", error)
                }
            }
        }

    func sendNotification() {
        // Code here
        let notificationContent = UNMutableNotificationContent()

        // Add the content to the notification content
        notificationContent.title = "Test"
        notificationContent.body = "Test body"
        notificationContent.badge = NSNumber(value: 3)

        // Add an attachment to the notification content
        if let url = Bundle.main.url(forResource: "dune",
                                        withExtension: "png") {
            if let attachment = try? UNNotificationAttachment(identifier: "dune",
                                                                url: url,
                                                                options: nil) {
                notificationContent.attachments = [attachment]
            }
        }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10,
                                                           repeats: false)
        let request = UNNotificationRequest(identifier: "testNotification",
                                           content: notificationContent,
                                           trigger: trigger)
       
        userNotificationCenter.add(request) { (error) in
           if let error = error {
               print("Notification Error: ", error)
           }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
    }
    
}
