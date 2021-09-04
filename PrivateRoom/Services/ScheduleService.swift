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
    
    private let jwtToken: String
    private let userId: Int
    
    init(){
        userId = UserDefaults.standard.integer(forKey:  UserDefaultKey.userID)
        jwtToken = UserDefaults.standard.string(forKey: UserDefaultKey.jwtToken)!
    }
    
    //스케쥴 조회 o
    func getSchedule(completion: @escaping (([GetScheduleResponse]) -> Void)){
        let url = Config.base_url + "/users/\(userId)/schedules"
        let headers: HTTPHeaders = ["Authorization" : jwtToken,
                                    "Content-Type" : "application/json" ]
        
        
        AF.request(url, method: .get, headers: headers).validate(statusCode: 200..<300).responseJSON {
            (response) in
            print("[ScheduleService] 스케줄 조회하기")
            switch response.result {
                case .success(let obj):
                    do {
                        print(obj)
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
    func createSchedule(schedule: PostScheduleRequest, completion: @escaping (Int)-> (Void)){
        let url = Config.base_url + "/users/\(userId)/schedules"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"

        request.addValue(jwtToken, forHTTPHeaderField: "Authorization")
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
        
        
        
        AF.request(request).validate(statusCode: 200..<300).responseJSON { (response) in
            print("[ScheduleService] 스케줄 생성")
            switch response.result {
                case .success(let obj):
                    print(obj)
                    let responseID = obj as! Int
                    completion(responseID)
                    break
                case .failure(let error):
                    print(error)
            }
        }

    }
    
    
    //스케쥴 수정
    func editSchedule(schedule: PutScheduleRequest){
        let url = Config.base_url + "/users/\(userId)/schedules/\(schedule.scheduleId)"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "PUT"

        request.addValue(jwtToken, forHTTPHeaderField: "Authorization")
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
        
        
        AF.request(request).validate(statusCode: 200..<300).responseString { (response) in
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
        let url =  Config.base_url + "/users/\(userId)/schedules/\(scheduleID)"
        let headers: HTTPHeaders = ["Authorization" : jwtToken,
                                    "Content-Type" : "application/json" ]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "DELETE"

        AF.request(url, method: .delete, encoding: URLEncoding.httpBody, headers: headers).validate(statusCode: 200..<300).responseString { (response) in
            print("[ScheduleService] 스케줄 삭제하기")
            switch response.result {
                case .success(let obj):
                    let responses = obj 
                   print(responses) //스케쥴 삭제 완료
                    break
                case .failure(let error):
                    print(error)
            }
        }
    }
    
}
