module StatsScraper
  class Event
    attr_reader :event_number,
                :period,
                :strength,
                :time_elapsed,
                :time_left,
                :event_name,
                :event_description,
                :visitor_on_ice,
                :home_on_ice

    def initialize(event_node)
      @event_number      = Integer(event_node.xpath("/html/body/tr/td[1]").text)
      @period            = Integer(event_node.xpath("/html/body/tr/td[2]").text)
      @strength          = event_node.xpath("/html/body/tr/td[3]").text
      time_box           = event_node.xpath("/html/body/tr/td[4]").children.map(&:text)
      @time_elapsed      = time_box.first
      @time_left         = time_box.last
      @event_name        = event_node.xpath("/html/body/tr/td[5]").text
      @event_description = event_node.xpath("/html/body/tr/td[6]").text

      @visitor_on_ice = parse_on_ice_table(event_node.xpath("/html/body/tr/td[7]"))
      @home_on_ice    = parse_on_ice_table(event_node.xpath("/html/body/tr/td[8]"))
    end

    private

    def parse_on_ice_table(on_ice_table)
      Nokogiri::HTML(on_ice_table.to_html).xpath("/html/body/td/table/tr/td/table").map do |player|
        player = Nokogiri::HTML(player.to_html)

        player_node = player.xpath("//td/font").first
        position, name = player_node.attributes["title"].value.split(" - ")
        number = player_node.text

        current_position = player.xpath("//tr[2]/td").text

        { name: name, position: position, current_position: current_position }
      end
    end
  end
end
