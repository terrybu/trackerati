# trackerati-ios
Hackerati time tracker app for iOS

Trackerati-ios is an iOS app that allows the users to browse through existing projects to add themselves and to submit hours. 

#Contributing

We use [synx](https://github.com/venmo/synx) to keep the file structure of the project neat and organized. Please note that The contents in the `Resources` directory of the `HockeySDK.embeddedframework` gets deleted when this runs even if you exclude the `Frameworks` directory. The work around is to download the [latest version of the Hockey SDK](http://hockeyapp.net/releases/) and copy the `Resources` directory from the image and paste it in the `HockeySDK.embeddedframework` directory (which can be found in `App/Trackerati/Frameworks/`) and overwrite the current `Resource` directory in Finder

#Pods

Trackerati uses these pods as of now:

- [AFNetworking](https://github.com/AFNetworking/AFNetworking)
   * Handles network monitoring
- [Firebase](https://www.firebase.com/docs/ios/)
   * Current data store
- [Google Plus SDK](https://developers.google.com/+/mobile/ios/getting-started)
   * For OAuth 2.0 and the user must give his/her permission to user profile and email adress.
- [MBProgressHUD](https://github.com/jdg/MBProgressHUD)
   * For general, full page loading indicators

# Data

The submitted records are stored in Firebase. 

There are 2 environments and URLs for each:

* Dev: `https://trackerati-dev.firebaseio.com`
   * For access to this, please contact **Patrick**
* Production: `blazing-torch-6772.firebaseio.com`
   * For access to this, please contact **Geoff**

The structure of the data for both environments are as follows:

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
          "date"    :"MM/dd/yyyy", //Must be in a string format - ex "01/05/2015"
          "hour"    :"8", //Must be in a string format
          "comment" :"optional", //Must be in a string format but is optional
          "type"    :"1" // Must be in a string format - used to denote billable ("1") or unbillable ("0")
          "status"  :"1" // Must be in a string format - used to denote full-time ("1") or part-time ("0")
          }
        }
      }
  }
}
```

**NOTE: A node must have at least one value otherwise it will be deleted. As such a placeholder is placed in every node to prevent it from deleting.**

Below is the validation rule on FireBase

```json
{
    "rules": {
        ".read": true,
        ".write": true,
        "Users":{
          "$username":{
              "records":{
                ".indexOn": ["date"],
                "$newrecords":{
                  "comment":{
                    ".validate": "newData.isString() && newData.val().length < 301" 
                  },
                  "date":{
                   ".validate": "newData.isString() && newData.val().matches(/^(0[1-9]|1[012])[/](0[1-9]|[12][0-9]|3[01])[/](19|20)[0-9][0-9]/) && newData.val().length == 10"
                 },
                 "type":{
                   ".validate": "newData.isString() && newData.val().matches(/^[0-1]/) && newData.val().length == 1"
                 },
                 "status":{
                   ".validate": "newData.isString() && newData.val().matches(/^[0-1]/) && newData.val().length == 1"
                 },
                 "hour":{
                   ".validate": "newData.isString() && newData.val().matches(/^[0.5,1.0,1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5,7.0,7.5,8.0,8.5,9.0,9.5,10.0, 10.5,11.0,11.5,12.0,12.5,13.0,13.5,14.0,14.5,15.0,15.5,16.0,16.5,17.0,17.5,18.0,18.5,19.0,19.5,20.0,20.5,21.0,21.5,22.0,22.5,23.0,23.5,24.0]/)"
                 },
                 "client":{
                    ".validate": "newData.isString() && newData.val().length > 0 && newData.val().length < 300" 
                  },
                  "project":{
                    ".validate": "newData.isString() && newData.val().length > 0 && newData.val().length < 300" 
                  }
                }
              }  
          }
        },
        "Projects":{
          "$client":{
            "$project":{
              "$user":{
                "name":{
                  ".validate": "newData.isString() && newData.val().length > 0 && newData.val().length < 300 && newData.val().matches(/^[a-zA-Z]/)"   
                }
              }
            }
          }
        }
    }
}
```
