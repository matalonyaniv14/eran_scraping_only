require_relative "app"
require 'rubygems'
task :environment do end

task :console do
  require 'pry'
  Pry.start
end

namespace :db do
  desc 'Scraping Data'

  # task scrape_threads: :environment do
  #   threads = (1..2).map do |t|
  #     Thread.new do
  #       last_block = Lead.last.last_block_lot[:block].to_i
  #       last_lot = Lead.last.last_block_lot[:lot].to_i
  #       last_block += 500 unless t == 1
  #       scraping = Scraping.new(boro: 4, block: last_block, lot: last_lot)
  #       1000.times do
  #         scraping.set_up
  #       end
  #     end
  #   end
  #   threads.each(&:join)
  # end
  desc '1 browser'
  task scrape: :environment do
      last_block = Lead.where.not(last_block_lot: nil).last.last_block_lot[:block].to_i
      last_lot = Lead.where.not(last_block_lot: nil).last.last_block_lot[:lot].to_i
      scraping = Scraping.new(boro: 5, block: last_block, lot: last_lot)
      count = 0

      while count <= 250
        begin
          scraping.reset_driver(start: 120, end: 240) if count == 100 || count == 200
          puts "Current Count: #{count}"
          scraping.set_up
        rescue StandardError => e
          message = e.message.empty? ? 'PROPERTY RECORD NOT FOUND FOR THIS BLOCK/LOT' : e.message
          Error.create(message: message, block: scraping.block, lot: scraping.lot)
          next
        ensure
          count += 1
          scraping.update_last
        end
      end
    end
  end
