module Text
  module LevenshteinDamerau
    # Adapted from https://github.com/threedaymonk/text/blob/master/lib/text/levenshtein.rb
    def distance(left, right)
      left  = left.encode(Encoding::UTF_8).unpack("U*")
      right = right.encode(Encoding::UTF_8).unpack("U*")

      left_l  = left.length
      right_l = right.length

      return right_l if left_l.zero?
      return left_l if right_l.zero?

      d = (0..right_l).to_a
      x = nil

      left_l.times do |i|
        e = i + 1
        right_l.times do |j|
          cost         = left[i] == right[j] ? 0 : 1
          insertion    = d[j + 1] + 1
          deletion     = e + 1
          substitution = d[j] + cost

          x = [insertion, deletion, substitution].min

          # Damerau
          if (i > 0 && j > 0 && left[i+1] == right[j] && left[i] == right[j-1])
            transposition = d[j-1] + cost
            x = [x, transposition].min
          end

          d[j] = e
          e = x
        end
        d[right_l] = x
      end

      return x
    end

    extend self
  end
end
