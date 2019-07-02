

## general actions for selenium linked in
class GeneralActions
  attr_accessor :driver
  def initialize
    driver_load
  end

  def driver_load
      options = Selenium::WebDriver::Chrome::Options.new
      # options.add_preference(:binary, ENV['GOOGLE_CHROME_BIN'])
      # options.add_argument('--headless')
      options.add_argument('--disable-gpu')
      options.add_argument('--no-sandbox')
      @driver = Selenium::WebDriver.for :chrome, options: options
  end

  def reset_driver(time)
    p 'reloading....'
    @driver.quit
    sleeping(time[:start], time[:end])
    driver_load


  end

  def sleeping(start = 4, finish = 6)
    time = rand(start..finish)
    puts "Waiting #{time} seconds"
    sleep(time)
  end

  def scrolling(position)
    if position == 'bottom'
      @driver.execute_script( "window.scrollTo(0, document.body.scrollHeight);" )
    else
      @driver.execute_script("window.scrollTo(0,-document.body.scrollHeight || -document.documentElement.scrollHeight)", "");
    end
  end

  def find(type, name)
    @driver.find_elements(type.to_sym => name)
  rescue StandardError => e
    false
  end

  def status(type, name)
    @driver.find_element(type.to_sym => name)
  rescue StandardError => e
    false
  end

  def clicking(type, name, link_text)
    status = nil
    @driver.find_elements(type.to_sym => name).each do |button|
      if button.text.include?(link_text)
        button.click
        status = true
        break
      else
        status = false
      end
    end
    status
  end

  def click(type, name)
    return false if status(type, name) == false

    if block_given?
      sleeping
      form = @driver.find_element(type.to_sym => name)
      form.click
      form.send_keys(yield)
    else
      @driver.find_element(type.to_sym => name).click
    end
  end
end
