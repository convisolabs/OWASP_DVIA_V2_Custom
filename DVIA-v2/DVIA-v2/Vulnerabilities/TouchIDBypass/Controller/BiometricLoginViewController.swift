import UIKit
import LocalAuthentication

class BiometricLoginViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var bypassButton: UIButton!
    @IBOutlet weak var resultTextView: UITextView!
    
    private let loginManager = Login()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Biometric Login"
        setupUI()
    }
    
    private func setupUI() {
        statusLabel.text = "Ready to authenticate"
        statusLabel.textColor = UIColor.darkGray
        
        resultTextView.layer.borderColor = UIColor.lightGray.cgColor
        resultTextView.layer.borderWidth = 1.0
        resultTextView.layer.cornerRadius = 5.0
        resultTextView.isEditable = false
        resultTextView.text = "Authentication results will appear here..."
        
        loginButton.setTitle("Login with Face ID/Touch ID", for: .normal)
        bypassButton.setTitle("Bypass Authentication", for: .normal)
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        authenticateWithBiometrics()
    }
    
    @IBAction func bypassButtonTapped(_ sender: Any) {
        attemptBypass()
    }
        
    func authenticateWithBiometrics() {
        statusLabel.text = "Authenticating..."
        statusLabel.textColor = UIColor.orange
        resultTextView.text = "Initiating biometric authentication..."
        
        loginManager.appleBio()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.checkAuthenticationResult()
        }
    }
    
    func checkAuthenticationResult() {
        if loginManager.logged {
            statusLabel.text = "Authentication Successful!"
            statusLabel.textColor = UIColor.green
            resultTextView.text = """
                ✅ Authentication successful!
                
                User has been authenticated using biometrics.
                This demonstrates proper implementation of:
                - LAContext initialization
                - Biometry type detection
                - Permission checking
                - Policy evaluation
                - Success/failure handling
                
                The loginManager.logged variable is now: true
                """
        } else {
            statusLabel.text = "Authentication Failed"
            statusLabel.textColor = UIColor.red
            resultTextView.text = """
                ❌ Authentication failed!
                
                Possible reasons:
                - User cancelled authentication
                - Too many failed attempts
                - Biometric hardware not available
                - Permission denied
                
                The loginManager.logged variable is: false
                """
        }
    }
    
    
    func attemptBypass() {
        statusLabel.text = "Attempting Bypass..."
        statusLabel.textColor = UIColor.orange
        resultTextView.text = """
            🔍 Attempting to bypass biometric authentication...
            
            This demonstrates potential vulnerabilities:
            - Direct access to loginManager.logged variable
            - No additional validation after biometric success
            - Possible runtime manipulation
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
            2. Modify the loginManager.logged variable directly
            3. Hook the LAContext.evaluatePolicy method
            4. Use memory inspection to find authentication state
            5. Bypass the biometric prompt entirely
            
            This demonstrates why additional security layers are needed!
            """
    }
    
    
    func demonstrateSecureImplementation() {
        resultTextView.text = """
            🔒 Secure Implementation Example:
            
            A more secure approach would include:
            1. Server-side validation of authentication
            2. Additional factors (PIN, password)
            3. Rate limiting and lockout mechanisms
            4. Secure storage of authentication state
            5. Runtime integrity checks
            6. Certificate pinning for API calls
            7. Jailbreak detection
            8. Anti-tampering measures
            
            The current implementation is vulnerable to:
            - Runtime manipulation
            - Memory inspection
            - Direct variable modification
            - Hook-based attacks
            """
    }
}