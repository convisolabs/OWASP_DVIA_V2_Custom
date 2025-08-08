//
//  LoginViewController.swift
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

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var biometricButton: UIButton!
    @IBOutlet weak var retrieveButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var bypassButton: UIButton!
    @IBOutlet weak var insecureButton: UIButton!
    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var statusLabel: UILabel!
    
    private let loginManager = Login()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Login - Info.plist Storage"
        setupUI()
    }
    
    private func setupUI() {
        statusLabel.text = "Ready to login with Info.plist storage"
        statusLabel.textColor = UIColor.darkGray
        
        resultTextView.layer.borderColor = UIColor.lightGray.cgColor
        resultTextView.layer.borderWidth = 1.0
        resultTextView.layer.cornerRadius = 5.0
        resultTextView.isEditable = false
        resultTextView.text = "Login with Info.plist storage results will appear here..."
        
        usernameTextField.placeholder = "Username"
        passwordTextField.placeholder = "Password"
        passwordTextField.isSecureTextEntry = true
        
        loginButton.setTitle("Login", for: .normal)
        biometricButton.setTitle("Biometric Login", for: .normal)
        retrieveButton.setTitle("Retrieve Credentials", for: .normal)
        clearButton.setTitle("Clear Credentials", for: .normal)
        bypassButton.setTitle("Bypass Login (Vulnerable)", for: .normal)
        insecureButton.setTitle("Store Insecurely (Vulnerable)", for: .normal)
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        performLogin()
    }
    
    @IBAction func biometricButtonTapped(_ sender: Any) {
        performBiometricLogin()
    }
    
    @IBAction func retrieveButtonTapped(_ sender: Any) {
        retrieveCredentials()
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        clearCredentials()
    }
    
    @IBAction func bypassButtonTapped(_ sender: Any) {
        attemptBypass()
    }
    
    @IBAction func insecureButtonTapped(_ sender: Any) {
        storeInsecurely()
    }
    
    // MARK: - Login Implementation
    
    func performLogin() {
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            showAlert(title: "Error", message: "One or more input fields is empty")
            return
        }
        
        statusLabel.text = "Performing login..."
        statusLabel.textColor = UIColor.orange
        resultTextView.text = "Attempting login with credentials..."
        
        let success = loginManager.performLogin(username: username, password: password)
        
        DispatchQueue.main.async {
            if success {
                self.statusLabel.text = "Login Successful!"
                self.statusLabel.textColor = UIColor.green
                self.resultTextView.text = """
                    ✅ Login successful!
                    
                    Credentials saved to Info.plist:
                    - Username: \(username)
                    - Password: \(password)
                    - Last Login Date: \(Date())
                    - Login Status: Active
                    
                    Security Status:
                    - Credentials stored in Info.plist
                    - Login state: \(self.loginManager.logged)
                    - User logged in: \(self.loginManager.isUserLoggedIn())
                    
                    Note: Credentials are stored in plain text in Info.plist
                    This demonstrates insecure credential storage.
                    """
            } else {
                self.statusLabel.text = "Login Failed"
                self.statusLabel.textColor = UIColor.red
                self.resultTextView.text = """
                    ❌ Login failed!
                    
                    Possible reasons:
                    - Invalid username/password
                    - Empty input fields
                    - Authentication error
                    
                    Try using:
                    - Username: admin
                    - Password: password123
                    
                    Security Status:
                    - Login state: \(self.loginManager.logged)
                    - User logged in: \(self.loginManager.isUserLoggedIn())
                    """
            }
        }
    }
    
    func performBiometricLogin() {
        statusLabel.text = "Performing biometric login..."
        statusLabel.textColor = UIColor.orange
        resultTextView.text = "Initiating biometric authentication..."
        
        loginManager.appleBio()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.loginManager.logged {
                self.statusLabel.text = "Biometric Login Successful!"
                self.statusLabel.textColor = UIColor.green
                self.resultTextView.text = """
                    ✅ Biometric authentication successful!
                    
                    Security Status:
                    - Login state: \(self.loginManager.logged)
                    - Biometric authentication: Passed
                    - User logged in: \(self.loginManager.isUserLoggedIn())
                    
                    Note: Biometric login doesn't store credentials in Info.plist
                    This is more secure than password-based login.
                    """
            } else {
                self.statusLabel.text = "Biometric Login Failed"
                self.statusLabel.textColor = UIColor.red
                self.resultTextView.text = """
                    ❌ Biometric authentication failed!
                    
                    Possible reasons:
                    - User cancelled authentication
                    - Too many failed attempts
                    - Biometric hardware not available
                    - Permission denied
                    
                    Security Status:
                    - Login state: \(self.loginManager.logged)
                    - Biometric authentication: Failed
                    - User logged in: \(self.loginManager.isUserLoggedIn())
                    """
            }
        }
    }
    
    // MARK: - Credential Management
    
    func retrieveCredentials() {
        statusLabel.text = "Retrieving credentials..."
        statusLabel.textColor = UIColor.orange
        resultTextView.text = "Reading stored credentials from Info.plist..."
        
        let credentials = loginManager.retrieveStoredCredentials()
        
        DispatchQueue.main.async {
            if let username = credentials.username, let password = credentials.password {
                self.statusLabel.text = "Credentials Retrieved"
                self.statusLabel.textColor = UIColor.blue
                self.resultTextView.text = """
                    📝 Stored credentials retrieved:
                    
                    Username: \(username)
                    Password: \(password)
                    
                    Security Status:
                    - Credentials found in Info.plist
                    - Login state: \(self.loginManager.logged)
                    - User logged in: \(self.loginManager.isUserLoggedIn())
                    
                    ⚠️ WARNING: Credentials are stored in plain text!
                    This demonstrates insecure credential storage.
                    """
            } else {
                self.statusLabel.text = "No Credentials Found"
                self.statusLabel.textColor = UIColor.orange
                self.resultTextView.text = """
                    📭 No stored credentials found
                    
                    This indicates:
                    - No previous login with credential storage
                    - Credentials were cleared
                    - Info.plist doesn't contain stored credentials
                    
                    Security Status:
                    - Login state: \(self.loginManager.logged)
                    - User logged in: \(self.loginManager.isUserLoggedIn())
                    """
            }
        }
    }
    
    func clearCredentials() {
        statusLabel.text = "Clearing credentials..."
        statusLabel.textColor = UIColor.orange
        resultTextView.text = "Removing stored credentials from Info.plist..."
        
        loginManager.clearStoredCredentials()
        
        DispatchQueue.main.async {
            self.statusLabel.text = "Credentials Cleared"
            self.statusLabel.textColor = UIColor.blue
            self.resultTextView.text = """
                🗑️ Stored credentials cleared!
                
                Actions performed:
                - Removed username from Info.plist
                - Removed password from Info.plist
                - Cleared last login date
                - Set login status to false
                
                Security Status:
                - Login state: \(self.loginManager.logged)
                - User logged in: \(self.loginManager.isUserLoggedIn())
                
                ✅ Credentials have been securely removed
                """
        }
    }
    
    // MARK: - Vulnerable Methods (for educational purposes)
    
    func attemptBypass() {
        statusLabel.text = "Attempting Bypass..."
        statusLabel.textColor = UIColor.orange
        resultTextView.text = """
            🔍 Attempting to bypass login validation...
            
            This demonstrates potential vulnerabilities:
            - Direct access to Login properties
            - Possible manipulation of login state
            - Runtime modification of authentication
            - Memory inspection opportunities
            
            For educational purposes only!
            """
        
        loginManager.bypassLoginValidation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.statusLabel.text = "Bypass Attempted"
            self.statusLabel.textColor = UIColor.red
            self.resultTextView.text = """
                ⚠️ Login bypass simulation completed!
                
                Security Status:
                - Login state: \(self.loginManager.logged)
                - User logged in: \(self.loginManager.isUserLoggedIn())
                
                In a real scenario, an attacker might:
                1. Use runtime manipulation tools (Frida, Cycript)
                2. Modify Login properties directly
                3. Hook the performLogin() method
                4. Bypass the authentication entirely
                5. Manipulate the Info.plist directly
                
                Vulnerabilities demonstrated:
                - Direct property manipulation
                - Method hooking possibilities
                - Authentication bypass
                - No integrity checks on login state
                
                This demonstrates why additional security layers are needed!
                """
        }
    }
    
    func storeInsecurely() {
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            showAlert(title: "Error", message: "One or more input fields is empty")
            return
        }
        
        statusLabel.text = "Storing Insecurely..."
        statusLabel.textColor = UIColor.orange
        resultTextView.text = "Storing credentials without validation..."
        
        loginManager.storeCredentialsInsecurely(username: username, password: password)
        
        DispatchQueue.main.async {
            self.statusLabel.text = "Credentials Stored Insecurely"
            self.statusLabel.textColor = UIColor.red
            self.resultTextView.text = """
                🚨 Credentials stored insecurely!
                
                Actions performed:
                - Stored username without validation
                - Stored password without validation
                - Bypassed all security checks
                - Saved to Info.plist directly
                
                Security Status:
                - Login state: \(self.loginManager.logged)
                - User logged in: \(self.loginManager.isUserLoggedIn())
                
                ⚠️ WARNING: This is a security vulnerability!
                - No input validation
                - No credential strength check
                - No authentication required
                - Direct file system access
                
                This demonstrates insecure credential storage practices.
                """
        }
    }
    
    // MARK: - Utility Methods
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showLoginStatus() {
        let status = loginManager.getLoginStatus()
        
        resultTextView.text = """
            📊 Current Login Status:
            
            Login State: \(status.logged)
            Has Stored Credentials: \(status.hasStoredCredentials)
            Is User Logged In: \(status.isUserLoggedIn)
            
            Info.plist Status:
            - File accessible: \(Bundle.main.path(forResource: "Info", ofType: "plist") != nil)
            - Contains credentials: \(status.hasStoredCredentials)
            
            Security Analysis:
            - Credentials in plain text: \(status.hasStoredCredentials)
            - Login bypass possible: Yes
            - File manipulation possible: Yes
            - Runtime modification possible: Yes
            """
    }
}
