// Jouzu Club - Automatic Furigana via Kuroshiro
// Loads kuromoji dictionary (~12-18MB) on first visit, cached after.
// Gracefully degrades if CDN or JS fails.

(function () {
  'use strict';

  var STORAGE_KEY = 'jouzu-furigana';
  var CDN = 'https://cdn.jsdelivr.net/npm';
  var DICT_PATH = CDN + '/kuromoji@0.1.2/dict';

  // Elements to skip when walking the DOM
  var SKIP_TAGS = new Set([
    'SCRIPT', 'STYLE', 'CODE', 'PRE', 'RUBY', 'RT', 'RP',
    'TEXTAREA', 'INPUT', 'SELECT', 'BUTTON', 'SVG', 'IMG'
  ]);

  // Regex to detect kanji (CJK Unified Ideographs)
  var HAS_KANJI = /[\u4e00-\u9faf\u3400-\u4dbf]/;

  // ---- Toggle button ----

  function createToggle() {
    var btn = document.createElement('button');
    btn.className = 'furigana-toggle';
    btn.setAttribute('aria-label', 'Toggle furigana');
    btn.title = 'Toggle furigana (振り仮名)';
    updateToggleLabel(btn);
    btn.addEventListener('click', function () {
      var hidden = document.body.classList.toggle('furigana-hidden');
      localStorage.setItem(STORAGE_KEY, hidden ? 'off' : 'on');
      updateToggleLabel(btn);
    });
    document.body.appendChild(btn);
    return btn;
  }

  function updateToggleLabel(btn) {
    var isHidden = document.body.classList.contains('furigana-hidden');
    btn.textContent = isHidden ? '振 OFF' : '振 ON';
  }

  // ---- DOM walking ----

  function collectTextNodes(root) {
    var nodes = [];
    var walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT, {
      acceptNode: function (node) {
        if (!node.textContent || !HAS_KANJI.test(node.textContent)) {
          return NodeFilter.FILTER_REJECT;
        }
        var el = node.parentElement;
        while (el && el !== root) {
          if (SKIP_TAGS.has(el.tagName)) return NodeFilter.FILTER_REJECT;
          el = el.parentElement;
        }
        return NodeFilter.FILTER_ACCEPT;
      }
    });
    while (walker.nextNode()) nodes.push(walker.currentNode);
    return nodes;
  }

  async function annotateNodes(kuroshiro, nodes) {
    for (var i = 0; i < nodes.length; i++) {
      var node = nodes[i];
      if (!node.parentElement) continue; // detached

      var html = await kuroshiro.convert(node.textContent, {
        mode: 'furigana',
        to: 'hiragana'
      });

      // Only replace if kuroshiro actually added ruby tags
      if (html !== node.textContent && html.indexOf('<ruby>') !== -1) {
        var span = document.createElement('span');
        span.innerHTML = html;
        node.parentElement.replaceChild(span, node);
      }
    }
  }

  // ---- Script loader ----

  function loadScript(src) {
    return new Promise(function (resolve, reject) {
      var s = document.createElement('script');
      s.src = src;
      s.onload = resolve;
      s.onerror = reject;
      document.head.appendChild(s);
    });
  }

  // ---- Main ----

  async function init() {
    var content = document.querySelector('.main-content');
    if (!content) return;

    var nodes = collectTextNodes(content);
    if (nodes.length === 0) return;

    // Restore user preference
    var pref = localStorage.getItem(STORAGE_KEY);
    if (pref === 'off') document.body.classList.add('furigana-hidden');

    // Show toggle immediately (even before dictionary loads)
    var btn = createToggle();
    btn.disabled = true;
    btn.textContent = '振 …';

    try {
      // Load libraries from CDN
      await loadScript(CDN + '/kuroshiro@1.2.0/dist/kuroshiro.min.js');
      await loadScript(CDN + '/kuroshiro-analyzer-kuromoji@1.1.0/dist/kuroshiro-analyzer-kuromoji.min.js');

      // Kuroshiro UMD exports { default: class }, analyzer exports the class directly
      var KuroshiroClass = window.Kuroshiro.default || window.Kuroshiro;
      var AnalyzerClass = window.KuromojiAnalyzer.default || window.KuromojiAnalyzer;
      var kuroshiro = new KuroshiroClass();
      await kuroshiro.init(new AnalyzerClass({ dictPath: DICT_PATH }));

      // Annotate
      await annotateNodes(kuroshiro, nodes);

      btn.disabled = false;
      updateToggleLabel(btn);
    } catch (err) {
      console.warn('[furigana] Failed to load kuroshiro:', err);
      btn.textContent = '振 ✕';
      btn.title = 'Furigana unavailable (failed to load dictionary)';
    }
  }

  // Run after DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
