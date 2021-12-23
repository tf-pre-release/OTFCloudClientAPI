/*
Copyright (c) 2021, Hippocrates Technologies S.r.l.. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. Neither the name of the copyright holder(s) nor the names of any contributor(s) may
be used to endorse or promote products derived from this software without specific
prior written permission. No license is granted to the trademarks of the copyright
holders even if such marks are included in this software.

4. Commercial redistribution in any form requires an explicit license agreement with the
copyright holder(s). Please contact support@hippocratestech.com for further information
regarding licensing.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
OF SUCH DAMAGE.
 */

import XCTest
@testable import OTFCloudClientAPI

class OTFCloudClientAPITests: XCTestCase {
    // Testing data
    // Let's not change the following data:
    var realNetworkService: NetworkingLayer!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        guard let url = Defaults.apiURL else {
            
            return
        }
        
        let configurations = NetworkingLayer.Configurations(APIBaseURL: url, apiKey: Defaults.APIKEY)
        TheraForgeNetwork.configureNetwork(configurations)
        
        realNetworkService = NetworkingLayer(session: NetworkingLayer.createSession(),
                                             keychainService: TheraForgeKeychainService.shared,
                                             currentAuth: nil)

        try testLogin()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
    }
}

extension OTFCloudClientAPITests {
    // MARK: - Test with real data
    // MARK: - Test Login
    func testLogin() throws {
        let promise = expectation(description: "Login API should return the same user from ")
        realNetworkService.login(request: OTFCloudClientAPI.Request.Login(email: testEmail,
                                                                          password: testPassword)) { (result) in
            XCTAssertNotNil(result)
            switch result {
            case .success(let response):
                XCTAssertEqual(response.data.email, self.testEmail)
            case .failure(let error):
                XCTFail("🔥 \(error.error.message)")
            }
            promise.fulfill()
        }

        waitForExpectations(timeout: requestTimeoutInterval) { error in
            if let error = error {
                print("Test failed Error: \(error.localizedDescription)")
            }
        }
    }

    func testLoginWrongCredentials() {
        let promise = expectation(description: "There should be an error in case of wrong email/password. and error should not be nil.")
        realNetworkService.login(request: OTFCloudClientAPI.Request.Login(email: testEmail,
                                                                          password: "1234")) { (result) in
            XCTAssertNotNil(result)
            switch result {
            case .success:
                XCTFail("Login Should not get success with wrong credentials.")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            promise.fulfill()
        }

        waitForExpectations(timeout: requestTimeoutInterval) { error in
            if let error = error {
                print("Test failed Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testSocialLogin() {
        let promise = expectation(description: "There should be an error in case of wrong email/password. and error should not be nil.")
        // swiftlint:disable line_length
        let appleIDToken = "eyJraWQiOiJZdXlYb1kiLCJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLmludm96b25lLmNhcmRpbmFsa2l0IiwiZXhwIjoxNjM3MjM1NzA5LCJpYXQiOjE2MzcxNDkzMDksInN1YiI6IjAwMTYxMC4wMDQ3OGQzZjY5Y2M0OWFjOGVjMzEwODEyZTQ5NDk5YS4wOTA0Iiwibm9uY2UiOiI1NTFmNThkMDU4YWFiM2JiMTMzMDE3ZGRjMDMxM2Y2NzkwNjM2MGY1MDgyMTNhZThlYWY5NzFlNTczZDJmMGQ5IiwiY19oYXNoIjoiZVJVTmdxRlo2ZzZCLTVQS1I0bGJXZyIsImVtYWlsIjoiNW56NWpoeWs4NEBwcml2YXRlcmVsYXkuYXBwbGVpZC5jb20iLCJlbWFpbF92ZXJpZmllZCI6InRydWUiLCJpc19wcml2YXRlX2VtYWlsIjoidHJ1ZSIsImF1dGhfdGltZSI6MTYzNzE0OTMwOSwibm9uY2Vfc3VwcG9ydGVkIjp0cnVlfQ.ECAXcyw5Kpl2siUn5D2_aGe6QvfH_irfk3pPMYqgT0Uj7ggEV5n_QDF1BaMK05nJABY9P7RHLnLeP3EMD6GlAYHC3Cp-AVQOJdXD4CSakZYYNbPtvfZBzpH5HzpueYNRt-4UNdS8JOluJkE3ftMKoqRmXVgYeN-ZHuI8Y23saIXKeByuTZkVy6jGBWKUrWZcHKAV-6oyopY1Mr7KHwssi90jGfVwEypqvDN5mqj-OvU-IncbHpsmyc8cqeVzU1shq4mATFbOQR1CcaHhtEmWC3ZsavuRe4tVbuFCgQrPCNe50Nk-eKpEMZt0O_K4b5jxDnUcP6-vpLO_A1FXOttOfA"
//        let googleIDToken = "eyJhbGciOiJSUzI1NiIsImtpZCI6ImQ0ZTA2Y2ViMjJiMDFiZTU2YzIxM2M5ODU0MGFiNTYzYmZmNWE1OGMiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI2MDkzNjIzMTg2NC0wN3EwaTVvazJqNTJybHYyZGl0Z3Rncm5wM25mZ3NmYy5hcHBzLmdvb2dsZXVzZXJjb250ZW50LmNvbSIsImF1ZCI6IjYwOTM2MjMxODY0LTA3cTBpNW9rMmo1MnJsdjJkaXRndGdybnAzbmZnc2ZjLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwic3ViIjoiMTA2NjY3NzIzODI2MzM5MDc2MzQwIiwiaGQiOiJpbnZvem9uZS5jb20iLCJlbWFpbCI6InplZXNoYW4uYWhtZWRAaW52b3pvbmUuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImF0X2hhc2giOiJya3J2X2VEa2FBMWU4Qms5SDFDbmlBIiwibm9uY2UiOiJiSTN3ejlLSERCQm5ITE1WNHh5d3VQVzVoaEJnZlgyRDNDMU1CUUh1NG9nIiwibmFtZSI6IlplZXNoYW4gQWhtZWQiLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUFUWEFKeUhpWEFVa011RGt6LVN3b1pNVVhDanByekpteVQzRjZKNlJ0eUw9czk2LWMiLCJnaXZlbl9uYW1lIjoiWmVlc2hhbiIsImZhbWlseV9uYW1lIjoiQWhtZWQiLCJsb2NhbGUiOiJlbiIsImlhdCI6MTYzNzY2OTczOCwiZXhwIjoxNjM3NjczMzM4fQ.Kj3jeujJxi20mEL0xzThXQsYf_FfJZdfhiRaYiplyMZbBxrF-D0Zsay3R3gmljuL68FIorEIC6f6Vw6rQPu24zBTiMdaLvfb4OLxw6_jA3rVwd5V0uhqP_o1n9DFJTdqE02TK2FXtHHP7jWCxu_sGwxjkEiV34qYQC8lTgVU4gePGsYFRaDBrjG0SMCy0TDpIuhTyx5w3uuTWnkq2zzWcLs2Ej1vGIsYYafLxpAHM7Lfmtv30OFRm1mdrdgRQvXQtU-JP85OYCerVhw6YUXPESzb-yp2EWbjbn-bz6orfB_hFyxDuf23JcUOpCBTCSnGm1Wb8jpquHZkWV5GCaMCKg"
        let idToken = appleIDToken
        let socialLogin = Request.SocialLogin(userType: .patient,
                                              socialType: .apple,
                                              authType: .login,
                                              identityToken: idToken)
        realNetworkService.socialLogin(request: socialLogin) { result in
            XCTAssertNotNil(result)
            switch result {
            case .success(_):
                promise.fulfill()
            case .failure(let error):
                XCTFail("🔥 \(error.error.message)")
            }
        }
        
        waitForExpectations(timeout: requestTimeoutInterval) { error in
            if let error = error {
                print("Test failed Error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Test Signup
    func testSignUp() throws {
        let promise = expectation(description: "Response should get into success block and it should not be nil.")

        realNetworkService.signup(request:
                                    .init(email: testEmail,
                                          password: testPassword,
                                          first_name: "FirstTestName",
                                          last_name: "LastTestName",
                                          type: .patient,
                                          dob: "08-07-1997",
                                          gender: "male",
                                          phoneNo: "(111) 111-1111")
        ) { (result) in
            XCTAssertNotNil(result)
            switch result {
            case .success(let response):
                XCTAssertNotNil(response)
            case .failure(let error):
                XCTFail("🔥 \(error.error.message)")
            }
            promise.fulfill()
        }

        waitForExpectations(timeout: requestTimeoutInterval) { error in
            if let error = error {
                print("Test failed Error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Test Change password
    func testChangePassword() throws {
        let promise = expectation(description: "Response should get into success block and it should not be nil.")
        realNetworkService.changePassword(request:
                                            .init(email: testEmail,
                                                  password: testPassword,
                                                  newPassword: testPassword)) { (result) in
            XCTAssertNotNil(result)
            switch result {
            case .success(let response):
                XCTAssertNotNil(response)
            case .failure(let error):
                XCTFail("🔥 \(error.error.message)")
            }
            promise.fulfill()
        }

        waitForExpectations(timeout: requestTimeoutInterval) { error in
            if let error = error {
                print("Test failed Error: \(error.localizedDescription)")
            }
        }
    }

    func testChangePasswordWrongCredentials() throws {
        let promise = expectation(description: "Should match the password changed message coming from the server.")
        realNetworkService.changePassword(request:
                                            .init(email: testEmail,
                                                  password: "123456",
                                                  newPassword: testPassword)) { (result) in
            XCTAssertNotNil(result)
            switch result {
            case .success:
                XCTFail("🔥 Change password should not get success with wrong credentials.")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            promise.fulfill()
        }

        waitForExpectations(timeout: requestTimeoutInterval) { error in
            if let error = error {
                print("Test failed Error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Test forgot password
    func testForgotPassword() throws {
        let promise = expectation(description: "Should recieve message from server for forgot password.")
        realNetworkService.forgotPassword(request: .init(email: testEmail)) { (result) in
            XCTAssertNotNil(result)
            switch result {
            case .success(let response):
                XCTAssertNotNil(response)
            case .failure(let error):
                print(error)
                XCTFail("🔥 \(error.error.message)")
            }
            promise.fulfill()
        }

        waitForExpectations(timeout: requestTimeoutInterval) { error in
            if let error = error {
                print("Test failed Error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Test RefreshToken
    func testRefreshToken() throws {
        let promise = expectation(description: "Got data")
        realNetworkService.login(request: OTFCloudClientAPI.Request.Login(email: testEmail,
                                                                          password: testPassword)) { (result) in
            XCTAssertNotNil(result)
            switch result {
            case .success(let response):
                XCTAssertEqual(response.data.email, self.testEmail)
                self.refreshToken {
                    promise.fulfill()
                }
            case .failure(let error):
                XCTFail("🔥 \(error.error.message)")
            }
        }

        waitForExpectations(timeout: requestTimeoutInterval) { error in
            if let error = error {
                print("Test failed Error: \(error.localizedDescription)")
            }
        }
    }

    func refreshToken(completion: @escaping () -> Void) {
        self.realNetworkService.refreshToken { (result) in
            XCTAssertNotNil(result)
            switch result {
            case .success(let response):
                completion()
                XCTAssertEqual(response.data.email, self.testEmail)
            case .failure(let error):
                completion()
                XCTFail("🔥 \(error.error.message)")
            }
        }
    }

    // MARK: - Test Reset password
    func testResetPassword() {
        let promise = expectation(description: "Should got failed for invalid code on reset password.")
        realNetworkService.resetPassword(request:
                                            .init(email: testEmail,
                                                  code: "code",
                                                  newPassword: testPassword)) { (result) in
            XCTAssertNotNil(result)
            switch result {
            case .success:
                XCTFail("🔥 Should not got succeded for wrong reset code.")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            promise.fulfill()
        }
        waitForExpectations(timeout: requestTimeoutInterval) { error in
            if let error = error {
                print("Test failed Error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Test Logout
    func testLogout() {
        let promise = expectation(description: "User Should logged out and should get the message 'Logged out.' from the server." )
        realNetworkService.signOut { (result) in
            XCTAssertNotNil(result)
            switch result {
            case .success(let response):
                XCTAssertNotNil(response)
            case .failure(let error):
                XCTFail("🔥 \(error.error.message)")
            }
            promise.fulfill()
        }

        waitForExpectations(timeout: requestTimeoutInterval) { error in
            if let error = error {
                print("Test failed Error: \(error.localizedDescription)")
            }
        }
    }
}
