import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Item {
    id: spinnerContainer
    width: {
        if (!Config.spinnerDisplayIcon) {
            return spinnerText.width;
        }
        if (!Config.spinnerDisplayText) {
            return spinner.width;
        }
        return (Config.loginAreaPosition === "left" || Config.loginAreaPosition === "right")
            ? (spinner.width + Config.spinnerSpacing + spinnerText.width)
            : Math.max(spinner.width, spinnerText.width);
    }
    height: {
        if (!Config.spinnerDisplayIcon) {
            return spinnerText.height;
        }
        if (!Config.spinnerDisplayText) {
            return spinner.height;
        }
        return (Config.loginAreaPosition === "left" || Config.loginAreaPosition === "right")
            ? Math.max(spinner.height, spinnerText.height)
            : (spinnerText.height + Config.spinnerSpacing + spinner.height);
    }

    Behavior on opacity {
        enabled: Config.enableAnimations
        NumberAnimation {
            duration: 150
        }
    }
    Behavior on visible {
        enabled: Config.enableAnimations && Config.spinnerDisplayText && Config.spinnerDisplayIcon
        ParallelAnimation {
            running: spinnerContainer.visible && Config.spinnerDisplayText && Config.spinnerDisplayIcon
            NumberAnimation {
                target: Config.loginAreaPosition === "left" || Config.loginAreaPosition === "right" ? spinnerText : spinner
                property: Config.loginAreaPosition === "left" ? "anchors.leftMargin" : (Config.loginAreaPosition === "right" ? "anchors.rightMargin" : "anchors.topMargin")
                from: -spinner.height
                to: Config.spinnerSpacing
                duration: 300
                easing.type: Easing.OutQuart
            }
            NumberAnimation {
                target: spinner
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: 200
            }
        }
    }

    Image {
        id: spinner
        visible: Config.spinnerDisplayIcon
        source: Config.spinnerDisplayIcon ? Config.getIcon(Config.spinnerIcon) : ""
        width: Config.spinnerDisplayIcon ? Config.spinnerIconSize : 0
        height: width
        sourceSize.width: width
        sourceSize.height: height
        opacity: Config.spinnerDisplayIcon ? (Config.spinnerDisplayText ? 0.0 : 1.0) : 0.0

        RotationAnimation {
            target: spinner
            running: spinner.visible && spinnerContainer.visible && Config.enableAnimations
            from: 0
            to: 360
            loops: Animation.Infinite
            duration: 1200
        }

        MultiEffect {
            source: spinner
            visible: spinner.visible
            anchors.fill: spinner
            colorization: 1
            colorizationColor: Config.spinnerColor
        }

        Component.onCompleted: {
            if (!Config.spinnerDisplayIcon) return;
            if (Config.loginAreaPosition === "left") {
                anchors.left = parent.left;
                anchors.verticalCenter = parent.verticalCenter;
            } else if (Config.loginAreaPosition === "right") {
                anchors.right = parent.right;
                anchors.verticalCenter = parent.verticalCenter;
            } else {
                anchors.top = spinnerText.bottom;
                anchors.topMargin = Config.spinnerSpacing;
                anchors.horizontalCenter = parent.horizontalCenter;
            }
        }
    }

    Text {
        id: spinnerText
        visible: Config.spinnerDisplayText
        text: Config.spinnerText
        color: Config.spinnerColor
        font.pixelSize: Config.spinnerFontSize
        font.weight: Config.spinnerFontWeight
        font.family: Config.spinnerFontFamily

        Component.onCompleted: {
            if (Config.spinnerDisplayIcon) {
                if (Config.loginAreaPosition === "left") {
                    anchors.left = spinner.right;
                    anchors.leftMargin = Config.spinnerSpacing;
                    anchors.verticalCenter = parent.verticalCenter;
                } else if (Config.loginAreaPosition === "right") {
                    anchors.right = spinner.left;
                    anchors.rightMargin = Config.spinnerSpacing;
                    anchors.verticalCenter = parent.verticalCenter;
                } else {
                    anchors.top = parent.top;
                    anchors.horizontalCenter = parent.horizontalCenter;
                }
            } else {
                if (Config.loginAreaPosition === "left") {
                    anchors.left = parent.left;
                    anchors.verticalCenter = parent.verticalCenter;
                } else if (Config.loginAreaPosition === "right") {
                    anchors.right = parent.right;
                    anchors.verticalCenter = parent.verticalCenter;
                } else {
                    anchors.horizontalCenter = parent.horizontalCenter;
                    anchors.verticalCenter = parent.verticalCenter;
                }
            }
        }

        SequentialAnimation on scale {
            id: spinnerTextAnimation
            running: spinnerText.visible && spinnerContainer.visible && Config.enableAnimations && Config.spinnerDisplayText
            loops: Animation.Infinite
            NumberAnimation {
                from: 1.0
                to: 1.05
                duration: 900
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                from: 1.05
                to: 1.0
                duration: 900
                easing.type: Easing.InOutQuad
            }
        }
    }

    Component.onDestruction: {
        if (spinnerTextAnimation) {
            spinnerTextAnimation.running = false;
            spinnerTextAnimation.stop();
        }
    }
}
