# camera-app
An app to capture a selfie and to upload it to the remote storage.

## Server 
Remote storage is implemented using Swift **Vapor** framework. 
1) First, you need to install Vapor on your system. It can be done with `brew install vapor` command. Run then `vapor` to make sure you have it installed.
2) In order to make server running, you can either run it via **Xcode** or navigate to CameraServer folder and run `swift run` command from your **Terminal**.

## iOS app
Before running iOS app, make sure to set the correct ip address of your server you're going to interact with. For that, you can find and replace `[your_server_ip_address]` with your server's ip value. 

Having that done, you're all good to run projects and make your adorable selfies. They will be stored on your server and in your Photos gallery. So nobody will see it, unless the request gets intersected by someone on your network since it's not secured. 👶 
