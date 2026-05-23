package timolr.chess.game.pieces;

import timolr.chess.game.pieces.grade0.CrawlerPiece;
import timolr.chess.game.pieces.grade0.EvilPawnPiece;
import timolr.chess.game.pieces.grade0.HollowPiece;
import timolr.chess.game.pieces.grade0.LongpawPiece;
import timolr.chess.game.pieces.grade0.PawnPiece;
import timolr.chess.game.pieces.grade0.RetreaterPiece;
import timolr.chess.game.pieces.grade0.SquirePiece;
import timolr.chess.game.pieces.grade1.BeastHandlerPiece;
import timolr.chess.game.pieces.grade1.CoilPiece;
import timolr.chess.game.pieces.grade1.ChoirPiece;
import timolr.chess.game.pieces.grade3.HuskPiece;
import timolr.chess.game.pieces.grade3.HydraPiece;
import timolr.chess.game.pieces.grade3.LibraryPiece;
import timolr.chess.game.pieces.grade1.BirdPiece;
import timolr.chess.game.pieces.grade1.BishopPiece;
import timolr.chess.game.pieces.grade1.DukePiece;
import timolr.chess.game.pieces.grade1.EaglePiece;
import timolr.chess.game.pieces.grade1.EclipsePiece;
import timolr.chess.game.pieces.grade1.HerbalistPiece;
import timolr.chess.game.pieces.grade1.JesterPiece;
import timolr.chess.game.pieces.grade1.KnightPiece;
import timolr.chess.game.pieces.grade1.LancerPiece;
import timolr.chess.game.pieces.grade1.LanternPiece;
import timolr.chess.game.pieces.grade1.PrincePiece;
import timolr.chess.game.pieces.grade1.RookPiece;
import timolr.chess.game.pieces.grade1.ShieldPiece;
import timolr.chess.game.pieces.grade2.BootPiece;
import timolr.chess.game.pieces.grade2.FeatherPiece;
import timolr.chess.game.pieces.grade2.PrincessPiece;
import timolr.chess.game.pieces.grade2.QueenPiece;
import timolr.chess.game.pieces.grade2.WardenPiece;
import timolr.chess.game.pieces.grade1.WizardPiece;
import timolr.chess.game.pieces.grade3.ForkPiece;
import timolr.chess.game.pieces.grade3.KingPiece;
import timolr.chess.game.pieces.grade3.OraclePiece;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class PieceRegistry {

    // ─────────────────────────────────────────────────────────────────────────
    // HOW TO ADD A CUSTOM PIECE
    //
    // 1. Create a Java class extending Piece (see the grade1/ package for examples).
    //    Set movement flags in the constructor — the JS engine reads them automatically.
    //
    // 2. Add one line here:
    //
    //      register("TYPE", "Label", "sprite", "♟", "♟", "x", false, new MyPiece(Teams.WHITE));
    //
    //    type    Unique UPPERCASE key stored in the DB.
    //    label   Name shown in the Army Builder palette.
    //    sprite  Base name for SVGs in src/main/webapp/sprites/ (or null).
    //    wUni    Unicode fallback for White (shown when SVG is absent).
    //    bUni    Unicode fallback for Black.
    //    char    Unique lowercase letter for this piece on the JS board.
    //            Letters already taken: p  n  r  b  j  q  k  l  e  y  d  z  h  s  f  a  o  i  g  m  w  c  t  u  x  ch  hk  hy  lb  fk  sq  lp  rt  ho  cr
    //    special Pass true only for pawn-like pieces that need hardcoded JS logic.
    //    piece   An instance of your piece class — grade and all flags are read from it.
    //
    // 3. Drop <sprite>_white.svg and <sprite>_black.svg into src/main/webapp/sprites/.
    //
    // 4. Rebuild and redeploy — the piece appears in the Army Builder automatically.
    // ─────────────────────────────────────────────────────────────────────────

    private static final List<PieceDefinition> PIECES;

    static {
        List<PieceDefinition> list = new ArrayList<>();

        register(list, "PAWN","Pawn","pawn","♙", "♟", "p", true,  new PawnPiece(Teams.WHITE));
        register(list, "KNIGHT","Knight","knight","♘", "♞", "n", false, new KnightPiece(Teams.WHITE));
        register(list, "ROOK","Rook","rook","♖", "♜", "r", false, new RookPiece(Teams.WHITE));
        register(list, "BISHOP","Bishop","bishop","♗", "♝", "b", false, new BishopPiece(Teams.WHITE));
        register(list, "JESTER","Jester","jester","♖", "♜", "j", false, new JesterPiece(Teams.WHITE));
        register(list, "QUEEN", "Queen","queen","♕", "♛", "q", false, new QueenPiece(Teams.WHITE));
        register(list, "KING","King","king","♔", "♚", "k", false, new KingPiece(Teams.WHITE));
        register(list, "LANCER","Lancer","lancer","♜", "♜", "l", false, new LancerPiece(Teams.WHITE));
        register(list, "EVIL_PAWN","Evil Pawn","evil_pawn", "♟", "♟", "e", false, new EvilPawnPiece(Teams.WHITE));
        register(list, "SQUIRE",   "Squire",   "squire",    "♟", "♟", "sq", false, new SquirePiece(Teams.WHITE));
        register(list, "LONGPAW",  "Longpaw",  "longpaw",   "♟", "♟", "lp", false, new LongpawPiece(Teams.WHITE));
        register(list, "RETREATER","Retreater","retreater",  "♟", "♟", "rt", false, new RetreaterPiece(Teams.WHITE));
        register(list, "HOLLOW",   "Hollow",   "hollow",    "♟", "♟", "ho", false, new HollowPiece(Teams.WHITE));
        register(list, "CRAWLER",  "Crawler",  "crawler",   "♟", "♟", "cr", false, new CrawlerPiece(Teams.WHITE));
        register(list, "PRINCE","Prince","prince","♝", "♝", "y", false, new PrincePiece(Teams.WHITE));
        register(list, "DUKE","Duke","duke","♞", "♞", "d", false, new DukePiece(Teams.WHITE));
        register(list, "WARDEN","Warden","warden","♛", "♛", "z", false, new WardenPiece(Teams.WHITE));
        register(list, "HERBALIST","Herbalist","herbalist","♗", "♝", "h", false, new HerbalistPiece(Teams.WHITE));
        register(list, "PRINCESS","Princess","princess","♕", "♛", "s", false, new PrincessPiece(Teams.WHITE));
        register(list, "BIRD","Bird","bird","♘", "♞", "f", false, new BirdPiece(Teams.WHITE));
        register(list, "BEAST_HANDLER","Beast Handler","beast_handler","♖", "♜", "a", false, new BeastHandlerPiece(Teams.WHITE));
        register(list, "BOOT","Boot","boot","♙", "♟", "o", false, new BootPiece(Teams.WHITE));
        register(list, "SHIELD","Shield","shield","♖", "♜", "i", false, new ShieldPiece(Teams.WHITE));
        register(list, "EAGLE","Eagle","eagle","♘", "♞", "g", false, new EaglePiece(Teams.WHITE));
        register(list, "LANTERN","Lantern","lantern","♗", "♝", "m", false, new LanternPiece(Teams.WHITE));
        register(list, "ECLIPSE","Eclipse","eclipse","♖", "♜", "w", false, new EclipsePiece(Teams.WHITE));
        register(list, "FEATHER","Feather","feather","♛", "♕", "c", false, new FeatherPiece(Teams.WHITE));
        register(list, "WIZARD","Wizard","wizard","♝", "♗", "t", false, new WizardPiece(Teams.WHITE));
        register(list, "ORACLE","Oracle","oracle","♚", "♔", "u", false, new OraclePiece(Teams.WHITE));
        register(list, "COIL","Coil",null,"♖", "♜", "x", false, new CoilPiece(Teams.WHITE));
        register(list, "CHOIR","Choir",null,"♗", "♝", "ch", false, new ChoirPiece(Teams.WHITE));
        register(list, "HUSK","Husk",null,"♔", "♚", "hk", false, new HuskPiece(Teams.WHITE));
        register(list, "HYDRA","Hydra",null,"♕", "♛", "hy", false, new HydraPiece(Teams.WHITE));
        register(list, "LIBRARY","Library",null,"♛", "♕", "lb", false, new LibraryPiece(Teams.WHITE));
        register(list, "FORK","Fork",null,"♔", "♚", "fk", false, new ForkPiece(Teams.WHITE));

        PIECES = Collections.unmodifiableList(list);
    }

    private static void register(List<PieceDefinition> list,
                                 String type, String label, String sprite,
                                 String whiteUnicode, String blackUnicode, String gameChar,
                                 boolean special, Piece template) {
        list.add(new PieceDefinition(type, label, sprite, whiteUnicode, blackUnicode,
                                     gameChar, special, template));

    }

    public static List<PieceDefinition> getAll() { return PIECES; }
}
