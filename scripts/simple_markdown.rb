require "cgi"

module SimpleMarkdown
  def self.inline(text)
    s = CGI.escapeHTML(text.to_s)
    s.gsub!(/!\[([^\]]*)\]\(([^)]+)\)/, '<img src="\\2" alt="\\1">')
    s.gsub!(/\[([^\]]+)\]\(([^)]+)\)/, '<a href="\\2">\\1</a>')
    s.gsub!(/\*\*(.+?)\*\*/, '<strong>\\1</strong>')
    s.gsub!(/__(.+?)__/, '<strong>\\1</strong>')
    s.gsub!(/\*(.+?)\*/, '<em>\\1</em>')
    s.gsub!(/_(.+?)_/, '<em>\\1</em>')
    s
  end

  def self.to_html(text)
    lines = text.to_s.lines.map(&:chomp)
    out, paragraph, list = [], [], nil

    flush_paragraph = lambda do
      unless paragraph.empty?
        out << "<p>#{inline(paragraph.join(" ").strip)}</p>"
        paragraph.clear
      end
    end

    close_list = lambda do
      if list
        out << "</#{list}>"
        list = nil
      end
    end

    lines.each do |line|
      stripped = line.strip
      if stripped.empty?
        flush_paragraph.call
        close_list.call
      elsif stripped =~ /\A(#+)\s+(.+)\z/
        flush_paragraph.call
        close_list.call
        n = [$1.length, 6].min
        out << "<h#{n}>#{inline($2)}</h#{n}>"
      elsif stripped =~ /\A[-*+]\s+(.+)\z/
        flush_paragraph.call
        if list != "ul"
          close_list.call
          out << "<ul>"
          list = "ul"
        end
        out << "<li>#{inline($1)}</li>"
      elsif stripped =~ /\A\d+[.)]\s+(.+)\z/
        flush_paragraph.call
        if list != "ol"
          close_list.call
          out << "<ol>"
          list = "ol"
        end
        out << "<li>#{inline($1)}</li>"
      else
        close_list.call
        paragraph << stripped
      end
    end

    flush_paragraph.call
    close_list.call
    out.join("\n")
  end
end
