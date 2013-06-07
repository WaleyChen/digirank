require 'rubygems'
require 'twilio-ruby'

class PhonenumbersController < ApplicationController
    protect_from_forgery

    include HTTParty

    @numbers
    COUNTRIES = [
        # 'AU',
        # 'AT', 
        # 'BE', 
        # 'BG', 
        # 'CA',
        # 'CZ', 
        # 'DK',
        # 'FI',  
        # 'FR', 
        # 'GR',
        # 'HK',
        # 'IE',  
        # 'IL',  
        # 'IT',  
        # 'JP', 
        # 'MX',
        # 'NL', 
        # 'NZ', 
        # 'PL', 
        # 'PT', 
        # 'PR', 
        # 'RO',
        # 'SK', 
        # 'ES', 
        # 'SE', 
        # 'CH',
        # 'GB', 
        'US'
    ]

    def price
        
    end

    def template(number, number_html, location, unique_digit_count, repetition_percentage, price)
        return "<div class=\"row-fluid result-row\">

      <div class=\"span3\">
        <div class=\"result\">
          <p class=\"number notranslate\"> #{ number_html } </p>
          <p class=\"subnumber notranslate\"> #{ number } <span class=\"location\">#{ location }</span></p>
        </div>
      </div>

      <div class=\"span6\">
        <div class=\"row-fluid number-status\">

          <div class=\"span3\">
            <div class=\"voice-status enabled \">
              <div class=\"status-icon\"></div>
              <div class=\"status-label\">
                Voice enabled</div>
            </div>
          </div>

          <div class=\"span3\">
            <div class=\"sms-status enabled \">
              <div class=\"status-icon\"></div>
              <div class=\"status-label\">
                SMS enabled</div>
            </div>
          </div>

          <div class=\"span3\">
            <div class=\"sms-status enabled\">
              <div style=\"font-size: 200%\">#{ unique_digit_count }</div>
              <div class=\"status-label\">
                Unique Digit Count </div>
            </div>
          </div>

          <div class=\"span3\">
            <div class=\"sms-status enabled \">
              <div style=\"font-size: 200%\">#{ repetition_percentage }</div>
              <div class=\"status-label\">
                Repetition % </div>
            </div>
          </div>

        </div>

      </div>
      <div class=\"span3\">
        <div class=\"buy\">
          <p class=\"display\">
              <span class=\"price\">
                <span class=\"currency notranslate\">$</span>
                <span class=\"amount notranslate\">#{ price }</span>
                <span class=\"cycle\">/month</span>
              </span>
              <a href=\"https://www.twilio.com/user/account/phone-numbers/available/local\" class=\"buy-number small-basic-link-button\" rel=\"{&quot;id&quot;:&quot;ID831a6af84ddb1fa03bef8691ccbc9517&quot;,&quot;number&quot;:&quot;#{ number }&quot;,&quot;displayPhoneNumber&quot;:&quot;#{ number }&quot;,&quot;sms&quot;:true,&quot;voice&quot;:true,&quot;iso&quot;:&quot;US&quot;,&quot;price&quot;:&quot;#{ price }&quot;,&quot;warning&quot;:null,&quot;requiresCertification&quot;:false,&quot;requiresNonResidentCertification&quot;:false,&quot;certificationType&quot;:false,&quot;isCertified&quot;:false}\">Buy</a>
            </p>
          </div>
      </div>
    </div>"
    end

    def index
        account_sid = ENV['TWILIO_ACCOUNT_SID']
        auth_token = ENV['TWILIO_AUTH_TOKEN']
        @numbers = []

        client = Twilio::REST::Client.new(account_sid, auth_token)

        COUNTRIES.each do |country|
            puts country
            @numbers = @numbers + client.account.available_phone_numbers.get(country).local.list()
        
            @numbers.each do |number|
                puts number.phone_number
                puts number.to_yaml

                db_number = Phonenumbers.where(:phonenumber => number.phone_number).first

                if db_number.nil?
                    phonenumber = Phonenumbers.new
                    phonenumber.phonenumber = number.phone_number
                    phonenumber.iso_country = number.iso_country
                    phonenumber.region = number.region
                    # puts phonenumber.save
                else
                    db_number.iso_country = number.iso_country if db_number.iso_country.nil?
                    db_number.region = number.region if db_number.region.nil?
                    # db_number.save
                end
            end
        end
    end

    def unranked
        numbers = Phonenumbers.all
        templates = []

        numbers.each do |number|
            templates << template(
                                        number.phonenumber, 
                                        number.phonenumber, 
                                        number.location,
                                        number.unique_digit_count,
                                        number.repetition_percentage,
                                        number.price
                                    )
        end

        render :json => templates
    end

    def repetition_and_digit_variation
        numbers = Phonenumbers.collection.find().sort({ unique_digit_count: 1, repetition_probability: 1 })
        templates = []

        numbers.each do |number|
            templates << template(
                                        number['phonenumber'], 
                                        number['phonenumber_both_html'], 
                                        number['location'],
                                        number['unique_digit_count'],
                                        number['repetition_percentage'],
                                        number['price']
                                    )
        end

        render :json => templates
    end

    def longest_repetitions
        numbers = Phonenumbers.collection.find().sort({ repetition_probability: 1 })
        templates = []

        numbers.each do |number|
            templates << template(
                                        number['phonenumber'], 
                                        number['phonenumber_repetition_html'], 
                                        number['location'],
                                        number['unique_digit_count'],
                                        number['repetition_percentage'],
                                        number['price']
                                    )
        end

        render :json => templates
    end

    def lowest_digit_variation
        numbers = Phonenumbers.collection.find().sort({ unique_digit_count: 1 })
        templates = []

        numbers.each do |number|
            templates << template(
                                        number['phonenumber'], 
                                        number['phonenumber_unique_digit_html'], 
                                        number['location'], 
                                        number['unique_digit_count'],
                                        number['repetition_percentage'],
                                        number['price']
                                    )
        end

        render :json => templates
    end
end
