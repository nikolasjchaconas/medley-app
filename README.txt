Medley

Instructions for building and executing:
    1. You will need a device running Mac OS X El Capitan to get this project to work with no issues.
    2. You should be able to just download this project, open it in XCode, and then press the play button at the top left with the device selected as iPhone 6s and it should open a simulator and begin working fine.
    3. If an error comes up about provisioning profiles, or you want to put it on an actual phone, then you will need to click on the parent "Medley" file in the file hierarchy in the left, and change the Team to your Apple ID, and append any random series of strings onto the Bundle Identifier. Such as changing it to com.medleyteam.app.Medley
    4. No other data files or anything are necessary.

Known bugs:
    1. The room view chat interaface has some issues with screen movement when being run. This will be fixed in a future iteration.
    2. The account information editing will always say that your password was successfully changed, even if the old password you enter is incorrect. This will be fixed in a future iteration, along with creating a new password confirmation box to account for mistakes.
    3. The room view is still mostly incomplete, so its features are mostly either non-working, or not working as intended.

Instructions for using Medley:
    1. To create an account, click on the Sign Up button at the bottom of the landing page. Then after creating an account, you will automatically be logged in.
    2. If you already have an account, you can just enter your info on the landing page and click login, then you'll be logged in.
    3. Once logged in, you have three options: "Create Room", "Join Room", "Settings".
    4. When creating a room, you can create a public or a private room, and if you create a private room you will be asked to enter a password. Once the room is created, you will be taken to the room view.
    5. When joining a room, you will be prompted for a room code to join the correct room. (This is currently not yet implemented).
    6. When tapping the Settings button, you will be taken to the settings page, where you can change your account settings (currently only password), view information about Medley, send us an e-mail, or log out of your account.
