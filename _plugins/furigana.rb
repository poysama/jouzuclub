# frozen_string_literal: true

# Build-time furigana plugin for Jekyll.
# Uses MeCab (via natto gem) to annotate kanji with hiragana readings.
# Gracefully skips if MeCab is not installed.

MECAB_AVAILABLE = begin
  require 'natto'
  require 'nokogiri'
  Natto::MeCab.new
  true
rescue LoadError, Natto::MeCabError => e
  Jekyll.logger.warn "Furigana:", "MeCab not available (#{e.message}). Building without furigana."
  false
end

if MECAB_AVAILABLE
  module JouzuFurigana
    SKIP_ANCESTORS = %w[code pre ruby rt rp script style svg textarea].freeze
    KANJI_RE = /[\p{Han}]/
    JAPANESE_RE = /[\p{Hiragana}\p{Katakana}\p{Han}]/
    KATAKANA_TO_HIRAGANA = 0x0060 # Unicode offset: katakana - hiragana
    VOCAB_ENTRY_RE = /\A(.+?)(?:\s*【(.+?)】)?(?:\s*\((.+?)\))?\s*[–\-]\s+(.+)\z/

    module_function

    def kata_to_hira(str)
      str.gsub(/[\u30A1-\u30F6]/) { |c| (c.ord - KATAKANA_TO_HIRAGANA).chr('UTF-8') }
    end

    def inside_skip_ancestor?(node)
      node.ancestors.any? { |a| SKIP_ANCESTORS.include?(a.name) }
    end

    # Split a token into kanji-stem + okurigana by matching trailing hiragana.
    # e.g. surface=食べる reading=たべる → ["食", "た", "べる"]
    def split_okurigana(surface, reading)
      # Strip matching trailing hiragana
      trail = 0
      while trail < surface.length && trail < reading.length &&
            surface[-(trail + 1)] == reading[-(trail + 1)]
        trail += 1
      end

      # Strip matching leading hiragana
      lead = 0
      max_lead = surface.length - trail
      max_read = reading.length - trail
      while lead < max_lead && lead < max_read &&
            surface[lead] == reading[lead]
        lead += 1
      end

      kanji_part = surface[lead...(surface.length - trail)]
      reading_part = reading[lead...(reading.length - trail)]
      prefix = lead > 0 ? surface[0...lead] : nil
      suffix = trail > 0 ? surface[(surface.length - trail)..] : nil

      [prefix, kanji_part, reading_part, suffix]
    end

    def annotate(nm, text)
      result = +""
      byte_pos = 0
      nm.parse(text) do |node|
        next if node.is_bos? || node.is_eos?

        surface = node.surface

        # Preserve whitespace: rlength includes preceding whitespace, length is just the token.
        # The difference gives us the byte-length of any gap (spaces, etc.) before this token.
        space_bytes = node.rlength - node.length
        if space_bytes > 0
          result << text.byteslice(byte_pos, space_bytes).force_encoding('UTF-8')
        end
        byte_pos += node.rlength

        features = node.feature.split(',')

        # MeCab IPAdic format: pos,pos1,pos2,pos3,conj_type,conj_form,base,reading,pronunciation
        reading_kata = features[7]

        # Skip if no reading, or if surface has no kanji
        if reading_kata.nil? || reading_kata.empty? || !surface.match?(KANJI_RE)
          result << surface
          next
        end

        reading = kata_to_hira(reading_kata)

        # If reading equals surface (all hiragana already), skip
        if reading == surface
          result << surface
          next
        end

        prefix, kanji, kana, suffix = split_okurigana(surface, reading)
        result << prefix if prefix
        if kanji && !kanji.empty? && kana && !kana.empty?
          result << "<ruby>#{kanji}<rp>(</rp><rt>#{kana}</rt><rp>)</rp></ruby>"
        else
          result << surface
        end
        result << suffix if suffix
      end
      result
    end

    # Transform a language-text code block into individual example cards with furigana.
    # Each line "Japanese。 - English." becomes its own card.
    def transform_example_block(nm, block)
      code = block.at_css('code') || block.at_css('pre')
      return unless code

      lines = code.text.strip.split("\n").reject(&:empty?)
      return if lines.empty?

      container = Nokogiri::XML::Node.new('div', block.document)
      container['class'] = 'example-sentences'

      lines.each do |line|
        parts = line.split(/\s+-\s+/, 2)
        jp = parts[0]&.strip
        en = parts[1]&.strip
        next unless jp && !jp.empty?

        card = Nokogiri::XML::Node.new('div', block.document)
        card['class'] = 'example-sentence'

        jp_el = Nokogiri::XML::Node.new('span', block.document)
        jp_el['class'] = 'example-jp'
        jp_el['lang'] = 'ja'
        jp_el.inner_html = annotate(nm, jp)
        card.add_child(jp_el)

        if en && !en.empty?
          en_el = Nokogiri::XML::Node.new('span', block.document)
          en_el['class'] = 'example-en'
          en_el.inner_html = en
          card.add_child(en_el)
        end

        container.add_child(card)
      end

      block.replace(container)
    end

    # Transform a vocabulary ordered list (after ## Vocabulary) into styled vocab cards.
    # Parses: "食べる 【た・べる】 (ru-verb) – to eat" into word, reading, POS, meaning.
    def transform_vocabulary_list(nm, ol)
      container = Nokogiri::XML::Node.new('div', ol.document)
      container['class'] = 'vocab-list'

      ol.css('> li').each do |li|
        text = li.text.strip
        m = text.match(VOCAB_ENTRY_RE)
        next unless m

        word = m[1].strip
        reading = m[2]&.strip
        pos = m[3]&.strip
        meaning = m[4].strip

        entry = Nokogiri::XML::Node.new('div', ol.document)
        entry['class'] = 'vocab-entry'

        word_el = Nokogiri::XML::Node.new('span', ol.document)
        word_el['class'] = 'vocab-word'
        word_el['lang'] = 'ja'
        word_el.inner_html = annotate(nm, word)
        entry.add_child(word_el)

        if reading
          reading_el = Nokogiri::XML::Node.new('span', ol.document)
          reading_el['class'] = 'vocab-reading'
          reading_el.content = reading
          entry.add_child(reading_el)
        end

        if pos
          pos_el = Nokogiri::XML::Node.new('span', ol.document)
          pos_el['class'] = 'vocab-pos'
          pos_el.content = pos
          entry.add_child(pos_el)
        end

        meaning_el = Nokogiri::XML::Node.new('span', ol.document)
        meaning_el['class'] = 'vocab-meaning'
        meaning_el.content = meaning
        entry.add_child(meaning_el)

        container.add_child(entry)
      end

      ol.replace(container) unless container.children.empty?
    end

    # Transform a bullet/numbered list of "Japanese - English" items into word cards
    # with boxes around Japanese words and arrows between transformations.
    # e.g. "食べる → 食べない - not eat" → [食べる] → [食べない] \n not eat
    def transform_word_list(nm, list)
      items = list.css('> li')
      return if items.length < 2

      # Items must have a separator (- or –) or an arrow (→) AND Japanese text
      matches = items.count do |li|
        text = li.text.strip
        has_sep = text.match?(/\s+[\-–]\s+/)
        has_arrow = text.include?('→')
        (has_sep || has_arrow) && text.match?(JAPANESE_RE)
      end
      return if matches < (items.length * 0.6).ceil

      container = Nokogiri::XML::Node.new('div', list.document)
      container['class'] = 'word-list'

      items.each do |li|
        text = li.text.strip

        # Split into Japanese chain and English meaning
        parts = text.split(/\s+[\-–]\s+/, 2)
        jp_chain = parts[0]&.strip
        en = parts[1]&.strip
        next unless jp_chain && !jp_chain.empty? && jp_chain.match?(JAPANESE_RE)

        # Extract trailing parenthetical note from JP chain
        # e.g. "行く → 行かせられる (Short form: 行かされる)"
        note = nil
        if jp_chain =~ /\s*\(([^)]+)\)\s*\z/
          note = $1
          jp_chain = jp_chain.sub(/\s*\([^)]+\)\s*\z/, '').strip
        end

        entry = Nokogiri::XML::Node.new('div', list.document)
        entry['class'] = 'word-entry'

        # Build the chain of boxes with arrows
        chain = Nokogiri::XML::Node.new('div', list.document)
        chain['class'] = 'word-chain'

        jp_parts = jp_chain.split(/\s*→\s*/)
        jp_parts.each_with_index do |jp, i|
          if i > 0
            arrow = Nokogiri::XML::Node.new('span', list.document)
            arrow['class'] = 'word-arrow'
            arrow.content = '→'
            chain.add_child(arrow)
          end

          box = Nokogiri::XML::Node.new('span', list.document)
          box['class'] = 'word-box'
          box['lang'] = 'ja'
          box.inner_html = annotate(nm, jp.strip)
          chain.add_child(box)
        end

        entry.add_child(chain)

        # Add parenthetical note if present
        if note
          note_el = Nokogiri::XML::Node.new('span', list.document)
          note_el['class'] = 'word-note'
          note_el.inner_html = annotate(nm, note)
          entry.add_child(note_el)
        end

        # Add English meaning inline with em-dash separator
        if en && !en.empty?
          sep = Nokogiri::XML::Node.new('span', list.document)
          sep['class'] = 'word-sep'
          sep.content = '—'
          entry.add_child(sep)

          en_el = Nokogiri::XML::Node.new('span', list.document)
          en_el['class'] = 'word-en'
          en_el.inner_html = en
          entry.add_child(en_el)
        end

        container.add_child(entry)
      end

      list.replace(container)
    end

    def process(doc)
      html = Nokogiri::HTML(doc.output)
      content = html.at_css('#main-content') || html.at_css('.main-content')
      return unless content

      nm = Natto::MeCab.new

      # 1. Transform language-text code blocks into example cards with furigana
      content.css('div.language-text.highlighter-rouge').each do |block|
        transform_example_block(nm, block)
      end

      # 2. Transform vocabulary lists (## Vocabulary → <ol>) into vocab cards
      content.css('h2').each do |h2|
        next unless h2['id'] == 'vocabulary'
        ol = h2.next_element
        next unless ol&.name == 'ol'
        transform_vocabulary_list(nm, ol)
      end

      # 3. Transform Japanese word lists (bullet/numbered) into word cards
      content.css('ul, ol').each do |list|
        next if inside_skip_ancestor?(list)
        next if list.parent.name == 'li' # skip nested lists
        transform_word_list(nm, list)
      end

      # 4. Annotate remaining prose text nodes
      content.traverse do |node|
        next unless node.text?
        next if inside_skip_ancestor?(node)
        next unless node.content.match?(KANJI_RE)

        annotated = annotate(nm, node.content)
        next if annotated == node.content

        fragment = Nokogiri::HTML.fragment(annotated)
        node.replace(fragment)
      end

      doc.output = html.to_html
    end
  end

  Jekyll::Hooks.register [:pages, :documents], :post_render do |doc|
    next unless doc.output_ext == '.html'
    next if doc.data['furigana'] == false
    JouzuFurigana.process(doc)
  end
end
