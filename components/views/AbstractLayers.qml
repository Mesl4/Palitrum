import QtQuick

Item {
    id: root
    property string seed: "default"

    property real baseHue: {
        let hash = 0;
        for (let i = 0; i < seed.length; i++) {
            hash = seed.charCodeAt(i) + ((hash << 5) - hash);
        }
        return (Math.abs(hash) % 256) / 255.0;
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
    }

    Repeater {
        model: 3
        Rectangle {
            anchors.centerIn: parent

            width: root.width * (0.5 + index * 0.15)
            height: width
            radius: width / 2

            x: Math.cos(index + seed.length) * 30
            y: Math.sin(index + seed.length) * 30
            rotation: (seed.charCodeAt(index % seed.length) % 360)

            color: Qt.hsla(baseHue + (index * 0.05), 0.6, 0.6, 0.45)
        }
    }
}
