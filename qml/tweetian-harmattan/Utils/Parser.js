/*
    Copyright (C) 2012 Dickson Leong
    This file is part of Tweetian.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

.pragma library

var validHashtagRegExp

String.prototype.parseUsername = function() {
    return this.replace(/@\w+/g, function(u) {
        return "<a style=\"color: LightSeaGreen; text-decoration: none\" href=\""+u+"\">"+u+"</a>"
    })
}

String.prototype.parseHashtag = function(hashtags) {
    if (!validHashtagRegExp) validHashtagRegExp = __buildValidHashtagRegExp()
    return this.replace(validHashtagRegExp, function(t) {
        if (hashtags) hashtags.push(t.substring(1))
        return "<a style=\"color: LightSeaGreen; text-decoration: none\" href=\""+t+"\">"+t+"</a>"
    })
}

String.prototype.parseURL = function(url, displayUrl, expandedUrl) {
    return this.replace(url, "<i><a style=\"color: LightSeaGreen; text-decoration: none\" href=\""+expandedUrl+"\">"+displayUrl+"</a></i>")
}

/**Convert <a href="...">source</a> to source**/
function unlink(source) {
    if (/</.test(source))
        return source.substring(source.indexOf('>') + 1, source.indexOf('<', 1))
    else if (/&q/.test(source))
        return source.substring(source.indexOf('&quot;&gt;') + 10, source.lastIndexOf('&lt;/a&gt;'))
    else return source
}

var __HTML_ENTITIES = {
    "&amp;": "&",
    "&lt;": "<",
    "&gt;": ">"
}

function unescapeHtml(text) {
    return text && text.replace(/(&amp;|&lt;|&gt;)/g, function(html) {
        return __HTML_ENTITIES[html]
    })
}

// Internal function for contruct validHashtagRegExp
function __buildValidHashtagRegExp() {
    var validHashtagArray = []

    function addCharsToValidHashtag(start, end) {
        var s = String.fromCharCode(start)
        if (end !== start)
            s += "-" + String.fromCharCode(end)
        validHashtagArray.push(s)
    }

    // Latin accented characters (subtracted 0xD7 from the range, it's a confusable multiplication sign. Looks like "x")
    addCharsToValidHashtag(0x00c0, 0x00d6);
    addCharsToValidHashtag(0x00d8, 0x00f6);
    addCharsToValidHashtag(0x00f8, 0x00ff);
    // Latin Extended A and B
    addCharsToValidHashtag(0x0100, 0x024f);
    // assorted IPA Extensions
    addCharsToValidHashtag(0x0253, 0x0254);
    addCharsToValidHashtag(0x0256, 0x0257);
    addCharsToValidHashtag(0x0259, 0x0259);
    addCharsToValidHashtag(0x025b, 0x025b);
    addCharsToValidHashtag(0x0263, 0x0263);
    addCharsToValidHashtag(0x0268, 0x0268);
    addCharsToValidHashtag(0x026f, 0x026f);
    addCharsToValidHashtag(0x0272, 0x0272);
    addCharsToValidHashtag(0x0289, 0x0289);
    addCharsToValidHashtag(0x028b, 0x028b);
    // Okina for Hawaiian (it *is* a letter character)
    addCharsToValidHashtag(0x02bb, 0x02bb);
    // Combining diacritics
    addCharsToValidHashtag(0x0300, 0x036f);
    // Latin Extended Additional
    addCharsToValidHashtag(0x1e00, 0x1eff);
    // Cyrillic
    addCharsToValidHashtag(0x0400, 0x04ff); // Cyrillic
    addCharsToValidHashtag(0x0500, 0x0527); // Cyrillic Supplement
    addCharsToValidHashtag(0x2de0, 0x2dff); // Cyrillic Extended A
    addCharsToValidHashtag(0xa640, 0xa69f); // Cyrillic Extended B
    // Hebrew
    addCharsToValidHashtag(0x0591, 0x05bf); // Hebrew
    addCharsToValidHashtag(0x05c1, 0x05c2);
    addCharsToValidHashtag(0x05c4, 0x05c5);
    addCharsToValidHashtag(0x05c7, 0x05c7);
    addCharsToValidHashtag(0x05d0, 0x05ea);
    addCharsToValidHashtag(0x05f0, 0x05f4);
    addCharsToValidHashtag(0xfb12, 0xfb28); // Hebrew Presentation Forms
    addCharsToValidHashtag(0xfb2a, 0xfb36);
    addCharsToValidHashtag(0xfb38, 0xfb3c);
    addCharsToValidHashtag(0xfb3e, 0xfb3e);
    addCharsToValidHashtag(0xfb40, 0xfb41);
    addCharsToValidHashtag(0xfb43, 0xfb44);
    addCharsToValidHashtag(0xfb46, 0xfb4f);
    // Arabic
    addCharsToValidHashtag(0x0610, 0x061a); // Arabic
    addCharsToValidHashtag(0x0620, 0x065f);
    addCharsToValidHashtag(0x066e, 0x06d3);
    addCharsToValidHashtag(0x06d5, 0x06dc);
    addCharsToValidHashtag(0x06de, 0x06e8);
    addCharsToValidHashtag(0x06ea, 0x06ef);
    addCharsToValidHashtag(0x06fa, 0x06fc);
    addCharsToValidHashtag(0x06ff, 0x06ff);
    addCharsToValidHashtag(0x0750, 0x077f); // Arabic Supplement
    addCharsToValidHashtag(0x08a0, 0x08a0); // Arabic Extended A
    addCharsToValidHashtag(0x08a2, 0x08ac);
    addCharsToValidHashtag(0x08e4, 0x08fe);
    addCharsToValidHashtag(0xfb50, 0xfbb1); // Arabic Pres. Forms A
    addCharsToValidHashtag(0xfbd3, 0xfd3d);
    addCharsToValidHashtag(0xfd50, 0xfd8f);
    addCharsToValidHashtag(0xfd92, 0xfdc7);
    addCharsToValidHashtag(0xfdf0, 0xfdfb);
    addCharsToValidHashtag(0xfe70, 0xfe74); // Arabic Pres. Forms B
    addCharsToValidHashtag(0xfe76, 0xfefc);
    addCharsToValidHashtag(0x200c, 0x200c); // Zero-Width Non-Joiner
    // Thai
    addCharsToValidHashtag(0x0e01, 0x0e3a);
    addCharsToValidHashtag(0x0e40, 0x0e4e);
    // Hangul (Korean)
    addCharsToValidHashtag(0x1100, 0x11ff); // Hangul Jamo
    addCharsToValidHashtag(0x3130, 0x3185); // Hangul Compatibility Jamo
    addCharsToValidHashtag(0xA960, 0xA97F); // Hangul Jamo Extended-A
    addCharsToValidHashtag(0xAC00, 0xD7AF); // Hangul Syllables
    addCharsToValidHashtag(0xD7B0, 0xD7FF); // Hangul Jamo Extended-B
    addCharsToValidHashtag(0xFFA1, 0xFFDC); // half-width Hangul
    // Japanese and Chinese
    addCharsToValidHashtag(0x30A1, 0x30FA); // Katakana (full-width)
    addCharsToValidHashtag(0x30FC, 0x30FE); // Katakana Chouon and iteration marks (full-width)
    addCharsToValidHashtag(0xFF66, 0xFF9F); // Katakana (half-width)
    addCharsToValidHashtag(0xFF70, 0xFF70); // Katakana Chouon (half-width)
    addCharsToValidHashtag(0xFF10, 0xFF19); // \
    addCharsToValidHashtag(0xFF21, 0xFF3A); //  - Latin (full-width)
    addCharsToValidHashtag(0xFF41, 0xFF5A); // /
    addCharsToValidHashtag(0x3041, 0x3096); // Hiragana
    addCharsToValidHashtag(0x3099, 0x309E); // Hiragana voicing and iteration mark
    addCharsToValidHashtag(0x3400, 0x4DBF); // Kanji (CJK Extension A)
    addCharsToValidHashtag(0x4E00, 0x9FFF); // Kanji (Unified)
    // -- Disabled as it breaks the Regex.
    //addCharsToValidHashtag(0x20000, 0x2A6DF); // Kanji (CJK Extension B)
    addCharsToValidHashtag(0x2A700, 0x2B73F); // Kanji (CJK Extension C)
    addCharsToValidHashtag(0x2B740, 0x2B81F); // Kanji (CJK Extension D)
    addCharsToValidHashtag(0x2F800, 0x2FA1F); // Kanji (CJK supplement)
    addCharsToValidHashtag(0x3003, 0x3003); // Kanji iteration mark
    addCharsToValidHashtag(0x3005, 0x3005); // Kanji iteration mark
    addCharsToValidHashtag(0x303B, 0x303B); // Han iteration mark

    var regExpString = "#[\\w" + validHashtagArray.join("") +"]+"
    return new RegExp(regExpString, "g")
}
