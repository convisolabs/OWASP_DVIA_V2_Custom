import Foundation

class NSURLSessionPinningDelegate: NSObject, URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            
            let serverTrust = challenge.protectionSpace.serverTrust!
            var isServerTrusted = false
            
            do {
                try SecTrustEvaluateWithError(serverTrust, &isServerTrusted)
            } catch {
                print("SSL Pinning Failed, unable to load remote certificate!")
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }
            
            if isServerTrusted {
                
                let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0)
                let cert1 = SecCertificateCopyData(serverCertificate!) as NSData
                
                let cert2 = NSData(contentsOfFile: Bundle.main.path(forResource: "vulnerableapp", ofType: "der")!)
                
                if cert2 != nil {
                    if cert2!.isEqual(to: cert1 as Data) {
                        print("SSL Pinning Complete!")
                        completionHandler(.useCredential, URLCredential(trust: serverTrust))
                        return
                    } else {
                        print("SSL Pinning Failed, certificates do not match!")
                    }
                } else {
                    print("SSL Pinning Failed, unable to load local certificate!")
                }
            } else {
                print("SSL Pinning Failed, unable to load remote certificate!")
            }
        }
        
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}
