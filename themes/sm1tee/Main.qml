import "."
import QtQuick
import SddmComponents
import QtQuick.Effects
import QtMultimedia
import "components"

Item {
    id: root
    state: Config.lockScreenDisplay ? "lockState" : "loginState"

    // TODO: Add own translations: https://github.com/sddm/sddm/wiki/Localization
    TextConstants {
        id: textConstants
    }

    property bool capsLockOn: false
    property bool numLockOn: false
    Component.onCompleted: {
        if (keyboard) {
            capsLockOn = keyboard.capsLock;
            numLockOn = keyboard.numLock;
        }
    }
    onCapsLockOnChanged: {
        loginScreen.updateCapsLock();
    }
    onNumLockOnChanged: {
        loginScreen.updateNumLock();
    }

    states: [
        State {
            name: "lockState"
            PropertyChanges {
                target: lockScreen
                opacity: 1.0
            }
            PropertyChanges {
                target: loginScreen
                opacity: 0.0
            }
            PropertyChanges {
                target: backgroundBlur
                blurMax: Config.lockScreenBlur
            }
            PropertyChanges {
                target: loginScreen.loginContainer
                scale: 0.5
            }
            PropertyChanges {
                target: backgroundBlur
                brightness: Config.lockScreenBrightness
            }
        },
        State {
            name: "loginState"
            PropertyChanges {
                target: lockScreen
                opacity: 0.0
            }
            PropertyChanges {
                target: loginScreen
                opacity: 1.0
            }
            PropertyChanges {
                target: backgroundBlur
                blurMax: Config.loginScreenBlur
            }
            PropertyChanges {
                target: loginScreen.loginContainer
                scale: 1.0
            }
            PropertyChanges {
                target: backgroundBlur
                brightness: Config.loginScreenBrightness
            }
        }
    ]
    transitions: Transition {
        enabled: Config.enableAnimations
        PropertyAnimation {
            duration: 150
            properties: "opacity"
        }
        PropertyAnimation {
            duration: 400
            properties: "blurMax"
        }
        PropertyAnimation {
            duration: 400
            properties: "brightness"
        }
    }

    Item {
        id: mainFrame
        property variant geometry: screenModel.geometry(screenModel.primary)
        x: geometry.x
        y: geometry.y
        width: geometry.width
        height: geometry.height
        clip: true

        // AnimatedImage { // `.gif`s are seg faulting with multi monitors... QT/SDDM issue?
        Image {
            // Background
            id: backgroundImage
            property string tsource: root.state === "lockState" ? Config.lockScreenBackground : Config.loginScreenBackground

            property bool isVideo: {
                if (!tsource || tsource.toString().length === 0)
                    return false;
                var parts = tsource.toString().split(".");
                if (parts.length === 0)
                    return false;
                var ext = parts[parts.length - 1];
                return ["avi", "mp4", "mov", "mkv", "m4v", "webm"].indexOf(ext) !== -1;
            }
            property bool displayColor: root.state === "lockState" && Config.lockScreenUseBackgroundColor || root.state === "loginState" && Config.loginScreenUseBackgroundColor
            property string placeholder: Config.animatedBackgroundPlaceholder // Idea stolen from astronaut-theme. Not a fan of it, but works...

            anchors.fill: parent
            anchors.margins: {
                var b = root.state === "lockState" ? Config.lockScreenBlur : Config.loginScreenBlur;
                return b > 0 ? -Math.max(b, 60) : 0;
            }
            source: {
                if (displayColor) return "";
                if (isVideo && placeholder.length > 0) return "backgrounds/" + placeholder;
                if (!isVideo && tsource.length > 0) return "backgrounds/" + tsource;
                return "";
            }
            cache: true
            mipmap: true

            onStatusChanged: {
                if (status === Image.Error) {
                    if (source !== "backgrounds/default.jpg" && source !== "") {
                        source = "backgrounds/default.jpg";
                    } else if (source === "backgrounds/default.jpg") {
                        // If even default fails, show color background
                        displayColor = true;
                    }
                }
            }

            Rectangle {
                id: backgroundColor
                anchors.fill: parent
                anchors.margins: 0
                color: root.state === "lockState" && Config.lockScreenUseBackgroundColor ? Config.lockScreenBackgroundColor : root.state === "loginState" && Config.loginScreenUseBackgroundColor ? Config.loginScreenBackgroundColor : "black"
                visible: parent.displayColor || (backgroundVideoLoader.item && backgroundVideoLoader.item.visible && parent.placeholder.length === 0)
            }

            // Load Video component dynamically only if it's actually a video
            Loader {
                id: backgroundVideoLoader
                anchors.fill: parent
                active: backgroundImage.isVideo && !backgroundImage.displayColor

                sourceComponent: Video {
                    id: backgroundVideo
                    autoPlay: true
                    loops: MediaPlayer.Infinite
                    muted: true
                    source: backgroundImage.tsource.toString().length > 0 ? Qt.resolvedUrl("backgrounds/" + backgroundImage.tsource) : ""

                    onSourceChanged: {
                        if (source && source.toString().length > 0) {
                            play();
                        }
                    }
                    onErrorOccurred: function (error) {
                        if (error !== MediaPlayer.NoError && (!backgroundImage.placeholder || backgroundImage.placeholder.length === 0)) {
                            backgroundImage.displayColor = true;
                        }
                    }
                    Component.onDestruction: {
                        stop();
                    }
                }
            }
        }
        MultiEffect {
            // Background blur
            id: backgroundBlur
            source: backgroundImage
            anchors.fill: backgroundImage
            blurEnabled: backgroundImage.visible && blurMax > 0
            blur: blurMax > 0 ? 1.0 : 0.0
            autoPaddingEnabled: false
        }

        Item {
            id: screenContainer
            anchors.fill: parent
            anchors.top: parent.top

            LockScreen {
                id: lockScreen
                z: root.state === "lockState" ? 2 : 1 // Fix tooltips from the login screen showing up on top of the lock screen.
                anchors.fill: parent
                focus: root.state === "lockState"
                enabled: root.state === "lockState"
                onLoginRequested: {
                    root.state = "loginState";
                    loginScreen.resetFocus();
                }
            }
            LoginScreen {
                id: loginScreen
                z: root.state === "loginState" ? 2 : 1
                anchors.fill: parent
                enabled: root.state === "loginState"
                opacity: 0.0
                onClose: {
                    root.state = "lockState";
                }
            }
        }
    }
}
