import QtQuick
import QtQuick.Controls
Button {
    hoverEnabled: false
    property alias buttonText: buttonLabel.text
    contentItem: Text {
        id: buttonLabel
        text: "Добавить проект"
        color: "#ffffff"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    onClicked: projectDialog.openForCreate()
    background: Rectangle {
        color: "transparent"
    }
}
