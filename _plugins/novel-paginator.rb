# frozen_string_literal: true

# NovelPaginator
#
# Splits a very long post (a novell/book dumped into one markdown file) into
# several shorter pages at build time, so the reader never loads the whole
# text at once.
#
# Trigger: a post whose front matter contains `paginate_novel: true`.
#
# The post body is expected to contain standalone full-width-digit lines
# (the book's printed page numbers, e.g. `　　　　１`). Each such marker
# line starts a new part; the marker line itself is dropped.
#
# Result:
#   * The original post still keeps its URL but its content is replaced by a
#     table of contents listing every part.
#   * One sub-page per part is generated below `<novel_path>/<n>/` (default
#     `novel/<slug>/<n>/`), sharing the `post` layout, each with prev/next
#     navigation pointing at the neighbouring parts.
#   * `novel_path` front matter overrides the output directory prefix.

module Jekyll
  class NovelPaginator < Generator
    safe true
    priority :low

    MARKER = /^[[:space:]]*[０-９]+[[:space:]]*$/

    KANJI = %w[
      一 二 三 四 五 六 七 八 九 十 十一 十二 十三 十四 十五 十六 十七 十八 十九
    ].freeze

    def generate(site)
      site.posts.docs.each do |doc|
        next unless doc.data["paginate_novel"]

        build(site, doc)
      end
    end

    private

    def build(site, doc)
      parts = split_parts(doc.content)
      return if parts.empty?

      total = parts.length
      base = (doc.data["novel_path"] || "novel/#{doc.data['slug']}").delete_prefix("/").delete_suffix("/")
      toc_url = doc.url
      doc.data["description"] = "#{doc.data['title']} — 全#{KANJI[total - 1]}話の目次"

      parts.each_with_index do |text, index|
        part = index + 1
        dir = "#{base}/#{part}"
        url = "/#{dir}/"

        nav = navigation_markdown(part, total, base, toc_url)
        body = converter(site).convert("#{nav}\n\n#{text}\n")

        page = ChapterPage.new(
          site, site.source, dir, "index.html",
          {
            "layout" => "post",
            "title" => "#{doc.data['title']}（第#{KANJI[part - 1]}話）",
            "description" => "#{doc.data['title']} 第#{KANJI[part - 1]}話（全#{KANJI[total - 1]}話）",
            "novel_part" => part,
            "novel_total" => total,
            "permalink" => url,
            "regenerate" => true,
            "render_with_liquid" => false,
            "path" => doc.path
          },
          body
        )
        site.pages << page
      end

      doc.content = toc_content(total, base)
      # The excerpt was memoized from the original full-length body at read
      # time; rebuild it from the short TOC so feed/SEO stay small.
      doc.data["excerpt"] = Jekyll::Excerpt.new(doc)
    end

    # Splits body lines around standalone full-width-digit marker lines.
    def split_parts(content)
      parts = []
      buffer = []
      content.each_line do |line|
        if MARKER.match?(line)
          parts << buffer.join unless buffer.join.strip.empty?
          buffer = []
        else
          buffer << line
        end
      end
      parts << buffer.join unless buffer.join.strip.empty?
      parts
    end

    def navigation_markdown(part, total, base, toc_url)
      prev_link = if part > 1
                    "[← 第#{KANJI[part - 2]}話](/#{base}/#{part - 1}/)"
                  else
                    "[目次](#{toc_url})"
                  end
      next_link = if part < total
                    "[第#{KANJI[part]}話 →](/#{base}/#{part + 1}/)"
                  else
                    "[目次](#{toc_url})"
                  end

      "> #{prev_link}　｜　#{next_link}"
    end

    def toc_content(total, base)
      lines = ["## 目次", "", "この物語は全#{KANJI[total - 1]}話に分けて掲載しています。", ""]
      total.times do |i|
        part = i + 1
        lines << "#{part}. [#{KANJI[i]}話](/#{base}/#{part}/)"
      end
      lines.join("\n")
    end

    def converter(site)
      site.find_converter_instance(Jekyll::Converters::Markdown)
    end
  end

  # A virtual page (no source file on disk) rendered like a regular page.
  class ChapterPage < Jekyll::Page
    def initialize(site, base, dir, name, data, content)
      @site = site
      @base = base
      @dir = dir
      @name = name
      @path = site.in_source_dir(base, dir, name)
      process(name)
      self.data = data
      self.content = content
      self.output = nil
    end

    # The page exists only in memory; there is no YAML to read.
    def read_yaml(*)
    end

    def type
      :pages
    end
  end
end
