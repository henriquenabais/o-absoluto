require "yaml"
require "json"
require "cgi"

def inline_markdown(text)
  s = CGI.escapeHTML(text.to_s)
  s.gsub!(/!\[([^\]]*)\]\(([^)]+)\)/, '<img src="\\2" alt="\\1">')
  s.gsub!(/\[([^\]]+)\]\(([^)]+)\)/, '<a href="\\2">\\1</a>')
  s.gsub!(/\*\*([^*]+)\*\*/, '<strong>\\1</strong>')
  s.gsub!(/\*([^*]+)\*/, '<em>\\1</em>')
  s
end

def markdown_to_html(text)
  lines = text.to_s.lines
  out = []
  paragraph = []
  flush = lambda do
    unless paragraph.empty?
      out << "<p>#{inline_markdown(paragraph.join(" ").strip)}</p>"
      paragraph.clear
    end
  end

  lines.each do |line|
    line = line.chomp
    if line.strip.empty?
      flush.call
    elsif line =~ /\A(#+)\s+(.+)\z/
      flush.call
      n = [$1.length, 6].min
      out << "<h#{n}>#{inline_markdown($2)}</h#{n}>"
    else
      paragraph << line.strip
    end
  end
  flush.call
  out.join("\n")
end

chapters = Dir["content/paginas/*.md"].map do |path|
  raw = File.read(path, encoding: "UTF-8")
  match = raw.match(/\A---\s*\n(.*?)\n---\s*\n?(.*)\z/m)
  next unless match
  data = YAML.safe_load(match[1], permitted_classes: [], aliases: false) || {}
  {
    "slug" => File.basename(path, ".md"),
    "title" => data["title"].to_s,
    "order" => data["order"].to_i,
    "html" => markdown_to_html(match[2])
  }
end.compact.sort_by { |c| [c["order"], c["title"]] }

File.write("content/chapters.json", JSON.pretty_generate(chapters) + "\n")
