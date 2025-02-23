# **Smart Voice Assistant App**

A **Flutter** application designed to transcribe speech to text, extract action items from meetings, and integrate with **Google Calendar** for scheduling tasks. The app also allows users to view their task history and provides a secure login system through **Google Sign-In**.

## **Features**

- **Speech-to-Text**: Convert spoken words into text in real-time.
- **Action Item Extraction**: Send transcriptions to an AI model to extract tasks, action items, meeting points, and deadlines.
- **Google Calendar Integration**: Add meeting events to Google Calendar.
- **Task History**: View previously extracted tasks using a local history stored in **SharedPreferences**.
- **Google Login Security**: Protect users' task history by using Google authentication, ensuring only authorized users can access their task data.
- **About Us Section**: Access License and GitHub profile from the "About Us" section.

## **Technologies Used**

- **Flutter**: Cross-platform framework for building the app UI and logic.
- **Speech to Text**: Speech recognition functionality using the `speech_to_text` package.
- **Google Sign-In**: Google authentication and API access via `google_sign_in` package.
- **Google Calendar API**: Integration with Google Calendar using `googleapis` package.
- **Shared Preferences**: Storing task history locally using the `shared_preferences` package.
- **HTTP Requests**: Sending API requests using the `http` package.
- **URL Launcher**: Launching external URLs like GitHub profile using the `url_launcher` package.

## **Installation**

1. Clone this repository to your local machine.

    ```bash
    git clone https://github.com/adityakr1108/Smart-Voice-Assistant.git
    ```

2. Navigate into the project folder.

    ```bash
    cd Smart-Voice-Assistant
    ```

3. Install dependencies using **Flutter**.

    ```bash
    flutter pub get
    ```

4. Set up **Google Sign-In** and **Google Calendar API**.

    - You’ll need to configure OAuth 2.0 credentials from the **Google Developer Console**.
    - Set up **Google Calendar API** and generate the `API Key` and **OAuth client ID** for authentication.
    - Follow the official Flutter setup guide for **Google Sign-In** and **Google APIs**.

## **Usage**

### Main Features

- **Speech Recognition**:  
  Press the microphone button to start listening, and the app will transcribe your speech into text in real-time.

- **AI-based Action Item Extraction**:  
  After transcribing the meeting, the app will send the text to an AI model for action item extraction, including **tasks**, **meeting points**, and **dates**.

- **Google Calendar Integration**:  
  The extracted meeting date is added to **Google Calendar**. You need to be logged in via Google to use this feature.

- **Task History**:  
  View previously extracted tasks stored in the app's local memory (SharedPreferences).

- **About Us Section**:  
  Learn more about the app by accessing the "About Us" section to check out the **License** and visit the **GitHub Profile**.

### Buttons in the App

- **Mic Button**:  
  Toggle between starting and stopping speech recognition.

- **Save Data**:  
  Save the extracted action items to Google Calendar.

- **Task History**:  
  Navigate to the task history screen to view previously stored tasks.

- **About Us**:  
  Show options to view the **License** and **GitHub** profile.

## **Video Tutorial**

For a step-by-step guide on how to use the Smart Voice Assistant App, watch the video tutorial below:

[**Watch the Video Tutorial**](https://drive.google.com/file/d/1PNvzNING-UaQ4Fn8NzbDHGjq9akFiOMe/view?usp=sharing)  


This tutorial covers:

- Setting up the app.
- How to use the speech-to-text functionality.
- Extracting action items from meeting transcriptions.
- Adding tasks to Google Calendar.
- Viewing task history.
- How to use the **About Us** section.

## **Demo**

### How It Works

1. Press the **mic button** to start speaking.
2. The app will transcribe your speech to text and send it to an AI model for **action item extraction**.
3. The app will display the extracted meeting agenda, summary, and date.
4. You can save the meeting details to **Google Calendar** after logging in through Google.
5. View all your previous task histories via the **Task History** button.

## **Limitations**

- **Google Calendar Integration**: Currently, there might be issues with Google Calendar API integration. Efforts are being made to make it seamless in future updates.
- **Speech Recognition**: Limited by accuracy based on the clarity of the speech.

## **Future Enhancements**

- **Conversation Analysis**: Adding a feature to analyze the conversation between two speakers, evaluating tone, fluency, and engagement.
- **Improved Task Extraction**: Enhance AI capabilities to extract more specific actions, meeting points, and deadlines.
- **Real-time Voice Processing**: Speeding up voice processing to ensure instant transcription and task extraction.

## **Contributing**

Feel free to contribute to this project by forking the repository, making improvements, or reporting bugs. All contributions are welcome!

1. Fork the repository.
2. Create a new branch for your changes.
3. Make the changes and commit them.
4. Push to the forked repository.
5. Open a pull request with a description of your changes.

## **License**

This project is licensed under the MIT License.

---

## **Contact Information**

- **GitHub**: [@adityakr1108](https://github.com/adityakr1108)
- **Email**: akagrawal1108@gmail.com
