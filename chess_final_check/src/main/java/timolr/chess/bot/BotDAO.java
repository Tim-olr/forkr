package timolr.chess.bot;

import org.hibernate.Session;
import org.hibernate.Transaction;
import timolr.chess.army.Army;
import timolr.chess.util.HibernateUtil;

import java.util.ArrayList;
import java.util.List;

public class BotDAO {

    public List<Bot> findAll() {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return s.createQuery("FROM Bot ORDER BY name", Bot.class).list();
        }
    }

    /** Lightweight projection — only the fields needed for the bot-picker UI. */
    public List<Object[]> findAllForPicker() {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return s.createQuery(
                "SELECT b.id, b.name, b.elo, b.collection, b.imagePath FROM Bot b ORDER BY b.name",
                Object[].class
            ).list();
        }
    }

    public Bot findById(Long id) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return s.get(Bot.class, id);
        }
    }

    public void save(Bot bot) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            Transaction tx = s.beginTransaction();
            s.persist(bot);
            tx.commit();
        }
    }

    public void update(Long id, String name, int elo, String collection,
                       List<String> voicelines,
                       List<String> g0Captures, List<String> g1Captures, List<String> g2Captures,
                       List<String> g0Takes, List<String> g1Takes, List<String> g2Takes,
                       List<String> winLines, List<String> loseLines,
                       List<Long> armyIds) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            Transaction tx = s.beginTransaction();
            Bot bot = s.get(Bot.class, id);
            if (bot == null) { tx.rollback(); return; }

            bot.setName(name);
            bot.setElo(elo);
            bot.setCollection(collection);
            bot.setVoicelines(filter(voicelines));
            bot.setG0CaptureLines(filter(g0Captures));
            bot.setG1CaptureLines(filter(g1Captures));
            bot.setG2CaptureLines(filter(g2Captures));
            bot.setG0TakeLines(filter(g0Takes));
            bot.setG1TakeLines(filter(g1Takes));
            bot.setG2TakeLines(filter(g2Takes));
            bot.setWinLines(filter(winLines));
            bot.setLoseLines(filter(loseLines));

            bot.getArmies().clear();
            if (armyIds != null) {
                for (Long armyId : armyIds) {
                    Army army = s.find(Army.class, armyId);
                    if (army != null) bot.getArmies().add(army);
                }
            }

            tx.commit();
        }
    }

    public void updateImagePath(Long id, String imagePath) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            Transaction tx = s.beginTransaction();
            Bot bot = s.get(Bot.class, id);
            if (bot != null) {
                bot.setImagePath(imagePath);
            }
            tx.commit();
        }
    }

    public void delete(Long id) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            Transaction tx = s.beginTransaction();
            Bot bot = s.get(Bot.class, id);
            if (bot != null) s.remove(bot);
            tx.commit();
        }
    }

    private List<String> filter(List<String> lines) {
        List<String> result = new ArrayList<>();
        if (lines == null) return result;
        for (String line : lines) {
            if (line != null && !line.isBlank()) result.add(line.trim());
        }
        return result;
    }
}
