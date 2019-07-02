

## Class that will take care of all scraping(inherits from general actions)
class Scraping < GeneralActions
  attr_accessor :block, :lot

  def initialize(args = {})
    super()
    @index = []
    @infos = []
    @boro = args[:boro]
    @block = args[:block]
    @lot = args[:lot]
    @p_count = 0
  end
  def wait_until
    Selenium::WebDriver::Wait.new(timeout: 60).until do
      yield
    end
  end

  def set_up
    sleeping(25, 45)
    update_count
    puts "Navigating to Borough: #{@boro}, Block: #{@block}, Lot: #{@lot}"
    page_check
    perform
  end

  def perform
    complaint_link_check ? info_check : nil
  end

  def page_check
    puts 'Page Check.......'
    block_given? ? yield : nil
    url = "http://a810-bisweb.nyc.gov/bisweb/PropertyProfileOverviewServlet?boro=#{@boro}&block=#{@block}&lot=#{@lot}"
    @driver.navigate.to(url)
    wait_until { @driver.current_url.include?("boro=5&block=#{@block}") }
    puts "On Page.... #{@driver.current_url}"
    confirmed_link_check ? nil : raise
    puts 'No error.... On Correct page'
  rescue Timeout::Error
    error_page_check
  end

  def confirmed_link_check
    return false if status('css', 'td .errormsg')

    puts 'Looking for link......'
    find('css', 'a').each do |elem|
      return true if
        elem.attribute('href').include?('ElevatorRecordsByLocationServlet')
    end
    puts 'Link Not Found'
  rescue NoMethodError => e
    puts 'confirmed_link_check error.......'
    false
  end

  def error_page_check
    p 'now in error_page_check........'
    if status('link_text', 'here') && @p_count < 3
      puts 'link { here } found'
      @p_count += 1
      page_check { @driver.navigate.refresh }
    else
      puts 'landed in error page'
      @p_count = 0
      raise 'landed in error page'
    end
  end

  def update_count
    if @lot == 100
      @lot = 1
      @block += 1
    else
      @lot += 1
    end
  end

  def update_last
    last_block_lot = { block: @block, lot: @lot }
    Lead.last.update(last_block_lot: last_block_lot)
  end

  def complaint_link_check
    if status('link_text', 'Complaints')
      click('link_text', 'Complaints')
      true
    end
  end

  def info_check
    @infos = find('class', 'content')
    @infos.each_with_index do |info, index|
      info.text == 'RES' || info.text == 'CLS' ? @index << index : nil
    end
    info_scrape
  end

  def info_scrape
    @index.each do |index|
        Lead.create(address: @infos[index - 5].text,
                    date: @infos[index - 4].text,
                    complaint: @infos[index - 3].text,
                    borough: @boro,
                    block: @block,
                    lot: @lot
                    )
    end
    puts " \n Lead Created..... [Complaint: #{Lead.last.complaint}]  [Date: #{Lead.last.date}] [Address: #{Lead.last.address}]"
    puts "\n"
    @index = []
  end
end
