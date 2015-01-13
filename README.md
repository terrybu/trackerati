# trackerati-ios
Hackerati time tracker app for iOS

Trackerati-ios is an iOS app that allows the users to browse through existing projects to add themselves and to submit hours. 
It ulitizes Google OAuth 2.0 and the user must give his/her permission to user profile and email adress.
The submitted records are stored in Firebase. --> blazing-torch-6772.firebaseio.com
The structure of the data is as follows:
```json
{
  "Projects":{
    "Client Name":{
      "Project Name":{
        "Unique Identifier":{
          "name":"User unique name" //Must be in a string format
          }
        }
      }  
  },
  "Users":{
    "User unique name":{
      "records":{
        "Unique Identifier":{
          "client"  :"sample client", //Must be in a string format
          "project" :"sample project", //Must be in a string format
          "date"    :"MM/dd/yyyy", //Must be in a string format - "01/05/2015"
          "hour"    :"8", //Must be in a string format
          "comment" :"optional" //Must be in a string format but is optional 
          }
        }
      }
  }
}
'''
** A node must have at least one value otherwise it will be deleted. As such a placeholder is placed in every node to prevent it from deleting. **

Pod install
source 'https://github.com/CocoaPods/Specs.git'
pod 'Firebase', '>= 2.0.3'
pod 'MCSwipeTableViewCell'
pod 'KNSemiModalViewController'
