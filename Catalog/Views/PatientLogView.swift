//
//  PatientLogView.swift
//  Catalog
//
//  Created by Allen Guo-Lu on 2024-05-30.
//

import SwiftUI

struct PatientLogView: View {
    
    @State private var image: Image? = nil
    @State private var showingImage = false
    @State private var refreshState = 0
    
    @State private var openConsentFormView = false
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    /*
                    if checkNil() {
                        img.onAppear {
                            showingImage = true
                        }
                    }
                    else if ({ print("NO IMAGE") ; return true })() {
                        
                    } */
                    if !showingImage {
                        Text("Patient Consent Form")
                            .fixedSize()
                            .font(.custom("Poppins-Regular", size: 16))
                            .padding(.leading, 150)
                            .padding(.trailing, 50)
                            .id(refreshState)
                        Spacer()
                        Button(action: {  }) {
                            Text("Export PDF")
                                .font(.custom("Poppins-Regular", size: 16))
                                .frame(width: 150, height: 50)
                                .foregroundColor(Color("TextColor"))
                                .background(Color("AccentColor"))
                                .cornerRadius(50)
                                .padding(.trailing, -100)
                        }
                        Button(action: {
                            // openConsentFormView.toggle()
                            image = returnScreenshot()
                            showingImage = true
                        })
                        {
                            Text("Image")
                                .font(.custom("Poppins-Regular", size: 16))
                                .frame(width: 150, height: 50)
                                .foregroundColor(Color("TextColor"))
                                .background(Color("AccentColor"))
                                .cornerRadius(50)
                                .frame(width: 400, height: 50)
                        }
                        /*
                        .navigationDestination(isPresented: $openConsentFormView) {
                            ConsentFormView(
                                loadStaticView: true
                            ).onAppear {
                                image = returnScreenshot()
                                print("image: \(checkNil())")
                                refreshState += 1
                                showingImage = true
                            }
                        } */
                    }
                    else if image == nil {
                        Text("Nothing appearing? Load the view first in the Forms tab and try again!")
                            .font(.custom("", size: 16))
                    }
                    else {
                        VStack {
                            Spacer(minLength: 100)
                            // Known bug with iOS 17.3: ignore any entitlement errors in XCode
                            ShareLink(
                                item: image!,
                                preview: SharePreview("PatientLog_\(getTime())", image: image!)
                            )
                            {
                                Text("Share Image")
                                    .font(.custom("Poppins-Regular", size: 16))
                                    .frame(width: 150, height: 50)
                                    .foregroundColor(Color("TextColor"))
                                    .background(Color("AccentColor"))
                                    .cornerRadius(50)
                                    .frame(width: 400, height: 50)
                            }
                            .onAppear {
                                print("loaded")
                            }
                            image
                            Spacer()
                        }
                    }
                }
            }
        }
    }
    
    func getTime() -> String {
        let now = Date()
        let calendar = Calendar.current
        let query: Set<Calendar.Component> = [
            .year,
            .month,
            .day
        ]
        let rawDate = calendar.dateComponents(query, from: now)
        return String(rawDate.year!) + String(rawDate.month!) + String(rawDate.day!)
    }
    
    /*
    func checkNil() -> Bool {
        if let img = image {
            print("HAS IMAGE")
            return false
        }
        else {
            print("NO IMAGE")
            return true
        }
    } */
    
    func setImage() {
        image = returnScreenshot()
    }
}

struct PatientLogView_Previews: PreviewProvider {
    static var previews: some View {
        PatientLogView()
    }
}
