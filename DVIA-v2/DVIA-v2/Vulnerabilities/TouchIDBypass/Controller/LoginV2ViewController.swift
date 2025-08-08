//
//  LoginV2ViewController.swift
//  DVIA - Damn Vulnerable iOS App (damnvulnerableiosapp.com)
//  Created by AppSec Analyst on 08/08/25.
//  Copyright © 2025 HighAltitudeHacks. All rights reserved.
//  You are free to use this app for commercial or non-commercial purposes
//  You are also allowed to use this in trainings
//  However, if you benefit from this project and want to make a contribution, please consider making a donation to The Juniper Fund (www.thejuniperfund.org/)
//  The Juniper fund is focusing on Nepali workers involved with climbing and expedition support in the high mountains of Nepal. When a high altitude worker has an accident (death or debilitating injury), the impact to the family is huge. The juniper fund provides funds to the affected families and help them set up a sustainable business.
//  For more information,  visit www.thejuniperfund.org
//  Or watch this video https://www.youtube.com/watch?v=HsV6jaA5J2I
//  And this https://www.youtube.com/watch?v=6dHXcoF590E
//

import UIKit
import LocalAuthentication

class LoginV2ViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var validateButton: UIButton!
    @IBOutlet weak var forceValidationButton: UIButton!
    @IBOutlet weak var bypassButton: UIButton!
    @IBOutlet weak var simulateChangeButton: UIButton!
    @IBOutlet weak var jailbreakTestButton: UIButton!
    @IBOutlet weak var secureAuthButton: UIButton!
    @IBOutlet weak var bypassJailbreakButton: UIButton!
    @IBOutlet weak var simulateJailbreakButton: UIButton!
    @IBOutlet weak var resultTextView: UITextView!
    
    private let loginManager = LoginV2()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Login V2 - Enhanced Security"
        setupUI()
    }
    
    private func setupUI() {
        statusLabel.text = "Ready to authenticate with enhanced security"
        statusLabel.textColor = UIColor.darkGray
        
        resultTextView.layer.borderColor = UIColor.lightGray.cgColor
        resultTextView.layer.borderWidth = 1.0
        resultTextView.layer.cornerRadius = 5.0
        resultTextView.isEditable = false
        resultTextView.text = "Login V2 with enhanced security results will appear here..."
        
        loginButton.setTitle("Login with Biometric Validation", for: .normal)
        validateButton.setTitle("Validate Biometrics State", for: .normal)
        forceValidationButton.setTitle("Force Biometric Validation", for: .normal)
        bypassButton.setTitle("Bypass Validation (Vulnerable)", for: .normal)
        simulateChangeButton.setTitle("Simulate Biometric Change", for: .normal)
        jailbreakTestButton.setTitle("Jailbreak Test 4", for: .normal)
        secureAuthButton.setTitle("Secure Authentication", for: .normal)
        bypassJailbreakButton.setTitle("Bypass Jailbreak (Vulnerable)", for: .normal)
        simulateJailbreakButton.setTitle("Simulate Jailbreak", for: .normal)
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        authenticateWithValidation()
    }
    
    @IBAction func validateButtonTapped(_ sender: Any) {
        validateBiometricsState()
    }
    
    @IBAction func forceValidationButtonTapped(_ sender: Any) {
        forceBiometricValidation()
    }
    
    @IBAction func bypassButtonTapped(_ sender: Any) {
        attemptBypass()
    }
    
    @IBAction func simulateChangeButtonTapped(_ sender: Any) {
        simulateBiometricChange()
    }
    
    @IBAction func jailbreakTestButtonTapped(_ sender: Any) {
        performJailbreakTest()
    }
    
    @IBAction func secureAuthButtonTapped(_ sender: Any) {
        performSecureAuthentication()
    }
    
    @IBAction func bypassJailbreakButtonTapped(_ sender: Any) {
        attemptJailbreakBypass()
    }
    
    @IBAction func simulateJailbreakButtonTapped(_ sender: Any) {
        simulateJailbreak()
    }
    
    // MARK: - Authentication with Validation Implementation
    
    func authenticateWithValidation() {
        statusLabel.text = "Authenticating with validation..."
        statusLabel.textColor = UIColor.orange
        resultTextView.text = "Initiating biometric authentication with validation..."
        
        // Use the LoginV2 class with appleBioWithValidation() function
        loginManager.appleBioWithValidation()
        
        // Check authentication result after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.checkAuthenticationResult()
        }
    }
    
    func checkAuthenticationResult() {
        let status = loginManager.getSecurityStatus()
        
        if status.logged && status.biometricsValid {
            statusLabel.text = "Authentication Successful!"
            statusLabel.textColor = UIColor.green
            resultTextView.text = """
                ✅ Authentication successful with biometric validation!
                
                Security Status:
                - Logged: \(status.logged)
                - Biometrics Valid: \(status.biometricsValid)
                - Biometrics Changed: \(status.biometricsChanged)
                - Jailbroken: \(status.isJailbroken)
                
                This demonstrates:
                - Proper biometric authentication
                - Biometric change detection
                - Validation of biometric state
                - Secure authentication flow
                
                The LoginV2 class successfully validated biometrics.
                """
        } else if status.biometricsChanged {
            statusLabel.text = "Biometric Changes Detected!"
            statusLabel.textColor = UIColor.red
            resultTextView.text = """
                ⚠️ Biometric changes detected - authentication blocked!
                
                Security Status:
                - Logged: \(status.logged)
                - Biometrics Valid: \(status.biometricsValid)
                - Biometrics Changed: \(status.biometricsChanged)
                - Jailbroken: \(status.isJailbroken)
                
                This indicates:
                - New fingerprints were added/removed
                - Face ID was reconfigured
                - Touch ID was reconfigured
                - Re-authentication required
                
                Security measure: Authentication blocked due to biometric changes.
                """
        } else {
            statusLabel.text = "Authentication Failed"
            statusLabel.textColor = UIColor.red
            resultTextView.text = """
                ❌ Authentication failed!
                
                Security Status:
                - Logged: \(status.logged)
                - Biometrics Valid: \(status.biometricsValid)
                - Biometrics Changed: \(status.biometricsChanged)
                - Jailbroken: \(status.isJailbroken)
                
                Possible reasons:
                - User cancelled authentication
                - Too many failed attempts
                - Biometric hardware not available
                - Permission denied
                
                The LoginV2 class properly handled the failure.
                """
        }
    }
    
    // MARK: - Biometric State Validation
    
    func validateBiometricsState() {
        statusLabel.text = "Validating biometric state..."
        statusLabel.textColor = UIColor.orange
        resultTextView.text = "Checking biometric configuration state..."
        
        let isValid = loginManager.validateBiometricsState()
        let status = loginManager.getSecurityStatus()
        
        DispatchQueue.main.async {
            if isValid {
                self.statusLabel.text = "Biometrics State Valid"
                self.statusLabel.textColor = UIColor.green
                self.resultTextView.text = """
                    ✅ Biometric state validation successful!
                    
                    Security Status:
                    - Logged: \(status.logged)
                    - Biometrics Valid: \(status.biometricsValid)
                    - Biometrics Changed: \(status.biometricsChanged)
                    - Jailbroken: \(status.isJailbroken)
                    
                    This indicates:
                    - Biometric configuration is unchanged
                    - No new fingerprints were added
                    - No existing fingerprints were removed
                    - Face ID/Touch ID configuration is stable
                    
                    The biometric state is considered valid for authentication.
                    """
            } else {
                self.statusLabel.text = "Biometrics State Invalid"
                self.statusLabel.textColor = UIColor.red
                self.resultTextView.text = """
                    ⚠️ Biometric state validation failed!
                    
                    Security Status:
                    - Logged: \(status.logged)
                    - Biometrics Valid: \(status.biometricsValid)
                    - Biometrics Changed: \(status.biometricsChanged)
                    - Jailbroken: \(status.isJailbroken)
                    
                    This indicates:
                    - Biometric configuration has changed
                    - Re-authentication is required
                    - Previous biometric state is no longer valid
                    
                    Security measure: Authentication blocked due to state changes.
                    """
            }
        }
    }
    
    func forceBiometricValidation() {
        statusLabel.text = "Forcing biometric validation..."
        statusLabel.textColor = UIColor.orange
        resultTextView.text = "Forcing a fresh biometric validation..."
        
        loginManager.forceBiometricValidation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let status = self.loginManager.getSecurityStatus()
            
            self.statusLabel.text = "Forced Validation Complete"
            self.statusLabel.textColor = UIColor.blue
            self.resultTextView.text = """
                🔄 Forced biometric validation completed!
                
                Security Status:
                - Logged: \(status.logged)
                - Biometrics Valid: \(status.biometricsValid)
                - Biometrics Changed: \(status.biometricsChanged)
                - Jailbroken: \(status.isJailbroken)
                
                This action:
                - Cleared saved biometric state
                - Forced fresh validation
                - Established new baseline
                
                Useful for:
                - Testing biometric detection
                - Resetting validation state
                - Development and debugging
                """
        }
    }
    
    // MARK: - Jailbreak Detection Implementation
    
    func performJailbreakTest() {
        statusLabel.text = "Performing Jailbreak Test 4..."
        statusLabel.textColor = UIColor.orange
        resultTextView.text = "Testing device jailbreak status using iOS Security Suite..."
        
        loginManager.jailbreakTest4Tapped()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let status = self.loginManager.getSecurityStatus()
            
            if status.isJailbroken {
                self.statusLabel.text = "Jailbreak Detected!"
                self.statusLabel.textColor = UIColor.red
                self.resultTextView.text = """
                    🚨 Device is Jailbroken!
                    
                    Security Status:
                    - Logged: \(status.logged)
                    - Biometrics Valid: \(status.biometricsValid)
                    - Biometrics Changed: \(status.biometricsChanged)
                    - Jailbroken: \(status.isJailbroken)
                    
                    This indicates:
                    - Device has been jailbroken
                    - Security measures may be compromised
                    - App will exit in 5 seconds
                    - iOS Security Suite detected jailbreak
                    
                    Security measure: App termination due to jailbreak detection.
                    """
                
                // Simula saída do app após 5 segundos
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    self.showJailbreakAlert()
                }
            } else {
                self.statusLabel.text = "Device Not Jailbroken"
                self.statusLabel.textColor = UIColor.green
                self.resultTextView.text = """
                    ✅ Device is Not Jailbroken
                    
                    Security Status:
                    - Logged: \(status.logged)
                    - Biometrics Valid: \(status.biometricsValid)
                    - Biometrics Changed: \(status.biometricsChanged)
                    - Jailbroken: \(status.isJailbroken)
                    
                    This indicates:
                    - Device security is intact
                    - No jailbreak detected
                    - iOS Security Suite validation passed
                    - Device is safe for authentication
                    
                    Security status: Normal
                    """
                
                self.showNormalDeviceAlert()
            }
        }
    }
    
    func showJailbreakAlert() {
        let alert = UIAlertController(title: "", message: "Device is Jailbroken, Exiting!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            print("🚨 Exiting app due to jailbreak detection")
            exit(0)
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func showNormalDeviceAlert() {
        let alert = UIAlertController(title: "", message: "Device is Not Jailbroken", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func performSecureAuthentication() {
        statusLabel.text = "Performing Secure Authentication..."
        statusLabel.textColor = UIColor.orange
        resultTextView.text = "Initiating comprehensive security check with jailbreak detection..."
        
        loginManager.performSecureAuthentication()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let status = self.loginManager.getSecurityStatus()
            
            if status.logged && status.biometricsValid && !status.isJailbroken {
                self.statusLabel.text = "Secure Authentication Successful!"
                self.statusLabel.textColor = UIColor.green
                self.resultTextView.text = """
                    ✅ Secure authentication completed successfully!
                    
                    Security Status:
                    - Logged: \(status.logged)
                    - Biometrics Valid: \(status.biometricsValid)
                    - Biometrics Changed: \(status.biometricsChanged)
                    - Jailbroken: \(status.isJailbroken)
                    
                    All security checks passed:
                    ✅ Jailbreak detection: Passed
                    ✅ Biometric validation: Passed
                    ✅ Authentication: Successful
                    
                    This demonstrates comprehensive security implementation.
                    """
            } else if status.isJailbroken {
                self.statusLabel.text = "Authentication Blocked - Jailbreak Detected"
                self.statusLabel.textColor = UIColor.red
                self.resultTextView.text = """
                    ❌ Authentication blocked due to jailbreak detection!
                    
                    Security Status:
                    - Logged: \(status.logged)
                    - Biometrics Valid: \(status.biometricsValid)
                    - Biometrics Changed: \(status.biometricsChanged)
                    - Jailbroken: \(status.isJailbroken)
                    
                    Security measure: Authentication blocked due to jailbreak detection.
                    """
            } else {
                self.statusLabel.text = "Secure Authentication Failed"
                self.statusLabel.textColor = UIColor.red
                self.resultTextView.text = """
                    ❌ Secure authentication failed!
                    
                    Security Status:
                    - Logged: \(status.logged)
                    - Biometrics Valid: \(status.biometricsValid)
                    - Biometrics Changed: \(status.biometricsChanged)
                    - Jailbroken: \(status.isJailbroken)
                    
                    Possible reasons:
                    - Biometric authentication failed
                    - Device security compromised
                    - User cancelled authentication
                    
                    The comprehensive security check properly handled the failure.
                    """
            }
        }
    }
    
    // MARK: - Bypass Attempt (for educational purposes)
    
    func attemptBypass() {
        statusLabel.text = "Attempting Bypass..."
        statusLabel.textColor = UIColor.orange
        resultTextView.text = """
            🔍 Attempting to bypass biometric validation...
            
            This demonstrates potential vulnerabilities:
            - Direct access to LoginV2 properties
            - Possible manipulation of validation state
            - Runtime modification of biometric checks
            - Memory inspection opportunities
            
            For educational purposes only!
            """
        
        loginManager.bypassBiometricValidation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.simulateBypass()
        }
    }
    
    func simulateBypass() {
        let status = loginManager.getSecurityStatus()
        
        statusLabel.text = "Bypass Attempted"
        statusLabel.textColor = UIColor.red
        resultTextView.text = """
            ⚠️ Bypass simulation completed!
            
            Security Status:
            - Logged: \(status.logged)
            - Biometrics Valid: \(status.biometricsValid)
            - Biometrics Changed: \(status.biometricsChanged)
            - Jailbroken: \(status.isJailbroken)
            
            In a real scenario, an attacker might:
            1. Use runtime manipulation tools (Frida, Cycript)
            2. Modify LoginV2 properties directly
            3. Hook the validateBiometricsState() method
            4. Bypass the biometric change detection
            5. Manipulate the LAContext extension
            
            Vulnerabilities demonstrated:
            - Direct property manipulation
            - Method hooking possibilities
            - State bypass capabilities
            - No integrity checks on validation
            
            This demonstrates why additional security layers are needed!
            """
    }
    
    func attemptJailbreakBypass() {
        statusLabel.text = "Attempting Jailbreak Bypass..."
        statusLabel.textColor = UIColor.orange
        resultTextView.text = """
            🔍 Attempting to bypass jailbreak detection...
            
            This demonstrates potential vulnerabilities:
            - Direct access to jailbreak detection methods
            - Possible manipulation of iOS Security Suite
            - Runtime modification of security checks
            - Memory inspection opportunities
            
            For educational purposes only!
            """
        
        loginManager.bypassJailbreakDetection()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let status = self.loginManager.getSecurityStatus()
            
            self.statusLabel.text = "Jailbreak Bypass Attempted"
            self.statusLabel.textColor = UIColor.red
            self.resultTextView.text = """
                ⚠️ Jailbreak bypass simulation completed!
                
                Security Status:
                - Logged: \(status.logged)
                - Biometrics Valid: \(status.biometricsValid)
                - Biometrics Changed: \(status.biometricsChanged)
                - Jailbroken: \(status.isJailbroken)
                
                In a real scenario, an attacker might:
                1. Use runtime manipulation tools (Frida, Cycript)
                2. Hook the JailbreakDetection.isJailbroken() method
                3. Modify the isJailbroken property directly
                4. Bypass the iOS Security Suite entirely
                5. Manipulate the jailbreak detection logic
                
                Vulnerabilities demonstrated:
                - Direct property manipulation
                - Method hooking possibilities
                - iOS Security Suite bypass
                - No integrity checks on detection
                
                This demonstrates why additional security layers are needed!
                """
        }
    }
    
    // MARK: - Biometric Change Simulation
    
    func simulateBiometricChange() {
        statusLabel.text = "Simulating Biometric Change..."
        statusLabel.textColor = UIColor.orange
        resultTextView.text = "Simulating a change in biometric configuration..."
        
        loginManager.simulateBiometricChange()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let status = self.loginManager.getSecurityStatus()
            
            self.statusLabel.text = "Change Simulation Complete"
            self.statusLabel.textColor = UIColor.blue
            self.resultTextView.text = """
                🔄 Biometric change simulation completed!
                
                Security Status:
                - Logged: \(status.logged)
                - Biometrics Valid: \(status.biometricsValid)
                - Biometrics Changed: \(status.biometricsChanged)
                - Jailbroken: \(status.isJailbroken)
                
                This simulation:
                - Cleared saved biometric state
                - Triggered change detection
                - Demonstrated validation mechanism
                
                Educational value:
                - Shows how biometric changes are detected
                - Demonstrates security measures
                - Illustrates validation process
                """
        }
    }
    
    func simulateJailbreak() {
        statusLabel.text = "Simulating Jailbreak..."
        statusLabel.textColor = UIColor.orange
        resultTextView.text = "Simulating a jailbroken device for testing purposes..."
        
        loginManager.simulateJailbreak()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let status = self.loginManager.getSecurityStatus()
            
            self.statusLabel.text = "Jailbreak Simulation Complete"
            self.statusLabel.textColor = UIColor.blue
            self.resultTextView.text = """
                🔄 Jailbreak simulation completed!
                
                Security Status:
                - Logged: \(status.logged)
                - Biometrics Valid: \(status.biometricsValid)
                - Biometrics Changed: \(status.biometricsChanged)
                - Jailbroken: \(status.isJailbroken)
                
                This simulation:
                - Set device as jailbroken
                - Triggered security warnings
                - Demonstrated detection mechanism
                
                Educational value:
                - Shows how jailbreak detection works
                - Demonstrates security measures
                - Illustrates iOS Security Suite usage
                """
        }
    }
    
    // MARK: - Additional Security Methods (for comparison)
    
    func demonstrateSecureImplementation() {
        resultTextView.text = """
            🔒 Secure Implementation Example:
            
            A more secure approach would include:
            1. Server-side validation of biometric state
            2. Encrypted storage of biometric state
            3. Integrity checks on validation data
            4. Additional authentication factors
            5. Rate limiting for validation attempts
            6. Anti-tampering measures
            7. Enhanced jailbreak detection
            8. Runtime integrity checks
            9. Certificate pinning for API calls
            10. Secure enclave usage
            11. iOS Security Suite integration
            12. Multiple jailbreak detection methods
            
            The current implementation is vulnerable to:
            - Runtime manipulation of LoginV2 properties
            - Method hooking on validation functions
            - Memory inspection of biometric state
            - Direct bypass of validation logic
            - UserDefaults manipulation
            - iOS Security Suite bypass
            - Jailbreak detection bypass
            """
    }
}
