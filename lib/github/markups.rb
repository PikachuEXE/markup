require "github/markup/markdown"
require "github/markup/rdoc"
require "shellwords"

markup_impl(::GitHub::Markups::MARKUP_MARKDOWN, ::GitHub::Markup::Markdown.new)

markup(::GitHub::Markups::MARKUP_TEXTILE, :redcloth, /textile/, ["Textile"]) do |content|
  RedCloth.new(content).to_html
end

markup_impl(::GitHub::Markups::MARKUP_RDOC, GitHub::Markup::RDoc.new)

markup(::GitHub::Markups::MARKUP_ORG, 'org-ruby', /org/, ["Org"]) do |content|
  Orgmode::Parser.new(content, {
                        :allow_include_files => false,
                        :skip_syntax_highlight => true
                      }).to_html
end

markup(::GitHub::Markups::MARKUP_CREOLE, :creole, /creole/, ["Creole"]) do |content|
  Creole.creolize(content)
end

markup(::GitHub::Markups::MARKUP_MEDIAWIKI, :wikicloth, /mediawiki|wiki/, ["MediaWiki"]) do |content|
  wikicloth = WikiCloth::WikiCloth.new(:data => content)
  WikiCloth::WikiBuffer::HTMLElement::ESCAPED_TAGS << 'tt' unless WikiCloth::WikiBuffer::HTMLElement::ESCAPED_TAGS.include?('tt')
  wikicloth.to_html(:noedit => true)
end

markup(::GitHub::Markups::MARKUP_ASCIIDOC, :asciidoctor, /adoc|asc(iidoc)?/, ["AsciiDoc"]) do |content|
  Asciidoctor::Compliance.unique_id_start_index = 1
  Asciidoctor.convert(content, :safe => :secure, :attributes => %w(showtitle=@ idprefix idseparator=- env=github env-github source-highlighter=html-pipeline))
end

command(
  ::GitHub::Markups::MARKUP_RST,
  "python2 -S #{Shellwords.escape(File.dirname(__FILE__))}/commands/rest2html",
  /re?st(\.txt)?/,
  ["reStructuredText"],
  "restructuredtext"
)

command(::GitHub::Markups::MARKUP_POD, :pod2html, /pod/, ["Pod"], "pod")
