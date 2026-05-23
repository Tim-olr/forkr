package timolr.chess.action;

import org.apache.struts2.ActionSupport;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

public abstract class JsonAction extends ActionSupport {

    private InputStream jsonStream;

    protected String json(String s) {
        jsonStream = new ByteArrayInputStream(s.getBytes(StandardCharsets.UTF_8));
        return SUCCESS;
    }

    public InputStream getJsonStream() { return jsonStream; }
}
