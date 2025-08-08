import Foundation
import LocalAuthentication

class LoginV2 {
    
    var logged: Bool = false
    var biometricsValid: Bool = false
    var biometricsChanged: Bool = false
    var isJailbroken: Bool = false
    
    func appleBioWithValidation() {
        var context = LAContext()
        var biometry = context.biometryType
        var error: NSError?
        
        // Verifica se a biometria foi alterada usando a extension LAContext
        self.biometricsChanged = LAContext.biometricsChanged()
        
        // Examina se o dispositivo tem permissão para usar a biometria
        var permissions = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
        
        if permissions {
            // Se a biometria foi alterada, considera inválida
            if self.biometricsChanged {
                print("⚠️ Biometric configuration has changed - authentication required")
                self.biometricsValid = false
                self.logged = false
                return
            }
            
            let reason = "Log in with Face ID"
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                success, error in
                if success {
                    self.logged = true
                    self.biometricsValid = true
                    print("✅ Authentication successful - biometrics validated")
                } else {
                    self.logged = false
                    self.biometricsValid = false
                    print("❌ Authentication failed: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        } else {
            self.logged = false
            self.biometricsValid = false
            print("❌ Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
        
    func checkJailbreakStatus() {
        // Implementação da Biblioteca iOS Security Suite para detecção de jailbreak
        self.isJailbroken = JailbreakDetection.isJailbroken()
        
        if self.isJailbroken {
            print("🚨 Device is Jailbroken - Security risk detected!")
            self.logged = false
            self.biometricsValid = false
        } else {
            print("✅ Device is Not Jailbroken - Security status: Normal")
        }
    }
    
    func authenticateWithJailbreakCheck() {
        // Verifica jailbreak antes de prosseguir com autenticação
        checkJailbreakStatus()
        
        if self.isJailbroken {
            print("⚠️ Authentication blocked due to jailbreak detection")
            return
        }
        
        // Prossegue com autenticação biométrica normal
        appleBioWithValidation()
    }

}
