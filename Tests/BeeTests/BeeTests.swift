import XCTest
import Bee

final class BeeTests: XCTestCase {

    static let shortTestDict = try! BeeDictionary(maximumWordCount: 100000)

    func testConstrainedDictionaryInit() throws {
        let sut = try! BeeDictionary(maximumWordCount: 100000)
        let entriesCount = sut.count
        XCTAssertEqual(entriesCount, 100000)
    }

    func testConstrainedDictionaryMatchMaskALT() throws {
        let sut = Self.shortTestDict

        let mask = CharMask.mask(from: "ALT")
        let indices = sut.indicesMatching(mask)
        let results = sut[indices].sorted().joined(separator: ", ")
        XCTAssertEqual(results, "AA, AAA, Aal, Aatal, aalt, all, alt")
    }

    func testConstrainedDictionaryMatchALT() throws {
        let sut = Self.shortTestDict
        let indices = sut.indicesMatching("ALT")
        let results = sut[indices].sorted().joined(separator: ", ")
        XCTAssertEqual(results, "alt")
    }

    func testConstrainedDictionaryMatchMaskAENNR() throws {
        let sut = Self.shortTestDict
        let mask = CharMask.mask(from: "AENNR")
        let indices = sut.indicesMatching(mask)
        let results = sut[indices].sorted().joined(separator: ", ")
        XCTAssertEqual(results, "AA, AAA, Aar, Aare, Ann, Anna, Annan, Anne, an, anrenne, anrennen")
    }

    func testConstrainedDictionaryMatchAENNR() throws {
        let sut = Self.shortTestDict
        let indices = sut.indicesMatching("AENNR")
        let results = sut[indices].sorted().joined(separator: ", ")
        XCTAssertEqual(results, "Ann, Anne, an")
    }

    func testFullDictionarySyncCreation() throws {
        let sut = try BeeDictionary()
        XCTAssertEqual(sut.count, 2152638)
    }

    func testFullDictionaryAsyncCreation() async throws {
        let sut = try await BeeDictionary()
        XCTAssertEqual(sut.count, 2152638)
    }

    func testFullDictionaryMatch() async throws {
        let sut = try await BeeDictionary.shared
        for testCase in Zeit.allCases {
            let results = sut.wordsMatching(testCase.letters).joined(separator: ", ")
            XCTAssertEqual(results, testCase.expected, file: testCase.file, line: testCase.line)
        }
    }
}

struct Zeit {
    var date: String
    var letters: String
    var expected: String
    var file: StaticString
    var line: UInt
    init(_ date: String, _ letters: String, _ expected: String, file: StaticString = #filePath, line: UInt = #line) {
        self.date = date
        self.letters = letters
        self.expected = expected
        self.file = file
        self.line = line
    }

    static var allCases: [Self] = [
        Zeit("2021-11-17", "RAAKLMHEA", "Kamelhaar, Alkmaar, Haarlem, Kalmare, Alarme, Harlem, Kalmar, Kamera, Karmel, Kerala, Kraale, Mahler, Makler, herkam, kahler, klarem, lahmer, Alarm, Areal, Elmar, Harem, Karel, Karla, Karma, Khmer, Klara, Kraal, Krale, Kreml, Lahar, Leara, Maare, Maler, Marek, Marke, Rahel, Rakel, Rhema, haare, harke, klare, krame, Aare, Arak, Aral, EMRK, Earl, Haar, Hera, Karl, Kerl, Kral, Kram, Lahr, Lara, Lear, Maar, Mahr, Mara, Mare, Mark, Marl, Rahe, Rahm, Rama, Reha, Rhea, arme, kehr, klar, mehr, merk, real, Aar, Ahr, Ara, ERK, LRA, LRK, RAL, RAM, REM, RMA, Rah, Reh, arm, her"),
        Zeit("2021-11-10", "SKNIEIRSN", "Sinnkrise, Innkreis, Inkreis, Risiken, Sinkens, Skinner, einriss, Eiriks, Kinnes, Kissen, Kniens, Krisen, Krisis, Nissen, Resins, Riesin, Sinnes, Skiern, rissen, sinken, Eriks, Kerns, Kessi, Kiens, Kinns, Knies, Kreis, Krise, Neins, Niers, Nikes, Nisse, Resin, Rinse, Risse, Serin, Sinns, Siris, Skier, Skins, keins, seins, sinke, sinne, Enns, Eris, ISIN, ISSN, Ines, Inns, Iris, Isis, Kies, Kirs, Ness, Reis, Rens, Senn, Sinn, Sire, Siri, Skin, Skis, eins, kess, riss, sein, ESN, Eis, KSN, RNS, RSS, SRK, Sir, Ski, Sri, ins, iss, sei, sek, sie"),
        Zeit("2021-11-03", "TMAOOIRVT", "Motivator, Tormotiv, Moritat, Ottomar, rotativ, Moovit, Ottmar, Voramt, Mitra, Motiv, Motor, Motto, Otmar, Tarot, Tavor, Timor, ratio, vitro, Atom, MTRA, Otto, Rita, Root, Rott, Taro, Timo, Tito, Tora, Toto, Tram, Trio, Vati, Vita, Vito, iota, matt, ritt, trat, ATM, ATV, Amt, Art, ITT, IoT, MRT, MTA, MTV, Ort, Rat, Tai, Tao, Tim, Tom, Tor, mit, rot, tat, toi, tot"),
        Zeit("2021-10-27", "SMTTRVEIM", "verstimmt, Stimmer, mimtest, simmert, stimmte, trimmst, tristem, Mister, Rittes, Streit, Tetris, Timers, Titers, Triest, mistet, reimst, rietst, stemmt, stiert, stimme, stimmt, triste, Emirs, Ersti, Items, Reims, Ritts, Semit, Sitte, Stier, Terms, Tiers, Times, Timms, Veits, meist, mimst, miste, reist, remis, trist, Eris, MMSI, Mems, Mets, Mist, RStV, Reis, Rems, Rest, Rist, Seim, Sire, Site, Test, Tims, Vers, eSIM, erst, mies, seit, Eis, Ems, ITS, MMS, MSI, MSR, MSV, RSV, RTS, SEV, SIM, SME, SVE, Set, Sir, Sri, StR, TMS, TSE, TSV, TVs, VMs, Vis, ist, sei, sie"),
        Zeit("2021-10-20", "AGTEETIRW", "Tragweite, wattigere, Teigware, agiertet, etwaiger, gewartet, wattiere, wattiger, agierte, etwaige, geartet, geratet, gewatet, rattige, wartete, wattige, wegtrat, Gatter, Target, Teeart, Tertia, Triage, Wegart, agiere, agiert, artete, artige, gerate, ragtet, rattig, wagtet, wartet, watete, wattig, Etage, Gatte, Gitta, Grate, Greta, Ratte, Tarte, Watte, artet, artig, garte, ragte, ratet, tagte, trage, tragt, wagte, warte, watet, Arie, Etat, Gate, Gatt, Gera, Grat, Riga, Rita, Ware, Watt, arge, arte, etwa, gare, gart, rage, ragt, rate, tage, tagt, trag, trat, wage, wagt, wart, wate, AEG, AWG, Air, Art, EGA, ETA, GRA, GTA, IEA, IRA, RAW, Rat, TAE, TWA, Tag, Tai, WEA, arg, gar, tat, war"),
        Zeit("2021-10-13", "LGIEONVSG", "Singvogel, losginge, Leggins, Loggien, losging, Ilgens, Legion, Leonis, Logins, Sigeln, Siglen, Single, Velins, Venlos, Violen, Vogels, Volens, loggen, oliven, olives, soviel, Elvis, Gleis, Igels, Ilgen, Insel, Legos, Leins, Lenis, Leoni, Leons, Levis, Ligen, Lions, Liven, Login, Logis, Niels, Nigel, Olegs, Olsen, Selin, Sigel, Sigle, Solei, Solen, VLogs, Velin, Venlo, Viole, Vlies, Vogel, Voile, igeln, linse, logen, logge, losen, olive, selig, senil, Elis, Gels, Igel, Ilse, Lego, Lein, Leni, Leon, Leos, Levi, Le??n, Lise, Loge, Logs, L??on, Neil, Nils, No??l, Oleg, Oles, Siel, Silo, Sole, Soli, VLSI, VLog, Velo, geil, leis, lieg, lies, live, lose, oliv, seil, viel, Eli, GLG, Gel, ILO, LNG, LSI, LSV, Leo, Nil, OLG, Ole, Sol, leg, log, los, ol??, vgl"),
        Zeit("2021-10-06", "FHMDCERAS", "sachfremd, scharfem, scharfe, Faches, Frames, Hafers, Schafe, scharf, Caf??s, Chefs, Fachs, Farce, Faser, Frame, Freds, Hafer, Harfe, SHAEF, Schaf, fache, fadem, fader, fades, fahre, fesch, frech, fremd, CAFM, CFDs, CSFR, Caf??, Chef, DEFA, FARC, FMEA, FSME, Fach, Farm, Fred, RDFS, REFA, Safe, darf, fade, fahr, AfD, CHF, DRF, DaF, EFH, FAS, FMS, FSC, FdH, Fes, MDF, MFA, MFH, MfS, RAF, RDF, RFC, SFr, SRF, fad"),
        Zeit("2021-09-29", "M??EIRFSTK", "Mistk??fer, imkerst, Fermis, Imkers, Kermit, Kirmes, Kismet, Metrik, Mister, M??rkte, M??ster, Timers, firmst, firmte, imkert, keimst, k??mest, merkst, miefst, reimst, ??rmste, Emirs, Fermi, Imker, Imkes, Items, Keims, Krems, Miefs, Mikes, Reims, Semit, Terms, Timer, Times, firme, firmt, imkre, keimt, k??met, k??mst, meist, merkt, mieft, miste, m??ste, reimt, remis, ??mter, EMRK, Emir, FSME, Imke, Item, Keim, Kims, Krim, MEKs, Mets, Mief, Mike, Mist, M??re, Reim, Rems, Seim, Term, Tims, eSIM, fMRT, firm, k??me, k??mt, merk, mies, time, Ems, FMS, Kfm, Kim, MEK, MRI, MRT, MSI, MSR, Met, MfS, M??r, REM, SIM, SME, TMS, Tim, mir, mit"),
        Zeit("2021-09-22", "MLLKOEUIG", "Kollegium, Elogium, mollige, ulkigem, Miguel, klugem, mollig, Golem, Kelim, Lemgo, MOLLE, Mille, Milou, Mogli, Mogul, Molke, Molli, Oleum, mogle, ollem, Emil, Imke, Keim, Kulm, Leim, Limo, Lom??, Melk, Mike, Mole, Moll, Muli, Mull, Olme, Ulme, molk, EMG, Elm, Emo, Emu, GMO, IGM, Ilm, KMU, Kim, LMU, MEK, MIG, Mio, Mol, OEM, Olm, Omi, UML, Ulm"),
        Zeit("2021-09-15", "LRWKSIEAH", "Kreiswahl, Wahlkreis, Wahlkrise, Klareis, Waliser, Walkers, Ariels, Eiklar, Israel, Lasker, Rahels, Relais, Rilkes, Salier, Seiwal, Serail, Serial, Sheila, Sklera, Walker, Walser, kahler, kahles, klares, Alkis, Ariel, Arles, Earls, Elias, Elisa, Hasel, Heils, Helis, Ilkas, Kalis, Karel, Karls, Kasel, Keils, Kerls, Kiels, Krale, Laser, Leaks, Lears, Lewis, Likes, Rahel, Rakel, Riehl, Rilke, Sahel, Silke, Slawe, Wales, Wiehl, halse, kahle, klare, walke, Ahle, Alis, Alki, Earl, Elis, Elsa, Hals, Heli, Ilka, Ilse, Kali, Karl, Keil, Kerl, Kiel, Kral, LKWs, Lahr, Laie, Lake, Lars, Leak, Lear, Leas, Liek, Lira, Lire, Lisa, Lise, Lkws, Reli, Sale, Siel, Sihl, Wahl, Wale, Wals, Wels, Werl, heil, kahl, klar, leih, leis, lieh, lies, like, real, seil, weil, welk, Ali, Alk, Eli, KHL, LKA, LKH, LRA, LRK, LRS, LSI, LWS, Lea, Lkw, RAL, SKL, Wal, als, las"),
        Zeit("2021-09-08", "HVLCIEGRE", "vergleich, vergliche, gleicher, verglich, Grieche, Reichel, Viecher, gleiche, verleih, verlieh, Ch??rie, Eichel, Leiche, Lerche, gleich, heiler, reiche, rieche, vergeh, Chile, Elche, Erich, Geher, Hegel, Heger, Helge, Riehl, Viech, eiche, glich, heile, hieve, lehre, leihe, reche, reich, reihe, riech, EHEC, Elch, HREE, Heer, Heli, Lech, Rehe, Vieh, eher, ehre, gehe, hege, heil, hier, ihre, leih, lieh, reih, Che, Chr, EHI, EHV, HIV, HLG, LHC, LHG, Reh, chi, ehe, geh, her, hie, ich, ihr"),
        Zeit("2021-09-01", "KRECTB??LA", "Talbr??cke, abr??ckte, ??berlack, Brackel, Kerbtal, Lackt??r, ableckt, abr??cke, abr??ckt, ber??ckt, kalbert, Bracke, Brakel, Br??cke, Clarke, Eckart, Lacker, L??beck, Racket, Tacker, Talker, ackert, backte, bleckt, b??ckte, kabelt, kalbre, kalbte, kalter, klarte, rektal, r??ckte, tracke, Acker, Barke, Blake, Break, Clark, Eklat, Kabel, Kaleb, Karel, Karte, Kater, Krale, Kreta, K??bel, Lacke, L??bke, L??cke, Rakel, Takel, Tarek, Track, Trakl, Treck, T??cke, backe, backt, b??cke, b??ckt, kable, kalbe, kalbt, kalte, kerbt, klare, klart, klebt, k??rte, leckt, reckt, r??cke, r??ckt, takle, t??rke, Akte, Bake, Bark, Beck, Cake, Kalb, Karl, Kart, Kate, Kerl, Kral, Lack, Lake, Leak, Rack, Reck, Talk, Teak, Trek, back, b??ck, b??ke, b??kt, eckt, ekr??, kalt, kcal, klar, kleb, k??re, k??rt, leck, r??ck, ATK, Abk, Akt, Alk, BKA, BKT, BRK, EKT, ERK, Eck, KBE, Kat, Kea, K??r, LKA, LKB, LRK, TBK, TK??, ??ke"),
        Zeit("2021-08-25", "KEZIMRLIA", "Reizklima, Mirakel, Eiklar, Karmel, Maikel, Makler, Marike, Zirkel, klarem, zirkle, Eirik, Erika, Imker, Kalme, Kamel, Karel, Kelim, Kemal, Klima, Krale, Kreml, Krimi, Maike, Makel, Malik, Marek, Marik, Marke, Milka, Rakel, Reiki, Rilke, imkre, klare, krame, zirka, Alki, EMRK, Erik, Ikea, Ilka, Imke, Irak, Kali, Karl, Keil, Keim, Kerl, Kiel, Kiez, Kira, Kral, Kram, Krim, Lake, Leak, Liek, Maik, Maki, Mark, Melk, Mika, Mike, Raki, Zika, klar, like, merk, Alk, ERK, IRK, Kai, Kea, Kia, Kim, Kir, LKA, LKZ, LRK, LZK, MEK, RKI, ZAK, kam, ??ke"),
        Zeit("2021-08-18", "TESNG??NLS", "l??ngstens, St??ngeln, St??ngels, l??ngsten, l??ngstes, St??ngel, gen??sst, l??ngste, n??selst, n??ssten, s??ngest, ??ngsten, Ge??sts, G??sten, g??lten, l??gest, l??ngst, l??sest, n??selt, n??sste, sengst, s??gten, s??nget, ??ngste, Gents, Ge??st, G??ste, Nests, Stegs, engst, ges??t, g??lte, legst, l??gst, l??set, l??sst, n??sst, sengt, s??gst, s??gte, s??ten, ??sest, ??sten, EStG, Gent, Nest, SSGT, Sets, Steg, engt, esst, legt, lest, l??gt, s??gt, s??st, s??te, ??ste, GLT, LTE, NET, Set, TLS, TSE, Tel, s??t, ??st"),
    ]
}
