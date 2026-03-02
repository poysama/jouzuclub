// Jouzu Club - Automatic Furigana via Kuroshiro
// Dictionary (~12MB) only loads when user opts in via toggle.
// Preference persists in localStorage.

(function () {
  'use strict';

  var STORAGE_KEY = 'jouzu-furigana';
  var CDN = 'https://cdn.jsdelivr.net/npm';
  var DICT_PATH = CDN + '/kuromoji@0.1.2/dict';

  var SKIP_TAGS = new Set([
    'SCRIPT', 'STYLE', 'CODE', 'PRE', 'RUBY', 'RT', 'RP',
    'TEXTAREA', 'INPUT', 'SELECT', 'BUTTON', 'SVG', 'IMG'
  ]);

  var HAS_KANJI = /[\u4e00-\u9faf\u3400-\u4dbf]/;

  var kuroshiroInstance = null;
  var isLoading = false;
  var isAnnotated = false;

  // ---- Toggle button ----

  function createToggle(onClick) {
    var btn = document.createElement('button');
    btn.className = 'furigana-toggle';
    btn.setAttribute('aria-label', 'Toggle furigana');
    btn.title = 'Toggle furigana (振り仮名)';
    btn.addEventListener('click', onClick);
    document.body.appendChild(btn);
    return btn;
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

  function yieldToMain() {
    return new Promise(function (r) { setTimeout(r, 0); });
  }

  async function annotateNodes(kuroshiro, nodes) {
    var BATCH = 5;
    for (var i = 0; i < nodes.length; i++) {
      var node = nodes[i];
      if (!node.parentElement) continue;

      var html = await kuroshiro.convert(node.textContent, {
        mode: 'furigana',
        to: 'hiragana'
      });

      if (html !== node.textContent && html.indexOf('<ruby>') !== -1) {
        var span = document.createElement('span');
        span.innerHTML = html;
        node.parentElement.replaceChild(span, node);
      }

      if (i % BATCH === 0) await yieldToMain();
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

  // ---- Load + annotate (lazy, on first enable) ----

  async function loadAndAnnotate(btn) {
    if (isLoading) return;
    isLoading = true;
    btn.textContent = '振 …';
    btn.disabled = true;

    try {
      if (!kuroshiroInstance) {
        await loadScript(CDN + '/kuroshiro@1.2.0/dist/kuroshiro.min.js');
        await loadScript(CDN + '/kuroshiro-analyzer-kuromoji@1.1.0/dist/kuroshiro-analyzer-kuromoji.min.js');

        var KuroshiroClass = window.Kuroshiro.default || window.Kuroshiro;
        var AnalyzerClass = window.KuromojiAnalyzer.default || window.KuromojiAnalyzer;
        kuroshiroInstance = new KuroshiroClass();
        await kuroshiroInstance.init(new AnalyzerClass({ dictPath: DICT_PATH }));
      }

      if (!isAnnotated) {
        var content = document.querySelector('.main-content');
        if (content) {
          var nodes = collectTextNodes(content);
          await annotateNodes(kuroshiroInstance, nodes);
          isAnnotated = true;
        }
      }

      document.body.classList.remove('furigana-hidden');
      localStorage.setItem(STORAGE_KEY, 'on');
      btn.textContent = '振 ON';
      btn.disabled = false;
    } catch (err) {
      console.warn('[furigana] Failed to load:', err);
      btn.textContent = '振 ✕';
      btn.title = 'Furigana unavailable (failed to load dictionary)';
      btn.disabled = false;
    } finally {
      isLoading = false;
    }
  }

  // ---- Main ----

  function init() {
    var content = document.querySelector('.main-content');
    if (!content) return;

    // Only show toggle on pages that have kanji
    var hasKanji = HAS_KANJI.test(content.textContent);
    if (!hasKanji) return;

    var pref = localStorage.getItem(STORAGE_KEY);

    var btn = createToggle(function () {
      if (isAnnotated && !document.body.classList.contains('furigana-hidden')) {
        // Already showing → hide
        document.body.classList.add('furigana-hidden');
        localStorage.setItem(STORAGE_KEY, 'off');
        btn.textContent = '振 OFF';
      } else if (isAnnotated) {
        // Annotated but hidden → show
        document.body.classList.remove('furigana-hidden');
        localStorage.setItem(STORAGE_KEY, 'on');
        btn.textContent = '振 ON';
      } else {
        // Not yet loaded → load and annotate
        loadAndAnnotate(btn);
      }
    });

    // Start with furigana off (default) unless user previously opted in
    if (pref === 'on') {
      loadAndAnnotate(btn);
    } else {
      document.body.classList.add('furigana-hidden');
      btn.textContent = '振 OFF';
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
