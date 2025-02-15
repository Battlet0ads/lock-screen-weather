import QtQuick 2.4
import Ubuntu.Components 1.3
import UserMetrics 0.1
import Qt.labs.settings 1.0

MainView {
    id: main_view

    applicationName: "lock-message-weather" // Обновленное имя приложения
    property string version : "v0.2.0" // Обновленная версия
    property bool isLandscape: a_p_layout.width > a_p_layout.height
    property bool isWide: a_p_layout.width > units.gu(80)

    property var weatherData: { temperature: "Loading...", conditions: "Loading..." } // Данные о погоде

    Metric {
        id: metrics
        name: "weather" // Обновленное имя метрики
        format: weatherData.temperature + "°C, " + weatherData.conditions
        emptyFormat: "No weather data"
        domain: "com.ubuntu.developer.lock-message-weather" // Обновленный домен
    }

    Settings {
        id: settings
        // Убрали momentmessage, он больше не нужен
    }

    AdaptivePageLayout {
        id: a_p_layout

        anchors.fill: parent
        primaryPage: main_page

        layouts: [
            PageColumnsLayout {
                when: isWide
                PageColumn {
                    fillWidth: true
                }
            },
            PageColumnsLayout {
                when: true
                PageColumn {
                    minimumWidth: units.gu(40)
                    fillWidth: true
                }
            }
        ]

        Page {
            id: main_page

            property int circleWidth: isWide ? (Math.min(main_view.width - units.gu(3), main_view.height) / 1.5) * 0.75
                                             : Math.min(main_view.width, main_view.height) / 1.5
            property int circleStartWidth: circleWidth / 4

            header: PageHeader {
                id: main_header
                title: "Weather on Lockscreen" // Обновленный заголовок
                leadingActionBar.actions: []
                trailingActionBar.actions: [
                    Action {
                        iconName: "info"
                        text: i18n.tr("Info")
                        onTriggered: {
                            a_p_layout.addPageToNextColumn(main_page, about_page)
                        }
                    }
                ]
            }

            Item {
                id: main_scene

                opacity: 0
                anchors {
                    top: main_header.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    margins: units.gu(2)
                }
                Behavior on opacity { NumberAnimation{duration: 1000}}
                Component.onCompleted: main_scene.opacity = 1

                Item {
                    id: moment_root

                    width: parent.width
                    height: parent.height*0.65

                    Rectangle {
                        id: moment_circle

                        color: UbuntuColors.purple
                        x: (parent.width - width)/2
                        y: height
                        width: main_page.circleStartWidth
                        height: width
                        radius: width/2
                    }

                    Label {
                        id: moment_label

                        text: i18n.tr("Weather") // Обновленный текст
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: moment_circle.bottom
                            topMargin: units.gu(2)
                        }
                    }
                }

                Item {
                    id: text_edit_item // Переименовали, но можно и удалить, если не нужен

                    anchors {
                        top: parent.top
                        topMargin: units.gu(2)
                        horizontalCenter: parent.horizontalCenter
                    }
                    width: main_page.circleWidth
                    height: width

                    Text {
                        id: temperatureText
                        color: UbuntuColors.porcelain
                        anchors.centerIn: parent
                        text: weatherData.temperature + "°C"
                        font.pixelSize: main_page.circleWidth / 4 // Пример, отрегулируйте размер шрифта
                    }

                    Text {
                        id: conditionsText
                        color: UbuntuColors.porcelain
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: temperatureText.bottom
                        text: weatherData.conditions
                        font.pixelSize: main_page.circleWidth / 6 // Пример, отрегулируйте размер шрифта
                    }
                }
            }
        }

        AboutPage {
            id: about_page
        }

        // Удалили SequentialAnimation, они больше не нужны

    }

    function updateWeather() {
        // Замените на реальный запрос к API погоды
        var apiKey = "YOUR_API_KEY"; // Замените на свой API ключ
        var city = "London"; // Замените на желаемый город
        var apiUrl = "https://api.openweathermap.org/data/2.5/weather?q=" + city + "&appid=" + apiKey + "&units=metric";

        var xhr = new XMLHttpRequest();
        xhr.open("GET", apiUrl);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText);
                    weatherData.temperature = response.main.temp.toFixed(1);
                    weatherData.conditions = response.weather[0].description;
                    metrics.update(0); // Обновление метрики
                } else {
                    weatherData.temperature = "Error";
                    weatherData.conditions = "Error loading weather";
                    metrics.update(0); // Обновление метрики
                    console.error("Error loading weather:", xhr.status, xhr.statusText);
                }
            }
        };
        xhr.send();
    }

    Timer {
        interval: 60000; // Обновление каждую минуту
        running: true;
        repeat: true;
        onTriggered: updateWeather();
    }

    Component.onCompleted: {
        updateWeather(); // Загрузка данных при запуске
    }
}
