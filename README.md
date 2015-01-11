# trackerati-ios
Hackerati time tracker app for iOS

This is an iOS app that allows the users to browse through existing projects to add themselves to it and submit hours worked on that project. 
It ulitizes Google OAuth 2.0 and the user must give his/her permission to user profile and email adress.
The submitted records are stored in Firebase. --> blazing-torch-6772.firebaseio.com
The structure of the data is as follows:
```json
{
  "Projects":{
    "Client Name":{
      "Project Name":{
        "Unique Identifier":{
          "name":"placeholder"
          }
        }
      }  
  }
  "Users":{
    "user unqiue name":{
      "records":{
        "Unique Identifier":{
          "name":"placeholder"
          }
        }
      }
  }
}
'''
** A node must have at least one value otherwise it will be deleted. As such a "placeholder" is placed in every tree to prevent it from deleting. **

