package timolr.chess.bot;

import jakarta.persistence.*;
import timolr.chess.army.Army;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

@Entity
@Table(name = "bots")
public class Bot {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(nullable = false)
    private int elo = 800;

    @Column(length = 100)
    private String collection;

    @Column(name = "image_path", length = 255)
    private String imagePath;

    // General voicelines (shown periodically)
    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "bot_voicelines", joinColumns = @JoinColumn(name = "bot_id"))
    @Column(name = "voiceline", length = 500)
    private List<String> voicelines = new ArrayList<>();

    // When opponent captures one of the bot's pieces
    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "bot_g0_captures", joinColumns = @JoinColumn(name = "bot_id"))
    @Column(name = "voiceline", length = 500)
    private List<String> g0CaptureLines = new ArrayList<>();

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "bot_g1_captures", joinColumns = @JoinColumn(name = "bot_id"))
    @Column(name = "voiceline", length = 500)
    private List<String> g1CaptureLines = new ArrayList<>();

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "bot_g2_captures", joinColumns = @JoinColumn(name = "bot_id"))
    @Column(name = "voiceline", length = 500)
    private List<String> g2CaptureLines = new ArrayList<>();

    // When the bot takes one of the opponent's pieces
    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "bot_g0_takes", joinColumns = @JoinColumn(name = "bot_id"))
    @Column(name = "voiceline", length = 500)
    private List<String> g0TakeLines = new ArrayList<>();

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "bot_g1_takes", joinColumns = @JoinColumn(name = "bot_id"))
    @Column(name = "voiceline", length = 500)
    private List<String> g1TakeLines = new ArrayList<>();

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "bot_g2_takes", joinColumns = @JoinColumn(name = "bot_id"))
    @Column(name = "voiceline", length = 500)
    private List<String> g2TakeLines = new ArrayList<>();

    // When the bot wins
    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "bot_win_lines", joinColumns = @JoinColumn(name = "bot_id"))
    @Column(name = "voiceline", length = 500)
    private List<String> winLines = new ArrayList<>();

    // When the bot loses
    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "bot_lose_lines", joinColumns = @JoinColumn(name = "bot_id"))
    @Column(name = "voiceline", length = 500)
    private List<String> loseLines = new ArrayList<>();

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
        name = "bot_armies",
        joinColumns = @JoinColumn(name = "bot_id"),
        inverseJoinColumns = @JoinColumn(name = "army_id")
    )
    private List<Army> armies = new ArrayList<>();

    private static final Random RNG = new Random();

    public String getRandomVoiceline() {
        if (voicelines.isEmpty()) return null;
        return voicelines.get(RNG.nextInt(voicelines.size()));
    }

    public String getRandomG0CaptureLine() {
        if (g0CaptureLines.isEmpty()) return null;
        return g0CaptureLines.get(RNG.nextInt(g0CaptureLines.size()));
    }

    public String getRandomG1CaptureLine() {
        if (g1CaptureLines.isEmpty()) return null;
        return g1CaptureLines.get(RNG.nextInt(g1CaptureLines.size()));
    }

    public String getRandomG2CaptureLine() {
        if (g2CaptureLines.isEmpty()) return null;
        return g2CaptureLines.get(RNG.nextInt(g2CaptureLines.size()));
    }

    public String getRandomG0TakeLine() {
        if (g0TakeLines.isEmpty()) return null;
        return g0TakeLines.get(RNG.nextInt(g0TakeLines.size()));
    }

    public String getRandomG1TakeLine() {
        if (g1TakeLines.isEmpty()) return null;
        return g1TakeLines.get(RNG.nextInt(g1TakeLines.size()));
    }

    public String getRandomG2TakeLine() {
        if (g2TakeLines.isEmpty()) return null;
        return g2TakeLines.get(RNG.nextInt(g2TakeLines.size()));
    }

    public String getRandomWinLine() {
        if (winLines.isEmpty()) return null;
        return winLines.get(RNG.nextInt(winLines.size()));
    }

    public String getRandomLoseLine() {
        if (loseLines.isEmpty()) return null;
        return loseLines.get(RNG.nextInt(loseLines.size()));
    }

    // Varargs setter for programmatic use
    public void setVoicelines(String... lines) {
        this.voicelines.clear();
        for (String line : lines) {
            if (line != null && !line.isBlank()) this.voicelines.add(line.trim());
        }
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public int getElo() { return elo; }
    public void setElo(int elo) { this.elo = elo; }

    public String getCollection() { return collection; }
    public void setCollection(String collection) { this.collection = (collection != null && !collection.isBlank()) ? collection.trim() : null; }

    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }

    public List<String> getVoicelines() { return voicelines; }
    public void setVoicelines(List<String> voicelines) { this.voicelines = voicelines; }

    public List<String> getG0CaptureLines() { return g0CaptureLines; }
    public void setG0CaptureLines(List<String> g0CaptureLines) { this.g0CaptureLines = g0CaptureLines; }

    public List<String> getG1CaptureLines() { return g1CaptureLines; }
    public void setG1CaptureLines(List<String> g1CaptureLines) { this.g1CaptureLines = g1CaptureLines; }

    public List<String> getG2CaptureLines() { return g2CaptureLines; }
    public void setG2CaptureLines(List<String> g2CaptureLines) { this.g2CaptureLines = g2CaptureLines; }

    public List<String> getG0TakeLines() { return g0TakeLines; }
    public void setG0TakeLines(List<String> g0TakeLines) { this.g0TakeLines = g0TakeLines; }

    public List<String> getG1TakeLines() { return g1TakeLines; }
    public void setG1TakeLines(List<String> g1TakeLines) { this.g1TakeLines = g1TakeLines; }

    public List<String> getG2TakeLines() { return g2TakeLines; }
    public void setG2TakeLines(List<String> g2TakeLines) { this.g2TakeLines = g2TakeLines; }

    public List<String> getWinLines() { return winLines; }
    public void setWinLines(List<String> winLines) { this.winLines = winLines; }

    public List<String> getLoseLines() { return loseLines; }
    public void setLoseLines(List<String> loseLines) { this.loseLines = loseLines; }

    public List<Army> getArmies() { return armies; }
    public void setArmies(List<Army> armies) { this.armies = armies; }
}
