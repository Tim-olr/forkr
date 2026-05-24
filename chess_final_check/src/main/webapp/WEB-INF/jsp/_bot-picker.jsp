<%-- _bot-picker.jsp — bot picker modal. Include before </body> in all sidebar pages except online-game. --%>
<div class="modal-backdrop" id="botPickerModal" style="display:none" onclick="if(event.target===this)closeBotPicker()">
    <div class="modal" style="max-width:520px;max-height:82vh;overflow:hidden;display:flex;flex-direction:column">
        <div class="modal-head">
            <span class="modal-title">Play vs Bots</span>
            <button class="modal-close" onclick="closeBotPicker()">✕</button>
        </div>
        <div id="botPickerBody" style="overflow-y:auto;flex:1;padding:16px 20px 20px"></div>
    </div>
</div>
<script>
(function() {
    var _botsLoaded = false;
    var _CTX = "${pageContext.request.contextPath}";

    window.openBotPicker = function() {
        document.getElementById('botPickerModal').style.display = 'grid';
        if (!_botsLoaded) {
            _botsLoaded = true;
            var body = document.getElementById('botPickerBody');
            body.innerHTML = '<div style="color:var(--ink-faint);text-align:center;padding:32px 0;font-size:13px">Loading…</div>';
            fetch(_CTX + '/botsJson')
                .then(function(r) { return r.json(); })
                .then(function(data) { _renderBots(data); })
                .catch(function() {
                    document.getElementById('botPickerBody').innerHTML =
                        '<div style="color:var(--ink-faint);text-align:center;padding:32px 0;font-size:13px">Failed to load bots.</div>';
                });
        }
    };

    window.closeBotPicker = function() {
        document.getElementById('botPickerModal').style.display = 'none';
    };

    function _esc(s) {
        if (!s) return '';
        return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    }

    function _renderBots(bots) {
        var container = document.getElementById('botPickerBody');
        container.innerHTML = '';
        if (!bots || bots.length === 0) {
            container.innerHTML = '<div style="color:var(--ink-faint);text-align:center;padding:32px 0;font-size:13px">No bots available yet.</div>';
            return;
        }
        var grouped = {}, order = [];
        bots.forEach(function(b) {
            var col = b.collection || 'Bots';
            if (!grouped[col]) { grouped[col] = []; order.push(col); }
            grouped[col].push(b);
        });
        order.forEach(function(col) {
            var h = document.createElement('div');
            h.style.cssText = 'font-size:11px;letter-spacing:.1em;text-transform:uppercase;color:var(--ink-faint);font-family:var(--font-mono);padding:8px 0 6px';
            h.textContent = col;
            container.appendChild(h);
            grouped[col].forEach(function(bot) {
                var card = document.createElement('div');
                card.style.cssText = 'display:flex;align-items:center;gap:12px;padding:10px 12px;border:1px solid var(--line);border-radius:6px;cursor:pointer;margin-bottom:8px;transition:background .12s';
                card.onmouseenter = function() { this.style.background = 'var(--bg-elev)'; };
                card.onmouseleave = function() { this.style.background = ''; };
                card.onclick = function() { window.location.href = _CTX + '/game?botId=' + bot.id; };
                var iw = document.createElement('div');
                iw.style.cssText = 'width:40px;height:40px;border-radius:50%;overflow:hidden;flex-shrink:0;background:var(--bg-elev-2);display:flex;align-items:center;justify-content:center;border:1px solid var(--line)';
                if (bot.imagePath) {
                    var img = document.createElement('img');
                    img.src = _CTX + '/' + bot.imagePath;
                    img.style.cssText = 'width:100%;height:100%;object-fit:cover';
                    iw.appendChild(img);
                } else {
                    iw.innerHTML = '<svg width="22" height="22" viewBox="0 0 45 45"><circle fill="url(#bg0)" stroke="#3a1800" stroke-width="1.5" cx="22.5" cy="11.5" r="5.5"/></svg>';
                }
                var info = document.createElement('div');
                info.style.flex = '1';
                info.innerHTML = '<div style="font-size:13.5px;font-weight:500">' + _esc(bot.name) + '</div>'
                               + '<div style="color:var(--ink-faint);font-size:12px">' + bot.elo + ' ELO</div>';
                var btn = document.createElement('button');
                btn.className = 'btn sm';
                btn.textContent = 'Play';
                btn.onclick = function(e) { e.stopPropagation(); window.location.href = _CTX + '/game?botId=' + bot.id; };
                card.appendChild(iw);
                card.appendChild(info);
                card.appendChild(btn);
                container.appendChild(card);
            });
        });
    }
}());
</script>
