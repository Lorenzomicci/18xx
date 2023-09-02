# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1847AE
      module Step
        class BuySingleTrainOfType < Engine::Step::BuySingleTrainOfType
          def buyable_trains(entity)
            # Can't buy trains from other corporations in phase 3
            return super if @game.phase.status.include?('can_buy_trains')

            super.select(&:from_depot?)
          end

          def process_buy_train(action)
            from_depot = action.train.from_depot?         
            super

            lfk = @game.lfk
            return if @game.train_bought_this_round || !lfk.floated? || !from_depot

            old_lfk_price = lfk.share_price
            lfk_revenue = action.train.price / 10
            lfk_owner = lfk.presidents_share.owner
            @game.bank.spend(lfk_revenue, lfk_owner) if lfk_owner.player?
            @log << "#{lfk.name} pays #{@game.format_currency(lfk_revenue)} to #{lfk_owner.name}" if lfk_owner.player?
            @game.stock_market.move_right(lfk)
            @game.log_share_price(lfk, old_lfk_price)
            @game.train_bought_this_round = true
          end
        end
      end
    end
  end
end
