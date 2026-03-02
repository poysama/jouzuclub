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
    KATAKANA_TO_HIRAGANA = 0x0060 # Unicode offset: katakana - hiragana

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
      nm.parse(text) do |node|
        if node.is_eos?
          next
        end

        surface = node.surface
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

    def process(doc)
      html = Nokogiri::HTML(doc.output)
      content = html.at_css('#main-content') || html.at_css('.main-content')
      return unless content

      nm = Natto::MeCab.new

      # 1. Transform language-text code blocks into example cards with furigana
      content.css('div.language-text.highlighter-rouge').each do |block|
        transform_example_block(nm, block)
      end

      # 2. Annotate remaining prose text nodes
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
