import Foundation
import LocalAuthentication

extension LAContext {
    // Guarda o estado da política de biometria
    static var savedBiometricsPolicyState: Data? {
        get {
            UserDefaults.standard.data(forKey: "BiometricsPolicyState")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "BiometricsPolicyState")
        }
    }
    
    // Verifica se a política de biometria foi alterada
    static func biometricsChanged() -> Bool {
        let context = LAContext()
        var error: NSError?
        context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        // Se não houver erro e o estado da política de biometria não foi alterado, retorna false
        if error == nil && LAContext.savedBiometricsPolicyState == nil {
            LAContext.savedBiometricsPolicyState = context.evaluatedPolicyDomainState
            return false
        }

        // Se houver erro ou o estado da política de biometria foi alterado, retorna true
        if let domainState = context.evaluatedPolicyDomainState, domainState != LAContext.savedBiometricsPolicyState {
            return true
        }
        
        return false
    }
}