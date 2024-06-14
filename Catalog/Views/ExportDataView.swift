//
//  ExportDataView.swift
//  Catalog
//
//  Created by Allen Guo-Lu on 2024-06-14.
//

import SwiftUI

struct ExportDataView: View {
    
    @State private var dataStrings: [String] = []
    @State private var exportURL = URL(string: "")
    
    var mainContent: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(dataStrings, id: \.self) { string in
                    Text(string)
                        .foregroundStyle(Color("BackgroundColor"))
                        .font(.custom("Poppins-Regular", size: 14))
                }
            }.onAppear {
                let patientData = getAllPatientData()
                for (key, value) in patientData {
                    dataStrings.append("Name: \(key)\nData: \(value)\n")
                }
            }
            .padding(.all, 75)
        }
        .background(Color("SecondaryColor"))
        .cornerRadius(10)
        .padding(.all, 100)
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            if exportURL != nil {
                ShareLink(
                    item: exportURL!
                )
                {
                    Text("Save as PDF")
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
            }
            
            mainContent
            
            Spacer(minLength: 200)
        }.onAppear {
            exportToPDF()
        }
    }
    
    // Sourced from: https://stackoverflow.com/a/60753437
    func exportToPDF() {

        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputFileURL = documentDirectory.appendingPathComponent("SwiftUI.pdf")

        //Normal with
        let width: CGFloat = 8.5 * 72.0
        //Estimate the height of your view
        let height: CGFloat = 1000
        let rootView = mainContent

        let pdfVC = UIHostingController(rootView: rootView)
        pdfVC.view.frame = CGRect(x: 0, y: 0, width: width, height: height)

        //Render the view behind all other views
        let rootVC = UIApplication.shared.keyWindow_?.rootViewController
        rootVC?.addChild(pdfVC)
        rootVC?.view.insertSubview(pdfVC.view, at: 0)

        //Render the PDF
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 8.5 * 72.0, height: height))
        
        DispatchQueue.main.async {
            do {
                try pdfRenderer.writePDF(to: outputFileURL, withActions: { (context) in
                    context.beginPage()
                    pdfVC.view.layer.render(in: context.cgContext)
                })
                
                exportURL = outputFileURL
                
            } catch {
                print("Could not create PDF file: \(error)")
            }
        }

        pdfVC.removeFromParent()
        pdfVC.view.removeFromSuperview()
    }
}

#Preview {
    ExportDataView()
}
