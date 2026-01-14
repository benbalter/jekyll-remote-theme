# frozen_string_literal: true

# ------------------------------------------ #
# Originally authored by Parker Moore
# https://github.com/jekyll/jekyll/pull/6615
# ------------------------------------------ #

module RuboCop
  module Cop
    module Jekyll
      class NoPutsAllowed < Cop
        MSG = "Avoid using `puts` to print things. Use `Jekyll.logger` instead."

        def_node_search :puts_called?, "(send nil? :puts _)"

        def on_send(node)
          add_offense(node, :location => :selector) if puts_called?(node)
        end
      end
    end
  end
end
