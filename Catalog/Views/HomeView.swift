//
//  HomeView.swift
//  Catalog
//
//  Created by Allen Guo-Lu on 2024-05-27.
//

import SwiftUI
import LocalAuthentication

private var rawData: [Any] = []

struct Document: Identifiable, Hashable {
    var id = UUID()
    let name: String
}

struct HomeView: View {
    @State private var screen = true
    @State private var new = true
    @State private var reqCount = false
    @State private var patientName = ""
    @State private var patientID = ""
    
    @State private var message = ""
    @State private var alert = false
    
    @State private var retrievedData = false
    @State private var verified = false
    @State private var refreshID = 0
    
    @State var presentConfirmDelete = false
    
    @State var openPatientLogView = false
    @State var openExportDataView = false
    
    let document: [Document] = [
        .init(name: "Patient Consent Form")
    ]
    
    // Removes specified chars from a string
    func removeChars(charactersOf string: String, rootString: String) -> String {
        let characterSet = CharacterSet(charactersIn: string)
        let components = rootString.components(separatedBy: characterSet)
        return components.joined(separator: "")
    }
    
    // Returns an array of UUIDs of all completed views/forms
    func filterCompletedViews() -> [UUID] {
        var array = [] as [UUID]
        
        do {
            guard let data = try KeychainManager.get(account: patientName)
            else { return [] as [UUID] }
            
            let raw = String(decoding: data, as: UTF8.self)
                .components(separatedBy: CharacterSet(charactersIn: ",\""))
                .map({ str in
                    return removeChars(charactersOf: "[] ", rootString: str)
                })
                .filter { !$0.isEmpty && !["[", "]", " "].contains($0) }
            
            document.forEach { doc in
                if doc.name == "Patient Consent Form" {
                    if raw.indices.contains(3) && !raw[3].isEmpty {
                        array.append(doc.id)
                    }
                }
            }
        } catch { }
        
        return array
    }
    
    // Sourced from: https://stackoverflow.com/a/51906033
    func getAllKeyChainItemsOfClass(_ secClass: String) -> [String:String] {
        
        let query: [String: Any] = [
            kSecClass as String : secClass,
            kSecReturnData as String  : kCFBooleanTrue as Any,
            kSecReturnAttributes as String : kCFBooleanTrue as Any,
            kSecReturnRef as String : kCFBooleanTrue as Any,
            kSecMatchLimit as String : kSecMatchLimitAll
        ]

        var result: AnyObject?

        let lastResultCode = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        var values = [String:String]()
        if lastResultCode == noErr {
            let array = result as? Array<Dictionary<String, Any>>

            for item in array! {
                if let key = item[kSecAttrAccount as String] as? String,
                    let value = item[kSecValueData as String] as? Data {
                    values[key] = String(data: value, encoding:.utf8)
                }
            }
        }

        return values
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)
            
            if screen {
                if !retrievedData {
                    VStack {
                        NavigationStack {
                            Form {
                                TextField("Patient Name", text: $patientName)
                                    .autocorrectionDisabled()
                                if !new {
                                    SecureField("Password", text: $patientID)
                                        .autocorrectionDisabled()
                                }
                                Toggle("New Patient", isOn: $new)
                                    .toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
                                if new {
                                    SecureField("Password (optional)", text: $patientID)
                                        .autocorrectionDisabled()
                                }
                            }
                            .scrollContentBackground(.hidden)
                            .background(Color("BackgroundColor"))
                            .frame(width: 300)
                            .navigationTitle("Login")
                            .navigationBarTitleDisplayMode(.inline)
                        }.frame(width: 300)
                            .padding(.top, 250)
                        
                        // Button to save a new user, or search for an existing one
                        // Presents an alert when necessary
                        Button(action: new ? save : search) {
                            Text("Create Forms")
                                .font(.custom("Poppins-Regular", size: 20))
                        }.alert(message, isPresented: $alert) { }
                        
                        Spacer(minLength: 100)
                    }
                }
                else {
                    VStack {
                        NavigationStack {
                            HStack {
                                Text("Logged in as \(patientName)")
                                    .font(.custom("Poppins-ExtraLight", size: 20))
                                    .padding(.leading, 22)
                                Spacer()
                                Button(action: logout) {
                                    Text("Logout")
                                        .padding(20)
                                }
                            }
                            
                            HStack {
                                Text("Required Forms")
                                    .font(.custom("OpenSans-Regular", size: 30))
                                    .padding(20)
                                Spacer()
                            }
                            
                            // Display a list of required forms
                            // Includes a dynamic loader for every document
                            List(document.filter { d in
                                !filterCompletedViews()
                                    .contains(d.id)
                            })
                            { doc in
                                NavigationLink(doc.name, value: doc)
                            }
                            .navigationDestination(for: Document.self) { doc in
                                // Link each list entry to a view
                                if doc.name == "Patient Consent Form" {
                                    ConsentFormView().navigationBarBackButtonHidden(true)
                                        .statusBarHidden(true)
                                        .onAppear {
                                            refreshData()
                                        }
                                        .onDisappear {
                                            refreshID += 1
                                        }
                                }
                            }
                            .scrollContentBackground(.hidden)
                            .background(Color("BackgroundColor"))
                            .padding(.top, -30)
                            
                            HStack {
                                Text("Completed Forms")
                                    .font(.custom("OpenSans-Regular", size: 30))
                                    .padding(20)
                                Spacer()
                            }
                            
                            // Display a list of completed forms
                            List(document.filter { d in
                                filterCompletedViews()
                                    .contains(d.id)
                            }) { doc in
                                NavigationLink(doc.name, value: doc)
                            }
                            .scrollContentBackground(.hidden)
                            .background(Color("BackgroundColor"))
                            .padding(.top, -30)
                            
                            // Selection menu bar with forms and storage
                            ZStack {
                                Rectangle()
                                    .fill(Color("PrimaryColor").shadow(.drop(color: Color("SecondaryColor"), radius: 5)))
                                    .frame(height: 55)
                                Rectangle()
                                    .frame(height: 60)
                                    .foregroundColor(Color("PrimaryColor"))
                                HStack {
                                    Spacer()
                                    Button(action: { screen = true }) {
                                        Image(systemName: screen ? "folder.circle.fill" : "folder.circle")
                                            .foregroundColor(screen ? Color("AccentColor") : Color("TextColor"))
                                            .font(.title)
                                            .padding(-10)
                                        Text("Forms")
                                            .foregroundColor(screen ? Color("AccentColor") : Color("TextColor"))
                                            .font(.custom("Poppins-ExtraLight", size: 20))
                                            .padding(15)
                                    }
                                    Spacer()
                                    Spacer()
                                    Button(action: { screen = false }) {
                                        Image(systemName: !screen ? "archivebox.fill" : "archivebox")
                                            .foregroundColor(!screen ? Color("AccentColor") : Color("TextColor"))
                                            .font(.title2)
                                            .padding(-10)
                                        Text("Storage")
                                            .foregroundColor(!screen ? Color("AccentColor") : Color("TextColor"))
                                            .font(.custom("Poppins-ExtraLight", size: 20))
                                            .padding(15)
                                    }
                                    Spacer()
                                }
                            }.frame(maxHeight: .infinity, alignment: .bottom)
                        }
                    }.edgesIgnoringSafeArea(.all)
                }
            }
            else {
                // Pending screen awaiting authentication from the device (ex. passcode)
                if (!verified) {
                    VStack {
                        Text("Authentication is needed.")
                            .font(.custom("", size: 20))
                            .padding(8)
                        Button(action: authenticate) {
                            Text("Verify")
                        }
                    }
                }
                // Admin panel for managing patient data
                else {
                    NavigationStack{
                        VStack {
                            Spacer(minLength: 100)
                            Text("Patient ID: \(patientID)")
                                .font(.custom("", size: 20))
                                .padding(8)
                            Spacer(minLength: 200)
                            Button(action: { openExportDataView.toggle() }) {
                                Text("Export Data to Disk")
                                    .frame(width: 400, height: 50)
                                    .foregroundColor(Color("TextColor"))
                                    .background(Color("AccentColor"))
                                    .cornerRadius(50)
                            }
                            .navigationDestination(isPresented: $openExportDataView) { ExportDataView() }
                            Button(action: { openPatientLogView.toggle() }) {
                                Text("Open Patient Log")
                                    .frame(width: 400, height: 50)
                                    .foregroundColor(Color("PrimaryColor"))
                                    .background(Color("SecondaryColor"))
                                    .cornerRadius(50)
                            }
                            .navigationDestination(isPresented: $openPatientLogView) { PatientLogView()
                            }
                            Spacer(minLength: 200)
                            Button("Delete All Data", role: .destructive) {
                                presentConfirmDelete = true
                            }
                            .confirmationDialog("Are you sure?", isPresented: $presentConfirmDelete) {
                                Button("I CONFIRM: Delete ALL Data", role: .destructive) {
                                    // Deletes all entries with class matching kSecClassGenericPassword
                                    let req: NSDictionary = [kSecClass: kSecClassGenericPassword]
                                    SecItemDelete(req)
                                    // Returns back to the main login screen
                                    screen = true
                                    logout()
                                }
                            }
                            Spacer()
                        }
                    }
                }
                
                // Navigation Bar at bottom of screen
                ZStack {
                    Rectangle()
                        .fill(Color("PrimaryColor").shadow(.drop(color: Color("SecondaryColor"), radius: 5)))
                        .frame(height: 55)
                    Rectangle()
                        .frame(height: 60)
                        .foregroundColor(Color("PrimaryColor"))
                    HStack {
                        Spacer()
                        Button(action: { screen = true }) {
                            Image(systemName: screen ? "folder.circle.fill" : "folder.circle")
                                .foregroundColor(screen ? Color("AccentColor") : Color("TextColor"))
                                .font(.title)
                                .padding(-10)
                            Text("Forms")
                                .foregroundColor(screen ? Color("AccentColor") : Color("TextColor"))
                                .font(.custom("Poppins-ExtraLight", size: 20))
                                .padding(15)
                        }
                        Spacer()
                        Spacer()
                        Button(action: { screen = false }) {
                            Image(systemName: !screen ? "archivebox.fill" : "archivebox")
                                .foregroundColor(!screen ? Color("AccentColor") : Color("TextColor"))
                                .font(.title2)
                                .padding(-10)
                            Text("Storage")
                                .foregroundColor(!screen ? Color("AccentColor") : Color("TextColor"))
                                .font(.custom("Poppins-ExtraLight", size: 20))
                                .padding(15)
                        }
                        Spacer()
                    }
                }.frame(maxHeight: .infinity, alignment: .bottom)
            }
        }.id(refreshID)
    }
    
    // Updates the rawData
    func refreshData() {
        do {
            guard let data = try KeychainManager.get(account: patientName)
            else {
                rawData = [patientName, patientID, [] as [Any], [] as [Any]]
                return
            }
            
            let raw = String(decoding: data, as: UTF8.self)
                .components(separatedBy: CharacterSet(charactersIn: ",\" "))
                .filter { !$0.isEmpty && !["[", "]"].contains($0) }
            rawData = [patientName] + raw ;
        } catch {
            rawData = [patientName, patientID, [] as [Any], [] as [Any]]
        }
    }
    
    // Prompts for device authentication after form is filled successfully
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if (context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Authentication is needed to return to the main menu.") { success, authenticationError in
                
                if success {
                    verified = true
                }
                else {
                    verified = false
                }
            }
        }
    }
    
    func search() {
        _ = find()
    }
    
    // Finds a patient by name and returns a String array with its data
    func find() -> String {
        // Exits the function if no name or password is provided
        if patientName.isEmpty || (!reqCount && patientID.isEmpty) {
            message = "Missing information."
            alert = true
            return ""
        }
        // Ensures that no patient name overrides the Count variable
        else if !reqCount && patientName == "Count" {
            message = "Conflicting name."
            alert = true
            return ""
        }
        
        // If searching for the data associated with the Count variable:
        if reqCount {
            if !patientID.isEmpty {
                return patientID
            }
            
            // Returns the ID of the Count variable (starting from 3000)
            do {
                guard let data = try KeychainManager.get(account: "Count") else { return "" }
                
                let password = String(decoding: data, as: UTF8.self)
                    .components(separatedBy: CharacterSet(charactersIn: "[,]\""))[2]
                return password
            }
            catch {
                do {
                    try KeychainManager.save(
                        account: "Count",
                        password: "3000",
                        consentForm: [],
                        invoice: []
                    )
                    return "3000"
                }
                catch {
                    message = "Error in creating count."
                    alert = true
                    return ""
                }
            }
        }
        // If searching for a normal patient user:
        else {
            do {
                guard let data = try KeychainManager.get(account: patientName)
                    else { return "" }
                
                let raw = String(decoding: data, as: UTF8.self)
                    .components(separatedBy: CharacterSet(charactersIn: ",\" "))
                    .filter { !$0.isEmpty && !["[", "]"].contains($0) }
                if raw[0] == patientID {
                    withAnimation(.easeIn(duration: 1.2))
                    { rawData = [patientName] + raw ; retrievedData = true }
                }
                else {
                    message = "Invalid password."
                    alert = true
                    return ""
                }
            } catch {
                message = "Could not retrieve patient."
                alert = true
                return ""
            }
        }
        return ""
    }
    
    // Saves the data of a patient
    func save() {
        if patientName.isEmpty {
            message = "Missing information."
            return alert = true
        }
        else if patientName == "Count" {
            message = "Conflicting name."
            return alert = true
        }
        
        // Note: Duplicates are allowed as common names may be duplicated
        // Therefore, there is no need to check for an existing user (patientName)
        
        reqCount = true
        patientID = self.find()
        reqCount = false
        do {
            // Saves patient data to KeyChain
            try KeychainManager.save(
                account: patientName,
                password: patientID,
                consentForm: [],
                invoice: []
            )
            // Ensures Count is saved as 3000 if nil (first patient is 3000)
            let count = (Int(patientID) == nil && !patientID.isEmpty)
                ? patientID
                : "3000"
            try KeychainManager.replace(
                account: "Count",
                password: Int(count) == nil
                    ? count
                    : String(Int(count)! + 1)
            )
            
            withAnimation(.easeIn(duration: 1.2)) {
                rawData = [patientName, patientID, [] as [Any], [] as [Any]]
                retrievedData = true
            }
        } catch {
            message = "Internal saving error."
            return alert = true
        }
    }
    
    // Resets all state variables to its defaults, returning to default view
    func logout() {
        rawData = []
        patientName = ""
        patientID = ""
        message = ""
        alert = false
        new = false
        retrievedData = false
        verified = false
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

// Returns a String array representation of the current patient's data
func retrieveData() -> [Any] {
    return rawData
}

// Returns a string dicitonary of all patient data
func getAllPatientData() -> [String : String] {
    return HomeView().getAllKeyChainItemsOfClass(kSecClassGenericPassword as String)
}
