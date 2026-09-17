# frozen_string_literal: true

require 'cgi'

# Generic tabbed content, usable in any post or page:
#
#   {% tabs dns %}
#   {% tab dnsutils %}
#   Prose, lists, images and fenced code blocks all work in here.
#
#   ```bash
#   nslookup -type=srv _ldap._tcp.dc._msdcs."$DOMAIN"
#   ```
#   {% endtab %}
#   {% tab nmap %}
#   ...
#   {% endtab %}
#   {% endtabs %}
#
# The group name is optional and only feeds element ids; it falls back to a
# per-page counter.
#
# Panel bodies are converted with the site's own Markdown converter, so what
# kramdown later sees is already final HTML. That is deliberate: it avoids
# relying on `markdown="1"` inside block HTML, and it keeps
# `_includes/refactor-content.html` working on snippets inside panels, which is
# what gives them their code header, language label and copy button.
module Jekyll
  module TabsTags
    PANEL_STACK = :tabs_panel_stack
    GROUP_COUNT = :tabs_group_count
    SCRIPT_DONE = :tabs_script_done

    module Util
      module_function

      # Strip the indentation shared by every non-blank line, so an author may
      # indent a panel body to taste without turning it into a code block.
      def dedent(text)
        lines = text.to_s.tr("\t", ' ').split("\n")
        pad = lines.reject { |line| line.strip.empty? }
                   .map { |line| line[/\A */].size }
                   .min || 0
        lines.map { |line| line.strip.empty? ? '' : line[pad..] }.join("\n").strip
      end

      def unquote(markup)
        text = markup.to_s.strip
        quoted = text.match(/\A(["'])(.*)\1\z/m)
        quoted ? quoted[2] : text
      end

      def slug(text, fallback)
        slug = text.to_s.strip.downcase.gsub(/[^a-z0-9_-]+/, '-').gsub(/\A-+|-+\z/, '')
        slug.empty? ? fallback : slug
      end
    end

    # One panel. Renders nothing itself: it hands its label and raw body to the
    # enclosing `tabs` block, which owns the markup.
    class TabBlock < Liquid::Block
      def initialize(tag_name, markup, options)
        super
        @label = Util.unquote(markup)
        raise Liquid::SyntaxError, "'tab' requires a label, e.g. {% tab nmap %}" if @label.empty?
      end

      def blank?
        false
      end

      def render(context)
        body = super.to_s
        stack = context.registers[PANEL_STACK]
        raise Liquid::SyntaxError, "'tab' must be used inside a 'tabs' block" if stack.nil? || stack.empty?

        stack.last << { label: @label, body: body }
        ''
      end
    end

    class TabsBlock < Liquid::Block
      SCRIPT = <<~JS
        <script>
        (function () {
          if (window.__tabsInit) { return; }
          window.__tabsInit = true;
          function closestTab(target) {
            return target instanceof Element ? target.closest('.tabs__tab') : null;
          }
          function select(tab) {
            var tabs = tab.parentNode.querySelectorAll('.tabs__tab');
            for (var i = 0; i < tabs.length; i++) {
              var on = tabs[i] === tab;
              var panel = document.getElementById(tabs[i].getAttribute('aria-controls'));
              tabs[i].setAttribute('aria-selected', on ? 'true' : 'false');
              tabs[i].tabIndex = on ? 0 : -1;
              if (panel) { panel.hidden = !on; }
            }
          }
          document.addEventListener('click', function (e) {
            var tab = closestTab(e.target);
            if (tab) { select(tab); }
          });
          document.addEventListener('keydown', function (e) {
            var tab = closestTab(e.target);
            if (!tab) { return; }
            var dir = e.key === 'ArrowLeft' ? -1 : (e.key === 'ArrowRight' ? 1 : 0);
            if (!dir) { return; }
            e.preventDefault();
            var tabs = tab.parentNode.querySelectorAll('.tabs__tab');
            var idx = Array.prototype.indexOf.call(tabs, tab);
            var next = tabs[(idx + dir + tabs.length) % tabs.length];
            select(next);
            next.focus();
          });
        })();
        </script>
      JS

      def initialize(tag_name, markup, options)
        super
        @group = Util.unquote(markup)
      end

      def blank?
        false
      end

      def render(context)
        panels = collect_panels(context)
        return '' if panels.empty?

        registers = context.registers
        registers[GROUP_COUNT] = registers.fetch(GROUP_COUNT, 0) + 1
        group = Util.slug(@group, "tabs-#{registers[GROUP_COUNT]}")
        converter = registers[:site].find_converter_instance(::Jekyll::Converters::Markdown)

        html = +'<div class="tabs">'
        html << nav(panels, group)
        panels.each_with_index do |panel, index|
          html << panel_html(panel, converter, group, index)
        end
        html << '</div>'

        html << SCRIPT unless registers[SCRIPT_DONE]
        registers[SCRIPT_DONE] = true
        html
      end

      private

      # Children push themselves onto a stack while the body renders, so nested
      # groups keep their panels apart.
      def collect_panels(context)
        stack = (context.registers[PANEL_STACK] ||= [])
        panels = []
        stack.push(panels)
        begin
          super_render(context)
        ensure
          stack.pop
        end
        panels
      end

      def super_render(context)
        @body.render(context)
      end

      def nav(panels, group)
        buttons = panels.each_with_index.map do |panel, index|
          active = index.zero?
          %(<button type="button" class="tabs__tab" role="tab" id="#{tab_id(group, index)}" ) +
            %(aria-controls="#{panel_id(group, index)}" aria-selected="#{active}" ) +
            %(tabindex="#{active ? 0 : -1}">#{CGI.escapeHTML(panel[:label])}</button>)
        end
        %(<div class="tabs__nav" role="tablist">#{buttons.join}</div>)
      end

      def panel_html(panel, converter, group, index)
        %(<div class="tabs__panel" role="tabpanel" id="#{panel_id(group, index)}" ) +
          %(aria-labelledby="#{tab_id(group, index)}"#{index.zero? ? '' : ' hidden'}>) +
          converter.convert(Util.dedent(panel[:body])) +
          '</div>'
      end

      def tab_id(group, index)
        "#{group}-tab-#{index + 1}"
      end

      def panel_id(group, index)
        "#{group}-panel-#{index + 1}"
      end
    end
  end
end

Liquid::Template.register_tag('tabs', Jekyll::TabsTags::TabsBlock)
Liquid::Template.register_tag('tab', Jekyll::TabsTags::TabBlock)
