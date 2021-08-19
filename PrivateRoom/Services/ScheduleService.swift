//
//  ScheduleService.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/10.
//

import Foundation
import Alamofire

class ScheduleService {
    static var shared = ScheduleService()
    
    private let deviceToken: String
    private let userId: Int
    
    init(){
        userId = UserDefaults.standard.integer(forKey:  UserDefaultKey.userID)
        deviceToken = UserDefaults.standard.string(forKey: UserDefaultKey.deviceToken)!
    }
    
    //스케쥴 조회 o
    func getSchedule(completion: @escaping (([GetScheduleResponse]) -> Void)){
        let url = Config.base_url + "/users/\(userId)/schedules"
        let headers: HTTPHeaders = ["Authorization" : deviceToken]
        AF.request(url, method: .get, headers: headers).validate(statusCode: 200...500).responseJSON {
            (response) in
            switch response.result {
                case .success(let obj):
                    do {
                        let dataJSON = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                        let postData = try JSONDecoder().decode([GetScheduleResponse].self, from: dataJSON)
                        completion(postData)
                    }catch {
                        print(error)
                    }
                    break
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    
    //스케쥴 생성 o
    func createSchedule(schedule: PostScheduleRequest){
        let url = Config.base_url + "/users/\(userId)/schedules"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"

        request.addValue(deviceToken, forHTTPHeaderField: "Authorization")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(schedule)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            print(jsonString)
            request.httpBody = jsonData
            // and decode it back
            let decoded = try JSONDecoder().decode(PostScheduleRequest.self, from: jsonData)
            print(decoded)
        } catch { print(error) }
        
        
        
        AF.request(request).responseString { (response) in
            print("[ScheduleService] 스케줄 생성")
            switch response.result {
                case .success(let obj):
                    print(obj) //스케줄 생성 완료
                
                    break
                case .failure(let error):
                    print(error)
            }
        }
        
//        let formDataString = (schedule.dictionary.compactMap({(key, value) -> String in
//            return "\(key)=\(value)" }) as Array).joined(separator: "&")
//        let formEncodedData = formDataString.data(using: .utf8)
//
//        let headers: HTTPHeaders = ["Authorization" : deviceToken]
//        request.httpBody = formEncodedData
//        AF.request(url, method: .post, parameters: parameter, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response) in
//            switch response.result {
//                case .success(let obj):
//                    let responses = obj as! String
//                   print(responses) //스케쥴 생성 완료
//                    break
//                case .failure(let error):
//                    print(error)
//            }
//        }
    }
    
    
    //스케쥴 수정
    func editSchedule(schedule: PutScheduleRequest){
        let url = "/users/\(userId)/schedules/\(schedule.scheduleId)"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "PUT"

        request.addValue(deviceToken, forHTTPHeaderField: "Authorization")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(schedule)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            print(jsonString)
            request.httpBody = jsonData
            // and decode it back
            let decoded = try JSONDecoder().decode(PutScheduleRequest.self, from: jsonData)
            print(decoded)
        } catch { print(error) }
        
        
        
        AF.request(request).responseString { (response) in
            print("[ScheduleService] 스케줄 수정하기")
            switch response.result {
                case .success(let obj):
                    print(obj) //스케줄 수정 완료
                
                    break
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    func deleteSchedule(scheduleID: Int){
        let url = "/users/\(userId)/schedules/\(scheduleID)"
        let headers: HTTPHeaders = ["Authorization" : deviceToken]
        //let parameter: Parameters = schedule.dictionary
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "DELETE"
//        let formDataString = (schedule.dictionary.compactMap({(key, value) -> String in
//            return "\(key)=\(value)" }) as Array).joined(separator: "&")
        //let formEncodedData = formDataString.data(using: .utf8)
        
        
        //request.httpBody = formEncodedData
        AF.request(url, method: .delete, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response) in
            switch response.result {
                case .success(let obj):
                    let responses = obj as! String
                   print(responses) //스케쥴 삭제 완료
                    break
                case .failure(let error):
                    print(error)
            }
        }
    }
    
}
