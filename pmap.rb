require 'celluloid'
# from Celluloid since it's not working normally
module Enumerable
    def pmap(&block)
      futures = map { |elem| Celluloid::Future.new(elem, &block) }
      futures.map { |future| future.value }
    end
  end