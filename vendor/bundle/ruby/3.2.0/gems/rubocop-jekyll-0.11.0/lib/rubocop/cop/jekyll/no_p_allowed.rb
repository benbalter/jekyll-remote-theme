# frozen_string_literal: true

# ------------------------------------------ #
# Originally authored by Parker Moore
# https://github.com/jekyll/jekyll/pull/6615
# ------------------------------------------ #

module RuboCop
  module Cop
    module Jekyll
      class NoPAllowed < Cop
        MSG = "Avoid using `p` to print things. Use `Jekyll.logger` instead."

        def_node_search :p_called?, "(send _ :p _)"

        def on_send(node)
          add_offense(node, :location => :selector) if p_called?(node)
        end
      end
    end
  end
end
