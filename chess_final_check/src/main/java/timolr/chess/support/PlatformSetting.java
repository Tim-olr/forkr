package timolr.chess.support;

import jakarta.persistence.*;

@Entity
@Table(name = "platform_settings")
public class PlatformSetting {

    @Id
    @Column(name = "setting_key", length = 50)
    private String key;

    @Column(name = "setting_value", nullable = false, length = 255)
    private String value;

    @Column(length = 200)
    private String description;

    public PlatformSetting() {}
    public PlatformSetting(String key, String value, String description) {
        this.key = key; this.value = value; this.description = description;
    }

    public String getKey() { return key; }
    public void setKey(String key) { this.key = key; }
    public String getValue() { return value; }
    public void setValue(String value) { this.value = value; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean isEnabled() { return "true".equalsIgnoreCase(value); }
}
