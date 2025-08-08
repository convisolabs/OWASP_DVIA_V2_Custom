//
//  BiometricChangeDetectionViewController.swift
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

class BiometricChangeDetectionViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var bypassButton: UIButton!
    @IBOutlet weak var resultTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Biometric Change Detection"
        setupUI()
    }
    
    private func setupUI() {
        statusLabel.text = "Ready to check biometric changes"
        statusLabel.textColor = UIColor.darkGray
        
        resultTextView.layer.borderColor = UIColor.lightGray.cgColor
        resultTextView.layer.borderWidth = 1.0
        resultTextView.layer.cornerRadius = 5.0
        resultTextView.isEditable = false
        resultTextView.text = "Biometric change detection results will appear here..."
        
        checkButton.setTitle("Check Biometric Changes", for: .normal)
        resetButton.setTitle("Reset Saved State", for: .normal)
        bypassButton.setTitle("Bypass Detection", for: .normal)
    }
    
    @IBAction func checkButtonTapped(_ sender: Any) {
        checkBiometricChanges()
    }
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        resetSavedState()
    }
    
    @IBAction func bypassButtonTapped(_ sender: Any) {
        attemptBypass()
    }
    
    // MARK: - Biometric Change Detection Implementation
    
    func checkBiometricChanges() {
        statusLabel.text = "Checking biometric changes..."
        statusLabel.textColor = UIColor.orange
        resultTextView.text = "Analyzing biometric policy domain state..."
        
        // Use the LAContext extension with biometricsChanged() function
        let hasChanged = LAContext.biometricsChanged()
        
        DispatchQueue.main.async {
            if hasChanged {
                self.statusLabel.text = "Biometric Changes Detected!"
                self.statusLabel.textColor = UIColor.red
                self.resultTextView.text = """
                    ⚠️ Biometric changes detected!
                    
                    This indicates that:
                    - New fingerprints were added to the device
                    - Existing fingerprints were removed
                    - Face ID was reconfigured
                    - Touch ID was reconfigured
                    
                    Security implications:
                    - Previous biometric authentication may be compromised
                    - User should re-authenticate
                    - Consider additional security measures
                    
                    The biometricsChanged() function returned: true
                    """
            } else {
                self.statusLabel.text = "No Biometric Changes"
                self.statusLabel.textColor = UIColor.green
                self.resultTextView.text = """
                    ✅ No biometric changes detected
                    
                    This indicates that:
                    - Biometric configuration is unchanged
                    - No new fingerprints were added
                    - No existing fingerprints were removed
                    - Face ID/Touch ID configuration is stable
                    
                    Security status: Normal
                    The biometricsChanged() function returned: false
                    """
            }
        }
    }
    
    func resetSavedState() {
        statusLabel.text = "Resetting saved state..."
        statusLabel.textColor = UIColor.orange
        resultTextView.text = "Clearing saved biometric policy state..."
        
        // Clear the saved biometric policy state
        LAContext.savedBiometricsPolicyState = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.statusLabel.text = "State Reset Complete"
            self.statusLabel.textColor = UIColor.blue
            self.resultTextView.text = """
                🔄 Saved biometric state has been reset
                
                This action:
                - Clears the saved biometric policy domain state
                - Forces a fresh baseline on next check
                - Simulates first-time setup
                
                Next biometric change check will:
                - Save the current state as baseline
                - Return false (no changes detected)
                
                This is useful for testing and development purposes.
                """
        }
    }
    
    // MARK: - Bypass Attempt (for educational purposes)
    
    func attemptBypass() {
        statusLabel.text = "Attempting Bypass..."
        statusLabel.textColor = UIColor.orange
        resultTextView.text = """
            🔍 Attempting to bypass biometric change detection...
            
            This demonstrates potential vulnerabilities:
            - Direct access to UserDefaults key "BiometricsPolicyState"
            - Possible manipulation of saved state
            - Runtime modification of domain state
            - Memory inspection opportunities
            
            For educational purposes only!
            """
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.simulateBypass()
        }
    }
    
    func simulateBypass() {
        statusLabel.text = "Bypass Attempted"
        statusLabel.textColor = UIColor.red
        resultTextView.text = """
            ⚠️ Bypass simulation completed!
            
            In a real scenario, an attacker might:
            1. Use runtime manipulation tools (Frida, Cycript)
            2. Modify UserDefaults key "BiometricsPolicyState" directly
            3. Hook the biometricsChanged() function
            4. Manipulate the evaluatedPolicyDomainState
            5. Bypass the change detection entirely
            
            Vulnerabilities demonstrated:
            - UserDefaults storage is not encrypted by default
            - Static function can be hooked
            - Domain state can be manipulated
            - No integrity checks on saved state
            
            This demonstrates why additional security layers are needed!
            """
    }
    
    // MARK: - Additional Security Methods (for comparison)
    
    func demonstrateSecureImplementation() {
        resultTextView.text = """
            🔒 Secure Implementation Example:
            
            A more secure approach would include:
            1. Encrypted storage of biometric state
            2. Integrity checks on saved data
            3. Server-side validation of biometric changes
            4. Additional authentication factors
            5. Rate limiting for change detection
            6. Anti-tampering measures
            7. Jailbreak detection
            8. Runtime integrity checks
            
            The current implementation is vulnerable to:
            - UserDefaults manipulation
            - Runtime hooking
            - Memory inspection
            - Direct state modification
            - Bypass of change detection
            """
    }
    
    // MARK: - Utility Methods for Testing
    
    func showCurrentState() {
        let currentState = LAContext.savedBiometricsPolicyState
        let hasState = currentState != nil
        
        resultTextView.text = """
            📊 Current Biometric State Information:
            
            Saved State Exists: \(hasState ? "Yes" : "No")
            State Data Size: \(currentState?.count ?? 0) bytes
            
            UserDefaults Key: "BiometricsPolicyState"
            Storage Location: UserDefaults.standard
            
            This information can be useful for:
            - Debugging biometric detection
            - Understanding state persistence
            - Security analysis
            - Testing bypass techniques
            """
    }
}
