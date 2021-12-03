import Foundation


public enum Char: UInt8, Comparable, Sendable {
    case invalid = 0
    case a = 1, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z = 26
    case ä = 27
    case ö = 28
    case ü = 29
    case ß = 30
    case newline = 31

    init(fromLatin1 char: UInt8) {
        switch char {
        case 10, 13:
            self = .newline
        case 65...90: // A-Z
            self = Char(rawValue: char - 64)!
        case 97...122:  // a-z
            self = Char(rawValue: char - 96)!
        case 0xc4 /* Ä */, 0xe4 /* ä */:
            self = .ä
        case 0xd6 /* Ö */, 0xf6 /* ö */:
            self = .ö
        case 0xdc /* Ü */, 0xfc /* ü */:
            self = .ü
        case 0xdf:
            self = .ß // ß
        case 0xc1 /* Á */, 0xc5 /* Å */, 0xe0 /* à */, 0xe1 /* á */, 0xe2 /* â */, 0xe3 /* ã */, 0xe5 /* å */:
            self = .a
        case 0xe7 /* ç */:
            self = .c
        case 0xc9 /* É */, 0xe8 /* è */, 0xe9 /* é */, 0xea /* ê */, 0xeb /* ë */:
            self = .e
        case 0xcd /* Í */, 0xec /* ì */, 0xed /* í */, 0xee /* î */, 0xef /* ï */:
            self = .i
        case 0xf1 /* ñ */:
            self = .n
        case 0xf2 /* ò */, 0xf3 /* ó */, 0xf4 /* ô */, 0xf8 /* ø */:
            self = .o
        case 0xfa /* ú */, 0xfb /* û */:
            self = .u
        case 0xff /* ÿ */:
            self = .y
        case 0xb5 /* µ */, 0xe6 /* æ */:
            self = .invalid
        default:
            self = .invalid
        }
    }

    var mask: CharMask { 1 << CharMask(self.rawValue) }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
