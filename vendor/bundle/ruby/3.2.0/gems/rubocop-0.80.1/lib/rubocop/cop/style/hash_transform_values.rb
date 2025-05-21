# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop looks for uses of `_.each_with_object({}) {...}`,
      # `_.map {...}.to_h`, and `Hash[_.map {...}]` that are actually just
      # transforming the values of a hash, and tries to use a simpler & faster
      # call to `transform_values` instead.
      #
      # This can produce false positives if we are transforming an enumerable
      # of key-value-like pairs that isn't actually a hash, e.g.:
      # `[[k1, v1], [k2, v2], ...]`
      #
      # This cop should only be enabled on Ruby version 2.4 or newer
      # (`transform_values` was added in Ruby 2.4.)
      #
      # @example
      #   # bad
      #   {a: 1, b: 2}.each_with_object({}) { |(k, v), h| h[k] = foo(v) }
      #   {a: 1, b: 2}.map { |k, v| [k, v * v] }
      #
      #   # good
      #   {a: 1, b: 2}.transform_values { |v| foo(v) }
      #   {a: 1, b: 2}.transform_values { |v| v * v }
      class HashTransformValues < Cop
        extend TargetRubyVersion
        include HashTransformMethod

        minimum_target_ruby_version 2.4

        def_node_matcher :on_bad_each_with_object, <<~PATTERN
          (block
            ({send csend} !(send _ :each_with_index) :each_with_object (hash))
            (args
              (mlhs
                (arg _key)
                (arg $_))
              (arg _memo))
            ({send csend} (lvar _memo) :[]= $(lvar _key) $_))
        PATTERN

        def_node_matcher :on_bad_hash_brackets_map, <<~PATTERN
          (send
            (const _ :Hash)
            :[]
            (block
              ({send csend} !(send _ :each_with_index) {:map :collect})
              (args
                (arg _key)
                (arg $_))
              (array $(lvar _key) $_)))
        PATTERN

        def_node_matcher :on_bad_map_to_h, <<~PATTERN
          ({send csend}
            (block
              ({send csend} !(send _ :each_with_index) {:map :collect})
              (args
                (arg _key)
                (arg $_))
              (array $(lvar _key) $_))
            :to_h)
        PATTERN

        private

        def extract_captures(match)
          val_argname, key_body_expr, val_body_expr = *match
          Captures.new(val_argname, val_body_expr, key_body_expr)
        end

        def new_method_name
          'transform_values'
        end
      end
    end
  end
end
