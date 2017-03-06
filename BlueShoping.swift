

/*
* Copyright 2017-2018 IBM Corporation
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

/**
*  Action to Send Push Notification using IBM Push Notifications service
*
*  @param {string} appId - Bluemix app GUID .
*  @param {string} appSecret - Bluemix Push Service appSecret.
*  @param {string} version - This is the version of the Tone analyzer service .
*  @param {object} message - The test value that is passing to the Tone analyzer service as user Input.
*  @param {string} cloudantUserName - Your cloudant username. This is for accessing your `mood` database in cloudant.
*  @param {object} cloudantPassword - Your cloudant password. This is for accessing your `mood` database in cloudant.
*  @param {string} deviceIds - The deviceId to which the message need to be send. This data will come from the `complaints` database.
*  @param {string} name - Name of the customer. This data will come from the `complaints` database.
*  @param {string} time - Time interval you need to add.

*  @return {object} whisk async.
*/
import KituraNet
import Foundation
import SwiftyJSON


func main(args: [String:Any]) -> [String:Any] {

  var result = "nothing"
  let version = args["version"] as? String;
  let userInput = args["message"] as? String;
  var toneMessage =  args["message"] as? String;

  let data = "{\"text\": \"\(toneMessage!)\"}".data(using: .utf8)

  //let cloudantUserName = args["cloudantUserName"] as? String;
  //let cloudantPassword = args["cloudantPassword"] as? String;

  let cloudantUserName = args["cloudantUserName"] as? String;
  let cloudantPermissionKey = args["cloudantPermissionKey"] as? String;
  let cloudantPermissionPassword = args["cloudantPermissionPassword"] as? String;
  let cloudantDbname = "mood";

  var appSecret = args["appSecret"] as? String;
  var appId = args["appId"] as? String;
  var deviceAarray = args["deviceIds"] as? String;
  var name = args["name"] as? String;

  var requestOptions: [ClientRequest.Options] = []
  requestOptions.append(.method("POST"))
  requestOptions.append(.schema("https://"))
  requestOptions.append(.hostname("watson-api-explorer.mybluemix.net"))
  requestOptions.append(.path("/tone-analyzer/api/v3/tone?version=2016-05-19"))
  requestOptions.append(.headers(["Accept":"application/json","Content-Type":"application/json"]))

   let req = HTTP.request(requestOptions) { resp in
        if let resp = resp, resp.statusCode == HTTPStatusCode.OK {
            do {
                var body = Data()
                try resp.readAllData(into: &body)
                let response = JSON(data: body)



                 var dic = response["document_tone"]["tone_categories"][0];
           var array = dic["tones"];
         var indexVale = "message"  
           var value = 0;

           for (index, object) in array {
              let name = Int((object["score"].floatValue)*100.0)
             if(value <= name ) {
                   value = name;
                   print (value)
                  indexVale = (object["tone_name"].string)!;
                }
          }
        print("High value is : \(indexVale)")

        let url = "\(cloudantUserName!).cloudant.com"
        let path = "/\(cloudantDbname)/_design/moodPick/_view/new_view?keys=[\"\(indexVale)\"]";

        print(url)
        print(path)

        var requestOptions1: [ClientRequest.Options] = []
          requestOptions1.append(.method("GET"))
        requestOptions1.append(.schema("http://"))
          requestOptions1.append(.hostname(url))
          requestOptions1.append(.path(path))

        let authData = "\(cloudantPermissionKey!):\(cloudantPermissionPassword!)"

        let dataer = authData.data(using: .utf8)
        let base64 = dataer!.base64EncodedString()
        print(base64)
        requestOptions1.append(.headers(["Authorization":"Basic \(base64)"]))

          let req1 = HTTP.request(requestOptions1) { resp in 
              if let resp = resp, resp.statusCode == HTTPStatusCode.OK {

                  do {
                     var body = Data()
                       try resp.readAllData(into: &body)
                       let response = JSON(data: body)
                       var i = 0;
                       for (index, object) in response {
                        if let string: Any  = object.object {
                        let json =  JSON(string)
              if let jsonObject: Any = json.object{
                print(jsonObject)
                  if let jj = jsonObject as? [[String:String]] {

                        let g = jj[0]["value"] ; 
                        print("ooo yeah \(g!)")

                        var intro = "Hi \(name!) , \(g!)";
                      Whisk.invoke(actionNamed:"/whisk.system/pushnotifications/sendMessage",withParameters:["appSecret":appSecret!,"appId":appId!,"deviceIds":deviceAarray!,"text":intro])
                  }}
            }
                       }
                  }catch {
                      print("Error parsing JSON ")
                  }

              }else {
                  if let resp = resp {
                //request failed
                      print("Error ; status code \(resp.statusCode) returned")
                  } else {
                     print("Error")
                 }
              }
          }
          req1.end()
               } catch {
                print("Error parsing JSON ")
            }
        } else {
            if let resp = resp {
                //request failed
                print("Error ; status code \(resp.statusCode) returned")
            } else {
                print("Error ")
            }
        }
    }
    req.write(from:data!) 
    req.end()
    return [ "greeting" : result ]
}
