#!/usr/bin/env ruby
require "yaml"
require "json"
require "kramdown"

phrases = Dir["_frases/*.md"].filter_map do |path|
  raw = File.read(path, encoding: "UTF-8")
  match = raw.match(/\A---\s*\n(.*?)\n---\s*(?:\n|\z)/m)
  next unless match

  data = YAML.safe_load(match[1], permitted_classes: [], aliases: false) || {}
  id = data["id"]
  text = data["phrase"]
  next if id.nil? || text.nil?

  sections = Array(data["sections"]).map do |section|
    case section["type"]
    when "texto"
      body = section["body"].to_s
      html = Kramdown::Document.new(body, input: "GFM").to_html
      { "type" => "texto", "html" => html }
    when "pdf"
      { "type" => "pdf", "file" => section["file"].to_s, "caption" => section["caption"].to_s }
    else
      nil
    end
  end.compact

  { "id" => id.to_i, "text" => text.to_s, "sections" => sections }
end

phrases.sort_by! { |p| p["id"] }
Dir.mkdir("data") unless Dir.exist?("data")
File.write("data/phrases.json", JSON.pretty_generate(phrases) + "\n")
puts "Geradas #{phrases.length} frases."
