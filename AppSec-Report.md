## Avaliação de Segurança (AppSec) — DVIA-v2

Data: 2025-08-08
Escopo: revisão estática do código-fonte do projeto iOS (`DVIA-v2`), incluindo dependências em `Pods/`.

### Sumário Executivo
- **Estado geral**: Aplicativo propositalmente vulnerável (DVIA). Foram identificadas múltiplas falhas críticas e altas, principalmente em transporte, armazenamento e criptografia.
- **Principais riscos**:
  - ATS desabilitado e uso de HTTP em claro (MITM/roubo de credenciais).
  - Armazenamento inseguro (NSUserDefaults, YapDatabase sem criptografia, Realm sem `encryptionKey`).
  - Criptografia fraca e chaves/senhas hardcoded.
  - Pinning TLS opcional e uso de APIs depreciadas para rede.
  - Segredos/credenciais hardcoded (Flurry API key, cookies de demonstração).

### Metodologia
- Revisão estática do código Swift/Obj-C e `Info.plist`.
- Busca por padrões inseguros (rede, armazenamento, chaveiro, criptografia, logs, hardcoded secrets).
- Inspeção de fluxos de rede e configurações de dependências (Realm, Parse, etc.).

---

### Achados Detalhados

#### 1) App Transport Security (ATS) desabilitado — CRÍTICO
- Evidência: `DVIA-v2/DVIA-v2/Info.plist`
```
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```
- Impacto: Permite tráfego não seguro (HTTP) e conexões a hosts sem requisitos modernos de TLS. Facilita ataques de interceptação (MITM) e downgrade.
- Recomendação: Remover `NSAllowsArbitraryLoads`; definir exceções estritas por domínio apenas quando necessário; exigir TLS forte (TLS 1.2+), PFS, e validações.

#### 2) Envio de dados sensíveis via HTTP e logs de respostas — CRÍTICO
- Evidência: `DVIA-v2/DVIA-v2/Vulnerabilities/Transport Layer Protection/Controller/TransportLayerProtectionViewController.swift`
```
@IBAction func sendOverHTTPTapped(_ sender: Any) {
    guard let url = URL(string: "http://example.com/") else { return }
    sendRequestOverUrl(url)
}
...
let postDictionary = [
  "card_number" : cardNumberTextField.text,
  "card_name"   : nameOnCardTextField.text,
  "card_cvv"    : CVVTextField.text
]
...
print("responseString = \(String(describing: responseString) )")
```
- Impacto: Exposição de dados de pagamento em claro na rede e em logs.
- Recomendação: Bloquear HTTP; usar somente HTTPS com ATS; não logar payloads/respostas contendo dados sensíveis; mascarar e aplicar data minimization.

#### 3) Pinning TLS parcial/opcional e APIs de rede depreciadas — ALTO
- Evidência: `TransportLayerProtectionViewController.swift` usa `NSURLConnection` e lida com `URLAuthenticationChallenge` manualmente; pinning só quando acionado.
```
@IBAction func send(usingSSLPinning ...)
@IBAction func send(usingPublicKeyPinning ...)
// ... NSURLConnection delegate ... comparação com certificado "example.der"
```
- Impacto: Falta de pinning por padrão e uso de APIs antigas pode levar a validações inconsistentes; superfície de bypass.
- Recomendação: Migrar para `URLSession` + delegate moderno; aplicar pinning (certificado ou chave pública) por padrão em rotas sensíveis; rotacionar pins e gerenciar falhas com safe fallback.

#### 4) Links e uso explícito de HTTP hardcoded — ALTO
- Evidência: `DVIA-v2/DVIA-v2/Constants.swift`
```
return "http://damnvulnerableiosapp.com"
return "http://highaltitudehacks.com/..."
```
- Impacto: Mesmo abrindo no Safari, promove tráfego não seguro e é propenso a MITM se tokens/PII forem transmitidos.
- Recomendação: Preferir `https://` para todos os recursos; redirecionar legado via HTTPS.

#### 5) Armazenamento inseguro em NSUserDefaults — MÉDIO
- Evidência: `Vulnerabilities/Insecure Data Storage/Controller/UserDefaultsViewController.swift`
```
UserDefaults.standard.set(userDefaultsTextField.text, forKey: "DemoValue")
```
- Impacto: NSUserDefaults não é apropriado para dados sensíveis; backup e extração via iTunes/FMF são triviais.
- Recomendação: Para dados sensíveis, usar Keychain com classes `...ThisDeviceOnly` e proteção adequada; do contrário, criptografar antes de persistir.

#### 6) Uso de Keychain sem atributos de acessibilidade fortes — ALTO
- Evidência de wrapper local: `Vendor/PDKeychainBindings/PDKeychainBindingsController.m`
```
// SecItemAdd sem kSecAttrAccessible / ThisDeviceOnly
NSMutableDictionary *data = [NSMutableDictionary ...]
[data setObject:stringData forKey:(__bridge id)kSecValueData];
SecItemAdd((__bridge CFDictionaryRef)data, NULL);
```
- Evidência em dependência Realm: `Pods/Realm/.../keychain_helper.cpp`
```
CFDictionaryAddValue(d.get(), kSecAttrAccessible, kSecAttrAccessibleAlways);
```
- Impacto: Itens podem ficar acessíveis em cenários inseguros (p.ex. Always) e serem migráveis via backup, aumentando risco de extração em dispositivos comprometidos.
- Recomendação: Definir `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly` (ou `...AfterFirstUnlockThisDeviceOnly` conforme caso de uso); isolar por Access Group quando aplicável.

#### 7) Realm sem criptografia em repouso — ALTO
- Evidência: Não há configuração de `Realm.Configuration(encryptionKey: ...)` no app; somente em `Pods/` aparecem APIs.
- Impacto: Banco local sem criptografia; extração de dados em repouso é facilitada se sandbox/backup for acessado.
- Recomendação: Gerar chave de 64 bytes (armazenada no Keychain com `ThisDeviceOnly`) e configurar `Realm.Configuration.encryptionKey` para todos os Realms.

#### 8) Credenciais/segredos hardcoded — ALTO
- Flurry API key: `DVIA-v2/DVIA-v2/AppDelegate.swift`
```
Flurry.startSession(apiKey: "8RM5WHP628853HQXFKDX", ...)
```
- Cookies de demonstração: `Vulnerabilities/Side Channel Data Leakage/Controller/Objective-C Methods/SetSharedCookies.m`
```
static NSString *const CookieUsername = @"admin123";
static NSString *const CookiePassword = @"dvpassword";
static NSString *const SiteURLString = @"http://highaltitudehacks.com";
```
- Senha de criptografia hardcoded: `BrokenCryptographyDetailsViewController.swift`
```
RNEncryptor.encryptData(..., password: "@daloq3as$qweasdlasasjdnj")
```
- Impacto: Exposição de segredos permite abuso de serviços de terceiros, engenharia reversa e descriptografia offline.
- Recomendação: Remover segredos do código; usar variáveis de ambiente/Config remoto; rotação periódica; para criptografia, derivar chaves em tempo de execução.

#### 9) Criptografia fraca/implementação inadequada — ALTO
- Evidência: `BrokenCryptographyPinDetailsViewController.swift`
```
let rounds = 500 // baixo para PBKDF2
print("encryptedData (SHA1): ...")
```
- Evidência: `BrokenCryptographyDetailsViewController.swift` grava dados em `Documents/` com senha fixa.
- Impacto: Derivação fraca facilita brute force; logging de hashes auxilia ataques; senha fixa quebra confidencialidade.
- Recomendação: Aumentar iteracoes (≥100k) ou usar scrypt/Argon2; não logar material sensível; usar chaves por usuário/dispositivo; usar Keychain para envelopamento de chaves.

#### 10) Armazenamento em banco sem criptografia (YapDatabase) — ALTO
- Evidência: `Vulnerabilities/Insecure Data Storage/Controller/YapDatabaseViewController.swift`
```
transaction.setObject(username, forKey: "Username", inCollection: "DVIA")
transaction.setObject(password, forKey: "Password", inCollection: "DVIA")
```
- Impacto: Credenciais em repouso em texto claro no sandbox.
- Recomendação: Criptografar campo/arquivo; preferir Keychain para segredos.

#### 11) URL Scheme sem validação forte — MÉDIO
- Evidência: `DVIA-v2/DVIA-v2/AppDelegate.swift`
```
func application(_ app: UIApplication, open url: URL, ... ) -> Bool {
  let splitUrl = url.absoluteString.components(separatedBy: "/phone/call_number/")
  if ((Int(splitUrl[1])) != nil) { ... }
}
```
- Impacto: Qualquer app pode invocar o scheme `dvia://`/`dviaswift://` para acionar fluxos sem autenticação; risco de phishing/UI spoof.
- Recomendação: Validar origem/assinatura, randomizar esquemas privados, exigir confirmação e sanitização robusta.

#### 12) Logging potencialmente sensível — MÉDIO
- Evidência: `print(...)` de erros e respostas em diversas rotas (ex.: transporte, criptografia imprime hashes).
- Impacto: Logs podem conter PII/segredos e serem exfiltrados em builds de produção.
- Recomendação: Centralizar logging com níveis; desabilitar logs verbosos em produção; sanitizar/mask dados.

#### 13) Uso de APIs depreciadas (NSURLConnection) — BAIXO
- Evidência: `TransportLayerProtectionViewController.swift`.
- Impacto: Comportamento inconsistente de segurança e manutenção reduzida.
- Recomendação: Migrar para `URLSession` + `URLSessionDelegate`.

---

### Implementação de SSL Pinning Moderno (Adicionada)

**Nova Classe**: `NSURLSessionPinningDelegate.swift`
- Implementa `URLSessionDelegate` com validação de certificado pinado
- Compara certificado do servidor com `vulnerableapp.der` local
- Usa `SecTrustEvaluateWithError` para validação inicial do OS
- Fallback seguro: cancela autenticação se pinning falhar

**Métodos Utilitários**: `DVIAUtilities.swift`
- `createPinnedURLSession()`: Cria URLSession com delegate de pinning
- `performSecureRequest(url:completion:)`: Executa requisições com pinning automático

**Uso**: `TransportLayerProtectionViewController.swift`
- Novo método `sendWithModernSSLPinning()` demonstra uso da implementação
- Substitui `NSURLConnection` depreciado por `URLSession` moderno
- Tratamento de erros e feedback ao usuário

**Melhorias sobre implementação anterior**:
- Usa APIs modernas (`URLSession` vs `NSURLConnection`)
- Estrutura mais limpa e reutilizável
- Melhor tratamento de erros e logging
- Mantém compatibilidade com arquitetura existente

### Nova Vulnerabilidade: Insecure Web Content (Adicionada)

**Nova Classe**: `InsecureWebContentViewController.swift`
- Demonstra três abordagens de carregamento de conteúdo web:
  1. **Padrão**: `URLSession.shared` sem pinning
  2. **Seguro**: Com `NSURLSessionPinningDelegate` 
  3. **Inseguro**: Deliberadamente sem pinning para comparação

**Características da Vulnerabilidade**:
- URL hardcoded: `"https://vulnerableapp.com"`
- Logging de dados recebidos (potencial vazamento de informações)
- Comparação visual entre métodos seguro/inseguro
- Interface didática com status em tempo real

**Arquivos Relacionados**:
- `InsecureWebContent.storyboard`: Interface com 3 botões para testar diferentes abordagens
- `vulnerableapp.der`: Certificado de exemplo para pinning
- Logs detalhados para análise de segurança

**Propósito Didático**:
- Demonstrar diferença entre requisições com/sem SSL pinning
- Mostrar como implementar pinning usando `NSURLSessionPinningDelegate`
- Comparar comportamento em cenários de MITM
- Educar sobre importância de validação de certificados

### Nova Vulnerabilidade: Biometric Authentication Bypass (Adicionada)

**Nova Classe**: `Login.swift`
- Implementa função `appleBio()` seguindo exatamente o padrão da imagem
- Usa `LAContext` para autenticação biométrica (Face ID/Touch ID)
- Variável `logged` para controlar estado de autenticação
- Tratamento de erros e permissões

**Características da Vulnerabilidade**:
- Autenticação baseada apenas em estado local (`logged` variable)
- Sem validação adicional após sucesso biométrico
- Vulnerável a runtime manipulation e memory inspection
- Falta de proteções contra bypass

**Classe de Demonstração**: `BiometricLoginViewController.swift`
- Interface para testar autenticação biométrica
- Demonstração de bypass para fins educacionais
- Comparação entre implementação vulnerável e segura
- Explicação detalhada de vulnerabilidades

**Arquivos Relacionados**:
- `BiometricLogin.storyboard`: Interface com botões para autenticar e tentar bypass
- `Login.swift`: Classe principal com função `appleBio()` da imagem
- Logs detalhados para análise de segurança

**Propósito Didático**:
- Demonstrar implementação padrão de autenticação biométrica
- Mostrar vulnerabilidades em autenticação baseada apenas em estado local
- Educar sobre necessidade de proteções adicionais
- Comparar implementação vulnerável vs. segura

**Vulnerabilidades Demonstradas**:
- Runtime manipulation (Frida, Cycript)
- Memory inspection para encontrar estado de autenticação
- Hook-based attacks em `LAContext.evaluatePolicy`
- Bypass direto da variável `logged`
- Falta de server-side validation

### Nova Vulnerabilidade: Biometric Change Detection Bypass (Adicionada)

**Nova Classe**: `LAContext.swift`
- Implementa extension `LAContext` seguindo exatamente o padrão da imagem
- Propriedade `savedBiometricsPolicyState: Data?` com getter/setter para UserDefaults
- Função `biometricsChanged() -> Bool` para detectar mudanças biométricas
- Usa `evaluatedPolicyDomainState` para comparação de estados

**Características da Vulnerabilidade**:
- Armazenamento em UserDefaults sem criptografia
- Função estática vulnerável a hooking
- Sem integridade checks no estado salvo
- Possível manipulação direta do estado
- Falta de proteções contra bypass

**Classe de Demonstração**: `BiometricChangeDetectionViewController.swift`
- Interface para testar detecção de mudanças biométricas
- Demonstração de bypass para fins educacionais
- Comparação entre implementação vulnerável e segura
- Explicação detalhada de vulnerabilidades

**Arquivos Relacionados**:
- `BiometricChangeDetection.storyboard`: Interface com botões para verificar, resetar e bypass
- `LAContext.swift`: Extension principal com função `biometricsChanged()` da imagem
- Logs detalhados para análise de segurança

**Propósito Didático**:
- Demonstrar implementação padrão de detecção de mudanças biométricas
- Mostrar vulnerabilidades em armazenamento não criptografado
- Educar sobre necessidade de proteções adicionais
- Comparar implementação vulnerável vs. segura

**Vulnerabilidades Demonstradas**:
- UserDefaults manipulation (chave "BiometricsPolicyState")
- Runtime hooking da função `biometricsChanged()`
- Memory inspection para encontrar estado salvo
- Bypass direto do estado de domínio
- Falta de server-side validation
- Ausência de integridade checks

**Funcionalidades da Extension**:
- `savedBiometricsPolicyState`: Propriedade para salvar/recuperar estado do UserDefaults
- `biometricsChanged()`: Função que compara estado atual com salvo
- Detecção de mudanças em fingerprints/Face ID
- Tratamento de primeiro uso (estado nil)

### Observações adicionais
- `example.der`/`google.der` no bundle: manter governança de pins (expiração/rotação).
- `Excessive Permissions`: revisar justificativas e escopo de uso para Camera/FaceID.

### Recomendações Prioritárias
1) Reativar ATS, remover `NSAllowsArbitraryLoads`, forçar HTTPS.
2) Proibir envio de dados sensíveis por HTTP; aplicar pinning por padrão em endpoints críticos.
3) Endurecer Keychain (`...ThisDeviceOnly`, acesso mínimo), criptografar bancos locais (Realm/YapDatabase).
4) Remover segredos hardcoded; rotação e vault/Config remoto.
5) Fortalecer criptografia (KDF robusto, sem logs, sem senhas fixas).
6) Revisar URL Schemes e sanitização.
7) Reduzir/mascarar logging em produção; migrar para APIs modernas de rede.

### Tabela de Severidade (resumo)
- Crítico: ATS desabilitado; HTTP com dados sensíveis.
- Alto: Keychain fraco; Realm sem criptografia; segredos hardcoded; criptografia fraca; YapDatabase em claro; pinning opcional.
- Médio: NSUserDefaults; URL Scheme; logging sensível.
- Baixo: APIs depreciadas; links HTTP informativos.

---

### Apêndice: Referências de Código
- `Info.plist`: ATS desabilitado (linhas com `NSAllowsArbitraryLoads`).
- `TransportLayerProtectionViewController.swift`: envio HTTP/HTTPS, logs, pinning com `NSURLConnection`.
- `Constants.swift`: URLs HTTP hardcoded.
- `PDKeychainBindingsController.m`: uso de Keychain sem `kSecAttrAccessible` forte.
- `Pods/Realm/.../keychain_helper.cpp`: `kSecAttrAccessibleAlways` (inseguro).
- `BrokenCryptography*`: senha hardcoded, PBKDF2 com `rounds=500`, logs de SHA1.
- `YapDatabaseViewController.swift`: credenciais em claro no DB.
- `AppDelegate.swift`: Flurry API key; URL scheme handler sem autenticação.

### Nova Vulnerabilidade: Login - Info.plist Storage (Refatorada)

**Classe Refatorada**: `Login.swift`
- **Mantido todo código original**: Método `appleBio()` preservado
- **Novo método de login**: `performLogin(username:password:)` que armazena credenciais no Info.plist
- **Armazenamento inseguro**: Credenciais em texto plano no Info.plist
- **Métodos de gerenciamento**: `retrieveStoredCredentials()`, `clearStoredCredentials()`, `isUserLoggedIn()`

**Características da Implementação Refatorada**:
- **Armazenamento no Info.plist**: Credenciais salvas diretamente no arquivo de configuração do app
- **Método original preservado**: `appleBio()` mantido para autenticação biométrica
- **Métodos de segurança**: `performSecureLogin()` com validação de formato
- **Métodos vulneráveis**: `bypassLoginValidation()`, `storeCredentialsInsecurely()`, `retrieveCredentialsInsecurely()`
- **Gerenciamento de estado**: Controle de login status via Info.plist

**Classe de Demonstração**: `LoginViewController.swift`
- **Interface completa**: Campos de username/password com 6 botões de funcionalidade
- **Demonstração de vulnerabilidades**: Bypass de login para fins educacionais
- **Gerenciamento de credenciais**: Recuperar e limpar credenciais armazenadas
- **Logs detalhados**: Para análise de segurança e debugging

**Arquivos Relacionados**:
- `Login.storyboard`: Interface com campos de login e 6 botões para diferentes funcionalidades
- `Login.swift`: Classe refatorada com armazenamento no Info.plist
- `Info.plist`: Arquivo de configuração onde credenciais são armazenadas
- Logs detalhados para análise de segurança

**Propósito Didático**:
- Demonstrar armazenamento inseguro de credenciais
- Mostrar como credenciais podem ser manipuladas no Info.plist
- Educar sobre vulnerabilidades em armazenamento local
- Comparar implementação vulnerável vs. segura

**Funcionalidades da Login Refatorada**:
- `performLogin(username:password:)`: Login básico com armazenamento no Info.plist
- `appleBio()`: Autenticação biométrica original (mantida)
- `retrieveStoredCredentials()`: Recupera credenciais do Info.plist
- `clearStoredCredentials()`: Remove credenciais do Info.plist
- `isUserLoggedIn()`: Verifica status de login via Info.plist
- `performSecureLogin()`: Login com validação de formato
- `validateStoredCredentials()`: Valida credenciais armazenadas
- `bypassLoginValidation()`: Método vulnerável para bypass
- `storeCredentialsInsecurely()`: Armazenamento vulnerável
- `retrieveCredentialsInsecurely()`: Recuperação vulnerável

**Vulnerabilidades Demonstradas**:
- **Armazenamento em texto plano**: Credenciais não criptografadas no Info.plist
- **Info.plist manipulation**: Arquivo de configuração pode ser modificado
- **Runtime manipulation**: Propriedades `Login` podem ser alteradas
- **Method hooking**: Funções de login podem ser interceptadas
- **Bypass de validação**: Login pode ser contornado
- **Acesso direto ao arquivo**: Info.plist pode ser lido diretamente
- **Falta de criptografia**: Credenciais expostas em texto plano
- **Sem integridade checks**: Não há verificação de integridade

**Melhorias sobre Versão Original**:
- **Funcionalidade expandida**: Login tradicional além da autenticação biométrica
- **Armazenamento persistente**: Credenciais salvas no Info.plist
- **Gerenciamento de estado**: Controle de login status
- **Demonstração de vulnerabilidades**: Múltiplas formas de bypass
- **Interface educacional**: Interface completa para testes
- **Logs detalhados**: Melhor feedback para análise

**Implementação de Armazenamento**:
- **Leitura do Info.plist**: `Bundle.main.path(forResource: "Info", ofType: "plist")`
- **Escrita no Info.plist**: `PropertyListSerialization.data(fromPropertyList:format:options:)`
- **Chaves utilizadas**: `StoredUsername`, `StoredPassword`, `LastLoginDate`, `IsUserLoggedIn`
- **Formato de dados**: XML property list
- **Persistência**: Credenciais mantidas entre sessões do app

**Vulnerabilidades Críticas Identificadas**:
- **Credenciais em texto plano**: Senhas visíveis no Info.plist
- **Arquivo acessível**: Info.plist pode ser lido por outras apps (em jailbreak)
- **Sem criptografia**: Dados sensíveis não protegidos
- **Bypass fácil**: Validação pode ser contornada
- **Manipulação direta**: Arquivo pode ser modificado externamente


