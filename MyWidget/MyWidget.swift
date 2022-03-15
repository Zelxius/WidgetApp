//
//  MyWidget.swift
//  MyWidget
//
//  Created by Colimasoft on 14/03/22.
//

import WidgetKit
import SwiftUI

// MODELO VAR

struct Modelo : TimelineEntry {
    var date: Date
    var widgetData : [JsonData]
}

struct JsonData: Decodable {
    var id : Int
    var name : String
    var email : String
}


// PROVIDER

struct Provider : TimelineProvider {
    
    func placeholder(in context: Context) -> Modelo{
        return Modelo(date: Date(), widgetData: Array(repeating: JsonData(id: 0, name: "", email: ""), count: 2))
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Modelo) -> Void) {
        completion(Modelo(date: Date(), widgetData: Array(repeating: JsonData(id: 0, name: "", email: ""), count: 2)))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Modelo>) -> Void) {
        getJson { (modelData) in
            let data = Modelo(date: Date(), widgetData: modelData)
            guard let update = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) else { return }
            let timeline = Timeline(entries: [data], policy: .after(update))
            completion(timeline)
        }
    }
    
    typealias Entry = Modelo
    
}

func getJson(completion: @escaping([JsonData]) -> ()){
    guard let url = URL(string: "https://jsonplaceholder.typicode.com/comments?postId=1") else { return }
    
    URLSession.shared.dataTask(with: url){data,_,_ in
        guard let data = data else { return }
        
        do {
            let json = try JSONDecoder().decode([JsonData].self, from: data)
            DispatchQueue.main.async {
                completion(json)
            }
        } catch let error as NSError {
            print("Fallo", error.localizedDescription)
        }
    }.resume()
}

// DISEÑO - VISTA

struct vista : View {
    let entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View{
        switch family {
        case .systemSmall:
            VStack(alignment: .center){
                Text("Mi Lista")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                Spacer()
                Text(String(entry.widgetData.count)).font(.custom("Arial", size: 80)).bold()
                Spacer()
            }
        case .systemMedium:
            VStack(alignment: .center){
                Text("Mi Lista")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                Spacer()
                VStack(alignment: .leading){
                    Text(entry.widgetData[0].name).bold()
                    Text(entry.widgetData[0].email)
                    Text(entry.widgetData[1].name).bold()
                    Text(entry.widgetData[1].email)
                }.padding(.leading)
                Spacer()
            }
        default:
            VStack(alignment: .center){
                Text("Mi Lista")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                Spacer()
                VStack(alignment: .leading){
                    ForEach(entry.widgetData, id:\.id){ item in
                        Text(item.name).bold()
                        Text(item.email)
                    }
                }.padding(.leading)
                Spacer()
            }

        }
    }
}

// CONFIGURACION

@main
    struct HelloWidget: Widget {
        var body: some WidgetConfiguration{
            StaticConfiguration(kind: "widget", provider: Provider()) { entry in
                vista(entry: entry)
            }.description("descripcion del widget")
                .configurationDisplayName("nombre del widget")
                .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        }
    }
