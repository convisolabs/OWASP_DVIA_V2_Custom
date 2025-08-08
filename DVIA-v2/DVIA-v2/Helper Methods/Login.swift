import Foundation
import LocalAuthentication

class Login {
    
    var logged: Bool = false
        
    // Não há verificação se o dispositivo sofreu processo de jailbreak
    func appleBio() {
        var context = LAContext()
        var biometry = context.biometryType
        var error: NSError?        
    
        // Examina se o dispositivo tem permissão para usar a biometria
        var permissions = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
        
        if permissions {
            let reason = "Log in with Face ID"
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {              
                success, error in
                if success {
                    self.logged = true
                    return
                } else {
                    print("Authentication failed: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        } else {
            print("Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
        
    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths.first!
        return documentsDirectory
    }
    
    func dataFilePath() -> String {
        return documentsDirectory().appendingFormat("/userInfo.plist")
    }
    
    func performLogin(username: String, password: String) -> Bool {
        // Validação básica de entrada
        if username.isEmpty || password.isEmpty {
            print("❌ Error: One or more input fields is empty")
            return false
        }
        
        if username == "admin" && password == "password123" {
            self.logged = true
            
            // Salva credenciais no Info.plist
            saveCredentialsToInfoPlist(username: username, password: password)
            
            print("✅ Login successful")
            return true
        } else {
            print("❌ Invalid credentials")
            return false
        }
    }
    
    func saveCredentialsToInfoPlist(username: String, password: String) {
        let data = NSMutableDictionary()
        
        guard let username = username.isEmpty ? nil : username else { return }
        guard let password = password.isEmpty ? nil : password else { return }
        
        data.setValue(username, forKey: "username")
        data.setValue(password, forKey: "password")
        data.setValue(Date(), forKey: "LastLoginDate")
        data.setValue(true, forKey: "IsUserLoggedIn")
        
        // Salva no arquivo userInfo.plist no documents directory
        data.write(toFile: dataFilePath(), atomically: true)
        
        // Também salva no Info.plist do bundle
        saveToInfoPlist(username: username, password: password)
        
        print("📝 Credentials saved to Info.plist")
    }
    
    func saveToInfoPlist(username: String, password: String) {
        if let infoPlistPath = Bundle.main.path(forResource: "Info", ofType: "plist") {
            do {
                let infoPlistData = try Data(contentsOf: URL(fileURLWithPath: infoPlistPath))
                var infoPlist = try PropertyListSerialization.propertyList(from: infoPlistData, options: [], format: nil) as! [String: Any]
                
                infoPlist["StoredUsername"] = username
                infoPlist["StoredPassword"] = password
                infoPlist["LastLoginDate"] = Date()
                infoPlist["IsUserLoggedIn"] = true
                
                let newData = try PropertyListSerialization.data(fromPropertyList: infoPlist, format: .xml, options: 0)
                
                try newData.write(to: URL(fileURLWithPath: infoPlistPath))
                
                print("✅ Credentials saved to Info.plist successfully")
            } catch {
                print("❌ Error saving to Info.plist: \(error.localizedDescription)")
            }
        }
    }
    
    func retrieveStoredCredentials() -> (username: String?, password: String?) {
        if let infoPlistPath = Bundle.main.path(forResource: "Info", ofType: "plist") {
            do {
                let infoPlistData = try Data(contentsOf: URL(fileURLWithPath: infoPlistPath))
                let infoPlist = try PropertyListSerialization.propertyList(from: infoPlistData, options: [], format: nil) as! [String: Any]
                
                let username = infoPlist["StoredUsername"] as? String
                let password = infoPlist["StoredPassword"] as? String
                
                return (username, password)
            } catch {
                print("❌ Error reading Info.plist: \(error.localizedDescription)")
            }
        }
        
        return (nil, nil)
    }
}