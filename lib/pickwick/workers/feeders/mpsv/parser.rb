module Pickwick
  module Workers
    module Feeders
      module MPSV
        class Parser

          def initialize(options={})
            @data      = options[:data]
            @bulk_size = options[:bulk_size] || 1000
            @document  = Nokogiri::XML(@data).remove_namespaces!
          end

          def fetch
            @document.css("VOLNEMISTO").each_slice(@bulk_size) do |offers|
              yield offers.map { |offer| __parse(offer) }
            end
          end

          def __parse(xml)
            offer = {}

            offer[:title]           = UnicodeUtils.downcase((xml.at("PROFESE").attributes["doplnek"].text rescue xml.at("PROFESE").attributes["nazev"].text))
            offer[:description]     = xml.at("POZNAMKA").text rescue nil

            offer[:start_date]      = Time.parse(xml.at("PRAC_POMER").attributes["od"].text).utc.iso8601 rescue nil
            offer[:employment_type] = xml.at("UVAZEK").attributes["nazev"].text == "Plný" ? "full-time" : "part-time"

            offer[:location]        = get_address(xml.at("PRACOVISTE"))
            offer[:contact]         = get_contact(xml.at("KONOS"))
            offer[:employer]        = get_employer(xml.at("FIRMA"))

            offer
          end

          def get_address(address)
            if address
              street, number = [], []

              street << address.attributes["ulice"].text rescue nil
              street << address.attributes["cobce"].text rescue nil if street.empty?

              number << address.attributes["cp"].text    rescue nil
              number << address.attributes["co"].text    rescue nil

              street << number.compact.join("/")

              city    = address.attributes["obec"].text
              street  = street.compact.join(" ")
              country = "Czech Republic"
              zip     = address.attributes["psc"].text rescue nil

              alternative_address = [street, city, zip, country].compact

              { city:        city,
                street:      street,
                country:     country }
            end
          end

          def get_contact(contact)
            if contact
              { name:  contact.text,
                email: (contact.attributes["email"].text rescue nil),
                phone: (contact.attributes["telefon"].text rescue nil) }
            end
          end

          def get_employer(employer)
            if employer
              { company: (employer.attributes["nazev"].text rescue nil) }
            end
          end

        end
      end
    end
  end
end
