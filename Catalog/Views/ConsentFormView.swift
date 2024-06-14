//
//  ConsentFormView.swift
//  Catalog
//
//  Created by Allen Guo-Lu on 2024-05-27.
//

import SwiftUI
import Combine
import LocalAuthentication

var uiImage: UIImage? = nil
var displayAsComplete = false

struct ConsentFormView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var loadStaticView = false
    
    @State private var rawData = retrieveData().indices.contains(3)
        ? retrieveData()
        : ["Sample", "3000", [] as [Any], [] as [Any]]
    
    @State private var birthDate = Date()
    @State private var selection = ""
    @State private var address = ""
    @State private var postal = ""
    @State private var home = ""
    @State private var cell = ""
    @State private var email = ""
    @State private var contact = ""
    @State private var relationship = ""
    @State private var contactPhone = ""
    @State private var reason = ""
    
    @State private var message = ""
    @State private var alert = false
    
    @State private var done = false
    
    var mainContent: some View {
        VStack {
            HStack {
                Spacer()
                Text("File Number:  \(String(describing: rawData[1]))          ")
                    .font(.custom("BookAntiqua", size: 13))
                    .padding([.top, .trailing], 30)
                    .padding(.bottom, -40)
            }
            Text("Patient Consent Form")
                .font(.custom("BookAntiqua", size: 24))
                .padding(.top, 30)
            Rectangle().fill(Color("TextColor"))
                .frame(width: 700, height: 1, alignment: .center)
                .padding(.top, -10)
            VStack {
                HStack {
                    Text("Patient Information:")
                        .font(.custom("BookAntiqua", size: 21))
                        .padding(.leading, 30)
                        .padding(.top, 5)
                    Spacer()
                }
                HStack {
                    Text("Legal Name:   \(String(describing: rawData[0]))")
                        .font(.custom("BookAntiqua", size: 15))
                        .padding(.leading, 30)
                        .padding(.top, 5)
                    Spacer()
                }
                HStack {
                    DatePicker("Birthdate:", selection: $birthDate, displayedComponents: .date)
                        .fixedSize()
                        .frame(width: 200)
                        .font(.custom("BookAntiqua", size: 15))
                        .padding(.leading, 27)
                        .padding(.top, -5)
                    Group {
                        Text("Gender:")
                            .fixedSize()
                            .font(.custom("BookAntiqua", size: 15))
                            .padding(.leading, 290)
                        Picker("Gender", selection: $selection) {
                            let array = ["Male", "Female", "Other"]
                            Text(selection.isEmpty ? "Select" : selection)
                                .font(.custom("BookAntiqua", size: 15))
                                .tag("")
                            ForEach(array, id: \.self) {
                                Text($0)
                            }
                        }.padding(.leading, 0)
                    }
                    Spacer()
                }.padding(.vertical, -0.2)
                HStack {
                    Text("Home Address:")
                        .font(.custom("BookAntiqua", size: 15))
                        .padding(.leading, 30)
                    TextField("__________________________________________________", text: $address)
                        .onReceive(Just(address)) { newValue in
                            let filtered = newValue.filter { "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,. ".contains($0) }
                            if filtered != newValue {
                                self.address = filtered
                            }
                        }
                        .fixedSize()
                        .font(.custom("BookAntiqua", size: 15))
                    Text("Postal Code:")
                        .font(.custom("BookAntiqua", size: 15))
                        .padding(.leading, 0)
                    TextField("_______________", text: $postal)
                        .onReceive(Just(postal)) { newValue in
                            let filtered = newValue.filter { "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".contains($0) }
                            if filtered != newValue || newValue.count > 6 {
                                self.postal = filtered.uppercased()
                            }
                        }
                        .autocorrectionDisabled(true)
                        .keyboardType(.asciiCapable)
                        .textInputAutocapitalization(.characters)
                        .font(.custom("BookAntiqua", size: 15))
                }.padding(.top, -5)
                HStack {
                    Text("Phone:    Home:")
                        .fixedSize()
                        .font(.custom("BookAntiqua", size: 15))
                        .padding(.leading, 30)
                    TextField("_________________", text: $home)
                        .onReceive(Just(home)) { newValue in
                            let filtered = newValue.filter { "0123456789()- ".contains($0) }
                            if filtered != newValue {
                                self.home = filtered
                            }
                        }.fixedSize()
                        .keyboardType(.numbersAndPunctuation)
                        .font(.custom("BookAntiqua", size: 15))
                    Text("Cell:")
                        .fixedSize()
                        .font(.custom("BookAntiqua", size: 15))
                        .padding(.leading, 10)
                    TextField("_________________________", text: $cell)
                        .onReceive(Just(cell)) { newValue in
                            let filtered = newValue.filter { "0123456789()- ".contains($0) }
                            if filtered != newValue {
                                self.cell = filtered
                            }
                        }.fixedSize()
                        .keyboardType(.numbersAndPunctuation)
                        .font(.custom("BookAntiqua", size: 15))
                    Text("Email:")
                        .fixedSize()
                        .font(.custom("BookAntiqua", size: 15))
                        .padding(.leading, 0)
                    TextField("_____________________", text: $email)
                        .onReceive(Just(email)) { newValue in
                            let filtered = newValue.filter { "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ@.".contains($0) }
                            if filtered != newValue {
                                self.email = filtered
                            }
                        }.fixedSize()
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .padding(.leading, -3)
                        .font(.custom("BookAntiqua", size: 15))
                    Spacer()
                }
                HStack {
                    Text("Emergency Contact:")
                        .font(.custom("BookAntiqua", size: 15))
                        .padding(.leading, 30)
                    TextField("______________", text: $contact)
                        .onReceive(Just(contact)) { newValue in
                            let filtered = newValue.filter { "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ".contains($0) }
                            if filtered != newValue {
                                self.contact = filtered
                            }
                        }.fixedSize()
                        .keyboardType(.alphabet)
                        .autocorrectionDisabled(true)
                        .font(.custom("BookAntiqua", size: 15))
                    Spacer()
                    Text("Relationship:")
                        .font(.custom("BookAntiqua", size: 15))
                    TextField("__________________", text: $relationship)
                        .onReceive(Just(relationship)) { newValue in
                            let filtered = newValue.filter { "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ".contains($0) }
                            if filtered != newValue {
                                self.relationship = filtered
                            }
                        }
                        .fixedSize()
                        .keyboardType(.alphabet)
                        .textInputAutocapitalization(.sentences)
                        .font(.custom("BookAntiqua", size: 15))
                    Text("Phone:")
                        .font(.custom("BookAntiqua", size: 15))
                        .padding(.trailing, 2)
                    TextField("____________________", text: $contactPhone)
                        .onReceive(Just(contactPhone)) { newValue in
                            let filtered = newValue.filter { "0123456789()- ".contains($0) }
                            if filtered != newValue {
                                self.contactPhone = filtered
                            }
                        }
                        .keyboardType(.numbersAndPunctuation)
                        .font(.custom("BookAntiqua", size: 15))
                    Spacer()
                }
                HStack {
                    Text("Reason for your visit:")
                        .font(.custom("BookAntiqua-Bold", size: 15))
                        .padding(.leading, 30)
                    TextField("________________________________________________________________________", text: $reason)
                        .fixedSize()
                        .onReceive(Just(reason)) { newValue in
                            let filtered = newValue.filter { "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ".contains($0) }
                            if filtered != newValue {
                                self.reason = filtered
                            }
                        }.fixedSize()
                        .padding(.leading, 5)
                        .keyboardType(.alphabet)
                        .font(.custom("BookAntiqua", size: 15))
                    Spacer()
                }
            }
        }
    }
    
    var body: some View {
        if !done {
            VStack {
                mainContent
                    .id(loadStaticView)
                    .onAppear {
                        displayAsComplete = false
                        fillForm()
                        screenshotForm()
                    }
                
                Spacer()
                
                if !displayAsComplete {
                    Button(action: submit) {
                        Text("Submit")
                            .font(.custom("Poppins-Regular", size: 22))
                            .padding(.bottom, 100)
                    }.alert(message, isPresented: $alert) { }
                }
            }.edgesIgnoringSafeArea(.all)
        }
        else {
            VStack {
                Button(action: authenticate) {
                    Text("Unlock")
                        .foregroundColor(Color("FadedAccentColor"))
                }
                Spacer()
                Text("Thank you for filling this form!")
                    .font(.custom("OpenSans-Regular", size: 30))
                    .padding(8)
                Text("Please return this device to the front desk.")
                Spacer(minLength: 475)
                
            }
        }
    }
    
    func getDate(str: String) -> Date? {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-ddHH:mm:ss"
        
        let startIndex = str.index(str.startIndex, offsetBy: 1)
        let endIndex = str.index(str.endIndex, offsetBy: 0)
        let range = startIndex ..< endIndex
        
        return format.date(from: String(str[range]))
    }
    
    func fillForm() {
        if !retrieveData().indices.contains(17) {
            return
        }
        rawData = retrieveData()
        birthDate = getDate(str: "\(rawData[2])\(rawData[3])" ) ?? Date()
        selection = rawData[5] as! String
        address = "\(rawData[6]) \(rawData[7]) \(rawData[8]) \(rawData[9])"
        postal = rawData[10] as! String
        home = rawData[11] as! String
        cell = rawData[12] as! String
        email = rawData[13] as! String
        contact = rawData[14] as! String
        relationship = rawData[15] as! String
        contactPhone = rawData[16] as! String
        reason = rawData[17] as! String
    }
    
    func screenshotForm() {
        uiImage = UIApplication.shared.keyWindow_?.rootViewController?.view.asImage()
        if loadStaticView {
            exit()
        }
    }
    
    func getTime() -> [Int] {
        let now = Date()
        let calendar = Calendar.current
        let query: Set<Calendar.Component> = [
            .year,
            .month,
            .day
        ]
        let rawDate = calendar.dateComponents(query, from: now)
        return [rawDate.year!, rawDate.month!, rawDate.day!]
    }
    
    func submit() {
        if selection.isEmpty || address.isEmpty || postal.isEmpty || home.isEmpty || cell.isEmpty || email.isEmpty || contact.isEmpty || relationship.isEmpty || contactPhone.isEmpty || reason.isEmpty {
            message = "Missing fields. Please fill in all parts of the form!"
            alert = true
            return
        }
        
        do {
            let date = getTime()
            try KeychainManager.replace(
                account: String(describing: rawData[0]),
                password: String(describing: rawData[1]),
                consentForm: [birthDate, selection, address, postal, home,
                      cell, email, contact, relationship, contactPhone,
                      reason, date[0], date[1], date[2]]
            )
            withAnimation(.easeIn(duration: 0.7)) { done = true }
        } catch {
            message = "Could not submit entries."
            alert = true
        }
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if (context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Authentication is needed to return to the main menu.") { success, authenticationError in
                if success {
                    DispatchQueue.main.async {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                else {
                    message = "Could not authenticate user."
                    alert = true
                }
            }
        }
    }
    
    func exit() {
        loadStaticView = false
        DispatchQueue.main.async {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

func returnScreenshot() -> Image? {
    if uiImage == nil { return nil }
    displayAsComplete = true
    return Image(uiImage: uiImage!)
}

// inspired by: https://stackoverflow.com/questions/68387187/how-to-use-uiwindowscene-windows-on-ios-15
extension UIApplication {
    
    var keyWindow_: UIWindow? {
        // Get connected scenes
        return self.connectedScenes
            // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
            // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
            // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
    
}

// https://stackoverflow.com/questions/30696307/how-to-convert-a-uiview-to-an-image
extension UIView {
    
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

struct ConsentFormView_Previews: PreviewProvider {
    static var previews: some View {
        ConsentFormView()
    }
}
