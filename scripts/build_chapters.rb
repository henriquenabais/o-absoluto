require "yaml"
require "json"
require_relative "simple_markdown"

chapters = Dir["content/paginas/*.md"].map do |path|
  raw = File.read(path, encoding: "UTF-8")
  match = raw.match(/\A---\s*\n(.*?)\n---\s*\n?(.*)\z/m)
  next unless match
  data = YAML.safe_load(match[1], permitted_classes: [], aliases: false) || {}
  {
    "slug" => File.basename(path, ".md"),
    "title" => data["title"].to_s,
    "order" => data["order"].to_i,
    "html" => SimpleMarkdown.to_html(match[2])
  }
end.compact.sort_by { |c| [c["order"], c["title"]] }

File.write("content/chapters.json", JSON.pretty_generate(chapters) + "\n")
