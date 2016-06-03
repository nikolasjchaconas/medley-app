Medley

Instructions for building and executing:
    1. You will need a device running Mac OS X El Capitan to get this project to work with no issues.
    2. You should be able to just download this project, open it in XCode, and then press the play button at the top left with the device selected as iPhone 6s and it should open a simulator and begin working fine.
    3. If an error comes up about provisioning profiles, or you want to put it on an actual phone, then you will need to click on the parent "Medley" file in the file hierarchy in the left, and change the Team to your Apple ID, and append any random series of strings onto the Bundle Identifier. Such as changing it to com.medleyteam.app.Medley
    4. No other data files or anything are necessary.

Known bugs:
    1. Sometimes when playing a video, if you lose connection to Firebase the video playback will just break.

Instructions for using Medley:
    1. To create an account, click on the Sign Up button at the bottom of the landing page. Then after creating an account, you will automatically be logged in.
    2. If you already have an account, you can just enter your info on the landing page and click login, then you'll be logged in.
    3. Once logged in, you have three options: "Create Room", "Join Room", "Settings".
    4. When creating a room, you can create a public or a private room, and if you create a private room you will be asked to enter a password. Once the room is created, you will be taken to the room view.
    5. When joining a room, you will be prompted for a room code to join the correct room. 
    6. When tapping the Settings button, you will be taken to the settings page, where you can change your account settings (currently only password), view information about Medley, send us an e-mail, or log out of your account.
    7. When in a room you can leave the room (top left), view the other members of the room (top right or swipe from right to left), chat with the other members of the room (tap Chat Room), or add videos to the playlist (tap Playlist)
    8. If you are the admin you can play/pause the video for all users in the room or tap Next or Prev to skip to the next video in the playlist or the previous video in the playlist respectively
    9. If non-admin, you can tap ReSync to attempt to resync the video with the admin. However this does not always work perfectly as it's very connection dependent so you can also tap Skip Forward and Skip Backwards to seek slightly forward or backwards in the video to fine tune the syncing of the video. After a little bit of fine tuning, perfect syncing between all devices can be achieved.
