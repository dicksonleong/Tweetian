import QtQuick 1.1
import com.nokia.meego 1.0
import "UIConstants.js" as UiConstants

// TODO: Remove UIConstants.js
QtObject{
    id: constant

    // color
    property color colorHighlighted: colorLight
    property color colorLight: settings.invertedTheme ? UiConstants.COLOR_FOREGROUND
                                                      : UiConstants.COLOR_INVERTED_FOREGROUND
    property color colorMid: settings.invertedTheme ? "#666666"
                                                    : UiConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
    property color colorTextSelection: UiConstants.COLOR_SELECT
    property color colorDisabled: settings.invertedTheme ? UiConstants.COLOR_DISABLED_FOREGROUND : "#444444"

    // padding size
    property int paddingSmall: UiConstants.PADDING_SMALL
    property int paddingMedium: UiConstants.PADDING_MEDIUM
    property int paddingLarge: UiConstants.PADDING_LARGE
    property int paddingXLarge: UiConstants.PADDING_DOUBLE
    property int paddingXXLarge: UiConstants.PADDING_XLARGE

    // font size
    property int fontSizeXSmall: UiConstants.FONT_SMALL
    property int fontSizeSmall: UiConstants.FONT_LSMALL
    property int fontSizeMedium: UiConstants.FONT_DEFAULT
    property int fontSizeLarge: UiConstants.FONT_SLARGE
    property int fontSizeXLarge: UiConstants.FONT_LARGE
    property int fontSizeXXLarge: UiConstants.FONT_XLARGE

    // graphic size
    property int graphicSizeTiny: UiConstants.SIZE_ICON_DEFAULT * 0.75
    property int graphicSizeSmall: UiConstants.SIZE_ICON_DEFAULT
    property int graphicSizeMedium: UiConstants.SIZE_ICON_LARGE
    property int graphicSizeLarge: UiConstants.SIZE_ICON_LARGE * 1.5
    property int graphicSizeXLarge: UiConstants.SIZE_ICON_LARGE * 2
    property int graphicSizeXXLarge: UiConstants.SIZE_ICON_LARGE * 3

    // other
    property int borderSizeMedium: 20
    property int headerHeight: inPortrait ? 65 : 55

    // --Twitter--
    property int charReservedPerMedia: 22
    property url twitterBirdIcon: settings.invertedTheme ? "Image/twitter-bird-light.png" : "Image/twitter-bird-dark.png"
}
