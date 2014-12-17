import QtQuick 2.3

/*!
  \qmltype InfiniteScrollItems
  \inqmlmodule Bacon2D
  \inherits Item
  \ingroup graphics
  \brief Enable a Item to do a infinite scroll. Good for backgrounds
*/
Item {
    id:root

    /*!
      \qmlproperty Item InifiniteScrollItem::target
      \brief \l Item that will used as texture for scrolling effect.
    */
    default property Item target

    /*!
      \qmlproperty Item InifiniteScrollItem::yStep
      \brief \l The amount of vertical pixels that will be translated for each update.
    */
    property real yStep: 0;
    /*!
      \qmlproperty Item InifiniteScrollItem::xStep
      \brief \l The amount of horizontal pixels that will be translated for each update.
    */
    property real xStep: 0;
    /*!
      \qmlproperty Item InifiniteScrollItem::updateInterval
      \brief \l Determines how often the scrolling item should be updated. In miliseconds.
    */
    property alias updateInterval: timer.interval

    implicitWidth: target.width
    implicitHeight: target.height

    ShaderEffectSource{
        id:shaderSource
        width: target.width; height:target.height
        sourceItem: target
        live:true
        visible:false
    }

    ShaderEffect {
        id:shader
        width: target.width; height:target.height

        property real shaderYStep: target ? yStep / target.width : 0
        property real shaderXStep: target ? xStep / target.height : 0

        property Item target: shaderSource
        property real __xAcc:0
        property real __yAcc:0

        vertexShader: "
                          uniform highp mat4 qt_Matrix;
                          attribute highp vec4 qt_Vertex;
                          attribute highp vec2 qt_MultiTexCoord0;
                          varying highp vec2 coord;
                          void main() {
                              coord = qt_MultiTexCoord0;
                              gl_Position = qt_Matrix * qt_Vertex;
                          }"
        fragmentShader: "
                          uniform float width;
                          uniform lowp float qt_Opacity;
                          uniform sampler2D target;
                          uniform float __xAcc;
                          uniform float __yAcc;
                          varying  highp vec2 coord;
                          void main(void) {
                              vec4 texel = texture2D(target, vec2(mod(coord.x + __xAcc, 1.0), mod(coord.y + __yAcc, 1.0)));
                              gl_FragColor = texel  * qt_Opacity;
                          } "

        Timer{
            id:timer;
            repeat: true
            running: root.xStep !== 0 || root.yStep !== 0
            onTriggered: {
                parent.__xAcc = parent.__xAcc + parent.shaderXStep % 1.0
                parent.__yAcc = parent.__yAcc + parent.shaderYStep % 1.0
            }
        }
    }
}

