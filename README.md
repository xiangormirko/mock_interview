#Mok 
Mock Interview iOS app completed by Mirko Xiang Zhao

GENERAL DESCRIPTION

The apps pulls general information from Glassdoor. User may add interview questions and undergo a mock interview session wher audio will be recorded and questions will be presented randomly.

USER EXPERIENCE

##Custom Interview
At first launch, the app instantiates one record containing top common  
interview questions. On top of that users are able to edit and add their own.  
With the "plus" button, users can pick more companies. Once a company is  
chosen, the app will try to pull some sample questions from Glassdoor.

##Interview Page
On the interview page, users can start a mock interview process. Existing  
questions will appear at a random order and the user can tap "Next Question"  
in order to go to the next one.

##Audio Recording
Audio is also recorded, the purpose of the audio is just a quick check on  
performance and tone. For this reason, the file is not stored and thus it is  
overwritten every time.

##Text to Speech
Users are able to activate the Text-to-Speech mode which reads out loud the  
the interview questions. The default is "not active".

##Edit Question
In this view accessible from the interview page by clicking the  
"Edit/Add Question" button, allows users to input their own questions  
as well as editing or deleting existing ones.


LIBRARIES USED

UIKit  
UIMapKit  
CoreData  
AVFoundation  
AVAudioRecorderDelegate    
CocoaPods:  
'Kanna', '~> 1.0.0'  
'HTMLReader', '~> 0.9'  
'Alamofire', '~> 3.0.0'  
'SwiftyJSON', '~> 2.3.0'  


INSTALLATION

Navigate to the desired folder.
https://github.com/xiangormirko/mock_interview.git
-open the file title 'mock_interview.xcworkspace'
-Thanks and enjoy!

