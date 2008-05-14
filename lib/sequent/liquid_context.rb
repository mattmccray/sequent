module Sequent
  module Context
    def self.init(ctx={}) 
      ctx['site'] = Sequent::Drops::SiteDrop.new()
      ctx
    end
  end
end